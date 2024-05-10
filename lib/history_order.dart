import 'package:flutter/material.dart';

void main() {
  runApp(HistoryPage());
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          : Center(
              child: Text(
                'Page ${_selectedIndex + 1}',
                style: TextStyle(fontSize: 30),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
