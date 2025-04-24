import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        focusNode: focusNode,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4285F4).withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4285F4)),
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: Color(0xFFEBF5FF).withOpacity(0.5),
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFF4285F4).withOpacity(0.7)),
        ),
        style: TextStyle(color: Color(0xFF4285F4)),
        cursorColor: Color(0xFF4285F4),
      ),
    );
  }
}
