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
