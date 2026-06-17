import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/map_picker.dart';
import '../../data/models/company_stop_model.dart';
import '../../data/models/district_option.dart';
import '../providers/stop_provider.dart';

class StopFormScreen extends StatefulWidget {
  final int driverId;
  final CompanyStopModel? stop;

  const StopFormScreen({
    super.key,
    required this.driverId,
    this.stop,
  });

  @override
  State<StopFormScreen> createState() => _StopFormScreenState();
}

class _StopFormScreenState extends State<StopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  LatLng _point = const LatLng(-18.0146, -70.2536);
  Uint8List? _imageBytes;
  String? _imageName;
  DistrictOption? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    final stop = widget.stop;
    if (stop != null) {
      _nameCtrl.text = stop.name;
      _addressCtrl.text = stop.address;
      _referenceCtrl.text = stop.reference;
      if (stop.latitude != 0 && stop.longitude != 0) {
        _point = LatLng(stop.latitude, stop.longitude);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<StopProvider>();
      await provider.loadDistricts();
      final stop = widget.stop;
      if (stop != null && stop.fkIdDistrict > 0 && mounted) {
        final match = provider.districts.firstWhere(
          (d) => d.id == stop.fkIdDistrict,
          orElse: () => const DistrictOption(id: 0, name: ''),
        );
        if (match.id > 0) setState(() => _selectedDistrict = match);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageName = image.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDistrict == null || _selectedDistrict!.id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un distrito de la lista')),
      );
      return;
    }
    final provider = context.read<StopProvider>();
    final ok = await provider.save(
      CompanyStopModel(
        id: widget.stop?.id ?? 0,
        driverId: widget.driverId,
        fkIdDistrict: _selectedDistrict!.id,
        districtLabel: _selectedDistrict!.name,
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        reference: _referenceCtrl.text.trim(),
        latitude: _point.latitude,
        longitude: _point.longitude,
        imageUrl: widget.stop?.imageUrl,
      ),
      imageBytes: _imageBytes,
      imageFileName: _imageName,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Paradero guardado' : provider.error ?? 'No se pudo guardar')),
    );
    if (ok) Navigator.of(context).pop(true);
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label es obligatorio';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StopProvider>();
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: Text(widget.stop == null ? 'Nuevo paradero' : 'Editar paradero')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _field(_nameCtrl, 'Nombre del paradero', validator: (v) => _required(v, 'Nombre')),
              const SizedBox(height: 14),
              _field(_addressCtrl, 'Direccion', validator: (v) => _required(v, 'Direccion')),
              const SizedBox(height: 14),
              _field(_referenceCtrl, 'Referencia', validator: (v) => _required(v, 'Referencia')),
              const SizedBox(height: 14),
              Autocomplete<DistrictOption>(
                initialValue: TextEditingValue(text: _selectedDistrict?.label ?? ''),
                displayStringForOption: (option) => option.label,
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  if (provider.districts.isEmpty) return const Iterable.empty();
                  if (query.isEmpty) return provider.districts.take(20);
                  final tokens = query.split(RegExp(r'\s+'));
                  return provider.districts
                      .where((option) => tokens.every((t) => option.label.toLowerCase().contains(t)))
                      .take(30);
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(color: AppColors.carbon50),
                    decoration: const InputDecoration(labelText: 'Distrito'),
                    validator: (_) {
                      if (_selectedDistrict == null || _selectedDistrict!.id == 0) {
                        return 'Selecciona un distrito';
                      }
                      return null;
                    },
                  );
                },
                onSelected: (value) => setState(() => _selectedDistrict = value),
              ),
              const SizedBox(height: 18),
              const Text(
                'Imagen del paradero (opcional)',
                style: TextStyle(color: AppColors.carbon400, fontSize: 12),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 112,
                  decoration: BoxDecoration(
                    color: AppColors.carbon800,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.carbon700),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : widget.stop?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(widget.stop!.imageUrl!, fit: BoxFit.cover, width: double.infinity),
                            )
                          : const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold500, size: 34),
                                  SizedBox(height: 4),
                                  Text('Toca para seleccionar', style: TextStyle(color: AppColors.carbon600, fontSize: 11)),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ubicacion en el mapa',
                style: TextStyle(color: AppColors.carbon400, fontSize: 12),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 260,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MapPicker(
                    tileUrl: provider.tileUrl,
                    initialPoint: _point,
                    onChanged: (point) => _point = point,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lat: ${_point.latitude.toStringAsFixed(6)}, Lng: ${_point.longitude.toStringAsFixed(6)}',
                style: const TextStyle(color: AppColors.carbon600, fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : _save,
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.carbon950),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(widget.stop == null ? 'Crear paradero' : 'Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.carbon50),
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
