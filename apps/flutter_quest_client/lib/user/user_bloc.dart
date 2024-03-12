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
import '/models/user.dart';
import 'user_event.dart';

class UserBloc extends Bloc<UserEvent, List<User>> {
  UserBloc()
      : super([]){

    on<UserAdded>((event, emit) async {
      final updatedUser = List<User>.from(state);
      updatedUser.add(event.user);
      emit(updatedUser);
    });

    on<UserRemoved>((event, emit) async {
      final updatedUser = List<User>.from(state);
      updatedUser.removeWhere((user) => user.id == event.user.id);
      emit(updatedUser);
    });
  }
}
