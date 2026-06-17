import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../providers/company_provider.dart';
import '../../../main/presentation/screens/company_main_screen.dart';

class CompanyOnboardingScreen extends StatefulWidget {
  const CompanyOnboardingScreen({super.key});

  @override
  State<CompanyOnboardingScreen> createState() => _CompanyOnboardingScreenState();
}

class _CompanyOnboardingScreenState extends State<CompanyOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  Uint8List? _logoBytes;
  String? _logoFileName;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rucCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _logoBytes = bytes;
      _logoFileName = image.name;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    final companyProvider = context.read<CompanyProvider>();
    final ok = await companyProvider.createCompany(
      userId: userId,
      name: _nameCtrl.text.trim(),
      ruc: _rucCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      logoBytes: _logoBytes,
      logoFileName: _logoFileName,
    );

    if (!mounted) return;
    if (ok) {
      final company = companyProvider.company;
      if (company != null) {
        await context.read<UserProvider>().setDriverId(company.id);
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CompanyMainScreen(skipBootstrap: true)),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(companyProvider.error ?? 'No se pudo crear la empresa')),
      );
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label es obligatorio';
    return null;
  }

  String? _email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email es obligatorio';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
      return 'Email no valido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CompanyProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.carbon950,
      appBar: AppBar(title: const Text('Crear empresa'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Completa los datos para activar el panel de gestor.',
                style: TextStyle(color: AppColors.carbon400),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  height: 132,
                  decoration: BoxDecoration(
                    color: AppColors.carbon800,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.carbon700),
                  ),
                  child: _logoBytes == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold500, size: 32),
                            SizedBox(height: 8),
                            Text('Seleccionar logo', style: TextStyle(color: AppColors.gold300)),
                          ],
                        )
                      : Image.memory(_logoBytes!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 18),
              _field(_nameCtrl, 'Nombre comercial', validator: (v) => _required(v, 'Nombre')),
              const SizedBox(height: 14),
              _field(_rucCtrl, 'RUC', keyboardType: TextInputType.number, validator: (v) => _required(v, 'RUC')),
              const SizedBox(height: 14),
              _field(_phoneCtrl, 'Telefono', keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              _field(_emailCtrl, 'Email', keyboardType: TextInputType.emailAddress, validator: _email),
              const SizedBox(height: 14),
              _field(_addressCtrl, 'Direccion'),
              const SizedBox(height: 14),
              _field(_descriptionCtrl, 'Descripcion', maxLines: 4),
              const SizedBox(height: 24),
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
                      : const Icon(Icons.business_rounded),
                  label: const Text('Crear empresa'),
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
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.carbon50),
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
