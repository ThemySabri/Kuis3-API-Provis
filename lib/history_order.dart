import 'package:flutter/material.dart';
import 'app_home_page.dart';
import 'cart_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class HistoryPageApp extends StatelessWidget {
  final String token;

  HistoryPageApp({required this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HistoryPage(token: token),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final String token;

  HistoryPage({required this.token});

  @override
  Widget build(BuildContext context) {
    return MyHomePage(token: token);
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String token;

  MyHomePage({required this.token});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String accessToken;
  late int userId;

  @override
  void initState() {
    super.initState();
    final tokenData = jsonDecode(widget.token);
    accessToken = tokenData['access_token'];
    userId = tokenData['user_id'];
    fetchData();
  }

  void fetchData() {
    // Asumsi fetchData melakukan sesuatu dengan accessToken dan userId
    print('Access Token: $accessToken');
    print('User ID: $userId');
  }

  int _selectedIndex = 2; // default to history tab

  List<Map<String, dynamic>> _orders = [
    {
      'id': 1,
      'date': 'May 10, 2024',
      'items': ['Pizza', 'Burger', 'Fries'],
      'total': 20,
    },
    {
      'id': 2,
      'date': 'May 9, 2024',
      'items': ['Sushi', 'Ramen', 'Salad'],
      'total': 30,
    },
    {
      'id': 3,
      'date': 'May 8, 2024',
      'items': ['Taco', 'Burrito', 'Guacamole'],
      'total': 15,
    },
    {
      'id': 4,
      'date': 'May 7, 2024',
      'items': ['Pasta', 'Garlic Bread', 'Salad'],
      'total': 25,
    },
    {
      'id': 5,
      'date': 'May 6, 2024',
      'items': ['Steak', 'Mashed Potatoes', 'Green Beans'],
      'total': 40,
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),

      body: _selectedIndex == 2
          ? ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: ListTile(
                      leading: Icon(Icons.fastfood),
                      title: Text('Order #${_orders[index]['id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Date: ${_orders[index]['date']}'),
                          Text(
                              'Items: ${(_orders[index]['items'] as List).join(', ')}'),
                          Text('Total: \$${_orders[index]['total']}'),
                        ],
                      ),
                      onTap: () {
                        // Implement onTap logic if needed
                      },
                    ),
                  ),
                );
              },
            )
          : SizedBox(), // replaced the Center widget with SizedBox
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2, // Set the initial index
        onTap: (index) {
          if (index == 0) {
            // Navigate to AppHomePage when Cart is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AppHomePage(token: widget.token)),
            );
          } else if (index == 1) {
            // Navigate to AppHomePage when Cart is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CartPage(token: widget.token)),
            );
          }
        }, // Handle tap events
      ),
    );
  }
}

class UserSession {
  static final _storage = FlutterSecureStorage();

  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
}
