import 'package:attender/Pages/ShowAttendancePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Data/Data.dart';
import '../Models/Class.dart';
import '../Models/ExpandableFAB.dart';
import 'AttendancePage.dart';

class ClassPage extends StatefulWidget {
  int classIndex;

  ClassPage({super.key, required this.classIndex });

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {

  static const _actionTitles = ['Pick date', 'Today\'s date'];

  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Class _class = Provider.of<Data>(context).classes[widget.classIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(_class.name)
      ),
      body: Center(
        child: _class.attendance == null ? const Text("No attendance taken yet") :
        ListView.builder(
          itemCount: _class.attendance?.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(Provider.of<Data>(context).classes[widget.classIndex].attendance!.keys.elementAt(index).toString()),
              onTap: () {
                DateTime dt = Provider.of<Data>(context , listen: false).classes[widget.classIndex].attendance!.keys.elementAt(index);
                print("Show attendance");

                print(Provider.of<Data>(context, listen: false).classes[widget.classIndex].attendance![dt]!);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>ShowAttendancePage(
                      date: dt,
                      attendance: Provider.of<Data>(context).classes[widget.classIndex].attendance![dt]!,
                    ),
                  )
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () async {

              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime(2100)
              );

              if (pickedDate != null) {
                print(pickedDate);
                
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AttendancePage(
                      classIndex: widget.classIndex,
                      date: pickedDate,
                      numStudents: _class.numStudents,
                      students: _class.students!,
                    ),
                    maintainState: true,
                  )
                ).then((value) => setState(() {}));
              } else {
                print("Cancelled");
              }
            },
            icon: const Icon(Icons.calendar_month_outlined)
          ),
          ActionButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AttendancePage(
                  classIndex: widget.classIndex,
                  date: DateTime.now(),
                  numStudents: _class.numStudents,
                  students: _class.students!,
                ),
                maintainState: true,
              )
            ).then((value) => setState(() {})),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
