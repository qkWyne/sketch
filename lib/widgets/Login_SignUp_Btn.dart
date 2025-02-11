import 'package:flutter/material.dart';

class LoginSignupBtn extends StatelessWidget {

  final String btnName;
  final VoidCallback? callback;

  LoginSignupBtn({
    required this.btnName,
    this.callback});

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: 120,
      height: 50,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape:  RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),), // <-- Radius
              ),
              backgroundColor:Colors.black,
              foregroundColor: Colors.white),
          onPressed: () {
            callback!();
          }, child: Text(btnName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)),
    );
  }
}
