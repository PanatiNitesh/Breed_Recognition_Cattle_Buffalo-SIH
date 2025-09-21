import 'dart:io'; // Required for handling File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Required for camera/gallery
import 'detection_results_page.dart'; // Import the new results page

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
                      minimumSize: MaterialStateProperty.all(Size.zero),
                      padding: MaterialStateProperty.all(
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
                  
                  // --- THIS IS THE FIX ---
                  // We check if _image is null.
                  // If it is, we show a placeholder. Otherwise, we show the image file.
                  child: _image == null
                      
                      // **FIXED WIDGET:** This placeholder won't crash if assets aren't configured.
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              size: 80,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Capture or Upload an Image',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        )
                      
                      // This part is correct and only runs when _image is not null.
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
                  minimumSize: MaterialStateProperty.all(
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
                        // If yes, push to the new detection results page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetectionResultsPage(imageFile: _image!),
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
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
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
