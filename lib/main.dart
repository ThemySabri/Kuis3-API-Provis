import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'app_home_page.dart'; 

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isLoggedIn = false; // Simulate logged-in state
  String? token; // Token received after login

  final String loginApiUrl = 'http://146.190.109.66:8000/login'; // Move API URL here

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Determine initial route based on logged-in state
      initialRoute: isLoggedIn ? '/apphome' : '/login',
      routes: {
        '/login': (context) => LoginPage(
          loginApiUrl: loginApiUrl,
          onLoginSuccess: (String token) {
            setState(() {
              isLoggedIn = true;
              this.token = token;
            });
          },
        ),
        '/signup': (context) => const SignUpPage(),
        '/apphome': (context) => AppHomePage(token: token!),
      },
    );
  }
}
