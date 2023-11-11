

import 'dart:io';
// import 'dart:mirrors';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';



class AddClass extends StatefulWidget {
  const AddClass({super.key});

  @override
  State<AddClass> createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTeachers();
  }

  List<String> teachersList = [];
  String selectedTeacherName = "";
  void getTeachers() async {
    print("Getting teachers");

    print("Teachers List 0:");
    print(teachersList);

    CollectionReference users = FirebaseFirestore.instance.collection("roles");

    List<String> temp = [];

    try {
      QuerySnapshot querySnapshot = await users.get();
      querySnapshot.docs.forEach((doc) {
        if (doc["role"] == "teacher") {
          if(!teachersList.contains(doc.id)){
            temp.add(doc.id);
          }
          print(doc.id);
        }
      });
    } catch (e) {
      print("Error getting teachers: $e");
    }

    setState(() {
      teachersList = temp;
    });

    selectedTeacherName = teachersList[0];
  }

  final classNameController = TextEditingController();
  int numStudentsController = 1;

  List<String> studentsList = [];

  late Excel selectedExcel;
  var sheetname;
  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path ?? "");

      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      selectedExcel = excel;
      //print(selectedExcel["Sheet1"].sheetName);
      Sheet sheet = selectedExcel["Sheet1"];
      sheetname = sheet.sheetName;

      getList();
    } else {
      // User canceled the picker
    }
  }

  getList() async {
    //tbleRows.clear();
    List<String> temp = [];

    //print(selectedExcel["Sheet1"].rows.length);
    for (var row in selectedExcel[sheetname].rows) {
      print(row[0]?.value);
      temp.add(row[0]!.value.toString());
    }

    print("Teachers List 0:");
    print(teachersList);

    setState(() {
      studentsList = temp;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Class"),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
        children: [
          const Text(
            "Create new class",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
              
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
            child: TextField(
              controller: classNameController,
              decoration: const InputDecoration(
                hintText: "Class name",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent)
                ),
                filled: true,
              ),
              onChanged: (value) {
                // Provider.of<Data>(context, listen: false).newClassName = value;/
              },
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ButtonBar(
              layoutBehavior: ButtonBarLayoutBehavior.constrained,
              alignment: MainAxisAlignment.center,
      
              children: [
                ElevatedButton(
                  child: Text("Import from Excel"),
                  onPressed: () {
                    pickFile();
                  },
                ),
                studentsList.isNotEmpty ? ElevatedButton(
                  child: Text("ViewStudents"),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder:  (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Center(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(30),
                                itemCount: studentsList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(studentsList[index]),
                                  );
                                },
                              ),
                            );
                          }
                        );
                      }
                    );
                  },
                ): SizedBox(),
              ]
            ),
          ),
      
          const Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
            child: Text("Number of students"),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: NumberPicker(
              minValue: 0,
              maxValue: 100,
              value: studentsList.length,
              step: 1,
              onChanged: (value) => setState(() => numStudentsController = value),
              axis: Axis.horizontal,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
              ),
            ),
          ),
              
          const Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Text("Select teacher"),
          ),
          teachersList.isNotEmpty ?
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            child: DropdownButton(
              value: teachersList[0],
              items: teachersList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: Text('Teachers'),
              onChanged: (String? value) {
                selectedTeacherName = value!.toString();
                print("Select teacher = $selectedTeacherName");
              },
              isExpanded: true,
            )
          ):SizedBox(),
      
              
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                child: const Text("Create class"),
                onPressed: () {
                  //TODO

                  if( classNameController.text != "" && studentsList.isNotEmpty && selectedTeacherName != "" ){
                    print("Creating class");
                    print("Class name: ${classNameController.text}");
                    print("Students: $studentsList");
                    print("Teacher: $selectedTeacherName");

                    CollectionReference classes = FirebaseFirestore.instance.collection("classes");
                    classes.doc(classNameController.text).set({
                      "students": studentsList,
                      "teacher": selectedTeacherName,
                    }).then((value) {
                      print("Class created");
                      Navigator.pop(context);
                    }).catchError((error) {
                      print("Failed to create class: $error");
                    });
                  }

                },
              ),
            ),
          )
        ],
      ),
    );
  }
}