import 'package:flutter/material.dart';
import '../../../core/models/dashboard.dart';

class LastTransactionsTable extends StatelessWidget {
  final List<RecentTransaction> transactions;

  const LastTransactionsTable({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Recent Transactions',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Table or Empty State - ONLY REAL DATA
            if (transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transactions will appear here once customers start placing orders',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2), // Order ID
                    1: FlexColumnWidth(2), // Customer/Date
                    2: FlexColumnWidth(1.5), // Total
                    3: FlexColumnWidth(1.5), // Action
                  },
                  children: [
                    // Header Row
                    TableRow(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF4B5563) : Colors.grey[300],
                      ),
                      children: [
                        _buildHeaderCell(context, 'Order ID', isDark),
                        _buildHeaderCell(context, 'Customer', isDark),
                        _buildHeaderCell(context, 'Total', isDark),
                        _buildHeaderCell(context, 'Action', isDark),
                      ],
                    ),
                    
                    // Data Rows - REAL DATA ONLY
                    ...transactions.take(10).map((transaction) => 
                      _buildDataRow(context, transaction, isDark)
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isDark ? Colors.grey[500] : Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  TableRow _buildDataRow(BuildContext context, RecentTransaction transaction, bool isDark) {
    final theme = Theme.of(context);
    
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF4B5563) : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      children: [
        // Order ID
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '#${transaction.orderId}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Customer Name & Date
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.customerName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                transaction.date.toString().substring(0, 10),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // Total Amount
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '\$${transaction.amount.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Action
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextButton(
            onPressed: () {
              _showTransactionDetails(context, transaction);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'View Details',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTransactionDetails(BuildContext context, RecentTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: #${transaction.orderId}'),
            const SizedBox(height: 8),
            Text('Customer: ${transaction.customerName}'),
            const SizedBox(height: 8),
            Text('Amount: \$${transaction.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Status: ${transaction.status}'),
            const SizedBox(height: 8),
            Text('Date: ${transaction.date.toString().substring(0, 10)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 