import 'dart:io';
import 'package:flutter/material.dart';
import 'animal_storage_service.dart'; // Import the service
import 'capture_page.dart';        // Import capture page for navigation
import 'home_page.dart';           // Import home page for navigation

// Enum to manage the current filter state
enum FamilyFilter { all, cattle, buffalo }

class MyFamilyPage extends StatefulWidget {
  const MyFamilyPage({super.key});

  @override
  State<MyFamilyPage> createState() => _MyFamilyPageState();
}

class _MyFamilyPageState extends State<MyFamilyPage> {
  List<AnimalRecord> _allAnimals = [];
  List<AnimalRecord> _filteredAnimals = [];
  bool _isLoading = true;
  FamilyFilter _currentFilter = FamilyFilter.all;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  // Load animals from storage and update the UI
  Future<void> _loadAnimals() async {
    setState(() { _isLoading = true; });
    final animals = await AnimalStorageService.getAnimals();
    setState(() {
      _allAnimals = animals;
      _applyFilter(); // Apply the current filter to the loaded list
      _isLoading = false;
    });
  }
  
  // Delete an animal and refresh the list
  Future<void> _deleteAnimal(String imagePath) async {
    // Show a confirmation dialog before deleting
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to remove this animal from your family?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await AnimalStorageService.deleteAnimal(imagePath);
      _loadAnimals(); // Reload the list from storage
    }
  }


  // Apply the selected filter to the list of animals
  void _applyFilter() {
    if (_currentFilter == FamilyFilter.cattle) {
      _filteredAnimals = _allAnimals.where((animal) => animal.family.toLowerCase() == 'cattle').toList();
    } else if (_currentFilter == FamilyFilter.buffalo) {
      _filteredAnimals = _allAnimals.where((animal) => animal.family.toLowerCase() == 'buffalo').toList();
    } else {
      _filteredAnimals = List.from(_allAnimals); // Show all
    }
    setState(() {}); // Re-render the UI with the filtered list
  }
  
  // Show the filter options in a popup menu with improved UI
  void _showFilterMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    
    showMenu<FamilyFilter>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(value: FamilyFilter.all, child: Text('All')),
        const PopupMenuItem(value: FamilyFilter.cattle, child: Text('Cattle')),
        const PopupMenuItem(value: FamilyFilter.buffalo, child: Text('Buffalo')),
      ],
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Colors.grey, width: 1),
      ),
      color: Colors.white,
    ).then((value) {
      if (value != null) {
        setState(() {
          _currentFilter = value;
          _applyFilter();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTopBar(context),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredAnimals.isEmpty
                        ? const Center(child: Text("No animals saved yet.", style: TextStyle(fontSize: 16)))
                        : ListView.builder(
                            itemCount: _filteredAnimals.length,
                            itemBuilder: (context, index) {
                              // --- CHANGE: Removed GestureDetector ---
                              // The delete action is now on an icon button inside the card.
                              return _buildAnimalCard(_filteredAnimals[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CapturePage())),
          ),
        ),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Builder(builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
                    onPressed: () => _showFilterMenu(context),
                  );
                }
              ),
              Container(width: 1, height: 24, color: Colors.black26),
              IconButton(
                icon: const Icon(Icons.home_outlined, color: Colors.black),
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (route) => false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalCard(AnimalRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.0),
                    child: Image.file(File(record.imagePath), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            
            const VerticalDivider(color: Colors.black, thickness: 2, width: 2),
            
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 8.0), // Adjusted padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CHANGE: Added a Row to hold the chip and delete icon ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Family chip is slightly smaller to fit
                        Flexible(child: _buildFamilyChip(record.family)),
                        // Delete icon button
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteAnimal(record.imagePath),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSuggestions(record),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () { /* TODO: Implement Read More logic */ },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Read More'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFamilyChip(String family) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade500),
      ),
      child: Text(
        'Family: $family',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildSuggestions(AnimalRecord record) {
    if (record.topMatches.isEmpty) {
      return Text(
        '${record.breed} (${record.confidence})',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top 3 Suggestions:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        ...record.topMatches.map(
          (suggestion) => Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
            child: Text(
              suggestion,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
