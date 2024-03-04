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
