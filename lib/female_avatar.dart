import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';

class FemaleAvatar extends StatefulWidget {
  @override
  _FemaleAvatarState createState() => _FemaleAvatarState();
}

class _FemaleAvatarState extends State<FemaleAvatar> {
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
    List<String> savedFaces = prefs.getStringList('savedFaces1') ?? [];

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
    await prefs.setStringList('savedFaces1', savedFaces);
  }

  Future<List<Map<String, dynamic>>> loadSavedFaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedFaces = prefs.getStringList('savedFaces1') ?? [];

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
      List<String> savedFaces = prefs.getStringList('savedFaces1') ?? [];

      // Remove the face at the selected index
      savedFaces.removeAt(selectedFaceIndex!);

      // Save the updated list back to SharedPreferences
      await prefs.setStringList('savedFaces1', savedFaces);

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
        'hair': '',
        'hijab': '',
        'sincipit': '',
        'supercilium': '',
        'oculus': '',
        'nasus': '',
        'glasses': '',
        'labium': '',
        'mandible': '',
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
    'hair',
    'hijab',
    'sincipit',
    'supercilium',
    'oculus',
    'nasus',
    'glasses',
    'labium',
    'mandible',
  ];



  // Stores the selected parts of the avatar
  Map<String, String> selectedParts = {
    'hair': '',
    'hijab': '',
    'sincipit': '',
    'supercilium': '',
    'oculus': '',
    'nasus': '',
    'glasses': '',
    'labium': '',
    'mandible': '',
  };


  // Contains the available parts for each category
  final Map<String, List<String>> avatarParts = {

    'hair': [
      'assets/images/female/hair/1.png','assets/images/female/hair/2.png','assets/images/female/hair/3.png','assets/images/female/hair/4.png','assets/images/female/hair/5.png',
      'assets/images/female/hair/6.png','assets/images/female/hair/7.png','assets/images/female/hair/8.png','assets/images/female/hair/9.png','assets/images/female/hair/10.png',
      'assets/images/female/hair/11.png','assets/images/female/hair/12.png','assets/images/female/hair/13.png','assets/images/female/hair/14.png','assets/images/female/hair/15.png',
      'assets/images/female/hair/16.png','assets/images/female/hair/17.png','assets/images/female/hair/18.png','assets/images/female/hair/19.png','assets/images/female/hair/20.png',
      'assets/images/female/hair/21.png','assets/images/female/hair/22.png','assets/images/female/hair/23.png','assets/images/female/hair/24.png','assets/images/female/hair/25.png',
      'assets/images/female/hair/26.png','assets/images/female/hair/27.png','assets/images/female/hair/28.png','assets/images/female/hair/29.png','assets/images/female/hair/30.png',
      'assets/images/female/hair/31.png','assets/images/female/hair/32.png','assets/images/female/hair/33.png','assets/images/female/hair/34.png','assets/images/female/hair/35.png',
      'assets/images/female/hair/36.png','assets/images/female/hair/37.png','assets/images/female/hair/38.png','assets/images/female/hair/39.png',
    ],

    'hijab': [
      'assets/images/female/hijaab/1.png','assets/images/female/hijaab/2.png','assets/images/female/hijaab/3.png','assets/images/female/hijaab/4.png','assets/images/female/hijaab/5.png',
      'assets/images/female/hijaab/6.png','assets/images/female/hijaab/7.png','assets/images/female/hijaab/8.png','assets/images/female/hijaab/9.png',
    ],
    'sincipit': [
      'assets/images/female/head/1.png','assets/images/female/head/2.png','assets/images/female/head/3.png','assets/images/female/head/4.png','assets/images/female/head/5.png',
      'assets/images/female/head/6.png','assets/images/female/head/7.png','assets/images/female/head/8.png','assets/images/female/head/9.png','assets/images/female/head/10.png',
      'assets/images/female/head/11.png','assets/images/female/head/12.png','assets/images/female/head/13.png','assets/images/female/head/14.png','assets/images/female/head/15.png',
      'assets/images/female/head/16.png','assets/images/female/head/17.png','assets/images/female/head/18.png','assets/images/female/head/19.png','assets/images/female/head/20.png',
      'assets/images/female/head/21.png','assets/images/female/head/22.png','assets/images/female/head/23.png',
    ],
    'supercilium':  [
      'assets/images/female/eyebrows/1.png','assets/images/female/eyebrows/2.png','assets/images/female/eyebrows/3.png','assets/images/female/eyebrows/4.png','assets/images/female/eyebrows/5.png',
      'assets/images/female/eyebrows/6.png','assets/images/female/eyebrows/7.png','assets/images/female/eyebrows/8.png','assets/images/female/eyebrows/9.png','assets/images/female/eyebrows/10.png',
      'assets/images/female/eyebrows/11.png','assets/images/female/eyebrows/12.png','assets/images/female/eyebrows/13.png','assets/images/female/eyebrows/14.png','assets/images/female/eyebrows/15.png',
      'assets/images/female/eyebrows/16.png','assets/images/female/eyebrows/17.png','assets/images/female/eyebrows/18.png','assets/images/female/eyebrows/19.png','assets/images/female/eyebrows/20.png',
      'assets/images/female/eyebrows/21.png','assets/images/female/eyebrows/22.png','assets/images/female/eyebrows/23.png','assets/images/female/eyebrows/24.png','assets/images/female/eyebrows/25.png',
      'assets/images/female/eyebrows/26.png','assets/images/female/eyebrows/27.png','assets/images/female/eyebrows/28.png','assets/images/female/eyebrows/29.png','assets/images/female/eyebrows/30.png',
      'assets/images/female/eyebrows/31.png','assets/images/female/eyebrows/32.png','assets/images/female/eyebrows/33.png','assets/images/female/eyebrows/34.png','assets/images/female/eyebrows/35.png',
      'assets/images/female/eyebrows/36.png','assets/images/female/eyebrows/37.png','assets/images/female/eyebrows/38.png','assets/images/female/eyebrows/39.png','assets/images/female/eyebrows/40.png',
      'assets/images/female/eyebrows/41.png','assets/images/female/eyebrows/42.png','assets/images/female/eyebrows/43.png','assets/images/female/eyebrows/44.png','assets/images/female/eyebrows/45.png',
      'assets/images/female/eyebrows/46.png','assets/images/female/eyebrows/47.png','assets/images/female/eyebrows/48.png','assets/images/female/eyebrows/49.png','assets/images/female/eyebrows/50.png',

    ],
    'oculus':[
      'assets/images/female/eyes/1.png','assets/images/female/eyes/2.png','assets/images/female/eyes/3.png','assets/images/female/eyes/4.png','assets/images/female/eyes/5.png',
      'assets/images/female/eyes/6.png','assets/images/female/eyes/7.png','assets/images/female/eyes/8.png','assets/images/female/eyes/9.png','assets/images/female/eyes/10.png',
      'assets/images/female/eyes/11.png','assets/images/female/eyes/12.png','assets/images/female/eyes/13.png','assets/images/female/eyes/14.png','assets/images/female/eyes/15.png',
      'assets/images/female/eyes/16.png','assets/images/female/eyes/17.png','assets/images/female/eyes/18.png','assets/images/female/eyes/19.png','assets/images/female/eyes/20.png',
      'assets/images/female/eyes/21.png','assets/images/female/eyes/22.png','assets/images/female/eyes/23.png','assets/images/female/eyes/24.png','assets/images/female/eyes/25.png',
      'assets/images/female/eyes/26.png','assets/images/female/eyes/27.png','assets/images/female/eyes/28.png','assets/images/female/eyes/29.png','assets/images/female/eyes/30.png',
      'assets/images/female/eyes/31.png','assets/images/female/eyes/32.png','assets/images/female/eyes/33.png','assets/images/female/eyes/34.png','assets/images/female/eyes/35.png',
      'assets/images/female/eyes/36.png','assets/images/female/eyes/37.png','assets/images/female/eyes/38.png','assets/images/female/eyes/39.png','assets/images/female/eyes/40.png',
      'assets/images/female/eyes/41.png','assets/images/female/eyes/42.png','assets/images/female/eyes/43.png','assets/images/female/eyes/44.png','assets/images/female/eyes/45.png',
      'assets/images/female/eyes/46.png','assets/images/female/eyes/47.png','assets/images/female/eyes/48.png','assets/images/female/eyes/49.png','assets/images/female/eyes/50.png',
    ],


    'nasus': [
  'assets/images/female/nose/1.png','assets/images/female/nose/2.png','assets/images/female/nose/3.png','assets/images/female/nose/4.png','assets/images/female/nose/5.png',
  'assets/images/female/nose/6.png','assets/images/female/nose/7.png','assets/images/female/nose/8.png','assets/images/female/nose/9.png','assets/images/female/nose/10.png',
  'assets/images/female/nose/11.png','assets/images/female/nose/12.png','assets/images/female/nose/13.png','assets/images/female/nose/14.png','assets/images/female/nose/15.png',
  'assets/images/female/nose/16.png','assets/images/female/nose/17.png','assets/images/female/nose/18.png','assets/images/female/nose/19.png','assets/images/female/nose/20.png',
  'assets/images/female/nose/21.png','assets/images/female/nose/22.png','assets/images/female/nose/23.png','assets/images/female/nose/24.png','assets/images/female/nose/25.png',
  'assets/images/female/nose/26.png','assets/images/female/nose/27.png','assets/images/female/nose/28.png','assets/images/female/nose/29.png','assets/images/female/nose/30.png',
  'assets/images/female/nose/31.png','assets/images/female/nose/32.png','assets/images/female/nose/33.png','assets/images/female/nose/34.png','assets/images/female/nose/35.png',
  'assets/images/female/nose/36.png','assets/images/female/nose/37.png','assets/images/female/nose/38.png','assets/images/female/nose/39.png','assets/images/female/nose/40.png',
  'assets/images/female/nose/41.png','assets/images/female/nose/42.png','assets/images/female/nose/43.png','assets/images/female/nose/44.png','assets/images/female/nose/45.png',
  'assets/images/female/nose/46.png','assets/images/female/nose/47.png','assets/images/female/nose/48.png','assets/images/female/nose/49.png','assets/images/female/nose/50.png',
  ],
    'glasses': [
  'assets/images/female/glasses/1.png','assets/images/female/glasses/2.png','assets/images/female/glasses/3.png','assets/images/female/glasses/4.png','assets/images/female/glasses/5.png',
  'assets/images/female/glasses/6.png','assets/images/female/glasses/7.png','assets/images/female/glasses/8.png','assets/images/female/glasses/9.png','assets/images/female/glasses/10.png',
  'assets/images/female/glasses/11.png','assets/images/female/glasses/12.png','assets/images/female/glasses/13.png','assets/images/female/glasses/14.png','assets/images/female/glasses/15.png',
  'assets/images/female/glasses/16.png','assets/images/female/glasses/17.png','assets/images/female/glasses/18.png','assets/images/female/glasses/19.png','assets/images/female/glasses/20.png',
  'assets/images/female/glasses/21.png','assets/images/female/glasses/22.png','assets/images/female/glasses/23.png','assets/images/female/glasses/24.png','assets/images/female/glasses/25.png',
  'assets/images/female/glasses/26.png','assets/images/female/glasses/27.png','assets/images/female/glasses/28.png','assets/images/female/glasses/29.png','assets/images/female/glasses/30.png',
  'assets/images/female/glasses/31.png','assets/images/female/glasses/32.png','assets/images/female/glasses/33.png','assets/images/female/glasses/34.png',
  ],

    'labium':[
  'assets/images/female/mouth/1.png','assets/images/female/mouth/2.png','assets/images/female/mouth/3.png','assets/images/female/mouth/4.png','assets/images/female/mouth/5.png',
  'assets/images/female/mouth/6.png','assets/images/female/mouth/7.png','assets/images/female/mouth/8.png','assets/images/female/mouth/9.png','assets/images/female/mouth/10.png',
  'assets/images/female/mouth/11.png','assets/images/female/mouth/12.png','assets/images/female/mouth/13.png','assets/images/female/mouth/14.png','assets/images/female/mouth/15.png',
  'assets/images/female/mouth/16.png','assets/images/female/mouth/17.png','assets/images/female/mouth/18.png','assets/images/female/mouth/19.png','assets/images/female/mouth/20.png',
  'assets/images/female/mouth/21.png','assets/images/female/mouth/22.png','assets/images/female/mouth/23.png','assets/images/female/mouth/24.png','assets/images/female/mouth/25.png',
  'assets/images/female/mouth/26.png','assets/images/female/mouth/27.png','assets/images/female/mouth/28.png','assets/images/female/mouth/29.png','assets/images/female/mouth/30.png',
  'assets/images/female/mouth/31.png','assets/images/female/mouth/32.png','assets/images/female/mouth/33.png','assets/images/female/mouth/34.png','assets/images/female/mouth/35.png',
  'assets/images/female/mouth/36.png','assets/images/female/mouth/37.png','assets/images/female/mouth/38.png','assets/images/female/mouth/39.png','assets/images/female/mouth/40.png',
  'assets/images/female/mouth/41.png','assets/images/female/mouth/42.png','assets/images/female/mouth/43.png','assets/images/female/mouth/44.png','assets/images/female/mouth/45.png',
  'assets/images/female/mouth/46.png','assets/images/female/mouth/47.png','assets/images/female/mouth/48.png','assets/images/female/mouth/49.png','assets/images/female/mouth/50.png',
  ],
    'mandible': [
  'assets/images/female/jaw/1.png','assets/images/female/jaw/2.png','assets/images/female/jaw/3.png','assets/images/female/jaw/4.png','assets/images/female/jaw/5.png',
  'assets/images/female/jaw/6.png','assets/images/female/jaw/7.png','assets/images/female/jaw/8.png','assets/images/female/jaw/9.png','assets/images/female/jaw/10.png',
  'assets/images/female/jaw/11.png','assets/images/female/jaw/12.png','assets/images/female/jaw/13.png','assets/images/female/jaw/14.png','assets/images/female/jaw/15.png',
  'assets/images/female/jaw/16.png','assets/images/female/jaw/17.png','assets/images/female/jaw/18.png','assets/images/female/jaw/19.png','assets/images/female/jaw/20.png',
  'assets/images/female/jaw/21.png','assets/images/female/jaw/22.png','assets/images/female/jaw/23.png','assets/images/female/jaw/24.png','assets/images/female/jaw/25.png',
  'assets/images/female/jaw/26.png','assets/images/female/jaw/27.png','assets/images/female/jaw/28.png','assets/images/female/jaw/29.png','assets/images/female/jaw/30.png',
  'assets/images/female/jaw/31.png','assets/images/female/jaw/32.png','assets/images/female/jaw/33.png','assets/images/female/jaw/34.png','assets/images/female/jaw/35.png',
  'assets/images/female/jaw/36.png','assets/images/female/jaw/37.png','assets/images/female/jaw/38.png','assets/images/female/jaw/39.png','assets/images/female/jaw/40.png',
  'assets/images/female/jaw/41.png','assets/images/female/jaw/42.png','assets/images/female/jaw/43.png','assets/images/female/jaw/44.png','assets/images/female/jaw/45.png',
  'assets/images/female/jaw/46.png','assets/images/female/jaw/47.png','assets/images/female/jaw/48.png','assets/images/female/jaw/49.png','assets/images/female/jaw/50.png',
  ],
  };

  String selectedCategory = 'hair';

  // Store the initial position and scale for each part
  Map<String, AvatarPartState> partsState = {
    'hair': AvatarPartState(),
    'hijab': AvatarPartState(),
    'sincipit': AvatarPartState(),
    'supercilium': AvatarPartState(),
    'oculus': AvatarPartState(),
    'nasus': AvatarPartState(),
    'glasses': AvatarPartState(),
    'labium': AvatarPartState(),
    'mandible': AvatarPartState(),
  };



  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: const Text('Sketch ( Female )', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Colors.white)),
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
                  .toList(),
            ),
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




