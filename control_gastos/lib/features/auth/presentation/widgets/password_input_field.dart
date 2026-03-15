import 'package:flutter/material.dart';
import 'package:control_gastos/core/utils/validators.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final String label;

  const PasswordInputField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.label = 'Contraseña',
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: Validators.password,
    );
  }
}
