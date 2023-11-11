import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'Role.dart';

class AuthGate extends StatelessWidget {
 const AuthGate({super.key});

 @override
 Widget build(BuildContext context) {
   return StreamBuilder<User?>(
     stream: FirebaseAuth.instance.authStateChanges(),
     builder: (context, snapshot) {
       if (!snapshot.hasData) {
         return SignInScreen(
          showAuthActionSwitch: false,
           providers: [
            EmailAuthProvider(),
           ],
           headerBuilder: (context, constraints, shrinkOffset) {
             return Padding(
               padding: const EdgeInsets.all(10),
               child: Image.asset('assets/dash.png'),
             );
           },
           subtitleBuilder: (context, action) {
             return Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0),
               child: action == AuthAction.signIn
                   ? const Text('Welcome to Atttender, please sign in!')
                   : const Text('Welcome to Attender, please sign up!'),
             );
           },
           footerBuilder: (context, action) {
            //  return const Padding(
            //    padding: EdgeInsets.only(top: 16),
            //    child: Text(
            //      'By signing in, you agree to our terms and conditions.',
            //      style: TextStyle(color: Colors.grey),
            //    ),
            //  );
            return SizedBox();
           },
           sideBuilder: (context, shrinkOffset) {
             return Padding(
               padding: const EdgeInsets.all(20),
               child: AspectRatio(
                 aspectRatio: 1,
                 child: Image.asset('dash.png'),
               ),
             );
           },
         );
       }

       return RoleGate(email: FirebaseAuth.instance.currentUser?.email.toString() ?? "Error");
     },
   );
 }
}