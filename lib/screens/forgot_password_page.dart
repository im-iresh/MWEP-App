import 'package:flutter/material.dart';

import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ForgotPasswordPage extends StatefulWidget {
  static const String id = 'forgot_password_screen';
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim());
      showDialog(context: context, builder: (context) {
        return const AlertDialog(
          content: Text('Password reset link sent, check inbox'),
        );
      });
    } on FirebaseAuthException
    catch (e) {
      print(e);
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          content: Text(e.message.toString()),
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                'Enter you email address below and we\'ll send a reset link to it',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            TextField(
                controller: _emailController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Email'
                )
            ),
            const SizedBox(
              height: 8.0,
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: resetPassword,
              color: Colors.lightBlueAccent,
              child: const Text('Reset Password'),
            )
          ],
        ),
      ),
    );
  }
}
