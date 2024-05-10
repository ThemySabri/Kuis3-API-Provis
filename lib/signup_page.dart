import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart'; // Import the LoginPage class
import 'app_home_page.dart'; // Import your app home page


class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  final String apiUrl = 'http://146.190.109.66:8000/users/';

  Future<void> signUp(BuildContext context, String username, String password) async {
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
        // Successful sign-up, show alert dialog and navigate to login page
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sign-up Successful'),
              content: Text('You have successfully signed up!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(
                          loginApiUrl: apiUrl,
                          onLoginSuccess: (token) {
                            // Handle login success
                            // For example, you can navigate to the app home page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => AppHomePage(token: token)),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
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
                title: Text('Sign-up Error'),
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
          print('Failed to sign up: ${response.reasonPhrase}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      // Handle exceptions
      print('Exception during sign-up: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Page'),
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
                signUp(context, username, password); // Pass the context here
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
