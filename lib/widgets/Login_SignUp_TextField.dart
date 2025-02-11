import 'package:flutter/material.dart';
class LoginSignUpTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool? obscure;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;



  LoginSignUpTextField({
     required this.controller,
      this.obscure = false,
      this.hintText,
      this.prefixIcon,
      this.suffixIcon,
     this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      child:  Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(8),
        child: TextFormField(
          controller: controller,
          obscureText: obscure!,
          style: TextStyle(height: 2),
          decoration:InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }
}
