import 'package:attender/Pages/ShowAttendancePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _beautifyDateTime(DateTime dateTime) {
    final now = DateTime.now();

    if(dateTime.isBefore(now)){
      // Calculate the difference in days
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        // Today
        return '${DateFormat('yMMMMd').format(dateTime)} (Today)';
      } else if (difference.inDays == 1) {
        // Yesterday
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        // Within the last week
        return DateFormat('EEEE').format(dateTime); // Format as day of the week
      } else {
        // More than a week ago
        return DateFormat('yMMMMd').format(dateTime); // Format as full date
      }
    }
    else{
      return DateFormat('yMMMMd').format(dateTime); // Format as full date
    }
  }

  @override
  Widget build(BuildContext context) {
    Class _class = Provider.of<Data>(context).classes[widget.classIndex];

    List<DateTime> sortedDates = _class.attendance?.keys.toList() ?? [];
    sortedDates.sort((a, b) => b.compareTo(a)); // Sort dates in descending order

    return Scaffold(
      appBar: AppBar(
        title: Text(_class.name),
      ),

      body: Center(
        child: _class.attendance == null
        ? const Text("No attendance taken yet")
        : ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              DateTime dt = sortedDates[index];
              return ListTile(
                title: Text(_beautifyDateTime(dt)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ShowAttendancePage(
                        date: dt,
                        attendance: _class.attendance![dt]!,
                        displayDate: _beautifyDateTime(dt),
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text('Do you want to delete this attendance ?'),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                Provider.of<Data>(context, listen: false).deleteAttendance(_class.name, dt);
                              });
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
      ),

      floatingActionButton: ExpandableFab(
        distance: 80,
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
                  
                if(Provider.of<Data>(context, listen: false).classes[widget.classIndex].attendanceTaken(pickedDate)){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text('Do you want to override this days attendance'),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AttendancePage(
                                    numStudents: _class.numStudents,
                                    students: _class.students!,
                                    classIndex: widget.classIndex,
                                    date: pickedDate,
                                  ),
                                ),
                              ).then((value) => setState(() {}));
                            },
                            child: Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );
                }
                else{
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
                }
              } else {
                print("Cancelled");
              }
            },
            icon: const Icon(Icons.calendar_month_outlined)
          ),
          ActionButton(
            onPressed: () {
              if(Provider.of<Data>(context, listen: false).classes[widget.classIndex].attendanceTaken(DateTime.now())){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text('Do you want to override this days attendance'),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AttendancePage(
                                  numStudents: _class.numStudents,
                                  students: _class.students!,
                                  classIndex: widget.classIndex,
                                  date: DateTime.now(),
                                ),
                              ),
                            ).then((value) => setState(() {}));
                          },
                          child: Text('Confirm'),
                        ),
                      ],
                    );
                  },
                );
              }
              else{
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AttendancePage(
                      classIndex: widget.classIndex,
                      date: DateTime.now(),
                      numStudents: _class.numStudents,
                      students: _class.students!,
                    ),
                    maintainState: true,
                  )
                ).then((value) => setState(() {}));
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
