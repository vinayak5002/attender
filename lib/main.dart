import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Data/Data.dart';
import 'Pages/MainPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(

      providers: [
        ChangeNotifierProvider(create: (context) => Data()),
      ],

      child: MaterialApp(
        title: 'Attender',
        theme: ThemeData.dark().copyWith(
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
          )
        ),
        home: const MyHomePage(title: 'Main page'),
      ),
    );
  }
}
