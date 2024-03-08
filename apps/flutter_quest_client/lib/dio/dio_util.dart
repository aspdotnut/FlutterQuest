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

import '/cubits/globalstate_cubit.dart';
import '/data/shared_prefs.dart';

Dio dio = Dio(
  BaseOptions(
    baseUrl: 'http://localhost:6969',
  ),
);

Dio refreshTokenDio = Dio(
  BaseOptions(
    baseUrl: 'http://localhost:6969'
  ),
);

final cubit = GetIt.instance<GlobalStateCubit>();

bool isDioSetup = false;

bool isRefreshingToken = false;

void setupDio() {
  if (!isDioSetup) {

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path == '/account/refresh') {
            return handler.next(options);
          }
          String? accessToken = await getPrefs('accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            if (!isRefreshingToken) {
              isRefreshingToken = true;
              bool isSuccessfulRefresh = await refreshToken();
              isRefreshingToken = false;

              if (isSuccessfulRefresh) {
                final opts = e.requestOptions;
                String? newAccessToken = await getPrefs('accessToken');
                opts.headers['Authorization'] = 'Bearer $newAccessToken';
                dio.fetch(opts).then(
                      (r) => handler.resolve(r),
                  onError: (e) => handler.reject(e),
                );
              } else {
                await handleFailedRefresh();
                handler.reject(e);
              }
            } else {
              handler.reject(e);
            }
          } else {
            handler.next(e);
          }
        },
      ),
    );
    isDioSetup = true;
  }
}

Future<bool> refreshToken() async {

  try {
    String? refreshToken = await getPrefs('refreshToken');
    if (refreshToken == null) return false;

    Response response = await refreshTokenDio.post(
      '/account/refresh',
      options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
    );

    String newAccessToken = response.data['accessToken'];
    String newRefreshToken = response.data['refreshToken'];
    await setPrefs('accessToken', newAccessToken);
    await setPrefs('refreshToken', newRefreshToken);
    return true;
  } catch (e) {
    return false;
  }
}

Future<void> handleFailedRefresh() async {

  await removePrefs('name');
  await removePrefs('accessToken');
  await removePrefs('refreshToken');
  cubit.logout();
}

Future<String> fetchData(String path) async {

  try {
    Response response = await dio.get(path);
    return response.data.toString();
  } on DioException {
    rethrow;
  }
}

Future<String> postData(String path, dynamic data) async {

  try {
    Response response = await dio.post(path, data: data);
    return response.data.toString();
  } on DioException {
    rethrow;
  }
}