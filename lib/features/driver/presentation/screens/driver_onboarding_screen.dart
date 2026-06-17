import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../providers/driver_provider.dart';
import '../../../main/presentation/screens/driver_main_screen.dart';

class DriverOnboardingScreen extends StatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  State<DriverOnboardingScreen> createState() => _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState extends State<DriverOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _docCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  String _licenseCategory = 'AIIb';
  String _vehicleType = 'Combi';

  static const _licenseCategories = ['AIIa', 'AIIb', 'AIIIa', 'AIIIb', 'AIIIc'];
  static const _vehicleTypes = ['Car', 'Pickup', 'Combi', 'Van', 'Bus', 'Minivan'];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _docCtrl.dispose();
    _phoneCtrl.dispose();
    _licenseCtrl.dispose();
    _plateCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    final driverProvider = context.read<DriverProvider>();
    final ok = await driverProvider.createDriver(
      fkIdUser: userId,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      documentNumber: _docCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      licenseNumber: _licenseCtrl.text.trim(),
      licenseCategory: _licenseCategory,
      vehiclePlate: _plateCtrl.text.trim(),
      vehicleBrand: _brandCtrl.text.trim(),
      vehicleModel: _modelCtrl.text.trim(),
      vehicleYear: int.tryParse(_yearCtrl.text.trim()) ?? 2020,
      vehicleCapacity: int.tryParse(_capacityCtrl.text.trim()) ?? 1,
      vehicleType: _vehicleType,
    );

    if (!mounted) return;
    if (ok) {
      final driver = driverProvider.driver;
      if (driver != null) {
        await context.read<UserProvider>().setDriverId(driver.id);
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DriverMainScreen(skipBootstrap: true)),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(driverProvider.error ?? 'No se pudo crear el perfil')),
      );
    }
  }

  String? _req(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label es obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<DriverProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.carbon950,
      appBar: AppBar(title: const Text('Perfil de conductor'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Completa tus datos para activar el panel de conductor.',
                style: TextStyle(color: AppColors.carbon400),
              ),
              const SizedBox(height: 20),
              _section('Datos personales'),
              _field(_firstNameCtrl, 'Nombres', validator: (v) => _req(v, 'Nombres')),
              const SizedBox(height: 14),
              _field(_lastNameCtrl, 'Apellidos', validator: (v) => _req(v, 'Apellidos')),
              const SizedBox(height: 14),
              _field(_docCtrl, 'DNI', keyboardType: TextInputType.number,
                  validator: (v) => _req(v, 'DNI')),
              const SizedBox(height: 14),
              _field(_phoneCtrl, 'Teléfono', keyboardType: TextInputType.phone,
                  validator: (v) => _req(v, 'Teléfono')),
              const SizedBox(height: 20),
              _section('Licencia de conducir'),
              _field(_licenseCtrl, 'Número de licencia',
                  validator: (v) => _req(v, 'Número de licencia')),
              const SizedBox(height: 14),
              _dropdown('Categoría de licencia', _licenseCategories, _licenseCategory,
                  (v) => setState(() => _licenseCategory = v!)),
              const SizedBox(height: 20),
              _section('Vehículo'),
              _field(_plateCtrl, 'Placa', validator: (v) => _req(v, 'Placa')),
              const SizedBox(height: 14),
              _field(_brandCtrl, 'Marca', validator: (v) => _req(v, 'Marca')),
              const SizedBox(height: 14),
              _field(_modelCtrl, 'Modelo', validator: (v) => _req(v, 'Modelo')),
              const SizedBox(height: 14),
              _field(_yearCtrl, 'Año', keyboardType: TextInputType.number, validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Año es obligatorio';
                final y = int.tryParse(v.trim());
                if (y == null || y < 1980) return 'Año inválido (mín. 1980)';
                return null;
              }),
              const SizedBox(height: 14),
              _field(_capacityCtrl, 'Capacidad de pasajeros',
                  keyboardType: TextInputType.number, validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Capacidad es obligatoria';
                final c = int.tryParse(v.trim());
                if (c == null || c < 1) return 'Capacidad mínima: 1';
                return null;
              }),
              const SizedBox(height: 14),
              _dropdown('Tipo de vehículo', _vehicleTypes, _vehicleType,
                  (v) => setState(() => _vehicleType = v!)),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.carbon950),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('Activar perfil de conductor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold500,
                    foregroundColor: AppColors.carbon950,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
              color: AppColors.gold400, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.carbon50),
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _dropdown(
      String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.carbon400, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.carbon800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.carbon700),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.carbon800,
              iconEnabledColor: AppColors.gold400,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
