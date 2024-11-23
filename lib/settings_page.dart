import 'package:daily_word/about_page.dart';
import 'package:flutter/material.dart';
import 'shared_preferences_helper.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();
  bool _autoPlay = false;

  @override
  void initState() {
    super.initState();
    _loadAutoPlayState();
  }

  Future<void> _loadAutoPlayState() async {
    final autoPlay = await _prefsHelper.getAutoPlay();
    setState(() {
      _autoPlay = autoPlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.play_circle_outline),
            title: Text('自动播放', style: TextStyle(fontSize: 20)),
            trailing: Switch(
              value: _autoPlay,
              onChanged: (bool value) async {
                await _prefsHelper.setAutoPlay(value);
                setState(() {
                  _autoPlay = value;
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('关于', style: TextStyle(fontSize: 20)),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }
} 