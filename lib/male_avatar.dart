import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';

class MaleAvatar extends StatefulWidget {
  @override
  _MaleAvatarState createState() => _MaleAvatarState();
}

class _MaleAvatarState extends State<MaleAvatar> {
  int? selectedFaceIndex;
  double zoomLevel = 150.0;

  _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
    } on FirebaseAuthException catch (e) {
      print("Error $e");
    }
  }

  Future<void> saveAvatarState(String faceName) async {
    String dateOnly = DateFormat('yyyy-MM-dd').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedFaces = prefs.getStringList('savedFaces') ?? [];

    // Encode selectedParts and partsState
    String encodedParts = jsonEncode(selectedParts);
    Map<String, Map<String, dynamic>> encodedStates = {};
    partsState.forEach((key, value) {
      encodedStates[key] = value.toJson();
    });

    // Save both selectedParts and partsState
    Map<String, dynamic> avatarState = {
      'name': faceName,
      'dateTime': dateOnly,
      'parts': encodedParts,
      'states': jsonEncode(encodedStates), // Save partsState here
    };

    savedFaces.add(jsonEncode(avatarState));
    await prefs.setStringList('savedFaces', savedFaces);
  }

  Future<List<Map<String, dynamic>>> loadSavedFaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedFaces = prefs.getStringList('savedFaces') ?? [];

    return savedFaces.map((face) {
      Map<String, dynamic> decodedFace = Map<String, dynamic>.from(jsonDecode(face));
      return {
        'name': decodedFace['name'],
        'dateTime': decodedFace['dateTime'],
        'parts': decodedFace['parts'],
        'states': decodedFace['states'], // Load partsState here
      };
    }).toList();
  }
  // Delete the selected saved face
  Future<void> deleteSavedFace() async {
    if (selectedFaceIndex != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedFaces = prefs.getStringList('savedFaces') ?? [];

      // Remove the face at the selected index
      savedFaces.removeAt(selectedFaceIndex!);

      // Save the updated list back to SharedPreferences
      await prefs.setStringList('savedFaces', savedFaces);

      // Optionally, you can show a message or update the UI after deleting
      setState(() {
        // Refresh the UI after deletion
        selectedFaceIndex = null; // Clear the selected face index
      });
    }
  }

  void loadFace(String encodedParts, String encodedStates) {
    Map<String, String> loadedParts = Map<String, String>.from(jsonDecode(encodedParts));
    Map<String, dynamic> loadedStates = Map<String, dynamic>.from(jsonDecode(encodedStates));

    setState(() {
      selectedParts = loadedParts;

      // Load partsState
      loadedStates.forEach((key, value) {
        partsState[key] = AvatarPartState(
          top: value['top'],
          left: value['left'],
          size: value['size'],
        );
      });
    });
  }

  // Reset the avatar to start a new face (clear all selected parts)
  void resetToNewFace() {
    setState(() {
      selectedParts = {
        'sincipit': '',
        'supercilium': '',
        'oculus': '',
        'hair': '',
        'nasus': '',
        'glasses': '',
        'moustache': '',
        'labium': '',
        'mandible': '',
        'beard': '',
      };
    });
  }
  void removeFilter() {
    setState(() {
      selectedParts[selectedCategory] = ''; // Reset the current selected part to empty (remove filter)
    });
  }
  void showNameDialog() {
    String name = ''; // Initial empty name
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Face',style: TextStyle(fontWeight: FontWeight.bold),),
          content: TextField(
            onChanged: (value) {
              name = value; // Update the name as the user types
            },
            decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.black),
            ),
                hintText: "Enter a name for this face",
              hintStyle: TextStyle(color: Colors.grey),
              label: Text("Name"),
              labelStyle: TextStyle(color: Colors.black),
              border:OutlineInputBorder(
                borderSide: BorderSide(width: 2,color: Colors.grey),
              ),),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  saveAvatarState(name); // Save with the entered name
                  Navigator.pop(context);
                }else {
                  // Show error if the name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a name for the face!")),
                  );
                }
              },
              child: const Text('Save',style: TextStyle(color: Colors.black,
                  fontWeight: FontWeight.bold,
              fontSize: 18),),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: const Text('Cancel',style: TextStyle(color: Colors.grey,
                  fontWeight: FontWeight.bold,fontSize: 18),),
            ),
          ],
        );
      },
    );
  }

  void showSavedFacesDialog(BuildContext context) async {
    List<Map<String, dynamic>> savedFaces = await loadSavedFaces();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Saved Face', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Container(
            height: 400,
            child: ListView.builder(
              itemCount: savedFaces.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 2, color: Colors.black),
                    ),
                    child: ListTile(
                      title: Text(savedFaces[index]['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Saved on: ${savedFaces[index]['dateTime']}'),
                      onTap: () {
                        loadFace(savedFaces[index]['parts'], savedFaces[index]['states']);
                        Navigator.pop(context);
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            selectedFaceIndex = index;
                          });
                          deleteSavedFace();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  void _bringPartToTop(String partKey) {
    setState(() {
      partOrder.remove(partKey); // Remove the part from its current position
      partOrder.add(partKey);    // Add it to the end of the list (top of the stack)
    });
  }
  List<String> partOrder = [
    'sincipit',
    'supercilium',
    'oculus',
    'hair',
    'nasus',
    'glasses',
    'moustache',
    'labium',
    'mandible',
    'beard',
  ];



  // Stores the selected parts of the avatar
  Map<String, String> selectedParts = {
    'sincipit': '',
    'supercilium': '',
    'oculus': '',
    'hair': '',
    'nasus': '',
    'glasses': '',
    'moustache': '',
    'labium': '',
    'mandible': '',
    'beard': '',
  };


  // Contains the available parts for each category
  final Map<String, List<String>> avatarParts = {
    'sincipit': [
      'assets/images/male/head/1.png','assets/images/male/head/2.png','assets/images/male/head/3.png','assets/images/male/head/4.png','assets/images/male/head/5.png',
      'assets/images/male/head/6.png','assets/images/male/head/7.png','assets/images/male/head/8.png','assets/images/male/head/9.png','assets/images/male/head/10.png',
      'assets/images/male/head/11.png','assets/images/male/head/12.png','assets/images/male/head/13.png','assets/images/male/head/14.png','assets/images/male/head/15.png',
      'assets/images/male/head/16.png','assets/images/male/head/17.png','assets/images/male/head/18.png','assets/images/male/head/19.png','assets/images/male/head/20.png',
      'assets/images/male/head/21.png','assets/images/male/head/22.png','assets/images/male/head/23.png',
    ],
    'supercilium': [
      'assets/images/male/eyebrows/1.png','assets/images/male/eyebrows/2.png','assets/images/male/eyebrows/3.png','assets/images/male/eyebrows/4.png','assets/images/male/eyebrows/5.png',
      'assets/images/male/eyebrows/6.png','assets/images/male/eyebrows/7.png','assets/images/male/eyebrows/8.png','assets/images/male/eyebrows/9.png','assets/images/male/eyebrows/10.png',
      'assets/images/male/eyebrows/11.png','assets/images/male/eyebrows/12.png','assets/images/male/eyebrows/13.png','assets/images/male/eyebrows/14.png','assets/images/male/eyebrows/15.png',
      'assets/images/male/eyebrows/16.png','assets/images/male/eyebrows/17.png','assets/images/male/eyebrows/18.png','assets/images/male/eyebrows/19.png','assets/images/male/eyebrows/20.png',
      'assets/images/male/eyebrows/21.png','assets/images/male/eyebrows/22.png','assets/images/male/eyebrows/23.png','assets/images/male/eyebrows/24.png','assets/images/male/eyebrows/25.png',
      'assets/images/male/eyebrows/26.png','assets/images/male/eyebrows/27.png','assets/images/male/eyebrows/28.png','assets/images/male/eyebrows/29.png','assets/images/male/eyebrows/30.png',
      'assets/images/male/eyebrows/31.png','assets/images/male/eyebrows/32.png','assets/images/male/eyebrows/33.png','assets/images/male/eyebrows/34.png','assets/images/male/eyebrows/35.png',
      'assets/images/male/eyebrows/36.png','assets/images/male/eyebrows/37.png','assets/images/male/eyebrows/38.png','assets/images/male/eyebrows/39.png','assets/images/male/eyebrows/40.png',
      'assets/images/male/eyebrows/41.png','assets/images/male/eyebrows/42.png','assets/images/male/eyebrows/43.png','assets/images/male/eyebrows/44.png','assets/images/male/eyebrows/45.png',
      'assets/images/male/eyebrows/46.png','assets/images/male/eyebrows/47.png','assets/images/male/eyebrows/48.png','assets/images/male/eyebrows/49.png','assets/images/male/eyebrows/50.png',

    ],
    'oculus': [
      'assets/images/male/eyes/1.png','assets/images/male/eyes/2.png','assets/images/male/eyes/3.png','assets/images/male/eyes/4.png','assets/images/male/eyes/5.png',
      'assets/images/male/eyes/6.png','assets/images/male/eyes/7.png','assets/images/male/eyes/8.png','assets/images/male/eyes/9.png','assets/images/male/eyes/10.png',
      'assets/images/male/eyes/11.png','assets/images/male/eyes/12.png','assets/images/male/eyes/13.png','assets/images/male/eyes/14.png','assets/images/male/eyes/15.png',
      'assets/images/male/eyes/16.png','assets/images/male/eyes/17.png','assets/images/male/eyes/18.png','assets/images/male/eyes/19.png','assets/images/male/eyes/20.png',
      'assets/images/male/eyes/21.png','assets/images/male/eyes/22.png','assets/images/male/eyes/23.png','assets/images/male/eyes/24.png','assets/images/male/eyes/25.png',
      'assets/images/male/eyes/26.png','assets/images/male/eyes/27.png','assets/images/male/eyes/28.png','assets/images/male/eyes/29.png','assets/images/male/eyes/30.png',
      'assets/images/male/eyes/31.png','assets/images/male/eyes/32.png','assets/images/male/eyes/33.png','assets/images/male/eyes/34.png','assets/images/male/eyes/35.png',
      'assets/images/male/eyes/36.png','assets/images/male/eyes/37.png','assets/images/male/eyes/38.png','assets/images/male/eyes/39.png','assets/images/male/eyes/40.png',
      'assets/images/male/eyes/41.png','assets/images/male/eyes/42.png','assets/images/male/eyes/43.png','assets/images/male/eyes/44.png','assets/images/male/eyes/45.png',
      'assets/images/male/eyes/46.png','assets/images/male/eyes/47.png','assets/images/male/eyes/48.png','assets/images/male/eyes/49.png','assets/images/male/eyes/50.png',
    ],
    'hair': [
      'assets/images/male/hair/1.png','assets/images/male/hair/2.png','assets/images/male/hair/3.png','assets/images/male/hair/4.png','assets/images/male/hair/5.png',
      'assets/images/male/hair/6.png','assets/images/male/hair/7.png','assets/images/male/hair/8.png','assets/images/male/hair/9.png','assets/images/male/hair/10.png',
      'assets/images/male/hair/11.png','assets/images/male/hair/12.png','assets/images/male/hair/13.png','assets/images/male/hair/14.png','assets/images/male/hair/15.png',
      'assets/images/male/hair/16.png','assets/images/male/hair/17.png','assets/images/male/hair/18.png','assets/images/male/hair/19.png','assets/images/male/hair/20.png',
      'assets/images/male/hair/21.png','assets/images/male/hair/22.png','assets/images/male/hair/23.png','assets/images/male/hair/24.png','assets/images/male/hair/25.png',
      'assets/images/male/hair/26.png','assets/images/male/hair/27.png','assets/images/male/hair/28.png','assets/images/male/hair/29.png','assets/images/male/hair/30.png',
      'assets/images/male/hair/31.png','assets/images/male/hair/32.png','assets/images/male/hair/33.png','assets/images/male/hair/34.png','assets/images/male/hair/35.png',
      'assets/images/male/hair/36.png','assets/images/male/hair/37.png','assets/images/male/hair/38.png','assets/images/male/hair/39.png','assets/images/male/hair/40.png',
      'assets/images/male/hair/41.png','assets/images/male/hair/42.png','assets/images/male/hair/43.png','assets/images/male/hair/44.png','assets/images/male/hair/45.png',
      'assets/images/male/hair/46.png','assets/images/male/hair/47.png','assets/images/male/hair/48.png','assets/images/male/hair/49.png','assets/images/male/hair/50.png',
      'assets/images/male/hair/51.png','assets/images/male/hair/52.png','assets/images/male/hair/53.png','assets/images/male/hair/54.png','assets/images/male/hair/55.png',
      'assets/images/male/hair/56.png','assets/images/male/hair/57.png','assets/images/male/hair/58.png','assets/images/male/hair/59.png','assets/images/male/hair/60.png',
      'assets/images/male/hair/61.png','assets/images/male/hair/62.png','assets/images/male/hair/63.png','assets/images/male/hair/64.png','assets/images/male/hair/65.png',
      'assets/images/male/hair/66.png','assets/images/male/hair/67.png','assets/images/male/hair/68.png','assets/images/male/hair/68.png','assets/images/male/hair/70.png',
      'assets/images/male/hair/71.png','assets/images/male/hair/72.png',
    ],
    'nasus': [
      'assets/images/male/nose/1.png','assets/images/male/nose/2.png','assets/images/male/nose/3.png','assets/images/male/nose/4.png','assets/images/male/nose/5.png',
      'assets/images/male/nose/6.png','assets/images/male/nose/7.png','assets/images/male/nose/8.png','assets/images/male/nose/9.png','assets/images/male/nose/10.png',
      'assets/images/male/nose/11.png','assets/images/male/nose/12.png','assets/images/male/nose/13.png','assets/images/male/nose/14.png','assets/images/male/nose/15.png',
      'assets/images/male/nose/16.png','assets/images/male/nose/17.png','assets/images/male/nose/18.png','assets/images/male/nose/19.png','assets/images/male/nose/20.png',
      'assets/images/male/nose/21.png','assets/images/male/nose/22.png','assets/images/male/nose/23.png','assets/images/male/nose/24.png','assets/images/male/nose/25.png',
      'assets/images/male/nose/26.png','assets/images/male/nose/27.png','assets/images/male/nose/28.png','assets/images/male/nose/29.png','assets/images/male/nose/30.png',
      'assets/images/male/nose/31.png','assets/images/male/nose/32.png','assets/images/male/nose/33.png','assets/images/male/nose/34.png','assets/images/male/nose/35.png',
      'assets/images/male/nose/36.png','assets/images/male/nose/37.png','assets/images/male/nose/38.png','assets/images/male/nose/39.png','assets/images/male/nose/40.png',
      'assets/images/male/nose/41.png','assets/images/male/nose/42.png','assets/images/male/nose/43.png','assets/images/male/nose/44.png','assets/images/male/nose/45.png',
      'assets/images/male/nose/46.png','assets/images/male/nose/47.png','assets/images/male/nose/48.png','assets/images/male/nose/49.png','assets/images/male/nose/50.png',
    ],
    'glasses': [
      'assets/images/male/glasses/1.png','assets/images/male/glasses/2.png','assets/images/male/glasses/3.png','assets/images/male/glasses/4.png','assets/images/male/glasses/5.png',
      'assets/images/male/glasses/6.png','assets/images/male/glasses/7.png','assets/images/male/glasses/8.png','assets/images/male/glasses/9.png','assets/images/male/glasses/10.png',
      'assets/images/male/glasses/11.png','assets/images/male/glasses/12.png','assets/images/male/glasses/13.png','assets/images/male/glasses/14.png','assets/images/male/glasses/15.png',
      'assets/images/male/glasses/16.png','assets/images/male/glasses/17.png','assets/images/male/glasses/18.png','assets/images/male/glasses/19.png','assets/images/male/glasses/20.png',
      'assets/images/male/glasses/21.png','assets/images/male/glasses/22.png','assets/images/male/glasses/23.png','assets/images/male/glasses/24.png','assets/images/male/glasses/25.png',
      'assets/images/male/glasses/26.png','assets/images/male/glasses/27.png','assets/images/male/glasses/28.png','assets/images/male/glasses/29.png','assets/images/male/glasses/30.png',
      'assets/images/male/glasses/31.png','assets/images/male/glasses/32.png','assets/images/male/glasses/33.png','assets/images/male/glasses/34.png',
    ],
    'moustache': [
      'assets/images/male/moustache/1.png','assets/images/male/moustache/2.png','assets/images/male/moustache/3.png','assets/images/male/moustache/4.png','assets/images/male/moustache/5.png',
      'assets/images/male/moustache/6.png','assets/images/male/moustache/7.png','assets/images/male/moustache/8.png','assets/images/male/moustache/9.png','assets/images/male/moustache/10.png',
      'assets/images/male/moustache/11.png','assets/images/male/moustache/12.png','assets/images/male/moustache/13.png','assets/images/male/moustache/14.png','assets/images/male/moustache/15.png',
      'assets/images/male/moustache/16.png','assets/images/male/moustache/17.png','assets/images/male/moustache/18.png','assets/images/male/moustache/19.png','assets/images/male/moustache/20.png',
      'assets/images/male/moustache/21.png','assets/images/male/moustache/22.png','assets/images/male/moustache/23.png',
    ],
    'labium': [
      'assets/images/male/mouth/1.png','assets/images/male/mouth/60.png','assets/images/male/mouth/3.png','assets/images/male/mouth/4.png','assets/images/male/mouth/5.png',
      'assets/images/male/mouth/6.png','assets/images/male/mouth/7.png','assets/images/male/mouth/8.png','assets/images/male/mouth/9.png','assets/images/male/mouth/10.png',
      'assets/images/male/mouth/51.png','assets/images/male/mouth/52.png','assets/images/male/mouth/53.png','assets/images/male/mouth/54.png','assets/images/male/mouth/55.png',
      'assets/images/male/mouth/56.png','assets/images/male/mouth/57.png','assets/images/male/mouth/58.png','assets/images/male/mouth/59.png','assets/images/male/mouth/20.png',
      'assets/images/male/mouth/21.png','assets/images/male/mouth/22.png','assets/images/male/mouth/23.png','assets/images/male/mouth/24.png','assets/images/male/mouth/25.png',
      'assets/images/male/mouth/26.png','assets/images/male/mouth/27.png','assets/images/male/mouth/28.png','assets/images/male/mouth/29.png','assets/images/male/mouth/30.png',
      'assets/images/male/mouth/31.png','assets/images/male/mouth/32.png','assets/images/male/mouth/33.png','assets/images/male/mouth/34.png','assets/images/male/mouth/35.png',
      'assets/images/male/mouth/36.png','assets/images/male/mouth/37.png','assets/images/male/mouth/38.png','assets/images/male/mouth/39.png','assets/images/male/mouth/40.png',
      'assets/images/male/mouth/41.png','assets/images/male/mouth/42.png','assets/images/male/mouth/43.png','assets/images/male/mouth/44.png','assets/images/male/mouth/45.png',
      'assets/images/male/mouth/46.png','assets/images/male/mouth/47.png','assets/images/male/mouth/48.png','assets/images/male/mouth/49.png','assets/images/male/mouth/50.png',
    ],
    'mandible': [
      'assets/images/male/jaw/1.png','assets/images/male/jaw/2.png','assets/images/male/jaw/3.png','assets/images/male/jaw/4.png','assets/images/male/jaw/5.png',
      'assets/images/male/jaw/6.png','assets/images/male/jaw/7.png','assets/images/male/jaw/8.png','assets/images/male/jaw/9.png','assets/images/male/jaw/10.png',
      'assets/images/male/jaw/11.png','assets/images/male/jaw/12.png','assets/images/male/jaw/13.png','assets/images/male/jaw/14.png','assets/images/male/jaw/15.png',
      'assets/images/male/jaw/16.png','assets/images/male/jaw/17.png','assets/images/male/jaw/18.png','assets/images/male/jaw/19.png','assets/images/male/jaw/20.png',
      'assets/images/male/jaw/21.png','assets/images/male/jaw/22.png','assets/images/male/jaw/23.png','assets/images/male/jaw/24.png','assets/images/male/jaw/25.png',
      'assets/images/male/jaw/26.png','assets/images/male/jaw/27.png','assets/images/male/jaw/28.png','assets/images/male/jaw/29.png','assets/images/male/jaw/30.png',
      'assets/images/male/jaw/31.png','assets/images/male/jaw/32.png','assets/images/male/jaw/33.png','assets/images/male/jaw/34.png','assets/images/male/jaw/35.png',
      'assets/images/male/jaw/36.png','assets/images/male/jaw/37.png','assets/images/male/jaw/38.png','assets/images/male/jaw/39.png','assets/images/male/jaw/40.png',
      'assets/images/male/jaw/41.png','assets/images/male/jaw/42.png','assets/images/male/jaw/43.png','assets/images/male/jaw/44.png','assets/images/male/jaw/45.png',
      'assets/images/male/jaw/46.png','assets/images/male/jaw/47.png','assets/images/male/jaw/48.png','assets/images/male/jaw/49.png','assets/images/male/jaw/50.png',
    ],
    'beard': [
      'assets/images/male/beard/1.png','assets/images/male/beard/2.png','assets/images/male/beard/3.png','assets/images/male/beard/4.png','assets/images/male/beard/5.png',
      'assets/images/male/beard/6.png','assets/images/male/beard/7.png','assets/images/male/beard/8.png','assets/images/male/beard/9.png','assets/images/male/beard/10.png',
      'assets/images/male/beard/11.png','assets/images/male/beard/12.png','assets/images/male/beard/13.png','assets/images/male/beard/14.png','assets/images/male/beard/15.png',
      'assets/images/male/beard/16.png','assets/images/male/beard/17.png','assets/images/male/beard/18.png','assets/images/male/beard/19.png','assets/images/male/beard/20.png',
      'assets/images/male/beard/21.png','assets/images/male/beard/22.png','assets/images/male/beard/23.png','assets/images/male/beard/24.png','assets/images/male/beard/25.png',
      'assets/images/male/beard/26.png','assets/images/male/beard/27.png','assets/images/male/beard/28.png','assets/images/male/beard/29.png','assets/images/male/beard/30.png',
      'assets/images/male/beard/31.png','assets/images/male/beard/32.png','assets/images/male/beard/33.png','assets/images/male/beard/34.png','assets/images/male/beard/35.png',
      'assets/images/male/beard/36.png','assets/images/male/beard/37.png','assets/images/male/beard/38.png','assets/images/male/beard/39.png','assets/images/male/beard/40.png',
      'assets/images/male/beard/41.png','assets/images/male/beard/42.png','assets/images/male/beard/43.png','assets/images/male/beard/44.png','assets/images/male/beard/45.png',
      'assets/images/male/beard/46.png','assets/images/male/beard/47.png','assets/images/male/beard/48.png','assets/images/male/beard/49.png','assets/images/male/beard/50.png',
      'assets/images/male/beard/51.png','assets/images/male/beard/52.png','assets/images/male/beard/53.png','assets/images/male/beard/54.png','assets/images/male/beard/55.png',
    ],
  };

  String selectedCategory = 'sincipit';

  // Store the initial position and scale for each part
  Map<String, AvatarPartState> partsState = {
    'sincipit': AvatarPartState(),
    'supercilium': AvatarPartState(),
    'oculus': AvatarPartState(),
    'hair': AvatarPartState(),
    'nasus': AvatarPartState(),
    'glasses': AvatarPartState(),
    'moustache': AvatarPartState(),
    'labium': AvatarPartState(),
    'mandible': AvatarPartState(),
    'beard': AvatarPartState(),
  };



  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: const Text('Sketch ( Male )', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Colors.white)),
        backgroundColor: Colors.grey.shade800,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: PopupMenuButton(position: PopupMenuPosition.under,
            color: Colors.grey[300],
            popUpAnimationStyle:  AnimationStyle(duration: Duration(milliseconds: 500)),itemBuilder: (context)=>[
              PopupMenuItem(
                onTap: resetToNewFace,
                child:Row(children: [
                           Icon(Icons.refresh,color: Colors.black,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("New Face",style: TextStyle(color: Colors.black),),
                  ),
                ]),

              ),
              PopupMenuItem(
                onTap: showNameDialog,
                child:Row(children: [
                           Icon(Icons.save,color: Colors.black,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Save Face",style: TextStyle(color: Colors.black),),
                  ),
                ]),

              ), PopupMenuItem(
                  onTap: () => showSavedFacesDialog(context),
                  child:  Row(children: [
                           Icon(Icons.folder_open,color: Colors.black,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Open Face",style: TextStyle(color: Colors.black),),
                  ),
                ]),

              ), PopupMenuItem(
                  onTap: _signOut,
                  child:Row(children: [
                           Icon(Icons.logout,color: Colors.black,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("SignOut",style: TextStyle(color: Colors.black),),
                  ),
                ]),

              ),
            ],child: Icon(Icons.menu_rounded,color: Colors.white,size: 30,),),
          )
        ],

    ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Stack(
                children: _buildAvatarParts(), // Build the stacked avatar parts
              ),
            ),
          ),
      // Zoom control slider
          // Zoom control slider
          // Zoom control slider
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Slider(
                  value: selectedCategory.isEmpty
                      ? zoomLevel // Global zoom level when no part is selected
                      : partsState[selectedCategory]!.size, // Zoom for selected part
                  min: 50.0, // Min zoom size
                  max: 200.0, // Max zoom size
                  divisions: 20,
                  activeColor: Colors.grey.shade800,// Number of divisions for zoom control
                  label: selectedCategory.isEmpty
                      ? zoomLevel.toStringAsFixed(1)
                      : partsState[selectedCategory]!.size.toStringAsFixed(1),
                  onChanged: (double value) {
                    setState(() {
                      if (selectedCategory.isNotEmpty) {
                        // If a part is selected, adjust that part's size
                        partsState[selectedCategory]!.size = value;
                      } else {
                        // Adjust global zoom if no part is selected
                        zoomLevel = value;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          _buildPartsSelectionBar(),
          _buildCategorySelector(),


        ],
      ),
    );
  }


  // Build all avatar parts with their positions and scaling
  List<Widget> _buildAvatarParts() {
    List<Widget> parts = [];
    for (String key in partOrder) {
      if (selectedParts[key]!.isNotEmpty) {
        AvatarPartState state = partsState[key]!;
        bool isEditable = selectedCategory == key;

        double minX = 0.0;
        double maxX = MediaQuery.of(context).size.width - state.size;
        double minY = 0.0;
        double maxY = MediaQuery.of(context).size.height - state.size;

        parts.add(
          Positioned(
            top: state.top,
            left: state.left,
            child: GestureDetector(
              onScaleUpdate: isEditable
                  ? (details) {
                setState(() {
                  double newSize = state.size * (1 + (details.scale - 1) * 0.05);
                  state.size = newSize.clamp(50.0, 200.0);

                  double newLeft = state.left + details.focalPointDelta.dx;
                  double newTop = state.top + details.focalPointDelta.dy;

                  state.left = newLeft.clamp(minX, maxX);
                  state.top = newTop.clamp(minY, maxY);
                });
              }
                  : null,
              child: Transform.scale(
                scale: state.size / 150,
                child: Image.asset(
                  selectedParts[key]!,
                  width: state.size,
                  height: state.size,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      }
    }
    return parts;
  }


  // Display the selection bar for parts based on selected category
  Widget _buildPartsSelectionBar() {
    List<String> filters = avatarParts[selectedCategory] ?? [];
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 130,
      color: Colors.grey[200],
      child: Row(
        children: [
          IconButton(
            onPressed: removeFilter,
            icon: Icon(Icons.refresh, size: 30),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:filters.asMap().entries.map((entry) {
    int index = entry.key + 1; // Numbering starts from 1
    String imagePath = entry.value;
                  return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedParts[selectedCategory] = imagePath;
                    _bringPartToTop(selectedCategory); // Bring the selected part to the top
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        color:Colors.grey[800],
                        width: 60,
                        height: 15,
                        child: Center(
                          child: Text(
                            '$index', // Show filter number
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Image.asset(
                          imagePath,
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ],
                  ),
                ),
              );})
                  .toList()
            )
          ),
        ],
      ),
    );
  }


  // Display the category selector to switch between different parts
  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: avatarParts.keys
            .map((category) => GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = category;
              _bringPartToTop(selectedCategory); // Bring the selected part to the top
            });

          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: selectedCategory == category
                  ? Colors.grey.shade800
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  color: selectedCategory == category
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }
}

class AvatarPartState {
  double top;
  double left;
  double size;

  AvatarPartState({
    this.top = 0.0,
    this.left = 0.0,
    this.size = 150.0,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'top': top,
      'left': left,
      'size': size,
    };
  }

  // Create from JSON
  factory AvatarPartState.fromJson(Map<String, dynamic> json) {
    return AvatarPartState(
      top: json['top'],
      left: json['left'],
      size: json['size'],
    );
  }
}




