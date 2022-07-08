import 'dart:convert';
import 'package:http/http.dart' as http;
import 'datamodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<ML> fetchValue() async {
  User? user = FirebaseAuth.instance.currentUser; //Access Firebase Auth data
  String? uid = FirebaseAuth.instance.currentUser?.uid
      .toString(); //Save current UID Login info
  final response = await http
      .get(Uri.parse('https://fitech-app.herokuapp.com/api/recommend/$uid'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return ML.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load value');
  }
}
