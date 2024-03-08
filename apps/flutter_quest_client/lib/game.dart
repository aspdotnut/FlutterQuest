// FlutterQuest
// A simple chatroom with certain game elements.
// Copyright (C) 2024 aspdotnut
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signalr_netcore/signalr_client.dart' hide ConnectionState;

import '/data/shared_prefs.dart';
import '/dio/account_dio.dart';
import '/dio/game_dio.dart';
import 'dio/dio_util.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  late final HubConnection hubConnection;

  @override
  void initState() {

    super.initState();

    Future<String> getAccessToken() async {
      var token = await getPrefs('accessToken');
      if (token == null) {
        await logOut();
        throw Exception('No access token');
      }
      return token;
    }

    var httpOptions = HttpConnectionOptions(
        accessTokenFactory: () async => await getAccessToken());
    hubConnection = HubConnectionBuilder()
        .withUrl('http://localhost:6969/gamehub', options: httpOptions)
        .build();

    _startHubConnection();

    hubConnection.on('ReceiveMessage', _handleReceivedMessage);

    hubConnection.onclose( ({Exception? error}) => print("Connection Closed: " + error.toString()));

    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  void dispose() {

    hubConnection.stop();

    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  _startHubConnection() async {
    try {
      await hubConnection.start();
      print('SignalR connection started.');
    } catch (e) {
      print('Error starting SignalR connection: $e');
    }
  }

  void _handleReceivedMessage(List<Object?>? arguments) {
    var messageType = arguments?[0] as int;
    var payload = arguments?[1] as Object;

    if (messageType == 0) {
      _addErrorMessage(payload);
    }

    if (messageType == 1) {
      _initialPlayerPos(payload);
    }

    if (messageType == 2) {
      _updatePlayerPos(payload);
    }

    if (messageType == 3) {
      _addChatMessage(payload);
    }
  }

  void _addErrorMessage(Object? payload) {

    if (payload is! Map) {
      print('Payload is not a Map.');
      return;
    }

    var message = payload['message'] as String;

    print('Error: $message');
  }

  void _initialPlayerPos(Object? payload) {

    if (payload is! Map) {
      print('Payload is not a Map.');
      return;
    }

    var userId = payload['id'] as int;
    var name = payload['name'] as String;
    var x = payload['x'] as int;
    var y = payload['y'] as int;

    print('Player $name ($userId) is at $x, $y.');
  }

  void _updatePlayerPos(Object? payload) {

    if (payload is! Map) {
      print('Payload is not a Map.');
      return;
    }

    var userId = payload['id'] as int;
    var name = payload['name'] as String;
    var x = payload['x'] as int;
    var y = payload['y'] as int;

    print('Player $name ($userId) moved to $x, $y.');
  }

  void _addChatMessage(Object? payload) {

    if (payload is! Map) {
      print('Payload is not a Map.');
      return;
    }

    var name = payload['name'] as String;
    var message = payload['message'] as String;

    print('Chat: $name - $message');
  }

  Future<void> _submit() async {
    authcheck();
  }

  Future<void> _logout() async {

    await hubConnection.stop();

    await logOut();
  }

  bool _onKey(KeyEvent event) {

    final key = event.logicalKey.keyLabel;

    var keys = ['Arrow Up', 'Arrow Down', 'Arrow Left', 'Arrow Right'];

    if (keys.contains(key) && (event is KeyDownEvent || event is KeyRepeatEvent)) {

      _accessTokenCheck();
      hubConnection.invoke('Move', args: [key]);
    }

    return false;
  }

  void _accessTokenCheck() async {

    var token = await getPrefs('accessToken');

    if (token == null) {

      await logOut();
      throw Exception('No access token');
    }

    var parts = token.split('.');
    var payload = parts[1];
    var normalized = base64Url.normalize(payload);
    var resp = utf8.decode(base64Url.decode(normalized));
    var map = json.decode(resp);
    var exp = map['exp'] as int;

    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var oneMinuteFromNow = now + 60;

    if (exp < oneMinuteFromNow) {

      bool isSuccessfulRefresh = await refreshToken();

      if (!isSuccessfulRefresh) {

        await handleFailedRefresh();
        throw Exception('Failed to refresh token');
      } else {

        print('Token refreshed: ${await getPrefs('accessToken')}');
      }
    }
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