import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_otp/email_otp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifyOTPEmailPage extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();

  VerifyOTPEmailPage({Key? key});

  Future<void> _verifyOTPAndCreateUser(
      BuildContext context,
      String name,
      String age,
      String email,
      String password,
      EmailOTP emailOTPInstance,
      String phoneNumber) async {
    try {
      if (await emailOTPInstance.verifyOTP(otp: otpController.text)) {
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': name,
            'age': age,
            'email': email,
            'phoneNumber': phoneNumber,
          });

          Navigator.pushReplacementNamed(context, 'home');
        } else {
          print('User creation failed.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User creation failed. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        print('Invalid OTP.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error verifying OTP and creating user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final String name = args['name'] ?? '';
    final String age = args['age'] ?? '';
    final String email = args['email'] ?? '';
    final String password = args['password'] ?? '';
    final String phoneNumber = args['phoneNumber'] ?? '';
    final EmailOTP emailOTPInstance = args['emailOTPInstance'] as EmailOTP;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                _verifyOTPAndCreateUser(
                  context,
                  name,
                  age,
                  email,
                  password,
                  emailOTPInstance,
                  phoneNumber,
                );
              },
              child: const Text('Verify OTP & Create User'),
            ),
          ],
        ),
      ),
    );
  }
}