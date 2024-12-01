import 'dart:convert';
import 'package:daily_word/model/triplevoc.dart';
import 'package:daily_word/model/vocabulary.dart';
import 'package:daily_word/progress/book_progress.dart';
import 'package:daily_word/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'helpers/vocabulary_nevigate.dart';
import 'model/book.dart';
import 'model/lesson.dart';
import 'widgets/vocabulary_card.dart';

class FlashcardPage extends StatefulWidget {
  final List<Book> books;
  TripleVoc curVoc;

  FlashcardPage({
    Key? key,
    required this.books,
    required this.curVoc,
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

  void _initVariables() {
    _totalVocabularies = widget.books[widget.curVoc.bookId].totalVocabularies;
    prefs.getProgressByKey(widget.curVoc.bookIdStr).then((progressMap) {
      setState(() {
        bookProgress = progressMap;
        _completedSize = bookProgress.totalCompleted;
        _isFavorite = bookProgress.isFavorite(widget.curVoc);
        _isCompleted = bookProgress.isCompleted(widget.curVoc);
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
  }

  Future<void> _loadVocabulary() async {
    try {
      String path =
          'assets/vocabulary/${widget.curVoc.bookIdStr}/words/${widget.curVoc.lessonId}.json';
      final String response =
          await DefaultAssetBundle.of(context).loadString(path);
      print(path);
      _vocabulary = Vocabulary.listFromJson(json.decode(response));
      print(_vocabulary.length);
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
        "vocabulary/${widget.curVoc.bookId}/mp3/${widget.curVoc.lessonId}/${widget.curVoc.vocabularyId}.mp3"));
  }

  void _navigateVocabulary(bool isNext) {
    final result = isNext
        ? getNextVocabulary(widget.books[widget.curVoc.bookId], widget.curVoc)
        : getPrevVocabulary(widget.books[widget.curVoc.bookId], widget.curVoc);

    setState(() {
      widget.curVoc = result.$1; // Update widget.curVoc
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

  void _markAsCompleted() async {
    bookProgress = await prefs.addCompletedVocabulary(widget.curVoc);
    setState(() {
      _isCompleted = true;
      _completedSize = bookProgress.totalCompleted;
    });
    _showSnackBar('🎉 恭喜你完成了第${_completedSize}个单词');
  }

  void _removeFromCompleted() async {
    bookProgress = await prefs.removeCompletedVocabulary(widget.curVoc);
    setState(() {
      _isCompleted = false;
      _completedSize = bookProgress.totalCompleted;
    });
    _showSnackBar('🎉 取消已完成');
  }

  void _markAsFavorite() async {
    bookProgress = await prefs.addFavoriteVocabulary(widget.curVoc);
    setState(() {
      _isFavorite = true;
      _completedSize = bookProgress.totalCompleted;
    });
    _showSnackBar('🎉 添加到已收藏');
  }

  void _removeFromFavorite() async {
    bookProgress = await prefs.removeFavoriteVocabulary(widget.curVoc);
    setState(() {
      _isFavorite = false;
      _completedSize = bookProgress.totalCompleted;
    });
    _showSnackBar('🎉 取消收藏');
  }

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
                    final selectedLesson =
                        widget.books[widget.curVoc.bookId].lessons.firstWhere(
                      (lesson) => lesson.lessonTitle == value,
                      orElse: () => widget.books[widget.curVoc.bookId]
                          .lessons[widget.curVoc.lessonId], // Fallback
                    );
                    setState(() {
                      widget.curVoc.lessonId =
                          widget.books[widget.curVoc.bookId].lessons.indexOf(
                              selectedLesson); // Update selectedLessonIndex
                      _loadVocabulary(); // Load vocabulary for the selected lesson
                      widget.curVoc.lessonId = widget
                          .curVoc.lessonId; // Update lessonId in widget.curVoc
                      widget.curVoc.vocabularyId = 0;
                      setState(() {});
                    });
                  },
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.books[widget.curVoc.bookId]
                              .lessons[widget.curVoc.lessonId].lessonTitle,
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
                        _buildBackgroundCard(context, 0.76, 24),
                        _buildBackgroundCard(context, 0.8, 16),
                        _buildBackgroundCard(context, 0.84, 8),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          VocabularyCard(
                            vocabulary: _vocabulary[widget.curVoc.vocabularyId],
                            curVoc: widget.curVoc,
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
                                _markAsCompleted();
                              } else {
                                _removeFromCompleted();
                              }
                            },
                            onToggleFavorite: () {
                              if (!_isFavorite) {
                                _markAsFavorite();
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
              _isFavorite = bookProgress.isFavorite(widget.curVoc);
              _isCompleted = bookProgress.isCompleted(widget.curVoc);
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
          bookId: widget.curVoc.bookId,
          lessonId: widget.curVoc.lessonId,
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
                    widget.curVoc.vocabularyId = index;
                    _playAudio();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: bookProgress.isCompleted(currentVoc)  // Use currentVoc instead
                        ? Colors.green
                        : Colors.grey,
                  ),
                  onPressed: () {
                    widget.curVoc.vocabularyId = index;
                    if (!bookProgress.isCompleted(currentVoc)) {  // Use currentVoc instead
                      _markAsCompleted();
                    } else {
                      _removeFromCompleted();
                    }
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: Icon(
                    bookProgress.isFavorite(currentVoc)  // Use currentVoc instead
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    widget.curVoc.vocabularyId = index;
                    if (!bookProgress.isFavorite(currentVoc)) {  // Use currentVoc instead
                      _markAsFavorite();
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
