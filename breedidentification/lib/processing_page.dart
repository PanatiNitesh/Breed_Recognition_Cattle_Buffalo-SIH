import 'dart:async';
import 'dart:io';
import 'package:breedidentification/detection_results_page.dart';
import 'package:flutter/material.dart';
 // Import the results page
import 'package:video_player/video_player.dart'; // Import the video player

class ProcessingPage extends StatefulWidget {
  final File imageFile;
  const ProcessingPage({super.key, required this.imageFile});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  String _statusText = "Analysing...";
  Timer? _timer;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // --- Video Controller Setup ---
    _videoController = VideoPlayerController.asset(
      'assets/videos/processing_orb.mp4',
    )..initialize().then((_) {
        _videoController.play();
        _videoController.setLooping(true);
        setState(() {});
      });

    // --- Rest of your logic (this is the same as before) ---
    _startStatusAnimation();
    _startBackendCall();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  // This loops the status text (same as before)
  void _startStatusAnimation() {
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _statusText = "Detecting...";
      });
      _timer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _statusText = "Analysing...";
        });
        _startStatusAnimation();
      });
    });
  }

  // This simulates your backend call (same as before)
  Future<void> _startBackendCall() async {
    await Future.delayed(const Duration(seconds: 7));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DetectionResultsPage(imageFile: widget.imageFile)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width for dynamic sizing
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- UPDATED: Video Player size is now dynamic ---
            SizedBox(
              // Set width and height to 80% of the screen width
              width: screenWidth * 0.8,
              height: screenWidth * 0.8,
              child: _videoController.value.isInitialized
                  ? ClipOval( // Clips the square video into a circle
                      child: AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  : const Center(
                      // This loader only shows while the video file itself is loading
                      child: CircularProgressIndicator(),
                    ),
            ),
            // --- End of video player ---

            const SizedBox(height: 40),

            // 2. The changing status text (same as before)
            Text(
              _statusText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            // ---REMOVED: The loading spinner at the bottom is now gone ---
          ],
        ),
      ),
    );
  }
}