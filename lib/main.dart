import 'package:flutter/material.dart';
import 'package:gisapp/pages/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: HomePage(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.blueAccent),
    );
  }
}



