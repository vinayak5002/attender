import 'package:attender/Pages/ClassPage.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import '../Data/Data.dart';
import 'AttendancePage.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final classNameController = TextEditingController();
  int numStudentsController = 1;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Center(
        child: ListView.builder(
          itemCount: Provider.of<Data>(context).classes.length,
          itemBuilder: (context, index){
            return ListTile(
              title: Text(Provider.of<Data>(context).classes[index].name),
              subtitle: Text("Number of students: ${Provider.of<Data>(context).classes[index].numStudents}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ClassPage(classIndex: index),
                  ),
                );
              },

              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmation'),
                      content: const Text('Do you want to delete this Class?'),
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
                              Provider.of<Data>(context, listen: false).deleteClass(Provider.of<Data>(context, listen: false).classes[index].name);
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


      floatingActionButton: FloatingActionButton(
        tooltip: 'Add class',
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            "Create new class",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            padding: const EdgeInsets.fromLTRB(5, 25, 5, 0),
                            child: NumberPicker(
                              minValue: 1,
                              maxValue: 100,
                              value: numStudentsController,
                              step: 1,
                              onChanged: (value) => setState(() => numStudentsController = value),
                              axis: Axis.horizontal,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white),
                              ),
                            ),
                          ),
                  
                          const Expanded(
                            child: SizedBox(
                              width: double.infinity, // Set width to fill available horizontal space
                              height: double.infinity, // Set height to fill available vertical space
                            ),
                          ),
                  
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              child: const Text("Create class"),
                              onPressed: () {
                                Provider.of<Data>(context, listen: false).addClass(classNameController.text, numStudentsController);
                                
                                classNameController.clear();
                                numStudentsController = 1;
                  
                                Navigator.of(context).pop();
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          );
        }
      ),

    );
  }
}
