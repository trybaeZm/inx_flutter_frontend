import 'package:flutter/material.dart';
import '../../../core/models/dashboard.dart';

class CustomersCard extends StatelessWidget {
  final DashboardStats stats;

  const CustomersCard({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.people_alt_rounded, size: 16, color: theme.textTheme.bodyMedium?.color),
                ),
                const SizedBox(width: 8),
                Text('Total Customers', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 10),
            Text('${stats.totalCustomers}', style: theme.textTheme.displaySmall),
            const SizedBox(height: 6),
            Text('Active customers', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
} 