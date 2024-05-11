import 'package:flutter/material.dart';
import 'app_home_page.dart';
import 'history_order.dart';

class CartPageApp extends StatelessWidget {
  final String token;

  CartPageApp({required this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CartPage(token: token),
    );
  }
}

class CartPage extends StatefulWidget {
  final String token;

  CartPage({required this.token});

  @override
  _CartPageState createState() => _CartPageState();
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

// Model for cart items
class CartItem {
  String name;
  double price;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => quantity * price;
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [
    CartItem(name: 'Kupat Tahu', price: 15000),
    CartItem(name: 'Pecel Lele', price: 20000),
    CartItem(name: 'Nasi Goreng', price: 25000),
  ];

  int _selectedIndex = 1; // Default to Cart

  int getTotalItems() {
    return _cartItems.fold(0, (int sum, item) => sum + item.quantity);
  }

  void _incrementQuantity(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void _decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      setState(() {
        item.quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = _cartItems.fold(0.0,
        (double previousValue, element) => previousValue + element.totalPrice);
    int totalItems = getTotalItems();

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
      ),
      body: ListView.builder(
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          var item = _cartItems[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text('Rp ${item.price.toStringAsFixed(2)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => _decrementQuantity(item),
                  ),
                  Text(item.quantity.toString()),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _incrementQuantity(item),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            // Navigate to AppHomePage when Home is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppHomePage(token: widget.token)),
            );
          }
          else if (index == 2) {
            // Navigate to HistoryPage when History is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryPage(token: widget.token)),
            );
          }
        }, // Handle tap events
      ),
      bottomSheet: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Items: $totalItems',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 4), // Penambahan jarak antar teks
                        Text(
                          'Total: Rp ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle checkout
                    },
                    child: Text('Checkout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
