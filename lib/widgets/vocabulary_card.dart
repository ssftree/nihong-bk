import 'package:flutter/material.dart';
import '../model/vocabulary.dart';
import '../model/triplevoc.dart';

class VocabularyCard extends StatelessWidget {
  final Vocabulary vocabulary;
  final TripleVoc curVoc;
  final bool isVisible;
  final bool isCompleted;
  final bool isFavorite;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onPlayAudio;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleFavorite;

  const VocabularyCard({
    Key? key,
    required this.vocabulary,
    required this.curVoc,
    required this.isVisible,
    required this.isCompleted,
    required this.isFavorite,
    required this.screenWidth,
    required this.screenHeight,
    required this.onPlayAudio,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleComplete,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.88,
      height: screenHeight * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildMainContent(),
          _buildNavigationButtons(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAudioButton(),
        const Spacer(),
        _buildVocabularyText(),
        const Spacer(),
      ],
    );
  }

  Widget _buildAudioButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 12.0),
      child: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: onPlayAudio,
          child: const Icon(
            Icons.play_arrow_outlined,
            color: Colors.orange,
            size: 42,
          ),
        ),
      ),
    );
  }

  Widget _buildVocabularyText() {
    return Column(
      children: [
        Text(
          vocabulary.kanji.isNotEmpty ? vocabulary.kanji : vocabulary.japanese,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        if (isVisible) ...[
          if (vocabulary.kanji.isNotEmpty)
            Text(
              vocabulary.japanese,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
          const SizedBox(height: 10),
          Text(
            "[${vocabulary.romaji}]",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.normal,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            vocabulary.chinese,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.normal,
              color: Colors.black54,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: screenHeight * 0.2),
          child: GestureDetector(
            onTap: onPrevious,
            child: const Icon(
              Icons.keyboard_arrow_left_outlined,
              color: Colors.grey,
              size: 36,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16, top: screenHeight * 0.2),
          child: GestureDetector(
            onTap: onNext,
            child: const Icon(
              Icons.keyboard_arrow_right_outlined,
              color: Colors.grey,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onToggleComplete,
              child: Icon(
                Icons.check_circle,
                color: isCompleted ? Colors.green : Colors.grey,
                size: 46,
              ),
            ),
            GestureDetector(
              onTap: onToggleFavorite,
              child: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 46,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 