import 'package:flutter/material.dart';
import 'package:gisapp/pages/home_page.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.blueAccent),
  ));

}

