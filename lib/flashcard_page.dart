import 'dart:convert';
import 'package:daily_word/model/triplevoc.dart';
import 'package:daily_word/model/vocabulary.dart';
import 'package:daily_word/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'helpers/vocabulary_nevigate.dart';
import 'model/book.dart';
import 'model/lesson.dart';


class FlashcardPage extends StatefulWidget {
  final List<Book> books;
  TripleVoc curVoc;
  Map<String, String> completedVocabularies;

  FlashcardPage({
    Key? key,
    required this.books,
    required this.curVoc,
    Map<String, String>? completedVocabularies,
  })  : completedVocabularies = completedVocabularies ?? {},
        super(key: key);

  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  List<Vocabulary> _vocabulary = [];
  bool _isLoading = true;
  int _totalVocabularies = 0;
  int _completedSize = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isVisible = true;
  final SharedPreferencesHelper prefs = SharedPreferencesHelper();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initVariables();
    _loadVocabulary(widget.curVoc.getBookIdString(), widget.curVoc.getLessonIdString());
  }

  void _initVariables() {
    _totalVocabularies =
        widget.books[widget.curVoc.bookId].totalVocabularies;
    _completedSize = widget.completedVocabularies.length;
  }

  Future<void> _loadVocabulary(String bookId, String lessonId) async {
    print('assets/vocabulary/${bookId}/words/${lessonId}.json');
    try {
      final String response = await DefaultAssetBundle.of(context).loadString(
          'assets/vocabulary/${bookId}/words/${lessonId}.json');
      _vocabulary = Vocabulary.listFromJson(json.decode(response));
    } catch (e) {
      print('Error loading vocabulary: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToPreviousVocabulary() {
    final result = getPrevVocabulary(widget.books[widget.curVoc.bookId], widget.curVoc, widget.completedVocabularies);
    setState(() {
      var preLess = widget.curVoc.lessonId;
      widget.curVoc = result.$1; // Update widget.curVoc
      if (preLess != widget.curVoc.lessonId) {
        _loadVocabulary(widget.curVoc.getBookIdString(), widget.curVoc.getLessonIdString());
        setState(() {}); // Trigger a rebuild to update the dropdown menu
      }
    });
  }

  void _navigateToNextVocabulary() {
    final result = getNextVocabulary(widget.books[widget.curVoc.bookId], widget.curVoc, widget.completedVocabularies);
    setState(() {
      var preLess = widget.curVoc.lessonId;
      widget.curVoc = result.$1; // Update widget.curVoc
      if (preLess != widget.curVoc.lessonId) {
        _loadVocabulary(widget.curVoc.getBookIdString(), widget.curVoc.getLessonIdString());
        setState(() {}); // Trigger a rebuild to update the dropdown menu
      }
    });
  }

  void _markAsCompleted() {
    String currentVocabularyId = "${widget.curVoc.getLessonIdString()}-${widget.curVoc.getVocabularyIdString()}";
    widget.completedVocabularies[currentVocabularyId] = currentVocabularyId; // Mark as completed
    prefs.addCompletedVocabulary(widget.curVoc.getBookIdString(), currentVocabularyId); // Save to shared preferences
    _completedSize = widget.completedVocabularies.length;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          _navigateToPreviousVocabulary(); // 右滑，导航到上一个词汇
        } else if (details.delta.dx < 0) {
          _navigateToNextVocabulary(); // 左滑，导航到下一个词汇
        }
      },
      // onVerticalDragEnd: (details) {
      //   if (details.velocity.pixelsPerSecond.dy < 0) {
      //     // 上滑
      //     _markAsCompleted();
      //     setState(() {
      //       _isCompleted = true; // 更新状态以指示完成
      //     });
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(' 🎉 Congratulations! You learned this vocabulary!'),
      //         duration: Duration(seconds: 2), // Duration for the message
      //       ),
      //     );
      //     Future.delayed(Duration(seconds: 2), () {
      //       _navigateToNextVocabulary(); // Move to the next vocabulary after the message
      //     });
      //   }
      // },
      child: Scaffold(
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
                          widget.books[widget.curVoc.bookId].title,
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
                    return widget.books.map((Book book) {
                      return PopupMenuItem<String>(
                        value: book.title,
                        child: Text(book.title),
                      );
                    }).toList();
                  },
                ),
              ),
              Flexible(
                child: PopupMenuButton<String>(
                  onSelected: (String value) {
                    // Find the index of the selected lesson
                    final selectedLesson = widget.books[widget.curVoc.bookId].lessons.firstWhere(
                      (lesson) => lesson.lessonTitle == value,
                      orElse: () => widget.books[widget.curVoc.bookId].lessons[widget.curVoc.lessonId], // Fallback
                    );
                    setState(() {
                      widget.curVoc.lessonId = widget.books[widget.curVoc.bookId].lessons.indexOf(selectedLesson); // Update selectedLessonIndex
                      print(selectedLesson.lessonTitle);
                      print(selectedLesson.lessonId);
                      _loadVocabulary(widget.curVoc.getBookIdString(), widget.curVoc.lessonId.toString()); // Load vocabulary for the selected lesson
                      widget.curVoc.lessonId = widget.curVoc.lessonId; // Update lessonId in widget.curVoc
                      widget.curVoc.vocabularyId = 0;
                      setState(() {

                      });
                    });
                  },
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget
                              .books[widget.curVoc.bookId].lessons[widget.curVoc.lessonId].lessonTitle,
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
                    return widget.books[widget.curVoc.bookId].lessons
                        .map((Lesson lesson) {
                      return PopupMenuItem<String>(
                        value: lesson.lessonTitle,
                        child: Text(lesson.lessonTitle),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: _completedSize / _totalVocabularies,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_completedSize}/${_totalVocabularies.toString()}',
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
                                padding:
                                    const EdgeInsets.only(top: 8.0, right: 12.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () async {
                                      print("vocabulary/${widget.curVoc.bookId}/mp3/${widget.curVoc.lessonId}/${widget.curVoc.vocabularyId}.mp3");
                                      await _audioPlayer.play(AssetSource(
                                          "vocabulary/${widget.curVoc.bookId}/mp3/${widget.curVoc.lessonId}/${widget.curVoc.vocabularyId}.mp3"));
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
                                _vocabulary[widget.curVoc.vocabularyId].kanji.isNotEmpty
                                    ? _vocabulary[widget.curVoc.vocabularyId].kanji
                                    : _vocabulary[widget.curVoc.vocabularyId].japanese,
                                style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              const SizedBox(height: 20),
                              if (_isVisible) 
                              Text(
                                _vocabulary[widget.curVoc.vocabularyId].kanji.isNotEmpty
                                    ? _vocabulary[widget.curVoc.vocabularyId].japanese
                                    : '',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black54),
                              ),
                              const SizedBox(height: 10),
                              if (_isVisible) 
                                Text(
                                  "[${_vocabulary[widget.curVoc.vocabularyId].romaji}]",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey[600]),
                                ),
                              const SizedBox(height: 16),
                              if (_isVisible) 
                                Text(
                                  _vocabulary[widget.curVoc.vocabularyId].chinese,
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
                            left: 24,
                            child: GestureDetector(
                              onTap: () {
                                // Show a congratulatory message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(' 🎉 Congratulations! You learned this vocabulary!', style: TextStyle(fontSize: 18)),
                                    duration: Duration(seconds: 2), // Duration for the message
                                  ),
                                );
                                _markAsCompleted(); // Mark the current vocabulary as completed
                                setState(() {
                                  _isCompleted = true; // Update the state to indicate completion
                                });
                                Future.delayed(Duration(seconds: 2), () {
                                  _navigateToNextVocabulary(); // Move to the next vocabulary after the message
                                });

                              },
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green, // Change color based on completion state
                                size: 46,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 24,
                            child: const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 46,
                            ),
                          ),
                          Positioned(
                            left: 16,
                            top: MediaQuery.of(context).size.height * 0.2,
                            child: GestureDetector(
                              onTap: _navigateToPreviousVocabulary, // Navigate to previous vocabulary
                              child: const Icon(
                                Icons.keyboard_arrow_left_outlined,
                                color: Colors.grey,
                                size: 36,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            top: MediaQuery.of(context).size.height * 0.2,
                            child: GestureDetector(
                              onTap: _navigateToNextVocabulary, // Navigate to next vocabulary
                              child: const Icon(
                                Icons.keyboard_arrow_right_outlined,
                                color: Colors.grey,
                                size: 36,
                              ),
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
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible; // Toggle visibility state
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFAB91),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: Icon(
                    _isVisible ? Icons.visibility : Icons.visibility_off, // Change icon based on visibility state
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
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
