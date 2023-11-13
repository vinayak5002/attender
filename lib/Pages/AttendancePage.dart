import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe_cards/swipe_cards.dart';

import '../Data/Data.dart';

// ignore: must_be_immutable
class AttendancePage extends StatefulWidget {
  final int classIndex;
  final int numStudents;
  final List<String> students;
  final DateTime date;

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

  bool viewListMode = false;
  bool markAllAbsent = false;

  List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;

  int _currentItemIndex = 0;

  void _toggleAttendence(String roll){
    setState(() {
      widget.attendance[roll] = !widget.attendance[roll]!;
    });
  }

  void _leftSwipe(){
    String studentName = widget.students.elementAt(_currentItemIndex);
    widget.attendance[studentName] = false;
  }

  void _rightSwipe(){
    String studentName = widget.students.elementAt(_currentItemIndex);
    widget.attendance[studentName] = true;
  }

  void _revertSwipe(){
    _currentItemIndex--;
    setState(() {
      _swipeItems.insert(0, 
          SwipeItem(
            content: widget.students.elementAt(_currentItemIndex),

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
    for(int i=0; i<widget.students.length; i++) {
      _swipeItems.add(
        SwipeItem(
          content: widget.students.elementAt(i),

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
        actions: <Widget>[
          !viewListMode ?
          IconButton(icon: const Icon(Icons.list), onPressed: (){
            setState(() {
              viewListMode = !viewListMode;
            });
          }) :
          IconButton(icon: const Icon(Icons.copy), onPressed: (){
            setState(() {
              viewListMode = !viewListMode;
            });
          },),
        ],
      ),

      body: 
      !viewListMode ?
      Column(
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
                        style: const TextStyle(fontSize: 30),
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
      ) :
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSwitch(value: markAllAbsent, onChanged: (value) {
              setState(() {
                markAllAbsent = value;
              });
              if(markAllAbsent == true){
                setState(() {
                  for(int i=0; i<widget.students.length; i++) {
                    widget.attendance[widget.students.elementAt(i)] = false;
                  }
                });
              }
              else{
                setState(() {
                  for(int i=0; i<widget.students.length; i++) {
                    widget.attendance[widget.students.elementAt(i)] = true;
                  }
                });
              }
            }),
          ),
          Expanded(
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
                        // _attendanceModified = true;
                      });
                    },
                  ),
                );
              },
            ),
          ),
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