import 'dart:convert';
import 'package:daily_word/model/triplevoc.dart';
import 'package:daily_word/model/vocabulary.dart';
import 'package:daily_word/model/book_progress.dart';
import 'package:daily_word/shared_preferences_helper.dart';
import 'package:daily_word/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'helpers/vocabulary_nevigate.dart';
import 'model/book.dart';
import 'model/lesson.dart';
import 'widgets/vocabulary_card.dart';
import 'widgets/vocabulary_manager.dart';

class FlashcardPage extends StatefulWidget {
  final List<Book> books;
  final int bookId;

  FlashcardPage({
    Key? key,
    required this.books,
    required this.bookId,
  }) : super(key: key);

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
  bool _isFavorite = false;
  bool _isCompleted = false;
  int _selectedIndex = 0;
  bool _autoPlay = true;
  BookProgress bookProgress = BookProgress();
  late VocabularyManager _vocabularyManager;
  TripleVoc curVoc = TripleVoc(bookId: 0, lessonId: 0, vocabularyId: 0);

  
  void _initVariables() {
    curVoc.bookId = widget.bookId;
    _totalVocabularies = widget.books[curVoc.bookId].totalVocabularies;
    prefs.getProgressByKey(curVoc.bookId).then((progressMap) {
      setState(() {
        bookProgress = progressMap;
        _completedSize = bookProgress.totalCompleted;
        _isFavorite = bookProgress.isFavorite(curVoc);
        _isCompleted = bookProgress.isCompleted(curVoc);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initVariables();
    prefs.getAutoPlay().then((value) {
      setState(() {
        _autoPlay = value;
      });
    });
    _loadVocabulary();
    _vocabularyManager = VocabularyManager(
      prefs: prefs,
      showSnackBar: _showSnackBar,
      onStateChanged: (bookProgress, isMarked, completedSize) {
        setState(() {
          this.bookProgress = bookProgress;
          if (bookProgress.isFavorite(curVoc) != _isFavorite) {
            _isFavorite = isMarked;
          } else {
            _isCompleted = isMarked;
          }
          _completedSize = completedSize;
        });
      },
    );
  }

  Future<void> _loadVocabulary() async {
    try {
      String path =
          'assets/vocabulary/${curVoc.bookId}/words/${curVoc.lessonId}.json';
      final String response =
          await DefaultAssetBundle.of(context).loadString(path);
      _vocabulary = Vocabulary.listFromJson(json.decode(response));
      if (_autoPlay) await _playAudio();
    } catch (e) {
      print('Error loading vocabulary: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playAudio() async {
    await _audioPlayer.play(AssetSource(
        "vocabulary/${curVoc.bookId}/mp3/${curVoc.lessonId}/${curVoc.vocabularyId}.mp3"));
  }

  void _navigateVocabulary(bool isNext) {
    final result = isNext
        ? getNextVocabulary(widget.books[curVoc.bookId], curVoc)
        : getPrevVocabulary(widget.books[curVoc.bookId], curVoc);

    setState(() {
      curVoc = result.$1; // Update curVoc
      _loadVocabulary();
      _initVariables();
      setState(() {});
    });
  }

  void _navigateToPreviousVocabulary() {
    _navigateVocabulary(false); // Navigate to previous
  }

  void _navigateToNextVocabulary() {
    _navigateVocabulary(true); // Navigate to next
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 18)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markAsCompleted(Vocabulary vocabulary) => _vocabularyManager.markAsCompleted(curVoc, vocabulary);
  void _removeFromCompleted() => _vocabularyManager.removeFromCompleted(curVoc);
  void _markAsFavorite(Vocabulary vocabulary) => _vocabularyManager.markAsFavorite(curVoc, vocabulary);
  void _removeFromFavorite() => _vocabularyManager.removeFromFavorite(curVoc);

  @override
  void dispose() {
    _audioPlayer.dispose(); // Stop audio when the page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                          widget.books[curVoc.bookId].title,
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
                        onTap: () {
                          setState(() {
                            curVoc.bookId = widget.books.indexOf(book);
                            curVoc.lessonId = 0;
                            curVoc.vocabularyId = 0;
                            _loadVocabulary();
                            _initVariables();
                          });
                        },
                      );
                    }).toList();
                  },
                ),
              ),
              Flexible(
                child: PopupMenuButton<String>(
                  onSelected: (String value) {
                    // Find the index of the selected lesson
                    final selectedLesson =
                        widget.books[curVoc.bookId].lessons.firstWhere(
                      (lesson) => lesson.lessonTitle == value,
                      orElse: () => widget.books[curVoc.bookId]
                          .lessons[curVoc.lessonId], // Fallback
                    );
                    setState(() {
                      curVoc.lessonId =
                          widget.books[curVoc.bookId].lessons.indexOf(
                              selectedLesson); // Update selectedLessonIndex
                      curVoc.vocabularyId = 0;
                      _loadVocabulary(); 
                      _initVariables();
                      setState(() {});
                    });
                  },
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.books[curVoc.bookId]
                              .lessons[curVoc.lessonId].lessonTitle,
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
                    return widget.books[curVoc.bookId].lessons
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
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: _completedSize / _totalVocabularies,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.teal),
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
                        buildBackgroundCard(context, 0.76, 24),
                        buildBackgroundCard(context, 0.8, 16),
                        buildBackgroundCard(context, 0.84, 8),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          VocabularyCard(
                            vocabulary: _vocabulary[curVoc.vocabularyId],
                            curVoc: curVoc,
                            isVisible: _isVisible,
                            isCompleted: _isCompleted,
                            isFavorite: _isFavorite,
                            screenWidth: MediaQuery.of(context).size.width,
                            screenHeight: MediaQuery.of(context).size.height,
                            onPlayAudio: _playAudio,
                            onPrevious: _navigateToPreviousVocabulary,
                            onNext: _navigateToNextVocabulary,
                            onToggleComplete: () {
                              if (!_isCompleted) {
                                _markAsCompleted(_vocabulary[curVoc.vocabularyId]);
                              } else {
                                _removeFromCompleted();
                              }
                            },
                            onToggleFavorite: () {
                              if (!_isFavorite) {
                                _markAsFavorite(_vocabulary[curVoc.vocabularyId]);
                              } else {
                                _removeFromFavorite();
                              }
                            },
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                      ),
                      child: Icon(
                        _isVisible ? Icons.visibility : Icons.visibility_off,
                        // Change icon based on visibility state
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildListView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              // Update favorite and completed status when switching modes
              _isFavorite = bookProgress.isFavorite(curVoc);
              _isCompleted = bookProgress.isCompleted(curVoc);
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: '卡片模式',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: '列表模式',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _vocabulary.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final vocab = _vocabulary[index];
        // Create a temporary TripleVoc for the current item
        final currentVoc = TripleVoc(
          bookId: curVoc.bookId,
          lessonId: curVoc.lessonId,
          vocabularyId: index  // Use the current index
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              vocab.kanji.isNotEmpty ? vocab.kanji : vocab.japanese,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vocab.kanji.isNotEmpty)
                  Text(vocab.japanese, style: const TextStyle(fontSize: 16)),
                Text("[${vocab.romaji}]", style: const TextStyle(fontSize: 14)),
                Text(vocab.chinese, style: const TextStyle(fontSize: 16)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    curVoc.vocabularyId = index;
                    _playAudio();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: bookProgress.isCompleted(currentVoc) ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    curVoc.vocabularyId = index;
                    if (!bookProgress.isCompleted(currentVoc)) {  // Use currentVoc instead
                      _markAsCompleted(_vocabulary[currentVoc.vocabularyId]);
                    } else {
                      _removeFromCompleted();
                    }
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: Icon(
                    bookProgress.isFavorite(currentVoc) ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    curVoc.vocabularyId = index;
                    if (!bookProgress.isFavorite(currentVoc)) {
                      _markAsFavorite(_vocabulary[currentVoc.vocabularyId]);
                    } else {
                      _removeFromFavorite();
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
