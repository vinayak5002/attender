
import 'dart:collection';

import 'package:attender/Data/Data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ShowAttendancePage extends StatefulWidget {

  final DateTime date;
  final List<String> students;
  final HashMap<String, bool> attendance;
  final String displayDate;

  
 const ShowAttendancePage({Key? key, required this.date, required this.attendance, required this.displayDate, required this.students}) : super(key: key);

  @override
  State<ShowAttendancePage> createState() => _ShowAttendancePageState();
}

class _ShowAttendancePageState extends State<ShowAttendancePage> {

  bool _attendanceModified = false;


  @override
  Widget build(BuildContext context) {
    List<String> sortedStudents = widget.attendance.keys.toList();
    sortedStudents.sort();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayDate),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: widget.students.length,
          itemBuilder: (context, index) {
            String roll = widget.students.elementAt(index);
            bool att = widget.attendance[roll]!;
            return Card(
              color: att ? Colors.green : Colors.redAccent,
              elevation: 15,
              margin: const EdgeInsets.all(4),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                selectedTileColor: Colors.orange[100],
                title: Text(roll),
                leading: att
                 ? const Icon(CupertinoIcons.checkmark_circle)
                 : const Icon(CupertinoIcons.clear_circled),
                onTap: () {
                  setState(() {
                    widget.attendance[roll] = !widget.attendance[roll]!;
                    _attendanceModified = true;
                  });
                },
              ),
            );
          },
        ),
      ),

      floatingActionButton: _attendanceModified
       ? FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          Provider.of<Data>(context, listen: false).storeData();
          Navigator.of(context).pop();
        },
       )
       : null,
    );
  }
}