import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinput/pinput.dart';

class VerifyOTPPage extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();

  VerifyOTPPage({Key? key});

  Future<void> _verifyOTPAndCreateUser(
      BuildContext context,
      String verificationId,
      String smsCode,
      String name,
      String age,
      String email,
      String password,
      String phoneNumber) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'age': age,
          'email': email,
          'phoneNumber': phoneNumber,
        });

        Navigator.pushReplacementNamed(context, 'home');
      } else {
        print('User not found or verification failed.');
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
    final String verificationId = args['verificationId'];
    final String name = args['name'];
    final String age = args['age'];
    final String email = args['email'];
    final String password = args['password'];
    final String phoneNumber = args['phoneNumber'];

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                fillColor: Colors.orange,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Pinput(
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              showCursor: true,
              onCompleted: (pin) {
                _verifyOTPAndCreateUser(
                  context,
                  verificationId,
                  pin,
                  name,
                  age,
                  email,
                  password,
                  phoneNumber,
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                _verifyOTPAndCreateUser(
                  context,
                  verificationId,
                  otpController.text,
                  name,
                  age,
                  email,
                  password,
                  phoneNumber,
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
              child: const Text(
                'Verify OTP & Create User',
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
