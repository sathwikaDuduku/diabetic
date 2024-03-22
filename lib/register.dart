import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_otp/email_otp.dart';

class SignupPage extends StatefulWidget {
  SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String otpMethod = 'phone';

  Future<void> _sendOTP(BuildContext context) async {
    try {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      if (otpMethod == 'phone') {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+${phoneController.text}',
          verificationCompleted: (PhoneAuthCredential credential) async {},
          verificationFailed: (FirebaseAuthException e) {
            print('Phone number verification failed: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) async {
            Navigator.pushReplacementNamed(
              context,
              'otp_verification', // Update with the correct route
              arguments: {
                'verificationId': verificationId,
                'phoneNumber': phoneController.text,
                'name': nameController.text,
                'age': ageController.text,
                'email': emailController.text,
                'password': passwordController.text,
              },
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
        // ... (Remaining phone authentication logic)
      } else if (otpMethod == 'email') {
        EmailOTP myauth = EmailOTP();
        myauth.setConfig(
          appEmail: "me@rohitchouhan.com",
          appName: "Email OTP",
          userEmail: emailController.text,
          otpLength: 6,
          otpType: OTPType.digitsOnly,
        );

        if (await myauth.sendOTP() == true) {
          Navigator.pushReplacementNamed(
            context,
            'otp_verify_email',
            arguments: {
              'phoneNumber': phoneController.text,
              'name': nameController.text,
              'age': ageController.text,
              'email': emailController.text,
              'password': passwordController.text,
              'emailOTPInstance': myauth, // Pass the EmailOTP instance
            },
          );
          // ... (Remaining email authentication logic)
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oops, OTP send failed'),
            ),
          );
        }
      }
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup Page'),
        backgroundColor: Colors.orange[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20),
            _buildTextFieldWithIcon(nameController, 'Name', Icons.person),
            SizedBox(height: 10),
            _buildTextFieldWithIcon(ageController, 'Age', Icons.calendar_today),
            SizedBox(height: 10),
            _buildTextFieldWithIcon(emailController, 'Email', Icons.email),
            SizedBox(height: 10),
            _buildTextFieldWithIcon(phoneController, 'Phone Number', Icons.phone),
            SizedBox(height: 10),
            _buildTextFieldWithIcon(passwordController, 'Password', Icons.lock, obscureText: true),
            SizedBox(height: 10),
            _buildTextFieldWithIcon(confirmPasswordController, 'Confirm Password', Icons.lock, obscureText: true),
            SizedBox(height: 10),
            Row(
              children: [
                Radio(
                  value: 'phone',
                  groupValue: otpMethod,
                  onChanged: (value) {
                    setState(() {
                      otpMethod = value as String;
                    });
                  },
                ),
                Text('Phone'),
                Radio(
                  value: 'email',
                  groupValue: otpMethod,
                  onChanged: (value) {
                    setState(() {
                      otpMethod = value as String;
                    });
                  },
                ),
                Text('Email'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _sendOTP(context);
              },
              child: Text('Send OTP'),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon(TextEditingController controller, String labelText, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}

