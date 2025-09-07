import 'package:flutter/material.dart';
import './ForgotPassword.dart'; // Email reset page
import './ForgotPasswordforOTP.dart'; // Phone OTP reset page

class ForgotPasswordOptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose how you'd like to reset your password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            // Option 1: Reset via Email
            ElevatedButton.icon(
              icon: Icon(Icons.email),
              label: Text("Reset via Email"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
              },
            ),
            SizedBox(height: 20),

            // Option 2: Reset via Phone (OTP)
            ElevatedButton.icon(
              icon: Icon(Icons.sms),
              label: Text("Reset via Phone (OTP)"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordWithOTP()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
