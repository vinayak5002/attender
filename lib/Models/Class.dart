

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
    
    // save the attendance whith only the date not not including the time
    this.attendance![DateTime(date.year, date.month, date.day)] = HashMap.from(attendance);
  }

  bool attendanceTaken(DateTime dt){
    // check if the attendance is take while check only the date and ignoring the time
    return attendance!.keys.any((element) => element.year == dt.year && element.month == dt.month && element.day == dt.day);
  }

}