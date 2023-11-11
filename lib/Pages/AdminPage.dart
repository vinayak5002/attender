import 'package:attender/Pages/admin/AddClass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key, this.email});

  final email;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getClasses();
  }

  Map<String, String> classList = {};
  void getClasses() async {
    CollectionReference classes = FirebaseFirestore.instance.collection("classes");

    Map<String, String> temp = {};

    try {
      QuerySnapshot querySnapshot = await classes.get();
      querySnapshot.docs.forEach((doc) {
        temp[doc.id] = doc["teacher"];
        print("${doc.id} -> ${doc["teacher"]}");
      });
    } catch (e) {
      print("Error getting classes: $e");
    }

    setState(() {
      classList = temp;
    });
  }

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

      body: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: <Widget>[
              Card(
                child: InkWell(
                  onTap: () {
                  },
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.add, size: 70),
                        Text("Add account")
                      ],
                    ),
                  ),
                ),
              ),
          
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddClass(),
                      )
                    );
                  },
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.add, size: 70),
                        Text("add class")
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          classList.isNotEmpty ? ListView.builder(
            shrinkWrap: true,
            itemCount: classList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(classList.keys.toList()[index]),
                subtitle: Text(classList.values.toList()[index]),
              );
            },
          ) : SizedBox()
        ],
      ),
    );
  }
}