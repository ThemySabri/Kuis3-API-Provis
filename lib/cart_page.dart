import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class CartItem {
  String name;
  double price;
  int quantity;
  String? imageUrl;
  int cartId; // Add cartId property

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
    required this.cartId, // Pass cartId to the constructor
  });

  double get totalPrice => quantity * price;
}

class _CartPageState extends State<CartPage> {
  int _selectedIndex = 1; // Initialize _selectedIndex here

  late String accessToken;
  late String userId;
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    try {
      if (widget.token == null) {
        print('Token is null');
        return;
      }

      final tokenData = jsonDecode(widget.token!);
      if (tokenData == null || !(tokenData is Map<String, dynamic>)) {
        print('Invalid token format');
        return;
      }

      final accessToken = tokenData['access_token'] as String?;
      final userId =
          tokenData['user_id']?.toString(); // Convert user_id to String

      if (accessToken == null || userId == null) {
        print('Access token or user ID is null');
        return;
      }

      // Fetch all items
      final allItemsResponse = await http.get(
        Uri.parse('http://146.190.109.66:8000/items/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (allItemsResponse.statusCode == 200) {
        final List<dynamic> allItemsData = jsonDecode(allItemsResponse.body);
        final Map<int, dynamic> itemMap =
            {}; // Map to store item data by item_id

        // Store item data in a map by item_id
        for (final itemData in allItemsData) {
          final itemId = itemData['id'] as int;
          itemMap[itemId] = itemData;
        }

        // Fetch cart data
        final cartResponse = await http.get(
          Uri.parse('http://146.190.109.66:8000/carts/$userId'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        // Inside fetchCart method
        if (cartResponse.statusCode == 200) {
          final List<dynamic> cartData = jsonDecode(cartResponse.body);
          final List<CartItem> cartItems = [];

          // Match cart data with item data and create cart items
          for (final itemData in cartData) {
            final itemId = itemData['item_id'] as int;
            final itemDetails = itemMap[itemId];

            if (itemDetails != null) {
              final name = itemDetails['title'] as String?;
              final price = itemDetails['price']?.toDouble() ?? 0.0;
              final quantity = itemData['quantity'] as int;
              final imageUrl = await fetchItemImage(itemId, accessToken);
              final cartId =
                  itemData['id'] as int; // Extract cartId from cart data

              if (name != null) {
                cartItems.add(CartItem(
                  name: name,
                  price: price,
                  quantity: quantity,
                  imageUrl: imageUrl,
                  cartId: cartId, // Pass cartId to the CartItem constructor
                ));
              }
            }
          }

          // Update _cartItems list
          setState(() {
            _cartItems = cartItems;
          });
        } else {
          print('Failed to fetch cart data: ${cartResponse.statusCode}');
        }
      } else {
        print('Failed to fetch all item data: ${allItemsResponse.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<String?> fetchItemImage(int itemId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('http://146.190.109.66:8000/items_image/$itemId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        // Return the image data as a base64 string
        return base64Encode(response.bodyBytes);
      } else {
        print(
            'Failed to fetch item image for item $itemId: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching item image: $error');
      return null;
    }
  }

  int getTotalItems() {
    return _cartItems.fold(0, (int sum, item) => sum + item.quantity);
  }

  void _deleteAllItems() async {
    try {
      final tokenData = jsonDecode(widget.token!);
      final accessToken = tokenData['access_token'] as String?;
      final userId = tokenData['user_id']?.toString(); // Get user_id from token

      if (accessToken == null || userId == null) {
        print('Access token or user ID is null');
        return;
      }

      final deleteResponse = await http.delete(
        Uri.parse(
            'http://146.190.109.66:8000/clear_whole_carts_by_userid/$userId'), // Use the new endpoint
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (deleteResponse.statusCode == 200) {
        setState(() {
          _cartItems
              .clear(); // Clear the _cartItems list after successful deletion
        });
      } else {
        print(
            'Failed to delete all items from cart: ${deleteResponse.statusCode}');
        // Handle error or show message to user
      }
    } catch (error) {
      print('Error deleting all items from cart: $error');
      // Handle error or show message to user
    }
  }

  void _removeItem(CartItem item) async {
    try {
      final tokenData = jsonDecode(widget.token!);
      final accessToken = tokenData['access_token'] as String?;

      if (accessToken == null) {
        print('Access token is null');
        return;
      }

      final deleteResponse = await http.delete(
        Uri.parse(
            'http://146.190.109.66:8000/carts/${item.cartId}'), // Use item.cartId
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (deleteResponse.statusCode == 200) {
        setState(() {
          _cartItems.remove(item);
        });
      } else {
        print('Failed to delete item from cart: ${deleteResponse.statusCode}');
        // Handle error or show message to user
      }
    } catch (error) {
      print('Error removing item from cart: $error');
      // Handle error or show message to user
    }
  }

  void _checkout() async {
    try {
      final tokenData = jsonDecode(widget.token!);
      final accessToken = tokenData['access_token'] as String?;
      final userId = tokenData['user_id']?.toString(); // Get user_id from token

      if (accessToken == null || userId == null) {
        print('Access token or user ID is null');
        return;
      }

      final checkoutResponse = await http.post(
        Uri.parse(
            'http://146.190.109.66:8000/set_status_harap_bayar/$userId'), // Use the new endpoint
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (checkoutResponse.statusCode == 200) {
        // Handle successful checkout, e.g., navigate to a confirmation page
        // Clear the cart items list after successful checkout
        setState(() {
          _cartItems.clear();
        });
        // Show the payment popup
        _showPaymentDialog();
      } else {
        print('Failed to checkout: ${checkoutResponse.statusCode}');
        // Handle error or show message to user
      }
    } catch (error) {
      print('Error during checkout: $error');
      // Handle error or show message to user
    }
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checkout Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Items: ${getTotalItems()}'),
              Text(
                  'Total Price: Rp ${_cartItems.fold(0.0, (double previousValue, item) => previousValue + item.totalPrice).toStringAsFixed(0)}'),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _makePayment(context); // Trigger the payment process
              },
              child: Text('Pay'),
            ),
          ],
        );
      },
    );
  }

  void _makePayment(BuildContext context) async {
    try {
      final tokenData = jsonDecode(widget.token!);
      final accessToken = tokenData['access_token'] as String?;
      final userId = tokenData['user_id']?.toString(); // Get user_id from token

      if (accessToken == null || userId == null) {
        print('Access token or user ID is null');
        return;
      }

      final paymentResponse = await http.post(
        Uri.parse(
            'http://146.190.109.66:8000/pembayaran/$userId'), // Use the new endpoint
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (paymentResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Successful'),
            duration: Duration(seconds: 2), // Adjust the duration as needed
          ),
        );
        // Handle successful payment
        Navigator.of(context).pop(); // Close the current screen
      } else {
        print('Failed to make payment: ${paymentResponse.statusCode}');
        // Handle error or show message to user
      }
    } catch (error) {
      print('Error making payment: $error');
      // Handle error or show message to user
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total items
    int totalItems = getTotalItems();

    // Calculate total price
    double total = _cartItems.fold(
        0.0, (double previousValue, item) => previousValue + item.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                var item = _cartItems[index];
                return Card(
                  margin:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: ListTile(
                    leading: SizedBox(
                      width: 50, // Adjust the width as needed
                      child: item.imageUrl != null
                          ? Image.memory(
                              base64Decode(item.imageUrl!),
                              fit: BoxFit.cover, // Adjust this as needed
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey, // Placeholder color
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name),
                        Text(
                          'Qty: ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ), // Display quantity
                      ],
                    ),
                    subtitle: Text(
                      'Rp ${item.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Color.fromARGB(255, 180, 0, 0),
                          onPressed: () => _removeItem(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Items: $totalItems',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 4), // Penambahan jarak antar teks
                    Text(
                      'Total: Rp ${total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _deleteAllItems(); // Call function to delete all items
                  },
                  child: Text('Delete All'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _checkout(); // Call the checkout function
                  },
                  child: Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
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
              MaterialPageRoute(
                  builder: (context) => AppHomePage(token: widget.token)),
            );
          } else if (index == 2) {
            // Navigate to HistoryPage when History is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HistoryPage(token: widget.token)),
            );
          }
        }, // Handle tap events
      ),
    );
  }
}
