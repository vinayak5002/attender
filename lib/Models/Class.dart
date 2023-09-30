

import 'dart:collection';

class Class {

  String name;
  int numStudents;
  List<String>? students;
  HashMap<DateTime, HashMap<String, bool>>? attendance;
  
  Class({
    required this.name,
    required this.numStudents
  }){
    students = List.generate(numStudents, (index) => (index+1).toString());

    attendance = HashMap<DateTime, HashMap<String, bool>>();
  }

  void saveAttendance(HashMap<String, bool> attendance, DateTime date){
    print("Saving attendance");
    print(attendance);
    this.attendance![date] = HashMap.from(attendance);
  }

}