import 'package:flutter/material.dart';

class FlashcardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String bookTitle;
  final String lessonTitle;

  const FlashcardAppBar({
    Key? key,
    required this.bookTitle,
    required this.lessonTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF6A1B9A),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: _buildDropdown(bookTitle, ['Option 1', 'Option 2', 'Option 3']),
          ),
          Flexible(
            child: _buildDropdown(lessonTitle, ['Sentence 1', 'Sentence 2', 'Sentence 3']),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String title, List<String> options) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        print('Selected: $value');
      },
      child: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white),
        ],
      ),
      itemBuilder: (context) {
        return options.map((choice) {
          return PopupMenuItem<String>(value: choice, child: Text(choice));
        }).toList();
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
