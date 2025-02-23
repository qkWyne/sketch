import 'package:flutter/services.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
                                  backgroundColor:Colors.grey.shade800,
                                  foregroundColor: Colors.white),
                              onPressed: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));

                              }, child: Text("LOGIN",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
                        ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Container(
                        //   width: 330,
                        //   height: 55,
                        //   child: OutlinedButton(style: OutlinedButton.styleFrom(
                        //     shape:  RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(8.0), // <-- Radius
                        //     ),
                        //     foregroundColor: Colors.grey.shade800,
                        //     side: const BorderSide(
                        //       width: 2,
                        //       color: Colors.black54,
                        //     ),
                        //     backgroundColor: Colors.white,
                        //   ),onPressed: (){
                        //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                        //
                        //   }, child: Text("LOGIN",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
                        // ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(110),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.shade800,
                            width: 12,
                          ),
                          right: BorderSide(
                            color: Colors.grey.shade800,
                            width: 12,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(90),
                        ),
                      ),
                    ),
                  Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(70),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),


        ],
      ),
    );
  }
}