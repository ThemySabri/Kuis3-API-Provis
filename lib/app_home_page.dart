import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'history_order.dart';
import 'cart_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('App Home Page'),
    );
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

class ItemWithQuantity {
  final Map<String, dynamic> item;
  int quantity;

  ItemWithQuantity(this.item, this.quantity);
}

class AppHomePage extends StatefulWidget {
  final String token;
  const AppHomePage({Key? key, required this.token}) : super(key: key);

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  late String accessToken;
  late int userId; // Declare userId variable

  List<ItemWithQuantity> itemsWithQuantity = [];

  TextEditingController searchController = TextEditingController();

  Map<int, Image> itemImages = {};

  @override
  void initState() {
    super.initState();
    final tokenData = jsonDecode(widget.token);
    accessToken = tokenData['access_token'];
    userId = tokenData['user_id']; // Extract user_id from token
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://146.190.109.66:8000/items'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          itemsWithQuantity = responseData
              .cast<Map<String, dynamic>>()
              .map((item) => ItemWithQuantity(item, 0))
              .toList(); // Initialize quantity to 0
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> searchItems(String keyword) async {
    try {
      if (keyword.isEmpty) {
        await fetchData();
        return;
      }

      final response = await http.get(
        Uri.parse('http://146.190.109.66:8000/search_items/$keyword'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          itemsWithQuantity = responseData
              .cast<Map<String, dynamic>>()
              .map((item) => ItemWithQuantity(item, 0))
              .toList(); // Initialize quantity to 0
        });
      } else {
        print('Failed to search items: ${response.statusCode}');
      }
    } catch (error) {
      print('Error searching items: $error');
    }
  }

  Future<Image> fetchImage(int itemId) async {
    if (!itemImages.containsKey(itemId)) {
      final response = await http.get(
        Uri.parse('http://146.190.109.66:8000/items_image/$itemId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final image = Image.memory(
          response.bodyBytes,
          height: 200,
          fit: BoxFit.fill,
        );
        setState(() {
          itemImages[itemId] = image; // Store fetched image
        });
        return image;
      } else {
        throw Exception('Failed to fetch image: ${response.statusCode}');
      }
    } else {
      return itemImages[itemId]!; // Return cached image
    }
  }

  Future<void> addToCart(int itemId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('http://146.190.109.66:8000/carts/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'item_id': itemId,
          'user_id': userId, // Use extracted user ID
          'quantity': quantity,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added to cart')),
        );
        print('Item added to cart successfully.');
        // Reset item quantity to zero for all items
        setState(() {
          itemsWithQuantity.forEach((item) {
            item.quantity = 0;
          });
        });
      } else {
        print('Failed to add item to cart: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding item to cart: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (value) {
                  searchItems(value);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (itemsWithQuantity.isNotEmpty)
                Column(
                  children: itemsWithQuantity.map((itemWithQuantity) {
                    return FutureBuilder<Image>(
                      future: fetchImage(itemWithQuantity.item['id'] as int),
                      builder: (context, snapshot) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              else if (snapshot.hasError)
                                Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: Center(child: Icon(Icons.error)),
                                )
                              else if (snapshot.hasData)
                                snapshot.data!
                              else
                                Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: Center(child: Placeholder()),
                                ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        itemWithQuantity.item['title'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(itemWithQuantity
                                                  .item['description'] ??
                                              ''),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (itemWithQuantity
                                                            .quantity >
                                                        0) {
                                                      itemWithQuantity
                                                          .quantity -= 1;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey[300],
                                                  ),
                                                  child: Icon(Icons.remove),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                itemWithQuantity.quantity
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    itemWithQuantity.quantity +=
                                                        1;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey[300],
                                                  ),
                                                  child: Icon(Icons.add),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          ElevatedButton(
                                            onPressed: () {
                                              addToCart(
                                                  itemWithQuantity.item['id']
                                                      as int,
                                                  itemWithQuantity.quantity);
                                            },
                                            child: Text('Add to Cart'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              //   SizedBox(height: 20),
              // Text(
              //   'Token: ${widget.token}', // Display the token
              //   style: TextStyle(fontSize: 18),
              // ),
              // SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {
              //     // Implement logout logic here
              //     // Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              //   },
              //   child: Text('Logout'),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0, // Set the initial index
        onTap: (index) {
          if (index == 1) {
            // Navigate to HistoryPage when History is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage(token : widget.token)),
            );
          }
          else if (index == 2) {
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
