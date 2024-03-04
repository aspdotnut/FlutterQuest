import 'dart:convert';

import 'dio_util.dart';

Future<void> authcheck() async {

  try {
    String response = await fetchData('/account/authcheck');
    print(response);
  }
  catch (e) {
    print(e);
  }
}

Future<void> move(key) async {

  try {
    final data = jsonEncode({'direction': key});
    String response = await postData('/movement/move', data);
    print(response);
  }
  catch (e) {
    print(e);
  }
}