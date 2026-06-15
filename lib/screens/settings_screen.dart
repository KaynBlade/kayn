import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          ListTile(
            title: const Text('App Language'),
            subtitle: const Text('English / 简体中文'),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Account & Security'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Clear all routes and force return to login screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
