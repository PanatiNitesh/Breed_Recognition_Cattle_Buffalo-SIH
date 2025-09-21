import 'package:flutter/material.dart';

// A simple data model to represent an animal in the list.
// In a real app, this would come from your local storage.
class AnimalRecord {
  final String imageUrl;
  final String family;
  final List<String>? suggestions;

  AnimalRecord({
    required this.imageUrl,
    required this.family,
    this.suggestions,
  });
}

// Mock data to populate the list, matching the screenshot
final List<AnimalRecord> _mockData = [
  AnimalRecord(
    imageUrl: 'https://picsum.photos/seed/gir_calf/300/300', // Placeholder
    family: 'Cattle',
    suggestions: [
      'Gir (92%)',
      'Sahiwal (5%)',
      'Red Sindhi (3%)',
    ],
  ),
  AnimalRecord(
    imageUrl: 'https://picsum.photos/seed/brown_cow/300/300', // Placeholder
    family: 'Cattle',
    suggestions: null, // No suggestions for this card
  ),
  AnimalRecord(
    imageUrl: 'https://picsum.photos/seed/buffalo/300/300', // Placeholder
    family: 'buffalo',
    suggestions: null, // No suggestions for this card
  ),
];

class MyFamilyPage extends StatelessWidget {
  const MyFamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- Top Bar (Back, Filter, Home) ---
              _buildTopBar(context),
              const SizedBox(height: 20),
              
              // --- List of Animal Cards ---
              Expanded(
                child: ListView.builder(
                  itemCount: _mockData.length,
                  itemBuilder: (context, index) {
                    return _buildAnimalCard(_mockData[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Replicates the top bar from the screenshot
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context), // Simple back navigation
          ),
        ),
        // Filter & Home Buttons
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
                onPressed: () {
                  // TODO: Implement filter logic
                },
              ),
              Container(width: 1, height: 24, color: Colors.black26), // Separator
              IconButton(
                icon: const Icon(Icons.home_outlined, color: Colors.black),
                onPressed: () {
                  // TODO: Implement home navigation
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Replicates the animal card from the screenshot
  Widget _buildAnimalCard(AnimalRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Image Section (Left) ---
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: Image.network(
                  record.imageUrl,
                  fit: BoxFit.cover,
                  // Simple loading/error placeholders
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.image_not_supported));
                  },
                ),
              ),
            ),
            
            // --- Info Section (Right) ---
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Family Chip
                    _buildFamilyChip(record.family),
                    const SizedBox(height: 8),

                    // Suggestions (if they exist)
                    if (record.suggestions != null)
                      _buildSuggestions(record.suggestions!),
                    
                    // Spacer pushes the button to the bottom
                    const Spacer(), 
                    
                    // Read More Button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement "Read More" logic
                        },
                        child: const Text(
                          'Read More',
                          style: TextStyle(color: Colors.blue),
                        ),
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

  // Helper for the "Family: ..." chip
  Widget _buildFamilyChip(String family) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        'Family: $family',
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
    );
  }

  // Helper to build the suggestions list
  Widget _buildSuggestions(List<String> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top 3 Suggestions:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        ...suggestions.map((suggestion) => Text(
              suggestion,
              style: const TextStyle(fontSize: 14),
            )),
      ],
    );
  }
}