import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/Class.dart';

class Data extends ChangeNotifier {

  String email = "";

  List<Class> classes = [];

  Data(){
    loadData();
  }

  Future<void> logInGetClasses(String email) async {
    this.email = email;

    loadData();

    notifyListeners();

    CollectionReference classCollection = FirebaseFirestore.instance.collection("classes");
    
    Map<String, List<String>> classNames = {};

    try {
      QuerySnapshot querySnapshot = await classCollection.get();
      querySnapshot.docs.forEach((doc) {
        if(doc["teacher"] == email){
          print(doc["students"]);
          List<String> students = (doc["students"] as List<dynamic>).cast<String>();
          classNames[doc.id.toString()] = students;
        }
      });
    } catch (e) {
      print("Error getting classes: $e");
    }

    // check if any new classes have been added
    classNames.forEach((key, value) {
      // if(! classes.any((element) => element.name == key)){
      //   classes.add(Class(name: key, students: value));
      //   print("Class getting added");
      // }
      print(key);
    });
    classes.forEach(((element) => print(element.name)));

    notifyListeners();
  } 

  void deleteAttendance(String cls, DateTime dt){
    classes.firstWhere((e) => e.name == cls).deleteAttendance(dt);
    notifyListeners();
    storeData();
  }

  void addClass(String name, List<String> students){
    classes.add(Class(name: name, students: students));
    notifyListeners();
    storeData();
  }

  void deleteClass(String name){
    classes.removeWhere((e) => e.name == name);
    notifyListeners();
    storeData();
  }

  void loadData() async {
      
    SharedPreferences pref = await SharedPreferences.getInstance();

    List<String>? loadedData = pref.getStringList('classes');

    print(loadedData);

    if(loadedData != null){
      classes = loadedData.map<Class>((e) => Class.fromMap(jsonDecode(e))).toList();
    }
    else{
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