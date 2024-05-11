import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(HistoryPageApp(
      token: '{"access_token": "your_access_token", "user_id": 123}'));
}

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

class HistoryPage extends StatefulWidget {
  final String token;

  HistoryPage({required this.token});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late String accessToken;
  late int userId;
  late String? status;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final tokenData = jsonDecode(widget.token);
    accessToken = tokenData['access_token'];
    userId = tokenData['user_id'];
    fetchUserStatus(userId, accessToken);
  }

  Future<void> fetchUserStatus(int userId, String token) async {
    try {
      final url = Uri.parse('http://146.190.109.66:8000/get_status/$userId');
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final userStatus = responseData['status']['status'];
        setState(() {
          status = userStatus;
        });
      } else {
        throw Exception('Failed to load status');
      }
    } catch (e) {
      log('Failed to fetch user status: $e');
    }
  }

  Future<void> bayar(int userId, String token) async {
    try {
      final url = Uri.parse('http://146.190.109.66:8000/pembayaran/$userId');
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        log('Pembayaran berhasil');
        // Refresh status after updating
        fetchUserStatus(userId, token);
      } else {
        throw Exception('Pembayaran gagal');
      }
    } catch (e) {
      log('Pembayaran gagal: $e');
    }
  }

  Future<void> setStatusPenjualTerima(int userId, String token) async {
    try {
      final url = Uri.parse(
          'http://146.190.109.66:8000/set_status_penjual_terima/$userId');
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        log('Status penjual diterima berhasil diatur');
        // Refresh status after updating
        fetchUserStatus(userId, token);
      } else {
        throw Exception('Gagal mengatur status penjual diterima');
      }
    } catch (e) {
      log('Gagal mengatur status penjual diterima: $e');
    }
  }

  Future<void> setStatusPenjualTolak(int userId, String token) async {
    try {
      final url = Uri.parse(
          'http://146.190.109.66:8000/set_status_penjual_tolak/$userId');
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        log('Status penjual ditolak berhasil diatur');
        // Refresh status after updating
        fetchUserStatus(userId, token);
      } else {
        throw Exception('Gagal mengatur status penjual ditolak');
      }
    } catch (e) {
      log('Gagal mengatur status penjual ditolak: $e');
    }
  }

  Future<void> setStatusDiantar(int userId, String token) async {
    try {
      final url =
          Uri.parse('http://146.190.109.66:8000/set_status_diantar/$userId');
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        log('Status diantar berhasil diatur');
        // Refresh status after updating
        fetchUserStatus(userId, token);
      } else {
        throw Exception('Gagal mengatur status diantar');
      }
    } catch (e) {
      log('Gagal mengatur status diantar: $e');
    }
  }

  Future<void> setStatusDiterima(int userId, String token) async {
    try {
      final url =
          Uri.parse('http://146.190.109.66:8000/set_status_diterima/$userId');
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        log('Status diterima berhasil diatur');
        // Refresh status after updating
        fetchUserStatus(userId, token);
      } else {
        throw Exception('Gagal mengatur status diterima');
      }
    } catch (e) {
      log('Gagal mengatur status diterima: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation here based on index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('On-Going Orders'),
      ),
      body: Center(
        child: status == null
            ? CircularProgressIndicator()
            : Text('User Status: $status'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
            icon: Icon(Icons.list_alt),
            label: 'On-going Order',
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (status == 'belum_bayar')
            FloatingActionButton.extended(
              onPressed: () {
                bayar(userId, accessToken);
              },
              label: Text('Bayar'),
              icon: Icon(Icons.payment),
            ),
          SizedBox(height: 16),
          if (status == 'terima_bayar')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    setStatusPenjualTerima(userId, accessToken);
                  },
                  label: Text('Set Penjual Terima'),
                  icon: Icon(Icons.check),
                ),
                SizedBox(width: 16),
                FloatingActionButton.extended(
                  onPressed: () {
                    setStatusPenjualTolak(userId, accessToken);
                  },
                  label: Text('Set Penjual Tolak'),
                  icon: Icon(Icons.close),
                ),
                SizedBox(width: 16),
                FloatingActionButton.extended(
                  onPressed: () {
                    setStatusDiantar(userId, accessToken);
                  },
                  label: Text('Set Diantar'),
                  icon: Icon(Icons.local_shipping),
                ),
              ],
            ),
          SizedBox(height: 16),
          if (status == 'diantar')
            FloatingActionButton.extended(
              onPressed: () {
                setStatusDiterima(userId, accessToken);
              },
              label: Text('Pesanan Diterima'),
              icon: Icon(Icons.thumb_up),
            ),
        ],
      ),
    );
  }
}
