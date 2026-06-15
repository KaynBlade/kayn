import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/db_helper.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();

  String _title = '';
  double _price = 0.0;
  String _description = '';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    bool isCreateMode = args != null && args['action'] == 'create';
    Product? existingProduct = args?['product'] as Product?;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCreateMode
              ? 'Post Second-hand Item'
              : (existingProduct != null ? 'Item Details' : 'Edit Item'),
        ),
        actions: [
          if (!isCreateMode && existingProduct != null) ...[
            // Delete Button (Delete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(existingProduct.id!),
            ),
          ],
        ],
      ),
      body: isCreateMode
          ? _buildForm(null)
          : (existingProduct != null
                ? _buildDetails(existingProduct)
                : const Center(child: Text('Data Error'))),
    );
  }

  // Form Component (Supports both "Create" and "Update")
  Widget _buildForm(Product? product) {
    bool isEdit = product != null;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              initialValue: isEdit ? product.title : '',
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val!.isEmpty ? 'Please enter item name' : null,
              onSaved: (val) => _title = val!,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: isEdit ? product.price.toString() : '',
              decoration: const InputDecoration(
                labelText: 'Expected Price (RM)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (val) => val!.isEmpty ? 'Please enter price' : null,
              onSaved: (val) => _price = double.parse(val!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: isEdit ? product.description : '',
              decoration: const InputDecoration(
                labelText:
                    'Detailed Description (Condition, meetup location, etc.)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              onSaved: (val) => _description = val!,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (isEdit) {
                    // Execute 【Update】
                    await _dbHelper.updateProduct(
                      Product(
                        id: product.id,
                        title: _title,
                        price: _price,
                        description: _description,
                      ),
                    );
                  } else {
                    // Execute 【Create】
                    await _dbHelper.insertProduct(
                      Product(
                        title: _title,
                        price: _price,
                        description: _description,
                      ),
                    );
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: Text(isEdit ? 'Save Changes' : 'Confirm Post'),
            ),
          ],
        ),
      ),
    );
  }

  // Details Display Component
  Widget _buildDetails(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: Colors.teal.shade50,
            child: const Icon(Icons.image, size: 60, color: Colors.teal),
          ),
          const SizedBox(height: 16),
          Text(
            'RM ${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 26,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                  ),
                  onPressed: () {
                    // Switch into edit state
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('Edit Item')),
                          body: _buildForm(product),
                        ),
                      ),
                    );
                  },
                  child: const Text('Edit Information'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Show Delete Confirmation Dialog (Delete)
  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Take Down?'),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteProduct(id);
              if (!mounted) return;

              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Return to home screen
            },
            child: const Text(
              'Confirm Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
