import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/data/shared_prefs.dart';
import '/dio/account_dio.dart';
import '/dio/game_dio.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  Future<void> _submit() async {
    authcheck();
  }

  Future<void> _logout() async {
    await logOut();
  }

  bool _onKey(KeyEvent event) {

    final key = event.logicalKey.keyLabel;

    var keys = ['Arrow Up', 'Arrow Down', 'Arrow Left', 'Arrow Right'];

    if (keys.contains(key) && (event is KeyDownEvent || event is KeyRepeatEvent)) {
      move(key);
    }

    return false;
  }

  

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: FutureBuilder<String?>(

          future: getPrefs('name'),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {

            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return Text('Game Page - ${snapshot.data}');
              }
              else {
                return const Text('Game Page - Guest');
              }
            }
            else {
              return const Text('Loading...');
            }
          },
        ),
      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[

            const Text('Click this button to log out'),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),

            const SizedBox(height: 60),

            const Text('Click this button to test authentication'),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => _submit(),
              child: const Text('Auth'),
            ),
          ],
        ),
      ),
    );
  }
}