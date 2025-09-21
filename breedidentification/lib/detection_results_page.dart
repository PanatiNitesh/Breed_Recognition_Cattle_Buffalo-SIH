import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import the new page you are creating
import 'my_family_page.dart'; 

// Note: To use the 'http' package, you must add it to your pubspec.yaml file:
// dependencies:
//   flutter:
//     sdk: flutter
//   http: ^1.2.1 // or the latest version

class DetectionResultsPage extends StatefulWidget {
  final File imageFile;

  const DetectionResultsPage({super.key, required this.imageFile});

  @override
  State<DetectionResultsPage> createState() => _DetectionResultsPageState();
}

class _DetectionResultsPageState extends State<DetectionResultsPage> {
  // State variables to manage API call status and results
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _detectionResult;

  @override
  void initState() {
    super.initState();
    // Trigger the API call when the page loads
    _uploadImageAndGetResults();
  }

  /// Sends the image to the prediction API and updates the state with the result.
  Future<void> _uploadImageAndGetResults() async {
    // API endpoint URL
    final uri = Uri.parse('https://ravindraog-breed-recognition-cattle-buffalo.hf.space/predict');

    try {
      // Create a multipart request to send the image file
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // The parameter name for the file, as specified
          widget.imageFile.path,
        ),
      );

      // Send the request and wait for the response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON.
        final responseBody = json.decode(response.body);
        setState(() {
          _detectionResult = responseBody;
          _isLoading = false;
        });
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        setState(() {
          _errorMessage = "Failed to get results. Status code: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      // Catch any errors during the API call
      setState(() {
        _errorMessage = "An error occurred: ${e.toString()}";
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Reusable style for the bottom buttons to keep the code clean
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
        // Use SingleChildScrollView to prevent bottom overflow when keyboard appears or content is too long
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Top Bar (Back Arrow & "Cattle Family") ---
                _buildTopBar(context, outlinedButtonStyle),
                const SizedBox(height: 20),

                // --- Image Display ---
                _buildImageDisplay(context),
                const SizedBox(height: 20),

                // --- Information Section (handles loading, error, and success states) ---
                _buildResultsSection(),
                const SizedBox(height: 20),


                // --- Bottom Action Buttons ---
                _buildActionButtons(outlinedButtonStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main content area, showing a loader, error message, or the detection results.
  Widget _buildResultsSection() {
    if (_isLoading) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Detecting breed, please wait..."),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_detectionResult != null) {
      return _buildInfoSection(_detectionResult!);
    }

    return const Center(child: Text("No results found."));
  }


  // Helper widget for the top bar
  Widget _buildTopBar(BuildContext context, ButtonStyle buttonStyle) {
    return Row(
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
          onPressed: () {},
          style: buttonStyle.copyWith(
            minimumSize: MaterialStateProperty.all(Size.zero),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          child: const Text('Cattle Family'),
        ),
      ],
    );
  }

  // Helper widget for the captured image
  Widget _buildImageDisplay(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(widget.imageFile, fit: BoxFit.cover),
      ),
    );
  }

  // Helper widget for the info cards, now populated with API data
  Widget _buildInfoSection(Map<String, dynamic> results) {
    // Safely get data from the results map according to the new structure
    final family = results['family'] ?? 'N/A';
    final breed = results['predicted_breed'] ?? 'N/A';
    final confidence = results['confidence'] ?? 'N/A';
    
    // Nested details object
    final details = results['details'] as Map<String, dynamic>? ?? {};
    final keyTraits = details['traits'] ?? 'No key traits available.';
    final nutritionTip = details['nutrition'] ?? 'No nutrition tips available.';

    // List of maps for top matches
    final suggestionsList = results['top_3_matches'] as List? ?? [];
    
    // Format the suggestions list into a readable string
    final suggestionsString = suggestionsList.isNotEmpty
        ? suggestionsList.map((match) {
            final matchBreed = match['breed'] ?? 'Unknown';
            final matchConfidence = match['confidence'] ?? 'N/A';
            return '$matchBreed ($matchConfidence)';
          }).join('\n')
        : 'No suggestions available.';

    return Column(
      children: [
        _buildInfoCard('Family', family),
        _buildInfoCard('Breed Identified', '$breed ($confidence)'),
        _buildInfoCard('Top 3 Matches', suggestionsString),
        _buildInfoCard('Key Traits', keyTraits),
        _buildInfoCard('Nutrition Tip', nutritionTip),
      ],
    );
  }

  // Reusable widget for each information row
  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the bottom buttons
  Widget _buildActionButtons(ButtonStyle buttonStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // --- THIS IS THE CHANGE ---
              // Navigate to the new page, removing all pages behind it
              // so 'back' goes to the app's root (home/capture page).
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyFamilyPage()),
                (route) => route.isFirst, // Removes all routes until the first one
              );
            },
            style: buttonStyle,
            child: const Text('Confirm/Add to family', textAlign: TextAlign.center,),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // --- THIS IS THE CHANGE ---
              // Close this page and go back to the previous one (capture page).
              Navigator.pop(context);
            },
            style: buttonStyle,
            child: const Text('Delete'),
          ),
        ),
      ],
    );
  }
}