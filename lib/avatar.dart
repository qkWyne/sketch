import 'dart:math';

import 'package:flutter/material.dart';

class Avatar extends StatefulWidget {
  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {

  // Stores the selected parts of the avatar
  Map<String, String> selectedParts = {
    'hair': '',
    'head': '',
    'eyebrows': '',
    'glasses': '',
    'eyes': '',
    'nose': '',
    'moustache': '',
    'mouth': '',
    'jaw': '',
    'beard': '',
  };

  // Contains the available parts for each category
  final Map<String, List<String>> avatarParts = {
    'hair': [
      'assets/images/2.png',
      'assets/images/hair1.png',
      'assets/images/hair2.png',
      'assets/images/hair3.png',
      'assets/images/hair4.png',
      'assets/images/hair5.png',
      'assets/images/hair6.png',
      'assets/images/hair7.png',
      'assets/images/hair8.png',
      'assets/images/hair9.png',
      'assets/images/hair10.png',
      'assets/images/hair11.png',
      'assets/images/hair12.png',
      'assets/images/hair13.png',
      'assets/images/hair14.png',

    ],
    'head': [
      'assets/images/af-signup.png',
      'assets/images/af-login.png',
    ],
    'eyebrows': [
      'assets/images/af-signup.png',
      'assets/images/af-login.png',
    ],
    'glasses': [
      'assets/images/glasses1.png',
      'assets/images/glasses2.png',
      'assets/images/glasses3.png',
      'assets/images/glasses4.png',
      'assets/images/glasses5.png',
      'assets/images/glasses6.png',
      'assets/images/glasses7.png',
      'assets/images/glasses8.png',
      'assets/images/glasses9.png',
      'assets/images/glasses10.png',
      'assets/images/glasses11.png',

    ],
    'eyes': [
      'assets/images/1.png',
      'assets/images/af-signup.png',
    ],
    'nose': [
      'assets/images/af-signup.png',
      'assets/images/af-login.png',
    ],
    'moustache': [
      'assets/images/mouch1.png',
      'assets/images/mouch2.png',
      'assets/images/mouch3.png',
      'assets/images/mouch4.png',
      'assets/images/mouch5.png',
      'assets/images/mouch6.png',
      'assets/images/mouch7.png',
      'assets/images/mouch8.png',
      'assets/images/mouch9.png',
    ],
    'mouth': [
      'assets/images/af-signup.png',
      'assets/images/af-login.png',
    ],
    'jaw': [
      'assets/images/af-signup.png',
      'assets/images/af-login.png',
    ],
    'beard': [
      'assets/images/3.png',
      'assets/images/beard1.png',
      'assets/images/beard2.png',
      'assets/images/beard3.png',
      'assets/images/beard4.png',
      'assets/images/beard5.png',
      'assets/images/beard6.png',
      'assets/images/beard7.png',
      'assets/images/beard8.png',
      'assets/images/beard9.png',
      'assets/images/beard10.png',
      'assets/images/beard11.png',
      'assets/images/beard12.png',
    ],
  };

  String selectedCategory = 'hair';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sketch',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.white),),
        backgroundColor: Colors.deepOrange,
        toolbarHeight: 60,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                selectedParts.clear(); // Clear selected parts
              });
            },
            icon: const Icon(Icons.refresh,color: Colors.white,),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
      child:Stack(

                children: _buildAvatarParts(), // Build the stacked avatar parts
              ),
            ),
          ),
          _buildPartsSelectionBar(),
          _buildCategorySelector(),
        ]
      ),
    );
  }
  Map<String, Map<String, dynamic>> partsState = {
    'hair': {'top': 120.0, 'left': 102.0, 'size': 150.0},
    'head': {'top': 120.0, 'left': 102.0, 'size': 150.0},
    'eyebrows': {'top': 120.0, 'left': 102.0, 'size': 150.0},
    'glasses': {'top': 120.0, 'left': 102.0, 'size': 150.0},
    'eyes': {'top': 120.0, 'left': 102.0, 'size': 150.0},
    'nose': {'top': 120.0, 'left': 102.0, 'size': 150.0},
    'moustache': {'top': 120.0, 'left': 102.0, 'size': 150.0},
    'mouth': {'top': 120.0, 'left': 102.0, 'size': 150.0},
    'jaw': {'top': 120.0, 'left': 102.0, 'size': 150.0},
    'beard': {'top': 120.0, 'left': 102.0, 'size': 150.0},
    // Add other parts similarly...
  };

  List<Widget> _buildAvatarParts() {
    List<Widget> parts = [];

    selectedParts.forEach((key, value) {
      if (value.isNotEmpty) {
        parts.add(Positioned(
          top: partsState[key]!['top'],
          left: partsState[key]!['left'],
          child: GestureDetector(
            onScaleUpdate: (details) {
              setState(() {
                // Drag movement
                partsState[key]!['left'] += details.focalPointDelta.dx;
                partsState[key]!['top'] += details.focalPointDelta.dy;

                // Smooth Resize: Scale factor ko controlled pace pe adjust karna
                double newSize = partsState[key]!['size'] * (1 + (details.scale - 1) * 0.1);
                partsState[key]!['size'] = newSize.clamp(100.0, 200.0); // Min/Max restriction
              });
            },
            child: Transform.scale(
              scale: partsState[key]!['size'] / 150, // Normalize scale factor
              child:   Image.asset(
              value,
              width: partsState[key]!['size'],
              height: partsState[key]!['size'],
              fit: BoxFit.contain,
            ),
          ),
          ),
        ));
      }
    });

    return parts;
  }
  // Display the selection bar for parts based on selected category
  Widget _buildPartsSelectionBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 100,
      color: Colors.grey[200],
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: avatarParts[selectedCategory]!
            .map((imagePath) => GestureDetector(
          onTap: () {
            setState(() {
              selectedParts[selectedCategory] = imagePath;
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
            });
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: selectedCategory == category
                  ? Colors.deepOrange
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
