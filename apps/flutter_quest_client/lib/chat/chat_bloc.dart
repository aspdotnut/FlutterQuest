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
import 'package:bloc/bloc.dart';
import '/models/chat.dart';
import 'chat_event.dart';

class ChatBloc extends Bloc<ChatEvent, List<Chat>> {
  ChatBloc()
      : super([
    const Chat(name: 'System', message: 'Welcome to the chat!'),
    const Chat(name: 'System', message: 'Type your message below and press Submit.'),
    const Chat(name: 'System', message: 'Use the arrow keys to move around.'),
    const Chat(name: 'System', message: 'Press the Logout button to log out.'),
    const Chat(name: 'System', message: 'Have fun!'),
  ]){

    on<ChatAdded>((event, emit) async {
      final updatedChat = List<Chat>.from(state);
      updatedChat.add(event.chat);
      emit(updatedChat);
    });
  }
}