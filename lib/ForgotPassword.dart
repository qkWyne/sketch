import 'package:sketch/LoginPage.dart';
import 'package:sketch/widgets/Login_SignUp_TextField.dart';
import 'package:sketch/widgets/Login_SignUp_Btn.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ForgotPassword extends StatefulWidget {
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}
class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();
  GlobalKey<FormState> _Formkey = GlobalKey<FormState>();

  _resetPassword() async {
    try {
      FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text).then((
          value)=> {
        print("Sent Email"),
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>LoginPage())),
      });
    } on FirebaseAuthException catch (e) {
      print("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(

          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/Newfolder/download.png",), fit: BoxFit.cover,),
              ),
            ),
            Positioned(
              left: 30,
              top: 40,
              child: InkWell(
                child: Container(
                  child: Text("LOGIN",style: TextStyle(
                    fontWeight: FontWeight.bold,fontSize: 25,color: Colors.grey.shade800,),),
                ),
                onTap:(){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                },
              ),
            ),
            Positioned(
              left: 239,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(110),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 675,
              child:Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide( //                    <--- top side
                      color: Colors.grey.shade800,
                      width: 12,
                    ),
                    right: BorderSide( //                    <--- top side
                      color: Colors.grey.shade800,
                      width: 12,
                    ),
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(90),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 290,
              top: 704,
              child:Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(

                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                  ),
                ),
              ),
            ),
            Center(
              child: Form(
                key: _Formkey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: Image.asset("assets/images/Newfolder/forget.png"),
                      ),
                      SizedBox(height: 20,),
                      Container(
                        child: Text("Reset Password",style: TextStyle(
                            color: Colors.black,
                            fontWeight:FontWeight.bold,
                            fontSize: 30),),
                      ),
                      SizedBox(height:50,),
                      Container(
                        alignment: Alignment(-0.8, 0),
                        child: Text("Email Address",
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight:FontWeight.bold,
                              fontSize: 16
                          ),),
                      ),
                      SizedBox(height: 5,),
                      LoginSignUpTextField(
                        controller: _emailController,
                        hintText: "Enter Email",
                        prefixIcon: Icon(Icons.email_rounded,color: Colors.grey.shade800,),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Email Required";
                          }
                          else if(!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"
                          ).hasMatch(value))
                          {
                            return "Please Valid Email";
                          }
                          return null;

                        },),
                      SizedBox(height: 40,),
                      Align(
                          alignment: Alignment(1, 0),
                          child: LoginSignupBtn(btnName:"SEND",
                            callback: (){
                              if(_Formkey.currentState!.validate()){
                                _resetPassword();
                              }
                            },)
                      ),




                    ],
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}