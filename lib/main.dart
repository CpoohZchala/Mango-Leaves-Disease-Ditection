import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

import 'dart:developer' as devtools;

void main() {
  runApp(const MyApp());
}

// Root of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Mango Disease Detection App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

// Home page of the application
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? filePath; // File to store the image path
  String? resultLabel; // Label to store the result from model
  double? accuracy; // Accuracy of the prediction

  // Method to load the TFLite model
  Future<void> _tfLiteInit() async {
    String? res = await Tflite.loadModel(
      model: "assets/model_unquant.tflite", // Path to the TFLite model
      labels: "assets/labels.txt", // Path to the labels file
      numThreads: 1, // Number of threads to use
      isAsset: true, // Whether the model is an asset
      useGpuDelegate: false, // Use GPU for computation
    );
    if (res == null) {
      devtools.log("Failed to load model");
    } else {
      devtools.log("Model loaded: $res");
    }
  }

  // Method to pick an image from the Camera
  Future<void> pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;
    var imageFile = File(image.path);

    setState(() {
      filePath = imageFile;
    });

    // Run the TFLite model on the selected image
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );

    if (recognitions == null) {
      devtools.log("recognitions is Null");
      return;
    }

    devtools.log(recognitions.toString());

    // Set the result label and accuracy from the recognitions
    if (recognitions.isNotEmpty) {
      setState(() {
        resultLabel = recognitions[0]['label'];
        accuracy = recognitions[0]['confidence'];
      });
    }
  }

  // Method to pick an image from the gallery
  Future<void> pickImagegallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    var imageFile = File(image.path);

    setState(() {
      filePath = imageFile;
    });

    // Run the TFLite model on the selected image
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );

    if (recognitions == null) {
      devtools.log("recognitions is Null");
      return;
    }

    devtools.log(recognitions.toString());

    // Set the result label and accuracy from the recognitions
    if (recognitions.isNotEmpty) {
      setState(() {
        resultLabel = recognitions[0]['label'];
        accuracy = recognitions[0]['confidence'];
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close(); // Close the TFLite model when the widget is disposed
  }

  @override
  void initState() {
    super.initState();
    _tfLiteInit(); // Initialize the TFLite model when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 186, 239, 191),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 8, 59, 13),
        title: const Text(
          "Mango Disease Detection",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Card(
                color: Color.fromARGB(
                    255, 222, 223, 218), // Background color of the card itself
                elevation: 20,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      Container(
                        height: 280,
                        width: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          image: filePath == null
                              ? const DecorationImage(
                                  image: AssetImage('assets/Image_Upload.png'),
                                )
                              : null,
                        ),
                        // Display the selected image or a placeholder
                        child: filePath == null
                            ? const Text('')
                            : Image.file(filePath!, fit: BoxFit.fill),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            // Display the result label
                            Text(
                              resultLabel ?? "Label",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            // Display the accuracy of the prediction
                            Text(
                              accuracy != null
                                  ? "The Accuracy is ${(accuracy! * 100).toStringAsFixed(2)}%"
                                  : "The Accuracy is 0%",
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  pickImageCamera();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 9, 40, 3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ), // Text color of the button
                ),
                child: const Text("Take a Photo"), // Button to take a photo
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  pickImagegallery(); // Call method to pick an image from the gallery
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ), // Text color of the button
                ),
                child: const Text(
                    "Pick from Gallery"), // Button to pick from the gallery
              ),
            ],
          ),
        ),
      ),
    );
  }
}
