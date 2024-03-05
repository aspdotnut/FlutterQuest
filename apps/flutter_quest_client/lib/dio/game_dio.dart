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