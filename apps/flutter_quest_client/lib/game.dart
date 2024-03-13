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

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '/data/shared_prefs.dart';
import '/dio/account_dio.dart';
import '/dio/dio_util.dart';
import '/models/user.dart';
import '/models/chat.dart';
import '/chat/chat_bloc.dart';
import '/chat/chat_event.dart';
import '/user/user_bloc.dart';
import '/user/user_event.dart';

extension MyIterable<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;

  T? firstWhereOrNull(bool Function(T element) test) {
    final list = where(test);
    return list.isEmpty ? null : list.first;
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final Set<LogicalKeyboardKey> _pressedKeys = {};
  Timer? _pollingTimer;

  late final HubConnection hubConnection;

  late final UserBloc userBloc;

  late final ChatBloc chatBloc;

  late int currentUserId;

  @override
  void initState() {

    super.initState();

    _getIdFromAccessToken();

    userBloc = UserBloc();

    chatBloc = ChatBloc();


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

    _startPollingKeys();
  }

  @override
  void dispose() {

    hubConnection.stop();

    _controller.dispose();
    _focusNode.dispose();

    ServicesBinding.instance.keyboard.removeHandler(_onKey);

    _stopPollingKeys();

    super.dispose();
  }

  void _getIdFromAccessToken() async {

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

    var id = int.parse(map['userId']);

    currentUserId = id;
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
    var hatColorString = payload['hatColor'] as String;
    var shirtColorString = payload['shirtColor'] as String;
    var legMovement = payload['legMovement'] as bool;
    var isActive = payload['isActive'] as bool;

    var hatColor = int.parse(hatColorString);
    var shirtColor = int.parse(shirtColorString);

    User user = User(id: userId, name: name, x: x, y: y, hatColor: hatColor, shirtColor: shirtColor, legMovement: legMovement, isActive: isActive);

    _addOrUpdateUser(user);
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
    var hatColorString = payload['hatColor'] as String;
    var shirtColorString = payload['shirtColor'] as String;
    var legMovement = payload['legMovement'] as bool;
    var isActive = payload['isActive'] as bool;

    var hatColor = int.parse(hatColorString);
    var shirtColor = int.parse(shirtColorString);

    User user = User(id: userId, name: name, x: x, y: y, hatColor: hatColor, shirtColor: shirtColor, legMovement: legMovement, isActive: isActive);

    if (!isActive) {

      _removeUser(user);

      return;
    }

    _addOrUpdateUser(user);
  }

  void _addChatMessage(Object? payload) {

    if (payload is! Map) {
      print('Payload is not a Map.');
      return;
    }

    var name = payload['name'] as String;
    var message = payload['message'] as String;

    Chat chat = Chat(name: name, message: message);

    chatBloc.add(ChatAdded(chat));
  }

  void _addOrUpdateUser(User user) {

    userBloc.add(UserRemoved(user));

    userBloc.add(UserAdded(user));
  }

  void _removeUser(user) {

    userBloc.add(UserRemoved(user));
  }

  Future<void> _submit() async {

      var message = _controller.text;

      if (message.isEmpty) {
        return;
      }

      _controller.clear();

      await hubConnection.invoke('Chat', args: [message]);

      _focusNode.requestFocus();
  }

  Future<void> _logout() async {

    await hubConnection.stop();

    await logOut();
  }

  bool _onKey(KeyEvent event) {

    final key = event.logicalKey;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _pressedKeys.add(key);
    }

    if (event is KeyUpEvent) {
      _pressedKeys.remove(key);
    }

    return false;
  }

  void _startPollingKeys() {
    _pollingTimer = Timer.periodic(Duration(milliseconds: 42), (timer) {
      _checkPressedKeys();
    });
  }

  void _stopPollingKeys() {
    _pollingTimer?.cancel();
  }

  void _checkPressedKeys() {

    if ((_pressedKeys.contains(LogicalKeyboardKey.arrowUp) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) ||
        (_pressedKeys.contains(LogicalKeyboardKey.arrowUp) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown) &&
        !_pressedKeys.contains(LogicalKeyboardKey.arrowLeft) &&
        !_pressedKeys.contains(LogicalKeyboardKey.arrowRight)) ||
        (!_pressedKeys.contains(LogicalKeyboardKey.arrowUp) &&
        !_pressedKeys.contains(LogicalKeyboardKey.arrowDown) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight))) {

      return;
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {

      _accessTokenCheck();
      hubConnection.invoke('Move', args: ['Up']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {

      _accessTokenCheck();
      hubConnection.invoke('Move', args: ['Down']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowLeft) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {

      _accessTokenCheck();
      hubConnection.invoke('Move', args: ['Left']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowRight) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)){

      _accessTokenCheck();
      hubConnection.invoke('Move', args: ['Right']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {

      _accessTokenCheck();

      if (userBloc.state.firstWhereOrNull((u) => u.id == currentUserId) == null) {
        return;
      }

      if (userBloc.state.firstWhere((u) => u.id == currentUserId).x == 0) {
        hubConnection.invoke('Move', args: ['Up']);
        return;
      }

      if (userBloc.state.firstWhere((u) => u.id == currentUserId).y == 0) {
        hubConnection.invoke('Move', args: ['Left']);
        return;
      }

      hubConnection.invoke('Move', args: ['UpLeft']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {

      _accessTokenCheck();

      if (userBloc.state.firstWhereOrNull((u) => u.id == currentUserId) == null) {
        return;
      }

      if (userBloc.state.firstWhere((u) => u.id == currentUserId).x == 3000) {
        hubConnection.invoke('Move', args: ['Up']);
        return;
      }

      if (userBloc.state.firstWhere((u) => u.id == currentUserId).y == 0) {
        hubConnection.invoke('Move', args: ['Right']);
        return;
      }

      hubConnection.invoke('Move', args: ['UpRight']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {

      _accessTokenCheck();

      if (userBloc.state.firstWhereOrNull((u) => u.id == currentUserId) == null) {
        return;
      }

      if (userBloc.state.firstWhere((u) => u.id == currentUserId).x == 0) {
        hubConnection.invoke('Move', args: ['Down']);
        return;
      }

      if (userBloc.state.firstWhere((u) => u.id == currentUserId).y == 3000) {
        hubConnection.invoke('Move', args: ['Left']);
        return;
      }

      hubConnection.invoke('Move', args: ['DownLeft']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown) &&
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {

      _accessTokenCheck();

      if (userBloc.state.firstWhereOrNull((u) => u.id == currentUserId) == null) {
        return;
      }

      if (userBloc.state.firstWhere((u) => u.id == currentUserId).x == 3000) {
        hubConnection.invoke('Move', args: ['Down']);
        return;
      }

      if (userBloc.state.firstWhere((u) => u.id == currentUserId).y == 3000) {
        hubConnection.invoke('Move', args: ['Right']);
        return;
      }

      hubConnection.invoke('Move', args: ['DownRight']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {

      _accessTokenCheck();
      hubConnection.invoke('Move', args: ['Up']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {

      _accessTokenCheck();
      hubConnection.invoke('Move', args: ['Down']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {

      _accessTokenCheck();
      hubConnection.invoke('Move', args: ['Left']);
    }

    else if (_pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {

      _accessTokenCheck();
      hubConnection.invoke('Move', args: ['Right']);
    }

    if (_pressedKeys.contains(LogicalKeyboardKey.enter)) {

      _accessTokenCheck();
      _submit();
    }
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Game Page'),
      ),

      body: Center(

        child: Row(
          children: [
            Expanded(
              child: Column(

                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[

                  Expanded(

                    child: Container(
                      padding: const EdgeInsets.all(15),

                      child: Column(
                        children: [

                          Expanded(

                            child: Container(

                              child: BlocBuilder<UserBloc, List<User>>(
                                bloc: userBloc,
                                builder: (context, state) {

                                  return state.firstWhereOrNull((u) => u.id == currentUserId) != null ?
                                    LayoutBuilder(
                                    builder: (context, constraints) {

                                      return Stack(
                                        clipBehavior: Clip.none,

                                        children: [

                                          Positioned(
                                            top: constraints.maxHeight / 2 - state.firstWhere((u) => u.id == currentUserId).y,
                                            left: constraints.maxWidth / 2 - state.firstWhere((u) => u.id == currentUserId).x,

                                            child: Ink.image(
                                              image: AssetImage('lib/assets/map.png'),
                                              width: 3044,
                                              height: 3100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),

                                          Positioned(
                                            top: constraints.maxHeight / 2 - state.firstWhere((u) => u.id == currentUserId).y - 1,
                                            left: constraints.maxWidth / 2 - state.firstWhere((u) => u.id == currentUserId).x - 1,

                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                              ),

                                              child: SizedBox(
                                                width: 3044,
                                                height: 3100,

                                                child: Stack(
                                                  clipBehavior: Clip.none,

                                                  children: [...state.where((u) => u.id != currentUserId).map((user) =>

                                                    Positioned(
                                                      top: user.y.toDouble() + 1,
                                                      left: user.x.toDouble() + 1,

                                                      child: SizedBox(
                                                        width: 44,
                                                        height: 100,

                                                        child: Stack(
                                                          clipBehavior: Clip.none,
                                                          children: [

                                                            Positioned(
                                                              bottom: 100,
                                                              left: -50,
                                                              right: -50,

                                                              child: Stack(
                                                                clipBehavior: Clip.none,
                                                                alignment: Alignment.center,

                                                                children: [
                                                                  FittedBox(
                                                                    fit: BoxFit.none,

                                                                    child: Text(
                                                                      user.name,
                                                                      overflow: TextOverflow.visible,
                                                                      softWrap: false,
                                                                      style: const TextStyle(fontSize: 12),
                                                                    )
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            Align(
                                                              alignment: Alignment.bottomCenter,

                                                              child: Ink.image(

                                                                image: AssetImage(
                                                                    user.legMovement
                                                                        ? 'lib/assets/pixel-boi-a.png'
                                                                        : 'lib/assets/pixel-boi-b.png'
                                                                ),
                                                                width: 44,
                                                                height: 100,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),

                                                            Align(
                                                              alignment: Alignment.bottomCenter,

                                                              child: ColorFiltered(
                                                                colorFilter: ColorFilter.mode(
                                                                  Color(user.hatColor),
                                                                  BlendMode.modulate,
                                                                ),
                                                                child: Image.asset(
                                                                  'lib/assets/pixel-boi-hat.png',
                                                                  width: 44,
                                                                  height: 100,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),

                                                            Align(
                                                              alignment: Alignment.bottomCenter,

                                                              child: ColorFiltered(
                                                                colorFilter: ColorFilter.mode(
                                                                  Color(user.shirtColor),
                                                                  BlendMode.modulate,
                                                                ),
                                                                child: Image.asset(
                                                                  'lib/assets/pixel-boi-shirt.png',
                                                                  width: 44,
                                                                  height: 100,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    )
                                                  ).toList(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: constraints.maxHeight / 2,
                                            left: constraints.maxWidth / 2,

                                            child: Stack(

                                              children: [

                                                SizedBox(
                                                  width: 44,
                                                  height: 100,

                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [

                                                      Positioned(
                                                        bottom: 100,
                                                        left: -50,
                                                        right: -50,

                                                        child: Stack(
                                                          clipBehavior: Clip.none,
                                                          alignment: Alignment.center,

                                                          children: [
                                                            FittedBox(
                                                                fit: BoxFit.none,

                                                                child: Text(
                                                                  state.firstWhere((u) => u.id == currentUserId).name,
                                                                  overflow: TextOverflow.visible,
                                                                  softWrap: false,
                                                                  style: const TextStyle(fontSize: 12),
                                                                )
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      Align(
                                                        alignment: Alignment.bottomCenter,

                                                        child: Ink.image(

                                                          image: AssetImage(
                                                              state.firstWhere((u) => u.id == currentUserId).legMovement
                                                                  ? 'lib/assets/pixel-boi-a.png'
                                                                  : 'lib/assets/pixel-boi-b.png'
                                                          ),
                                                          width: 44,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),

                                                      Align(
                                                        alignment: Alignment.bottomCenter,

                                                        child: ColorFiltered(
                                                          colorFilter: ColorFilter.mode(
                                                            Color(state.firstWhere((u) => u.id == currentUserId).hatColor),
                                                            BlendMode.modulate,
                                                          ),
                                                          child: Image.asset(
                                                            'lib/assets/pixel-boi-hat.png',
                                                            width: 44,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),

                                                      Align(
                                                        alignment: Alignment.bottomCenter,

                                                        child: ColorFiltered(
                                                          colorFilter: ColorFilter.mode(
                                                            Color(state.firstWhere((u) => u.id == currentUserId).shirtColor),
                                                            BlendMode.modulate,
                                                          ),
                                                          child: Image.asset(
                                                            'lib/assets/pixel-boi-shirt.png',
                                                            width: 44,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                          )
                                        ],
                                      );
                                    }
                                  ): SizedBox();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(15),
                    color: Colors.grey[200],
                    alignment: Alignment.bottomRight,

                    child: ElevatedButton(
                      onPressed: _logout,
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 300,
              padding: const EdgeInsets.all(15),
              color: Colors.grey[350],

              child: Column(

                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: <Widget>[

                  const Text('Chat'),

                  const SizedBox(height: 15),

                  Expanded(

                    child: BlocBuilder<ChatBloc, List<Chat>>(
                      bloc: chatBloc,
                      builder: (context, chatList) => ListView.builder(
                        reverse: true,
                        itemCount: chatList.length,
                        itemBuilder: (context, index) {

                          final chat = chatList[chatList.length - 1 - index];

                          return ListTile(
                            title: Text(chat.name),
                            subtitle: Text(chat.message),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Column(

                    children: [

                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter your message',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
