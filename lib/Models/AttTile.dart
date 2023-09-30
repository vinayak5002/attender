
import 'package:flutter/material.dart';

class AttTile extends StatefulWidget {

  String roll;
  final VoidCallback attend;

  AttTile({Key? key, required this.roll, required this.attend}) : super(key: key);

  @override
  State<AttTile> createState() => _AttTileState();
}

class _AttTileState extends State<AttTile> with AutomaticKeepAliveClientMixin {

  bool present = true;

  void changeColor(){
    setState(() {
      present = !present;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("Tap Tap");
        changeColor();
        widget.attend();
      },
      child: ListTile(
        tileColor: present ? Colors.green : Colors.grey,
        title: Text(widget.roll),
        trailing: Checkbox(
          value: present,
          onChanged: (bool? value) {  },
        ),
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}