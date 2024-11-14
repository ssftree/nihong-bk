import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioButton extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const AudioButton({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          // Placeholder for additional functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFAB91),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        ),
        child: const Icon(Icons.visibility_off, color: Colors.white, size: 28),
      ),
    );
  }
}
