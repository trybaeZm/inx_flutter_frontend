import 'package:flutter/material.dart';

class AiAgentsScreen extends StatelessWidget {
  const AiAgentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('AI Agents'),
        backgroundColor: isDark ? const Color(0xFF374151) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(6, (i) => _AgentCard(index: i + 1)),
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final int index;
  const _AgentCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      color: isDark ? const Color(0xFF374151) : Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.smart_toy_outlined, size: 28),
            const SizedBox(height: 12),
            Text('Agent #$index', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Status: Idle', style: theme.textTheme.bodySmall),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Configure'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


