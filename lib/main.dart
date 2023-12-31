import 'package:attender/utils/AuthGate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Data/Data.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {  

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        // home: const AuthGate()
        home: const AuthGate(),
      ),
    );
  }
}
