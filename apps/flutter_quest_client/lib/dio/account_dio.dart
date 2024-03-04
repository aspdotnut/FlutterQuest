import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'dart:convert';

import '/cubits/globalstate_cubit.dart';
import '/data/shared_prefs.dart';

final cubit = GetIt.instance<GlobalStateCubit>();

Dio dio = Dio(
  BaseOptions(
    baseUrl: 'http://localhost:6969',
  ),
);

Future<void> register(String name, String password) async {

  try {

    final response = await dio.post(
      '/account/register',
      data: jsonEncode({'name': name, 'password': password}),
    );

    if (response.statusCode == 200) {
      final String accessToken = response.data['accessToken'];
      final String refreshToken = response.data['refreshToken'];
      await setPrefs('name', name);
      await setPrefs('accessToken', accessToken);
      await setPrefs('refreshToken', refreshToken);
      cubit.login();
    }
  }
  catch (e) {
    print('Register error: $e');
  }
}

Future<void> logIn(String name, String password) async {

  try {

    final response = await dio.post(
      '/account/login',
      data: jsonEncode({'name': name, 'password': password}),
    );

    if (response.statusCode == 200) {
      final String accessToken = response.data['accessToken'];
      final String refreshToken = response.data['refreshToken'];
      await setPrefs('name', name);
      await setPrefs('accessToken', accessToken);
      await setPrefs('refreshToken', refreshToken);
      cubit.login();
    }
  }
  catch (e) {
    print('Login error: $e');
  }
}

Future<void> logOut() async {
  await removePrefs('name');
  await removePrefs('accessToken');
  await removePrefs('refreshToken');
  cubit.logout();
}
