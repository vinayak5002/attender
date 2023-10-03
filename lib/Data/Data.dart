import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/Class.dart';

class Data extends ChangeNotifier {

  List<Class> classes = [];

  Data(){
    loadData();
  }

  void deleteAttendance(String cls, DateTime dt){
    classes.firstWhere((e) => e.name == cls).deleteAttendance(dt);
    notifyListeners();
    storeData();
  }

  void loadData() async {
      
    SharedPreferences pref = await SharedPreferences.getInstance();

    List<String>? loadedData = pref.getStringList('classes');

    if(loadedData != null){
      classes = loadedData.map<Class>((e) => Class.fromMap(jsonDecode(e))).toList();
    }
    else{
      classes.add(Class(name: "CSE-E", numStudents: 71));
      classes.add(Class(name: "CSE-F", numStudents: 71));
    }

    notifyListeners();
  }

  void storeData() async {

    List<String> saveList = classes.map(((e) => jsonEncode(Class.toMap(e)))).toList();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setStringList("classes", saveList);

    print("Saved list:");
    print(saveList);
  }
}