import 'dart:developer';
import 'package:sketch/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sketch/widgets/Login_SignUp_TextField.dart';
import 'package:sketch/widgets/Login_SignUp_Btn.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}
class MenuItems{

}
class _SignupPageState extends State<SignupPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();
  GlobalKey<FormState> _FormKey = GlobalKey<FormState>();
  bool obscure1 = true;
  bool obscure2 = true;

  _signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      log("User Created");
      // String uid = FirebaseAuth.instance.currentUser!.uid;
      // await FirebaseFirestore.instance.collection("users").doc(uid).set({
      //   "userID":uid,
      //   "userCreate_At":DateTime.now(),
      //   "userName":_nameController.text,
      //   "userEmail":_emailController.text,
      // });
      // log("User Data Saved");
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
    } on FirebaseAuthException catch (e) {
     print("Error $e");
      if (e.code == 'email-already-in-use') {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           duration: Duration(seconds: 3),
             content: Text("This email is already exist")),
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
                        child: Text("LOGIN",style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 25,color: Colors.grey.shade800),),
                      ),
                onTap: (){
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
                key: _FormKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: Text("Signup",style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight:FontWeight.bold,
                            fontSize: 30),),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        child: Text("Designers, welcome home.",
                          style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 15),),
                      ),
                      SizedBox(height: 20,),
                      Container(
                        alignment: Alignment(-0.8, 0),
                        child: Text("Name",
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight:FontWeight.bold,
                              fontSize: 16
                          ),),
                      ),
                      SizedBox(height: 2,),
                      LoginSignUpTextField(
                        controller: _nameController,
                        prefixIcon: Icon(Icons.person,color: Colors.grey.shade800,),
                        hintText: "Enter Name",
                        validator: (value){
                          if(value!.isEmpty){
                            return "Name Required";
                          }
                          else if(!RegExp(r"^[a-zA-Z ]*[A-Za-z]$"
                          ).hasMatch(value))
                          {
                            return "Please Valid Name";
                          }
                          return null;

                        },),
                      SizedBox(height: 15,),
                      Container(
                        alignment: Alignment(-0.8, 0),
                        child: Text("Email",
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight:FontWeight.bold,
                              fontSize: 16
                          ),),
                      ),
                      SizedBox(height: 2,),
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
                      SizedBox(height: 15),
                      Container(
                        alignment: Alignment(-0.8, 0),
                        child: Text("Password",
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight:FontWeight.bold,
                              fontSize: 16
                          ),),
                      ),
                      SizedBox(height: 2,),
                      LoginSignUpTextField(
                        controller: _passwordController,
                        obscure: obscure1,
                        prefixIcon: Icon(Icons.password,color: Colors.grey.shade800,),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            obscure1 = !obscure1;
                          });
                        }, icon: Icon(obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,color: Colors.grey.shade800,)),
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
                      SizedBox(height: 15,),
                      Container(
                        alignment: Alignment(-0.8, 0),
                        child: Text("Confirm Password",
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight:FontWeight.bold,
                              fontSize: 16
                          ),),
                      ),
                      SizedBox(height: 2,),
                      LoginSignUpTextField(
                        controller: _confirmpasswordController ,
                        obscure: obscure2,
                        prefixIcon: Icon(Icons.password,color: Colors.grey.shade800,),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            obscure2 = !obscure2;
                          });
                        }, icon: Icon(obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,color: Colors.grey.shade800,)),
                        hintText: "Enter Confirm Password",
                        validator: (value){
                          if(value!.isEmpty){
                            return "Password Required";
                          }
                          else if(value!=_passwordController.text)
                          {
                            return "Password Not Match";
                          }
                          return null;

                        },
                      ),
                      SizedBox(height: 30,),
                      Align(
                          alignment: Alignment(1, 0),
                          child: LoginSignupBtn(btnName:"SIGNUP",
                            callback: (){
                            if(_FormKey.currentState!.validate()){
                              _signup();
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