import 'dart:io';
import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/product_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DBHelper _dbHelper = DBHelper();
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final session = await _dbHelper.getCurrentSession();
    setState(() {
      _userId = session?['current_user_id'];
      _userName = session?['current_user_name'] ?? 'Guest';
      _userEmail = session?['current_user_email'] ?? 'guest@xmu.edu.my';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Center')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_userEmail, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.bookmark_border, color: Colors.teal),
            title: const Text('My Listed Items'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (_userId != null) {
                _navigateToProductList(
                  'My Listed Items',
                  _dbHelper.getMyListedItems(_userId!),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.favorite_border, color: Colors.teal),
            title: const Text('My Favorites'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (_userId != null) {
                _navigateToProductList(
                  'My Favorites',
                  _dbHelper.getMyFavorites(_userId!),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _navigateToProductList(
    String pageTitle,
    Future<List<Product>> dataFetchMethod,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(pageTitle)),
          body: FutureBuilder<List<Product>>(
            future: dataFetchMethod,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No item logs found under this tab.'),
                );
              }
              final items = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  return Card(
                    child: ListTile(
                      leading: product.imagePath != null
                          ? Image.file(
                              File(product.imagePath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.shopping_bag, color: Colors.teal),
                      title: Text(
                        product.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('RM ${product.price.toStringAsFixed(2)}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
