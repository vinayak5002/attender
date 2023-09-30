import 'package:attender/Pages/ClassPage.dart';
import 'package:flutter/material.dart';
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
            );
          },
        ),
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),

    );
  }
}
