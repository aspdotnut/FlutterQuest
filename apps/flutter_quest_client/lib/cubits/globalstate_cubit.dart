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