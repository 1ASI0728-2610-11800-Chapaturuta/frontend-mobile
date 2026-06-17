import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../../main/presentation/screens/role_router_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  int _role = 0; // 0=Pasajero, 2=Conductor

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _nameCtrl.text.trim(),
      role: _role,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleRouterScreen()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(auth.error ?? 'Error al registrar'),
        ),
      );
    }
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label es obligatorio' : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email es obligatorio';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) {
      return 'Email no válido';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Contraseña es obligatoria';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Debe incluir una mayúscula';
    if (!RegExp(r'\d').hasMatch(v)) return 'Debe incluir un número';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.carbon950,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.gold400),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    color: AppColors.gold400,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Únete a ChapaTuRuta',
                  style: TextStyle(color: AppColors.carbon400, fontSize: 14),
                ),
                const SizedBox(height: 28),
                _label('Nombre'),
                _textField(
                  controller: _nameCtrl,
                  hint: 'Tu nombre',
                  validator: (v) => _required(v, 'Nombre'),
                ),
                const SizedBox(height: 16),
                _label('Email'),
                _textField(
                  controller: _emailCtrl,
                  hint: 'tu@correo.com',
                  keyboard: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                _label('Contraseña'),
                _textField(
                  controller: _passwordCtrl,
                  hint: 'Mín 8 caracteres, mayúscula y número',
                  obscure: _obscure,
                  validator: _validatePassword,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.carbon400),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 16),
                _label('Confirmar contraseña'),
                _textField(
                  controller: _confirmCtrl,
                  hint: 'Repite la contraseña',
                  obscure: _obscureConfirm,
                  validator: _validateConfirm,
                  suffix: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.carbon400),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 16),
                _label('Tipo de cuenta'),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.carbon800,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.carbon700),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _role,
                      isExpanded: true,
                      dropdownColor: AppColors.carbon800,
                      iconEnabledColor: AppColors.gold400,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Pasajero')),
                        DropdownMenuItem(value: 2, child: Text('Conductor')),
                      ],
                      onChanged: (v) => setState(() => _role = v ?? 0),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold500,
                      foregroundColor: AppColors.carbon950,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                          )
                        : const Text(
                            'Crear cuenta',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
                      style: TextStyle(color: AppColors.gold300, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.carbon400,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.carbon400, fontSize: 13),
        filled: true,
        fillColor: AppColors.carbon800,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.carbon700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.carbon700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gold500, width: 1.5),
        ),
      ),
    );
  }
}
