import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _emailNotifications = true;
  bool _pushNotifications = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Settings',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive app notifications'),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    trailing: Switch(
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive notifications via email'),
                    trailing: Switch(
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.push_pin),
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive push notifications'),
                    trailing: Switch(
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Business Settings Card
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Business Settings',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Business Logo', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.attach_file, size: 18),
                          label: const Text('Choose File'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 40,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                            ),
                            child: Text('No file chosen', style: theme.textTheme.bodySmall),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9FA8FF),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Upload Logo'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Company Alias', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    const TextField(
                      decoration: InputDecoration(hintText: 'e.g. cake-studio'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Save Alias'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Payment Link', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'Set a company alias first',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: () {}, child: const Text('Copy')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Account Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to account settings
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Privacy & Security'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to privacy settings
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Show about dialog
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 