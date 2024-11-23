import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('关于'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // App Logo
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icon/icon.png', // 确保添加你的应用图标
                width: 100,
                height: 100,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // App Name
          const Center(
            child: Text(
              '日语单词本',  // 替换为你的应用名称
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Version
          const SizedBox(height: 40),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '这是一个帮助用户学习日语单词的应用。通过这个应用，你可以：',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          // Features
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('• 学习常用日语单词'),
                SizedBox(height: 8),
                Text('• 听取单词发音'),
                SizedBox(height: 8),
                Text('• 收藏重要单词'),
                SizedBox(height: 8),
                Text('• 记录学习进度'),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Contact
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '联系我们',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '如果你有任何问题或建议，请发送邮件至：\nssfu.dev@gmail.com',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 