
import 'dart:collection';

import 'package:attender/Models/AttTile.dart';
import 'package:flutter/material.dart';


class ShowAttendancePage extends StatefulWidget {

  DateTime date;
  HashMap<String, bool> attendance;

  
 ShowAttendancePage({Key? key, required this.date, required this.attendance}) : super(key: key);

  @override
  State<ShowAttendancePage> createState() => _ShowAttendancePageState();
}

class _ShowAttendancePageState extends State<ShowAttendancePage> {
  @override
  Widget build(BuildContext context) {
    List<String> sortedStudents = widget.attendance.keys.toList();
    sortedStudents.sort((a, b) {
      int numA = int.tryParse(a) ?? 0; // Convert string to integer or use 0 if not a valid number
      int numB = int.tryParse(b) ?? 0;

      return numA - numB; // Compare as numbers
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance"),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: widget.attendance.values.length,
          itemBuilder: (context, index) {
            String roll = sortedStudents.elementAt(index);
            return ListTile(
              title: Text(roll),
              trailing: Checkbox(
                value: widget.attendance[roll],
                onChanged: (bool? value) {  },
              ),
            );
          },
        ),
      ),
    );
  }
}