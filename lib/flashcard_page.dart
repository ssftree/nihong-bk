import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'components/flashcard/audio_button.dart';
import 'components/flashcard/flashcard.dart';
import 'components/flashcard/flashcard_app_bar.dart';
import 'components/flashcard/progress_bar.dart';
import 'model/lesson.dart';
import 'model/vocabulary.dart';

class FlashcardPage extends StatefulWidget {
  final String bookTitle;
  final Lesson lesson;
  final String vocabularyID;

  const FlashcardPage({
    Key? key,
    required this.bookTitle,
    required this.lesson,
    required this.vocabularyID,
  }) : super(key: key);

  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  List<Vocabulary> _vocabulary = [];
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    try {
      final String response = await DefaultAssetBundle.of(context).loadString(
          'assets/vocabulary/${widget.lesson.lessonId}/words/${widget.lesson.lessonId}.json');
      setState(() {
        _vocabulary = Vocabulary.listFromJson(json.decode(response));
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading vocabulary: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A),
      appBar: FlashcardAppBar(
        bookTitle: widget.bookTitle,
        lessonTitle: widget.lesson.lessonTitle,
      ),
      body: Column(
        children: [
          const ProgressBar(current: 15, total: 150),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Flashcard(
                vocabulary: _vocabulary.isNotEmpty ? _vocabulary[0] : null,
                audioPlayer: _audioPlayer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AudioButton(audioPlayer: _audioPlayer),
        ],
      ),
    );
  }
}
