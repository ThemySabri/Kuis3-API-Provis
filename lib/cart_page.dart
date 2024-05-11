import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CartPage(),
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

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
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
              ));
        },
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
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
