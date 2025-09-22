import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

// --- Data Model ---
// Represents a single animal record that we will save.
class AnimalRecord {
  final String imagePath; // Local path to the saved image
  final String family;
  final String breed;
  final String confidence;
  final List<String> topMatches;

  AnimalRecord({
    required this.imagePath,
    required this.family,
    required this.breed,
    required this.confidence,
    required this.topMatches,
  });

  // Convert an AnimalRecord instance to a JSON map
  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'family': family,
        'breed': breed,
        'confidence': confidence,
        'topMatches': topMatches,
      };

  // Create an AnimalRecord instance from a JSON map
  factory AnimalRecord.fromJson(Map<String, dynamic> json) {
    return AnimalRecord(
      imagePath: json['imagePath'],
      family: json['family'],
      breed: json['breed'],
      confidence: json['confidence'],
      // Ensure topMatches is correctly parsed as a list of strings
      topMatches: List<String>.from(json['topMatches']),
    );
  }
}

// --- Service Class ---
// Handles all logic for saving, loading, and deleting records.
class AnimalStorageService {
  static const _key = 'animalFamily'; // Key for storing the list in SharedPreferences

  // Save a new animal record to the list
  static Future<void> addAnimal(File imageFile, Map<String, dynamic> detectionResult) async {
    // 1. Copy the image from its temporary path to a permanent app directory
    final String savedImagePath = await _saveImagePermanently(imageFile);

    // 2. Create a new AnimalRecord object from the API results and the new image path
    final newRecord = AnimalRecord(
      imagePath: savedImagePath,
      family: detectionResult['family'] ?? 'N/A',
      breed: detectionResult['predicted_breed'] ?? 'N/A',
      confidence: detectionResult['confidence'] ?? 'N/A',
      // Convert the 'top_3_matches' list into a simple list of strings
      topMatches: (detectionResult['top_3_matches'] as List<dynamic>? ?? [])
          .map((match) => "${match['breed']} (${match['confidence']})")
          .toList(),
    );

    // 3. Get all existing records, add the new one, and save the updated list
    final allRecords = await getAnimals();
    allRecords.add(newRecord);
    await _saveAnimals(allRecords);
  }
  
  // Get all stored animal records
  static Future<List<AnimalRecord>> getAnimals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? animalsJsonString = prefs.getString(_key);

    if (animalsJsonString == null) {
      return []; // Return empty list if nothing is stored yet
    }

    final List<dynamic> jsonList = json.decode(animalsJsonString);
    return jsonList.map((jsonItem) => AnimalRecord.fromJson(jsonItem)).toList();
  }
  
  // Delete an animal record by its image path (which acts as a unique ID)
  static Future<void> deleteAnimal(String imagePath) async {
    // 1. Delete the actual image file from device storage
    try {
      final fileToDelete = File(imagePath);
      if (await fileToDelete.exists()) {
        await fileToDelete.delete();
      }
    } catch (e) {
      print("Error deleting file: $e");
    }

    // 2. Remove the record's data from SharedPreferences
    final allRecords = await getAnimals();
    allRecords.removeWhere((record) => record.imagePath == imagePath);
    await _saveAnimals(allRecords);
  }

  // Helper function to save the list of records to SharedPreferences
  static Future<void> _saveAnimals(List<AnimalRecord> animals) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(animals.map((animal) => animal.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
  
  // Helper function to copy the image to a permanent location
  static Future<String> _saveImagePermanently(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final newPath = path.join(directory.path, fileName);
    return (await imageFile.copy(newPath)).path;
  }
}

