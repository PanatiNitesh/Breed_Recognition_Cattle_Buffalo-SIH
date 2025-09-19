import 'dart:io'; // Required for handling File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Required for camera/gallery
import 'processing_page.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  // This variable will hold the image file after picking
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // This function handles picking an image from gallery or camera
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This defines the style for your buttons to look consistent
    final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      minimumSize: const Size(150, 50), // Set a good size
      side: const BorderSide(color: Colors.black, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0), // Makes it rounded
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // --- Top Bar (Back Arrow & "Cattle Family") ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // "Cattle Family" Button
                  OutlinedButton(
                    onPressed: () {},
                    style: outlinedButtonStyle.copyWith(
                      // FIXED: Use WidgetStateProperty
                      minimumSize: WidgetStateProperty.all(Size.zero),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    child: const Text('Cattle Family'),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- Image Container ---
              // --- Image Container ---
              Container(
                height:
                   MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(128),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // This should match the Container
                  // This is your code snippet
                  child:
                      _image == null
                          ? Image.asset(
                            'assets/images/calf_placeholder.png',
                            fit: BoxFit.cover,
                          )
                          : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              
              const Spacer(), // Pushes buttons to the bottom
              // --- Bottom Buttons ---
              // "Upload" Button
              OutlinedButton(
                onPressed:
                    () => _getImage(ImageSource.gallery), // Opens Gallery
                style: outlinedButtonStyle.copyWith(
                  // FIXED: Use WidgetStateProperty
                  minimumSize: WidgetStateProperty.all(
                    const Size(double.infinity, 50),
                  ),
                ),
                child: const Text('Upload'),
              ),
              const SizedBox(height: 15),

              // "Capture" and "Detect" Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed:
                        () => _getImage(ImageSource.camera), // Opens Camera
                    style: outlinedButtonStyle,
                    child: const Text('Capture'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // First, check if an image is actually selected
                      if (_image != null) {
                        // If yes, push to the new processing page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProcessingPage(imageFile: _image!),
                          ),
                        );
                      } else {
                        // If no image, show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please capture or upload an image first.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }, // <-- End of onPressed
                    style: outlinedButtonStyle.copyWith(
                      // FIXED: Wrap colors in WidgetStateProperty.all()
                      backgroundColor: WidgetStateProperty.all(Colors.black),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    child: const Text('Detect'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
