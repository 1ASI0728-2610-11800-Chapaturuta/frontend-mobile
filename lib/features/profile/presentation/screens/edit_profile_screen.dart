import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../../data/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Mujer';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().currentUser;
      if (user != null) {
        _nameController.text = user.name;
        _lastNameController.text = user.lastName;
        _usernameController.text = user.username;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        if (['Hombre', 'Mujer', 'Otro'].contains(user.gender)) {
          _selectedGender = user.gender;
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<UserProvider>();
      final currentUser = provider.currentUser;
      if (currentUser != null) {
        final updatedUser = UserModel(
          id: currentUser.id,
          name: _nameController.text,
          lastName: _lastNameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          gender: _selectedGender,
          favoriteRoutes: currentUser.favoriteRoutes,
          driverId: currentUser.driverId,
          role: currentUser.role,
        );
        await provider.updateUser(updatedUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado')),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.carbon800,
                      border: Border.all(color: AppColors.gold500, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 50, color: AppColors.carbon600),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: AppColors.gold500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.carbon950),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildField(controller: _nameController, label: 'Nombre', hint: 'Juan',
                  validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 16),
              _buildField(controller: _lastNameController, label: 'Apellido', hint: 'Pérez',
                  validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 16),
              _buildField(controller: _usernameController, label: 'Usuario', hint: 'juanperez',
                  validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 16),
              _buildField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'juan@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Email inválido' : null),
              const SizedBox(height: 16),
              _buildField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  hint: '+51 999 000 111',
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Género', style: TextStyle(fontSize: 12, color: AppColors.carbon400, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.carbon800,
                      border: Border.all(color: AppColors.carbon700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        isExpanded: true,
                        dropdownColor: AppColors.carbon800,
                        style: const TextStyle(color: AppColors.carbon100),
                        items: ['Hombre', 'Mujer', 'Otro']
                            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedGender = v ?? _selectedGender),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('Cambiar contraseña'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<UserProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gold600, AppColors.gold500, AppColors.gold400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: AppColors.carbon950,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.carbon950, strokeWidth: 2))
                            : const Text('Guardar cambios', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.carbon400, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.carbon100),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
