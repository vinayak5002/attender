import 'package:flutter/cupertino.dart';

import '../Models/Class.dart';

class Data extends ChangeNotifier {

  List<Class> classes = [];

  Data(){
    classes.add(Class(name: "CSE-E", numStudents: 71));
    classes.add(Class(name: "CSE-F", numStudents: 71));
  }
}