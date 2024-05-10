import 'package:flutter/material.dart';

class AppHomePage extends StatelessWidget {
  final String token; // Define a variable to hold the token
  const AppHomePage({Key? key, required this.token}) : super(key: key); // Add the token parameter to the constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the App!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Token: $token', // Display the token
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement logout logic here
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
