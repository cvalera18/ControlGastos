import 'package:flutter/material.dart';
import 'package:control_gastos/core/utils/validators.dart';

class EmailInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const EmailInputField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'correo@ejemplo.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: Validators.email,
    );
  }
}
