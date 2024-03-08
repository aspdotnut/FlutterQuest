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

import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalState {

  final bool isLoggedIn;


  const GlobalState({

    required this.isLoggedIn,
  });
}

class GlobalStateCubit extends Cubit<GlobalState> {

  GlobalStateCubit() : super(const GlobalState(isLoggedIn: false));

  void login() => emit(const GlobalState(isLoggedIn: true));

  void logout() => emit(const GlobalState(isLoggedIn: false));
}