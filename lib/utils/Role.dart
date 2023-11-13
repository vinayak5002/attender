import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Data/Data.dart';
import '../Pages/AdminPage.dart';
import '../Pages/MainPage.dart';

class RoleGate extends StatefulWidget {
  const RoleGate({super.key, this.email});

  final email;

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  bool isTeacher = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  void _checkUserRole() {
    getRole(widget.email).then((bool result) {
      if (result) {
        Provider.of<Data>(context, listen: false).logInGetClasses(widget.email);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MyHomePage(email: widget.email),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdminPage(email: widget.email),
          ),
        );
      }
    }).catchError((error) {
      // Handle error, e.g., show an error message or log the error.
      print("Error checking user role: $error");
    });
  }

  Future<bool> getRole(String email) async {
    CollectionReference users = FirebaseFirestore.instance.collection('roles');

    try {
      DocumentSnapshot documentSnapshot = await users.doc(email).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        return data['role'] == 'teacher';
      } else {
        return false;
      }
    } catch (e) {
      // Handle the exception, e.g., show an error message or log the error.
      print("Error getting user role: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/waiting.png"),
      ),
    );
  }
}