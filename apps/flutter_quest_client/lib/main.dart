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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'dio/dio_util.dart';
import 'login.dart';
import 'game.dart';
import '/cubits/globalstate_cubit.dart';

final GetIt getIt = GetIt.instance;

void setup() {

  getIt.registerLazySingleton<GlobalStateCubit>(() => GlobalStateCubit());

  setupDio();
}

void main() {

  setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GlobalStateCubit>(),
      child: MaterialApp(

        title: 'Flutter Quest',
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Quest Home Page'),

      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<GlobalStateCubit, GlobalState>(

      builder: (context, state) {

        _isLoggedIn = state.isLoggedIn;
        return _isLoggedIn ? const GamePage() : const LoginPage();
      },
    );
  }
}
