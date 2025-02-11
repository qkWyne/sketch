import 'package:sketch/LoginPage.dart';
import 'package:sketch/SignupPage.dart';
import 'package:flutter/material.dart';
class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/Newfolder/download.png",), fit: BoxFit.cover,),
            ),
            child:  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          width:250,
                          child: Image.asset("assets/images/Newfolder/sketch.png"),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          child: Text("Sketch is a toolkit made by qkWyne , for designers",
                            style: TextStyle(fontWeight:FontWeight.bold,color: Colors.black45),),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          width: 330,
                          height: 55,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape:  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  backgroundColor:Colors.black,
                                  foregroundColor: Colors.white),
                              onPressed: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignupPage()));

                              }, child: Text("SIGNUP",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 330,
                          height: 55,
                          child: OutlinedButton(style: OutlinedButton.styleFrom(
                            shape:  RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // <-- Radius
                            ),
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                            backgroundColor: Colors.white,
                          ),onPressed: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));

                          }, child: Text("LOGIN",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),

          Positioned(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(110),
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
                  top: BorderSide(
                    color: Colors.black,
                    width: 12,
                  ),
                  right: BorderSide(
                    color: Colors.black,
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
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}