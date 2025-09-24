import 'package:flutter/material.dart';
import '../../../widgets/charts/widgets.dart';
import '../../../core/models/dashboard.dart';

class SalesByCategoryChart extends StatelessWidget {
  final List<CategorySales> categorySales;

  const SalesByCategoryChart({
    Key? key,
    required this.categorySales,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sales by Category',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            
            // Chart Section
            if (categorySales.isEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F282D) : const Color(0xFFE7F3F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'No data available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              )
            else
              DonutChart(
                values: categorySales.map((e) => e.sales).toList(),
                labels: categorySales.map((e) => e.category).toList(),
                height: 200,
              ),
            
            const SizedBox(height: 16),
            
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categorySales.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final colors = [
                  const Color(0xFF3B82F6),
                  const Color(0xFF10B981),
                  const Color(0xFFF59E0B),
                  const Color(0xFFEF4444),
                  const Color(0xFF8B5CF6),
                  const Color(0xFF06B6D4),
                ];
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Summary Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4B5563) : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Categories',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${categorySales.length}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Sales',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '\$${categorySales.fold(0.0, (sum, item) => sum + item.sales).toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
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