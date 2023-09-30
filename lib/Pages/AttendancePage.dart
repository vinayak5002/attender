

import 'dart:collection';

import 'package:attender/Models/AttTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../Data/Data.dart';
import '../Models/Class.dart';

class AttendancePage extends StatefulWidget {
  int classIndex;
  int numStudents;
  List<String> students;
  DateTime date;

  late HashMap<String, bool> attendance;

  AttendancePage({
    Key? key,
    required this.classIndex,
    required this.date,
    required this.numStudents,
    required this.students
  }) : super(key: key) {
    attendance = HashMap.from({
      for (var key in List.from(students))
        key: true
    });
  }


  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {


  @override
  Widget build(BuildContext context) {

    void attend(String roll){
      print("Call back");
      print("Roll: ${roll}");
      setState(() {
        widget.attendance[roll] = !widget.attendance[roll]!;
      });
      print(widget.attendance);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<Data>(context).classes[widget.classIndex].name),
      ),

      body: Center(
        child: ListView.builder(
          itemCount: Provider.of<Data>(context).classes[widget.classIndex].numStudents,
          addAutomaticKeepAlives: true,
          itemBuilder: (context, index) {
            String studentName = Provider.of<Data>(context).classes[widget.classIndex].students![index];
            return AttTile(
              roll: studentName,
              attend: () => attend(studentName)
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<Data>(context, listen: false).classes[widget.classIndex].saveAttendance(widget.attendance, widget.date);
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),

    );
  }
}