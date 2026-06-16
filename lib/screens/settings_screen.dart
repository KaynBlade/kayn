import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DBHelper dbHelper = DBHelper();

    return Scaffold(
      appBar: AppBar(title: const Text('System Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Push Notifications'),
            subtitle: const Text(
              'Notify me when someone is interested in my items',
            ),
            value: true,
            activeColor: Colors.teal,
            onChanged: (bool value) {},
          ),
          const Divider(),

          // 1. Logout Action
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text('Logout Account'),
            subtitle: const Text('Sign out from current session safely'),
            onTap: () async {
              await dbHelper.clearSession();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
          const Divider(),

          // 2. Delete Account Action
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account Permanently',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Erase your profile and all your listings from market',
            ),
            onTap: () => _showDeleteAccountDialog(context, dbHelper),
          ),
        ],
      ),
    );
  }

  // Dialog for permanent account deletion
  void _showDeleteAccountDialog(BuildContext context, DBHelper dbHelper) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Danger Zone: Delete Account?',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Are you absolutely sure? This will permanently delete your user profile and remove ALL items you have posted on the marketplace. This action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final session = await dbHelper.getCurrentSession();
              if (session != null) {
                int userId = session['current_user_id'];
                final db = await dbHelper.database;

                // Cascade delete: remove user's products and account
                await db.delete(
                  'products',
                  where: 'seller_id = ?',
                  whereArgs: [userId],
                );
                await db.delete('users', where: 'id = ?', whereArgs: [userId]);
                await dbHelper.clearSession();
              }

              if (!context.mounted) return;
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Your account and listings have been completely erased.',
                  ),
                ),
              );
            },
            child: const Text(
              'Confirm Erase',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
