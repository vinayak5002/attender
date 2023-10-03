

import 'dart:collection';

import 'package:attender/Models/AttTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:swipe_cards/swipe_cards.dart';

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

  List<SwipeItem> _swipeItems = <SwipeItem>[];
  List<String> sortedStudents = [];
  MatchEngine? _matchEngine;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _currentItemIndex = 0;

  void _toggleAttendence(String roll){
    print("Call back");
    print("Roll: ${roll}");
    setState(() {
      widget.attendance[roll] = !widget.attendance[roll]!;
    });
    print(widget.attendance);
  }

  void _leftSwipe(){
    String studentName = sortedStudents.elementAt(_currentItemIndex);
    widget.attendance[studentName] = false;
  }

  void _rightSwipe(){
    String studentName = sortedStudents.elementAt(_currentItemIndex);
    widget.attendance[studentName] = true;
  }

  void _revertSwipe(){
    _currentItemIndex--;
    setState(() {
      _swipeItems.insert(0, 
          SwipeItem(
            content: sortedStudents.elementAt(_currentItemIndex),

            likeAction: () {
              _rightSwipe();
            },
            
            nopeAction: () {
              _rightSwipe();
            },

            superlikeAction: () {
            },
          )
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    sortedStudents = widget.attendance.keys.toList();
    sortedStudents.sort((a, b) {
      int numA = int.tryParse(a) ?? 0; // Convert string to integer or use 0 if not a valid number
      int numB = int.tryParse(b) ?? 0;

      return numA - numB; // Compare as numbers
    });

    for(int i=0; i<sortedStudents.length; i++) {
      _swipeItems.add(
        SwipeItem(
          content: sortedStudents.elementAt(i),

          likeAction: () {
            _rightSwipe();
          },
          
          nopeAction: () {
            _leftSwipe();
          },

          superlikeAction: () {
          },

        )
      );
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<Data>(context).classes[widget.classIndex].name),
      ),

      body: Column(
        children: [
          Expanded(
            flex: 16,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight,
                child: SwipeCards(
                  // itemChanged: 
                  matchEngine: _matchEngine!,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.blue,
                      child: Text(
                        _swipeItems[index].content,
                        style: const TextStyle(fontSize: 100),
                      ),
                    );
                  },
                  onStackFinished: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Stack Finished"),
                      duration: Duration(milliseconds: 500),
                    ));
                  },
                  itemChanged: (SwipeItem item, int index) {
                    print("item: ${item.content}, index: $index");
                    _currentItemIndex++;
                  },
          
                  leftSwipeAllowed: true,
                  rightSwipeAllowed: true,
                  upSwipeAllowed: false,
                  fillSpace: true,
                  
                  likeTag: Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.green)
                    ),
                    child: Text('Like'),
                  ),
                  nopeTag: Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.red)
                    ),
                    child: Text('Nope'),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: ElevatedButton(
                onPressed: () {
                  _revertSwipe();
                },
                child: Text("Revert"),
              ),
            ),
          )
        ],
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<Data>(context, listen: false).classes[widget.classIndex].saveAttendance(widget.attendance, widget.date);
          Provider.of<Data>(context, listen: false).storeData();
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),

    );
  }
}