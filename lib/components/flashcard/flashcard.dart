import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../model/vocabulary.dart';

class Flashcard extends StatelessWidget {
  final Vocabulary? vocabulary;
  final AudioPlayer audioPlayer;

  const Flashcard({Key? key, required this.vocabulary, required this.audioPlayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildBackgroundCard(context, 0.76, 24),
        _buildBackgroundCard(context, 0.8, 16),
        _buildBackgroundCard(context, 0.84, 8),
        _buildContent(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.88,
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 5, blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  await audioPlayer.play(AssetSource('vocabulary/1/mp3/1/1.mp3'));
                },
                child: const Icon(Icons.play_arrow_outlined, color: Colors.orange, size: 42),
              ),
              const Spacer(),
              Text(
                vocabulary?.kanji ?? vocabulary?.japanese ?? 'No Vocabulary',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Spacer(),
            ],
          ),
          const Positioned(bottom: 20, left: 20, child: Icon(Icons.check_circle, color: Colors.green, size: 40)),
          const Positioned(bottom: 20, right: 20, child: Icon(Icons.star, color: Colors.amber, size: 40)),
        ],
      ),
    );
  }

  Widget _buildBackgroundCard(BuildContext context, double scale, double topOffset) {
    return Positioned(
      top: topOffset,
      child: Container(
        width: MediaQuery.of(context).size.width * scale,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
