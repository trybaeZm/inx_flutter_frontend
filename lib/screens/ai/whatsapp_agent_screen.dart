import 'package:flutter/material.dart';

class WhatsAppAgentScreen extends StatelessWidget {
  const WhatsAppAgentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('WhatsApp Sales Agent'),
        backgroundColor: isDark ? const Color(0xFF374151) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: isDark ? const Color(0xFF374151) : Colors.white,
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connect WhatsApp Business', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Text('Enable automated order handling via WhatsApp.', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.link),
                  label: const Text('Connect Account'),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text('Recent Conversations', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (_, i) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Customer ${i + 1}'),
                      subtitle: const Text('Hi, is this item available?'),
                      trailing: const Text('2m ago'),
                    ),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


