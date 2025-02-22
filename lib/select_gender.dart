import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sketch/female_avatar.dart';
import 'package:sketch/male_avatar.dart';

import 'LoginPage.dart';
class SelectGender extends StatefulWidget {
  const SelectGender({super.key});

  @override
  State<SelectGender> createState() => _SelectGenderState();
}

class _SelectGenderState extends State<SelectGender> {
  String selectedGender = '';

  _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
    } on FirebaseAuthException catch (e) {
      print("Error $e");
    }
  }

  void selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body:
      Stack(
        children:[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/Newfolder/download.png",), fit: BoxFit.cover,),
            ),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: InkWell(
              child: Container(
                width: 120,
                height: 40,
                decoration: BoxDecoration(
                color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Center(
                  child: Text("SIGN OUT",style: TextStyle(
                      fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),
                ),
              ),
              onTap: (){
                _signOut();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _genderCard("Male", "assets/images/Newfolder/male.png", selectedGender == "Male"),
                  const SizedBox(height:  30),
                  _genderCard("Female", "assets/images/Newfolder/female.png", selectedGender == "Female"),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedGender.isNotEmpty) {
                      if(selectedGender == "Male"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MaleAvatar()));
                      }
                      if(selectedGender == "Female"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FemaleAvatar()));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Continue",style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
        ),]
      ),
    );
  }

  Widget _genderCard(String gender, String imagePath, bool isSelected) {
    return GestureDetector(
      onTap: () => selectGender(gender),
      child: AnimatedContainer(
        width: 250,
        height: 250,
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[800] : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (isSelected)
              const BoxShadow(
                color: Color(0xFF424242),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(image:AssetImage(imagePath),fit: BoxFit.fill ,)
                ),),
            const SizedBox(height: 10),
            Text(
              gender,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
