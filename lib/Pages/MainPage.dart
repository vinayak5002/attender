import 'package:attender/Pages/ClassPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import '../Data/Data.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.email}) : super(key: key);

  final String email;

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
        title: Text(widget.email),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
          )
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            itemCount: Provider.of<Data>(context).classes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // number of items in each row
              mainAxisSpacing: 8.0, // spacing between rows
              crossAxisSpacing: 2.0, // spacing between columns
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ClassPage(classIndex: index),
                    ),
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Provider.of<Data>(context).classes[index].name,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 4,),
                        Text(
                          "Number of students: ${Provider.of<Data>(context).classes[index].numStudents}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
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
                                // Provider.of<Data>(context, listen: false).addClass(classNameController.text, numStudentsController);
                                
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
