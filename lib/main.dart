// Import Dart IO to handle local files (like images)
import 'dart:io';

// Flutter core imports
import 'package:flutter/material.dart';

// Image Picker to pick image from gallery or camera
import 'package:image_picker/image_picker.dart';

// Firebase Core to initialize Firebase
import 'package:firebase_core/firebase_core.dart';

// ML Kit package for text recognition (OCR)
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Entry point of the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures all bindings are initialized before Firebase
  await Firebase.initializeApp(); // Initializes Firebase services
  runApp(MyApp()); // Runs the Flutter app
}

// Root widget of the app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Kit OCR', // App title
      theme: ThemeData(primarySwatch: Colors.teal), // Sets app theme color
      home: TextScannerPage(), // Sets home screen of the app
      debugShowCheckedModeBanner: false, // Hides the debug banner
    );
  }
}

// Stateful widget to manage image, scanning, and results
class TextScannerPage extends StatefulWidget {
  @override
  _TextScannerPageState createState() => _TextScannerPageState();
}

class _TextScannerPageState extends State<TextScannerPage> {
  File? _image; // Stores the selected image
  String _scannedText = 'Text will appear here...'; // Stores the recognized text
  bool _isScanning = false; // Flag to show loading indicator

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker(); // Creates image picker instance
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Opens gallery to pick an image

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Save picked image to _image
        _scannedText = 'Scanning...'; // Show scanning message
        _isScanning = true; // Show loading indicator
      });
      _detectText(pickedFile.path); // Call OCR function
    }
  }

  // Function to recognize text from image using ML Kit
  Future<void> _detectText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath); // Convert image path to InputImage
    final textRecognizer = TextRecognizer(); // Create ML Kit TextRecognizer instance

    try {
      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage); // Perform OCR on the image

      setState(() {
        _scannedText = recognizedText.text; // Save recognized text
        _isScanning = false; // Hide loading indicator
      });
    } catch (e) {
      setState(() {
        _scannedText = 'Failed to recognize text: $e'; // Show error message
        _isScanning = false; // Hide loading indicator
      });
    }
  }

  // Builds the UI of the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Text Recognition')), // App bar with title
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage, // Calls image picker
              child: Text('Pick Image & Scan Text'), // Button label
            ),
            SizedBox(height: 20), // Spacing
            if (_image != null)
              Image.file(_image!, height: 200), // Shows selected image
            SizedBox(height: 20), // Spacing
            _isScanning
                ? CircularProgressIndicator() // Shows loading if scanning
                : Text(
              _scannedText, // Displays recognized text
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
