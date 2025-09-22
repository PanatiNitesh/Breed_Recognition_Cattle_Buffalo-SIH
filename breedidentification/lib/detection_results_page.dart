import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'my_family_page.dart';
import 'animal_storage_service.dart';

class DetectionResultsPage extends StatefulWidget {
  final File imageFile;

  const DetectionResultsPage({super.key, required this.imageFile});

  @override
  State<DetectionResultsPage> createState() => _DetectionResultsPageState();
}

class _DetectionResultsPageState extends State<DetectionResultsPage> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _detectionResult;

  @override
  void initState() {
    super.initState();
    _uploadImageAndGetResults();
  }

  Future<void> _uploadImageAndGetResults() async {
    final uri = Uri.parse('https://ravindraog-breed-recognition-cattle-buffalo.hf.space/predict');
    try {
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', widget.imageFile.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          _detectionResult = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to get results. Status code: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: ${e.toString()}";
        _isLoading = false;
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(context, outlinedButtonStyle),
                      const SizedBox(height: 20),
                      _buildImageDisplay(context),
                      const SizedBox(height: 20),
                      _buildResultsSection(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButtons(outlinedButtonStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_isLoading) {
      return const Center(child: Column(children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Detecting breed, please wait...")],));
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center));
    }
    if (_detectionResult != null) {
      return _buildInfoSection(_detectionResult!);
    }
    return const Center(child: Text("No results found."));
  }

  Widget _buildTopBar(BuildContext context, ButtonStyle buttonStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(12)),
          child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyFamilyPage()),
            );
          },
          style: buttonStyle.copyWith(
            minimumSize: MaterialStateProperty.all(Size.zero),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
          child: const Text('Cattle Family'),
        ),
      ],
    );
  }

  Widget _buildImageDisplay(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(widget.imageFile, fit: BoxFit.cover)),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> results) {
    final family = results['family'] ?? 'N/A';
    final breed = results['predicted_breed'] ?? 'N/A';
    final confidence = results['confidence'] ?? 'N/A';
    final details = results['details'] as Map<String, dynamic>? ?? {};

    // Updated to match the new API response structure
    final aiSummary = details['ai_summary'] ?? 'No summary available.';
    final keyTraits = details['enhanced_traits'] ?? 'No key traits available.';
    final nutritionTip = details['improved_nutrition_plan'] ?? 'No nutrition tips available.';
    final managementTip = details['management_tip'] ?? 'No management tips available.';

    final suggestionsList = results['top_3_matches'] as List? ?? [];
    final suggestionsString = suggestionsList.isNotEmpty
        ? suggestionsList.map((match) => '${match['breed']} (${match['confidence']})').join('\n')
        : 'No suggestions available.';

    return Column(
      children: [
        _buildInfoCard('Family', family),
        _buildInfoCard('Breed Identified', '$breed ($confidence)'),
        _buildInfoCard('Top 3 Matches', suggestionsString),
        _buildInfoCard('Summary', aiSummary), // Added Summary
        _buildInfoCard('Key Traits', keyTraits), // Updated from 'traits' to 'enhanced_traits'
        _buildInfoCard('Nutrition Plan', nutritionTip), // Updated from 'nutrition' to 'improved_nutrition_plan'
        _buildInfoCard('Management Tip', managementTip), // Added Management Tip
      ],
    );
  }

  // --- THIS FUNCTION IS MODIFIED ---
  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity, // Ensure card takes full width
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column( // Changed from Row to Column
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), // Title (heading)
          const SizedBox(height: 4), // Small space between title and value
          Text(value, style: const TextStyle(fontSize: 15)), // Value (response) on a new line
        ],
      ),
    );
  }
  // --- END OF MODIFICATION ---


  Widget _buildActionButtons(ButtonStyle buttonStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: (_detectionResult == null) ? null : () async {
              await AnimalStorageService.addAnimal(widget.imageFile, _detectionResult!);
              
              if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved to your family!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyFamilyPage()),
                  (route) => false,
                );
              }
            },
            style: buttonStyle,
            child: const Text('Confirm/Add to family', textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: buttonStyle,
            child: const Text('Delete'),
          ),
        ),
      ],
    );
  }
}