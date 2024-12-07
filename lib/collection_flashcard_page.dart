import 'package:daily_word/model/triplevoc.dart';
import 'package:daily_word/model/vocabulary.dart';
import 'package:daily_word/model/book_progress.dart';
import 'package:daily_word/shared_preferences_helper.dart';
import 'package:daily_word/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'widgets/vocabulary_card.dart';
import 'widgets/vocabulary_manager.dart';

class CollectionFlashcardPage extends StatefulWidget {
  final bool isFavoriteMode;

  CollectionFlashcardPage({
    Key? key,
    required this.isFavoriteMode,
  }) : super(key: key);

  @override
  _CollectionFlashcardPageState createState() =>
      _CollectionFlashcardPageState();
}

class _CollectionFlashcardPageState extends State<CollectionFlashcardPage> {
  List<TripleVoc> _allCollectedVocs = [];
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isVisible = true;
  final SharedPreferencesHelper prefs = SharedPreferencesHelper();
  bool _isFavorite = false;
  bool _isCompleted = false;
  int _selectedIndex = 0;
  bool _autoPlay = true;
  BookProgress bookProgress = BookProgress();
  late VocabularyManager _vocabularyManager;
  TripleVoc curVoc =
      TripleVoc(bookId: 0, lessonId: 0, vocabularyId: 0); // FIXME

  Map<String, StoredVocabulary> favoriteMap = {};
  Map<String, StoredVocabulary> completedMap = {};

  bool collectionIsFavorite(TripleVoc voc) {
    return favoriteMap["${voc.bookId}-${voc.lessonId}-${voc.vocabularyId}"] != null;
  }

  bool collectionIsCompleted(TripleVoc voc) {
    return completedMap["${voc.bookId}-${voc.lessonId}-${voc.vocabularyId}"] != null;
  }

  void _initVariables() {
    prefs.getProgressByKey(curVoc.bookId).then((progressMap) {
      setState(() {
        bookProgress = progressMap;
        // TODO: Check if the current vocabulary is marked as favorite or completed
        _isFavorite = collectionIsFavorite(curVoc);
        _isCompleted = collectionIsCompleted(curVoc);
      });
    });
  }

  Vocabulary getInsideVocabulary(TripleVoc voc) {
    var insideVoc = widget.isFavoriteMode ?
    favoriteMap["${voc.bookId}-${voc.lessonId}-${voc.vocabularyId}"] :
    completedMap["${voc.bookId}-${voc.lessonId}-${voc.vocabularyId}"];
    var vocab = insideVoc?.vocabulary ?? Vocabulary(id: '', kanji: '', japanese: '', romaji: '', chinese: '', type: '');
    return vocab;
  }

  @override
  void initState() {
    super.initState();
    _loadAllCollectedVocabularies().then((_) {
      _initVariables();
      _playAudio();
    });
    
    prefs.getAutoPlay().then((value) {
      setState(() {
        _autoPlay = value;
      });
    });
    
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
        });
      },
    );
  }

  (Map<String, StoredVocabulary>, List<TripleVoc>) loadCollectionMap(
      int bookId, Map<String, StoredVocabulary> collections, bool sorted) {
    Map<String, StoredVocabulary> newCollections = {};
    List<TripleVoc> sortedCollections = [];
    for (final key in collections.keys) {
      final parts = key.split('-');
      final voc = TripleVoc(
        bookId: bookId,
        lessonId: int.parse(parts[0]),
        vocabularyId: int.parse(parts[1]),
      );
      newCollections["${bookId}-${key}"] = collections[key]!;
      if (sorted) {
        sortedCollections.add(voc);
      }
    }
    return (newCollections, sortedCollections);
  }

  Future<void> _loadAllCollectedVocabularies() async {
    // FIXME: id ONLY 2
    for (int bookId = 0; bookId < 2; bookId++) {
      final progress = await prefs.getProgressByKey(bookId);
      final result = loadCollectionMap(bookId, progress.completedWords, !widget.isFavoriteMode);
      completedMap.addAll(result.$1);
      _allCollectedVocs.addAll(result.$2);
      final favResult = loadCollectionMap(bookId, progress.favoriteWords, widget.isFavoriteMode);
      favoriteMap.addAll(favResult.$1);
      _allCollectedVocs.addAll(favResult.$2);
    }

    if (widget.isFavoriteMode) {
      _allCollectedVocs = _allCollectedVocs.where((voc) => favoriteMap["${voc.bookId}-${voc.lessonId}-${voc.vocabularyId}"] != null).toList();
    } else {
      _allCollectedVocs = _allCollectedVocs.where((voc) => completedMap["${voc.bookId}-${voc.lessonId}-${voc.vocabularyId}"] != null).toList();
    }
    setState(() {
      curVoc = _allCollectedVocs[0];
    });
  }

  Future<void> _playAudio() async {
    await _audioPlayer.play(AssetSource(
        "vocabulary/${curVoc.bookId}/mp3/${curVoc.lessonId}/${curVoc.vocabularyId}.mp3"));
  }

  void _navigateVocabulary(bool isNext) {
    if (_allCollectedVocs.isEmpty) return;
    final currentIndex = _allCollectedVocs.indexOf(curVoc);
    int newIndex;

    if (isNext) {
      newIndex =
          currentIndex < _allCollectedVocs.length - 1 ? currentIndex + 1 : 0;
    } else {
      newIndex =
          currentIndex > 0 ? currentIndex - 1 : _allCollectedVocs.length - 1;
    }

    setState(() {
      curVoc = _allCollectedVocs[newIndex];
      _playAudio();
      _initVariables();
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
          title: Text(
            widget.isFavoriteMode ? '我的收藏' : '已完成的',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                            vocabulary: getInsideVocabulary(curVoc),
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
                                _markAsCompleted(getInsideVocabulary(curVoc));
                              } else {
                                _removeFromCompleted();
                              }
                            },
                            onToggleFavorite: () {
                              if (!_isFavorite) {
                                _markAsFavorite(getInsideVocabulary(curVoc));
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
      itemCount: _allCollectedVocs.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final voc = _allCollectedVocs[index];
        var vocab = getInsideVocabulary(voc);

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
                    setState(() {
                      curVoc = voc;  // 更新为使用实际的 voc
                    });
                    _playAudio();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: collectionIsCompleted(voc)  // 使用 collectionIsCompleted
                        ? Colors.green
                        : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      curVoc = voc;  // 更新为使用实际的 voc
                    });
                    if (!collectionIsCompleted(voc)) {
                      _markAsCompleted(vocab);
                    } else {
                      _removeFromCompleted();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    collectionIsFavorite(voc)  // 使用 collectionIsFavorite
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      curVoc = voc;  // 更新为使用实际的 voc
                    });
                    if (!collectionIsFavorite(voc)) {
                      _markAsFavorite(vocab);
                    } else {
                      _removeFromFavorite();
                    }
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
