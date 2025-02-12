import 'package:sketch/SignupPage.dart';
import 'package:sketch/ForgotPassword.dart';
import 'package:sketch/avatar.dart';
import 'package:sketch/widgets/Login_SignUp_TextField.dart';
import 'package:sketch/widgets/Login_SignUp_Btn.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> _Formkey = GlobalKey<FormState>();
  bool obscure = true;

  _login() async {
    try {
      final User? firebaseUser = (await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text)).user;
      if(firebaseUser!=null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Avatar()));
      }

    } on FirebaseAuthException catch (e) {
      print("Error $e");
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No user found with this email.")),
        );
      }else {
        // Other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
              content: Text("Email and Password are Incorrect. Please try again.")),
        );
      }
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
                  child: Text("SIGNUP",style: TextStyle(
                      fontWeight: FontWeight.bold,fontSize: 25,color: Colors.grey[800],),),
                ),
                onTap:(){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignupPage()));
                  },
              ),
            ),
            Positioned(
              left: 239,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
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

                  color: Colors.grey[800],
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
                          child: Text("Login",style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight:FontWeight.bold,
                              fontSize: 30),),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          child: Text("Designers, welcome home.",
                            style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 15),),
                        ),
                        SizedBox(height: 60,),
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
                        SizedBox(height: 20,),
                        Container(
                          alignment: Alignment(-0.8, 0),
                          child: Text("Password",
                            style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight:FontWeight.bold,
                                fontSize: 16
                            ),),
                        ),
                        SizedBox(height: 5,),
                  LoginSignUpTextField(
                    controller: _passwordController,
                    obscure: obscure,
                    prefixIcon: Icon(Icons.password,color: Colors.grey.shade800,),
                    suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        obscure = !obscure;
                      });
                    }, icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,color: Colors.grey.shade800,)),
                    hintText: "Enter Password",
                    validator: (value){
                      if(value!.isEmpty){
                        return "Password Required";
                      }
                      else if(!RegExp(r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*\W)(?!.* ).{8,16}$"
                      ).hasMatch(value))
                      {
                        return "Please Valid Password";
                      }
                      return null;

                    },


                  ),
                        SizedBox(height: 20,),
                        InkWell(
                          child: Container(
                            alignment: Alignment(-0.8, 0),
                            child: Text("Forgot Password?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black45,
                              ),),
                          ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword() ));
                          },
                        ),
                        SizedBox(height: 15,),
                  Align(
                      alignment: Alignment(1, 0),
                      child: LoginSignupBtn(btnName:"LOGIN",
                        callback: (){
                          if(_Formkey.currentState!.validate()){
                            _login();
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