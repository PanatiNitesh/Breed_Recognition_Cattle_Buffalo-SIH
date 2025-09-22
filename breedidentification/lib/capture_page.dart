import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'my_family_page.dart';        // Import the family page for navigation
import 'processing_page.dart';      // Import the processing page

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

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
    final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      minimumSize: const Size(150, 50),
      side: const BorderSide(color: Colors.black, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  OutlinedButton(
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyFamilyPage()),
                      );
                    },
                    style: outlinedButtonStyle.copyWith(
                      minimumSize: MaterialStateProperty.all(Size.zero),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    child: const Text('Cattle Family'),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Container(
                height: MediaQuery.of(context).size.height * 0.6,
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
                  borderRadius: BorderRadius.circular(20),
                  // --- THIS IS THE CHANGE ---
                  // It now shows your image asset when no file is selected.
                  child: _image == null
                      ? Image.asset(
                          'assets/images/calf_placeholder.png',
                          fit: BoxFit.cover,
                          // Optional: Add an error builder in case the asset fails to load
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                'Placeholder not found.',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        )
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              
              const Spacer(),
              OutlinedButton(
                onPressed: () => _getImage(ImageSource.gallery),
                style: outlinedButtonStyle.copyWith(
                  minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                ),
                child: const Text('Upload'),
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => _getImage(ImageSource.camera),
                    style: outlinedButtonStyle,
                    child: const Text('Capture'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      if (_image != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProcessingPage(imageFile: _image!),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please capture or upload an image first.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
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

