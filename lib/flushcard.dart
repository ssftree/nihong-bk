import 'dart:convert';
import 'package:daily_word/model/vocabulary.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'model/lesson.dart';

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
      _vocabulary = Vocabulary.listFromJson(json.decode(response));
    } catch (e) {
      print('Error loading vocabulary: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: PopupMenuButton<String>(
                onSelected: (String value) {
                  print('Selected: $value');
                },
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.bookTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
                itemBuilder: (BuildContext context) {
                  return {'Option 1', 'Option 2', 'Option 3'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ),
            Flexible(
              child: PopupMenuButton<String>(
                onSelected: (String value) {
                  print('Selected: $value');
                },
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.lesson.lessonTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
                itemBuilder: (BuildContext context) {
                  return {'Sentence 1', 'Sentence 2', 'Sentence 3'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: 15 / 150,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '15/150',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildBackgroundCard(context, 0.76, 24),
                  _buildBackgroundCard(context, 0.8, 16),
                  _buildBackgroundCard(context, 0.84, 8),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    Container(
                      width: MediaQuery.of(context).size.width * 0.88,
                      height: MediaQuery.of(context).size.height * 0.5,
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
                      child: Stack(children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, right: 12.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () async {
                                    await _audioPlayer.play(
                                        AssetSource('vocabulary/1/mp3/1/1.mp3'));
                                  },
                                  child: Icon(
                                    Icons.play_arrow_outlined,
                                    color: Colors.orange,
                                    size: 42,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _vocabulary[0].kanji.isNotEmpty
                                  ? _vocabulary[0].kanji
                                  : _vocabulary[0].japanese,
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _vocabulary[0].kanji.isNotEmpty
                                  ? _vocabulary[0].japanese
                                  : '',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black54),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "[${_vocabulary[0].romaji}]",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _vocabulary[0].chinese,
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black54),
                            ),
                            const Spacer(),
                          ],
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 40,
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: MediaQuery.of(context).size.height * 0.2,
                          child: const Icon(
                            Icons.keyboard_arrow_left_outlined,
                            color: Colors.grey,
                            size: 36,
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: MediaQuery.of(context).size.height * 0.2,
                          child: const Icon(
                            Icons.keyboard_arrow_right_outlined,
                            color: Colors.grey,
                            size: 36,
                          ),
                        ),
                      ]),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFAB91),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Icon(
                  Icons.visibility_off,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCard(
      BuildContext context, double scale, double topOffset) {
    return Positioned(
      top: topOffset,
      child: Container(
        width: MediaQuery.of(context).size.width * scale,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
