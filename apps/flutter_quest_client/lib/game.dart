import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart' hide ConnectionState;

import '/data/shared_prefs.dart';
import '/dio/account_dio.dart';
import '/dio/game_dio.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  late HttpConnectionOptions httpOptions;
  late HubConnection hubConnection;

  final maxRetryCount = 5;

  @override
  void initState() {

    super.initState();

    httpOptions = HttpConnectionOptions(
        accessTokenFactory: () async => await getAccessToken());
    hubConnection = HubConnectionBuilder()
        .withUrl('http://localhost:6969/gamehub', options: httpOptions)
        .build();

    _startHubConnection();

    hubConnection.on('ReceiveMessage', _handleReceivedMessage);

    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  void dispose() {
    hubConnection.stop();

    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  _startHubConnection([int retryCount = 0]) async {
    if (retryCount >= maxRetryCount) {
      print('Max retry count reached');
      return;
    }

    try {
      await hubConnection.start();
      print('SignalR connection started.');
    } catch (e) {
      print('Error starting SignalR connection: $e');
      await Future.delayed(Duration(seconds: 3));
      return _startHubConnection(retryCount + 1);
    }
  }

  void _handleReceivedMessage(List<Object?>? arguments) {
    int messageType = arguments?[0] as int? ?? 0;
    String payload = arguments?[1] as String? ?? '';

    if (messageType == 0 || payload == '') {
      print('type or payload missing, request not allowed? implement refreshtoken dio later');
      return;
    }

    if (messageType == 1) {
      _addErrorMessage(payload);
    }

    if (messageType == 2) {
      _updatePlayerPos(payload);
    }

    if (messageType == 3) {
      _addChatMessage(payload);
    }
  }

  void _addErrorMessage(String payload) {
    var message = jsonDecode(payload);
    print('Error: $message');
  }

  void _updatePlayerPos(String payload) {
    var message = jsonDecode(payload);
    print('Player position: $message');
  }

  void _addChatMessage(String payload) {
    var message = jsonDecode(payload);
    print('Chat: $message');
  }

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
      hubConnection.invoke('Move', args: [key]);
    }

    return false;
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

  static getAccessToken() {
    return getPrefs('accessToken');
  }
}