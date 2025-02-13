import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';

class Avatar extends StatefulWidget {
  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
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
        'head': '',
        'eyebrows': '',
        'eyes': '',
        'hair': '',
        'nose': '',
        'glasses': '',
        'moustache': '',
        'mouth': '',
        'jaw': '',
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
    'head',
    'eyebrows',
    'eyes',
    'hair',
    'nose',
    'glasses',
    'moustache',
    'mouth',
    'jaw',
    'beard',
  ];



  // Stores the selected parts of the avatar
  Map<String, String> selectedParts = {
    'head': '',
    'eyebrows': '',
    'eyes': '',
    'hair': '',
    'nose': '',
    'glasses': '',
    'moustache': '',
    'mouth': '',
    'jaw': '',
    'beard': '',
  };


  // Contains the available parts for each category
  final Map<String, List<String>> avatarParts = {
    'head': [
      'assets/images/head/1.png', 'assets/images/head/2.png',
      'assets/images/head/3.png', 'assets/images/head/3.png', 'assets/images/head/4.png',
      'assets/images/head/5.png', 'assets/images/head/6.png', 'assets/images/head/7.png',
    ],
    'eyebrows': [
      'assets/images/eyebrows/1.png', 'assets/images/eyebrows/2.png',
      'assets/images/eyebrows/3.png', 'assets/images/eyebrows/4.png', 'assets/images/eyebrows/5.png',
      'assets/images/eyebrows/6.png', 'assets/images/eyebrows/7.png', 'assets/images/eyebrows/8.png',
    ],
    'eyes': [
      'assets/images/eyes/1.png', 'assets/images/eyes/2.png',
      'assets/images/eyes/3.png', 'assets/images/eyes/4.png', 'assets/images/eyes/5.png',
      'assets/images/eyes/6.png', 'assets/images/eyes/7.png', 'assets/images/eyes/8.png',
    ],
    'hair': [
      'assets/images/hair/1.png', 'assets/images/hair/2.png',
      'assets/images/hair/3.png', 'assets/images/hair/4.png', 'assets/images/hair/5.png',
      'assets/images/hair/6.png', 'assets/images/hair/7.png', 'assets/images/hair/8.png',
    ],
    'nose': [
     'assets/images/nose/1.png', 'assets/images/nose/2.png',
      'assets/images/nose/3.png', 'assets/images/nose/4.png', 'assets/images/nose/5.png',
      'assets/images/nose/6.png', 'assets/images/nose/7.png', 'assets/images/nose/8.png',
    ],
    'glasses': [
      'assets/images/glasses/1.png', 'assets/images/glasses/2.png',
      'assets/images/glasses/3.png', 'assets/images/glasses/4.png', 'assets/images/glasses/5.png',
      'assets/images/glasses/6.png', 'assets/images/glasses/7.png', 'assets/images/glasses/8.png',
    ],
    'moustache': [
      'assets/images/moustache/1.png', 'assets/images/moustache/2.png',
      'assets/images/moustache/3.png', 'assets/images/moustache/4.png', 'assets/images/moustache/5.png',
      'assets/images/moustache/6.png', 'assets/images/moustache/7.png', 'assets/images/moustache/8.png',
    ],
    'mouth': [
      'assets/images/mouth/1.png', 'assets/images/mouth/2.png',
      'assets/images/mouth/3.png', 'assets/images/mouth/4.png', 'assets/images/mouth/5.png',
      'assets/images/mouth/6.png', 'assets/images/mouth/7.png', 'assets/images/mouth/8.png',
    ],
    'jaw': [
      'assets/images/jaw/1.png', 'assets/images/jaw/2.png',
      'assets/images/jaw/3.png', 'assets/images/jaw/4.png', 'assets/images/jaw/5.png',
      'assets/images/jaw/6.png', 'assets/images/jaw/7.png', 'assets/images/jaw/8.png',
    ],
    'beard': [
      'assets/images/beard/1.png', 'assets/images/beard/2.png',
      'assets/images/beard/3.png', 'assets/images/beard/4.png', 'assets/images/beard/5.png',
      'assets/images/beard/6.png', 'assets/images/beard/7.png', 'assets/images/beard/8.png',
    ],
  };

  String selectedCategory = 'head';

  // Store the initial position and scale for each part
  Map<String, AvatarPartState> partsState = {
    'head': AvatarPartState(),
    'eyebrows': AvatarPartState(),
    'eyes': AvatarPartState(),
    'hair': AvatarPartState(),
    'nose': AvatarPartState(),
    'glasses': AvatarPartState(),
    'moustache': AvatarPartState(),
    'mouth': AvatarPartState(),
    'jaw': AvatarPartState(),
    'beard': AvatarPartState(),
  };



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: const Text('Sketch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Colors.white)),
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
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 100,
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
              children: avatarParts[selectedCategory]!
                  .map((imagePath) => GestureDetector(
                onTap: () {
                  setState(() {
                    selectedParts[selectedCategory] = imagePath;
                    _bringPartToTop(selectedCategory); // Bring the selected part to the top
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    imagePath,
                    width: 80,
                    height: 80,
                  ),
                ),
              ))
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




