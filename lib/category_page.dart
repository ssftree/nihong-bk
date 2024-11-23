import 'dart:convert';
import 'package:daily_word/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'flashcard_page.dart';
import 'model/triplevoc.dart';
import 'model/book.dart';
import 'model/lesson.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Book>> _futureBooks;
  late Map<String, Map<String, String>> _completedVocabularies = {};
  late Map<String, Map<String, String>> _favoriteVocabularies = {};

  @override
  void initState() {
    super.initState();
    _futureBooks = _loadBookModel();
    _loadCompletedVocabularies();
  }

  int _getTotalFavoriteSize() {
    int total = 0;
    _favoriteVocabularies.forEach((key, value) {
      total += value.length;
    });
    return total;
  }

  int _getTotalCompletedSize() {
    int total = 0;
    _completedVocabularies.forEach((key, value) {
      total += value.length;
    });
    return total;
  }

  Future<List<Book>> _loadBookModel() async {
    final String response = await DefaultAssetBundle.of(context)
        .loadString('assets/vocabulary/0/metadata/metadata.json');
    final book = Book.fromJson(json.decode(response));
    return [book];
  }

  void _loadCompletedVocabularies() async {
    final SharedPreferencesHelper prefs = SharedPreferencesHelper();
    _completedVocabularies = await prefs.getCompletedVocabularies();
    _favoriteVocabularies = await prefs.getFavoriteVocabularies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A), // Deep purple background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'benkyou',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 26,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Language'),
                      content: const Text('Only Chinese is supported now'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                children: [
                  const Text(
                    '🇨🇳', // Using the flag emoji here
                    style: TextStyle(
                        fontSize:
                            20), // Adjust font size to make it look like an icon
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '简体中文',
                    style: TextStyle(color: Colors.white),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                '单词',
                style: TextStyle(
                  color: Color(0xFF6A1B9A),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '挑选你喜欢的单词集',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCard(
                      icon: Icons.star,
                      title: '我的收藏',
                      count: '${_getTotalFavoriteSize()}  cards',
                      iconColor: Colors.pink[200]!,
                    ),
                    const SizedBox(width: 16),
                    _buildCard(
                      icon: Icons.check,
                      title: '我已完成',
                      count: '${_getTotalCompletedSize()} cards',
                      iconColor: Colors.green[200]!,
                    ),
                    const SizedBox(width: 16),
                    _buildCard(
                      icon: Icons.add,
                      title: '新集合',
                      count: '',
                      iconColor: Colors.red[200]!,
                    ),
                    // Add more cards as needed
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<Book>>(
                  future: _futureBooks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No books available'));
                    } else {
                      final books = snapshot.data!;
                      return ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          final completedVocabularies = _completedVocabularies[book.bookId] ?? {};
                          return _buildCategoryItem(book, completedVocabularies);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String count,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (count.isNotEmpty)
            Text(
              count,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Book book, Map<String, String> completedVocabularies) {
    var total = book.totalVocabularies;
    var completed = completedVocabularies.length;
    return GestureDetector(
        onTap: () async {
          final books = await _futureBooks;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FlashcardPage(
                      books: books,
                      curVoc: TripleVoc(bookId: 0, lessonId: 0, vocabularyId: 0),
                    completedVocabularies: completedVocabularies,
                    )),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$completed/$total',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: completed / total,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[300]!),
                ),
              ),
            ],
          ),
        ));
  }

}
