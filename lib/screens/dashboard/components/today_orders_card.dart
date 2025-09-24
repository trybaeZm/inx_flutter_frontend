import 'package:flutter/material.dart';
import '../../../core/models/dashboard.dart';

class TodayOrdersCard extends StatelessWidget {
  final List<TodayOrderData> todayOrders;
  final int todayOrdersCount;

  const TodayOrdersCard({
    Key? key,
    required this.todayOrders,
    required this.todayOrdersCount,
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
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Orders',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: todayOrdersCount > 0 ? Colors.green.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$todayOrdersCount orders',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: todayOrdersCount > 0 ? Colors.green : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Orders List or Empty State - ONLY REAL DATA
            if (todayOrders.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.today_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders today yet',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Orders placed today will appear here',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Column(
                children: todayOrders.map((order) => _buildOrderItem(
                  context,
                  order,
                  isDark,
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, TodayOrderData order, bool isDark) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3F44) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.06), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          // Order Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${order.orderId}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${order.time}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Amount
          Text(
            '\$${order.amount.toStringAsFixed(2)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 