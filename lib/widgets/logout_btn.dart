import 'package:flutter/material.dart';
class logoutbtn extends StatelessWidget {
  final String btnName;
  final Icon? icon;
  final Color? bgColor;
  final VoidCallback? callback;

  logoutbtn({
      required this.btnName,
      this.icon,
      this.bgColor = Colors.red,
      this.callback});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: (){
      callback!();
    },style: ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: Colors.white,
    ),child: icon!=null ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon!,
        SizedBox(
          width: 5,
        ),
        Text(btnName),
      ],
    )
    :Text(btnName),
    );
  }
}
