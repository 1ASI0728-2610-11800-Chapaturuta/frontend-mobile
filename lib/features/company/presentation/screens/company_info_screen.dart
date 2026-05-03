import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/company_model.dart';
import '../providers/company_provider.dart';

class CompanyInfoScreen extends StatefulWidget {
  const CompanyInfoScreen({super.key});

  @override
  State<CompanyInfoScreen> createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  int? _companyId;
  int _fkIdUser = 0;
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    final company = context.read<CompanyProvider>().company;
    _companyId = company?.id;
    _fkIdUser = company?.fkIdUser ?? 0;
    _logoUrl = company?.logoUrl;
    _nameCtrl.text = company?.name ?? '';
    _rucCtrl.text = company?.ruc ?? '';
    _phoneCtrl.text = company?.phone ?? '';
    _emailCtrl.text = company?.email ?? '';
    _addressCtrl.text = company?.address ?? '';
    _descriptionCtrl.text = company?.description ?? '';
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _companyId == null) return;

    final provider = context.read<CompanyProvider>();
    final ok = await provider.updateCompany(
      CompanyModel(
        id: _companyId!,
        fkIdUser: _fkIdUser,
        name: _nameCtrl.text.trim(),
        ruc: _rucCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        logoUrl: _logoUrl,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Empresa actualizada' : provider.error ?? 'No se pudo guardar'),
      ),
    );
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
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: const Text('Datos de empresa')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
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
                  onPressed: isLoading ? null : _save,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.carbon950),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Guardar cambios'),
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
