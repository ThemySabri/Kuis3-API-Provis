import 'dart:convert';
import 'package:flutter/material.dart';
import 'signup_page.dart'; // Import the SignUpPage class
import 'package:http/http.dart' as http;
import 'app_home_page.dart'; // Import your app home page

class LoginPage extends StatelessWidget {
  final String loginApiUrl;
  final Function(String) onLoginSuccess;

  const LoginPage({Key? key, required this.loginApiUrl, required this.onLoginSuccess}) : super(key: key);

  final String apiUrl = 'http://146.190.109.66:8000/login';

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String username = usernameController.text;
                String password = passwordController.text;
                login(context, username, password); // Call login function
              },
              child: Text('Login'),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Navigate to the sign-up page using Navigator.of(context)
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpPage()));
              },
              child: Text(
                'Don\'t have an account? Sign up here',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login(BuildContext context, String username, String password) async {
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Successful login
        print('Login successful!');
        // Parse JSON response
        String token = response.body;
        print('Token: $token');
        // Navigate to the app home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AppHomePage(token: token)),
        );
      } else {
        // Handle errors
        Map<String, dynamic> errorResponse = jsonDecode(response.body);
        if (errorResponse.containsKey('detail')) {
          // Show error message to the user
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Login Error'),
                content: Text(errorResponse['detail']),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Handle other errors
          print('Failed to log in: ${response.reasonPhrase}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      // Handle exceptions
      print('Exception during login: $e');
    }
  }
}
