import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  String _title = '';
  double _price = 0.0;
  String _description = '';
  String? _selectedImagePath;
  int? _currentUserId;
  bool _isFavCached = false;

  @override
  void initState() {
    super.initState();
    _loadSessionAndFavContext();
  }

  void _loadSessionAndFavContext() async {
    final session = await _dbHelper.getCurrentSession();
    _currentUserId = session?['current_user_id'];

    if (mounted && _currentUserId != null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      Product? product = args?['product'] as Product?;
      if (product != null && product.id != null) {
        bool fav = await _dbHelper.isFavorite(_currentUserId!, product.id!);
        setState(() {
          _isFavCached = fav;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    bool isCreateMode = args != null && args['action'] == 'create';
    Product? existingProduct = args?['product'] as Product?;
    bool isOwner =
        existingProduct != null && _currentUserId == existingProduct.sellerId;

    if (!isCreateMode &&
        existingProduct != null &&
        _selectedImagePath == null) {
      _selectedImagePath = existingProduct.imagePath;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCreateMode
              ? 'Post Second-hand Item'
              : (existingProduct != null ? 'Item Details' : 'Edit Item'),
        ),
        actions: [
          if (!isCreateMode && existingProduct != null && isOwner) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(existingProduct.id!),
            ),
          ],
          if (!isCreateMode && existingProduct != null && !isOwner) ...[
            IconButton(
              icon: Icon(
                _isFavCached ? Icons.favorite : Icons.favorite_border,
                color: _isFavCached ? Colors.red : Colors.white,
              ),
              onPressed: () async {
                if (_currentUserId != null && existingProduct.id != null) {
                  await _dbHelper.toggleFavorite(
                    _currentUserId!,
                    existingProduct.id!,
                  );
                  setState(() {
                    _isFavCached = !_isFavCached;
                  });
                }
              },
            ),
          ],
        ],
      ),
      body: isCreateMode
          ? _buildForm(null)
          : (existingProduct != null
                ? _buildDetails(existingProduct, isOwner)
                : const Center(child: Text('Data Error'))),
    );
  }

  Widget _buildForm(Product? product) {
    bool isEdit = product != null;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: _selectedImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.teal),
                          SizedBox(height: 8),
                          Text(
                            'Upload Item Image (Tap to browse)',
                            style: TextStyle(color: Colors.teal),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
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
                    await _dbHelper.updateProduct(
                      Product(
                        id: product.id,
                        title: _title,
                        price: _price,
                        description: _description,
                        sellerId: product.sellerId,
                        sellerName: product.sellerName,
                        sellerEmail: product.sellerEmail,
                        imagePath: _selectedImagePath,
                      ),
                    );
                  } else {
                    await _dbHelper.insertProduct(
                      Product(
                        title: _title,
                        price: _price,
                        description: _description,
                        imagePath: _selectedImagePath,
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

  Widget _buildDetails(Product product, bool isOwner) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: product.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(product.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.image, size: 60, color: Colors.teal),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RM ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOwner ? 'Your Listing' : 'Seller: ${product.sellerName}',
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
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
          if (isOwner)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Information'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                ),
                onPressed: () {
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
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Contact Seller via Email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Simulating email client to: ${product.sellerEmail}',
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

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
              Navigator.pop(dialogContext);
              Navigator.pop(context);
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
