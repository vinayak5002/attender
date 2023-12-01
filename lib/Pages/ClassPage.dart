import 'dart:collection';
import 'dart:io';

import 'package:attender/Pages/ShowAttendancePage.dart';
import 'package:attender/utils/FileStorage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import 'package:path_provider/path_provider.dart';

import '../Data/Data.dart';
import '../Models/Class.dart';
import '../Models/ExpandableFAB.dart';
import 'AttendancePage.dart';

class ClassPage extends StatefulWidget {
  final int classIndex;

  const ClassPage({super.key, required this.classIndex });

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

  void exportAttendence(){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Export'),
            content: const Text('Export attendance'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  final Workbook workbook = Workbook();
                  Worksheet sheet = workbook.worksheets[0];

                  List<String> stds = Provider.of<Data>(context, listen: false).classes[widget.classIndex].students;

                  for (int i = 0; i < stds.length; i++) {
                    sheet.getRangeByIndex(i + 1, 1).setText(stds[i]);
                  }

                  HashMap<DateTime, HashMap<String, bool>> att = Provider.of<Data>(context, listen: false).classes[widget.classIndex].attendance ?? HashMap<DateTime, HashMap<String, bool>>();

                  att.keys.toList().forEach((element) {
                    if (DateUtils.isSameDay(element, DateTime.now())) {
                      for (int i = 0; i < stds.length; i++) {
                        sheet.getRangeByIndex(i + 1, 2).setText(att[element]![stds[i]] == true ? "P" : "A");
                      }
                    }
                  });

                  String filename = DateTime.now().toString();

                  //ask for permission
                  await Permission.manageExternalStorage.request();
                  var status = await Permission.manageExternalStorage.status;
                  if (status.isDenied) {
                    // We didn't ask for permission yet or the permission has been denied   before but not permanently.
                    return;
                  }

                  // You can can also directly ask the permission about its status.
                  if (await Permission.storage.isRestricted) {
                    // The OS restricts access, for example because of parental controls.
                    return;
                  }
                  if (status.isGranted) {

                    Directory? downloadsDirectory = await getExternalStorageDirectory();

                    Directory? _path = await getExternalStorageDirectory(); 
                    String _localPath = _path!.path + Platform.pathSeparator + Provider.of<Data>(context, listen: false).classes[widget.classIndex].name;
                    final savedDir = Directory(_localPath);
                    bool hasExisted = await savedDir.exists();
                    if (!hasExisted) {
                        savedDir.create();
                    }
                    String headPath = _localPath;

                    if (downloadsDirectory != null) {
                      String filePath = '${headPath}/$filename.xlsx';

                      File file = File(filePath);
                      final List<int> bytes = workbook.saveAsStream();
                      await file.writeAsBytes(bytes);

                      print("File saved at: $filePath");
                      bool fileExists = await File(filePath).exists();
                      if (fileExists) {
                        OpenFile.open(filePath);
                      } else {
                        print('File does not exist.');
                      }
                    } else {
                      print("Unable to access the downloads directory");
                    }


                  }
                  workbook.dispose();
                  Navigator.of(context).pop();
                  return;
                },
                child: const Text('Todays'),
              ),
            ],
          );
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    Class _class = Provider.of<Data>(context).classes[widget.classIndex];

    List<DateTime> sortedDates = _class.attendance?.keys.toList() ?? [];
    sortedDates.sort((a, b) => b.compareTo(a)); // Sort dates in descending order

    return Scaffold(
      appBar: AppBar(
        title: Text(_class.name),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: (() {
              exportAttendence();
            }),
          )
        ],
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
                        students: _class.students,
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
                        actions: <Widget>[ElevatedButton(
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
                  
                // ignore: use_build_context_synchronously
                if(Provider.of<Data>(context, listen: false).classes[widget.classIndex].attendanceTaken(pickedDate)){
                  // ignore: use_build_context_synchronously
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
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AttendancePage(
                                    numStudents: _class.numStudents!,
                                    students: _class.students,
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
                        numStudents: _class.numStudents!,
                        students: _class.students,
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
                                  numStudents: _class.numStudents!,
                                  students: _class.students,
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
                      numStudents: _class.numStudents!,
                      students: _class.students,
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
