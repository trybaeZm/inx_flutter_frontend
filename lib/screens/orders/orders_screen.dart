import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Placeholder dataset. Hook this to API later.
  final List<_OrderRow> _orders = [
    _OrderRow(
      orderStatus: 'Completed',
      orderDate: '07 Aug 2025',
      customerName: 'Thomas bwalya',
      product: '500',
      orderId: '25',
      amount: 'ZMW 1.00',
      paymentStatus: 'Paid',
    ),
    _OrderRow(
      orderStatus: 'Pending',
      orderDate: '07 Aug 2025',
      customerName: 'Thomas bwalya',
      product: '500',
      orderId: '24',
      amount: 'ZMW 1.00',
      paymentStatus: 'Paid',
    ),
    _OrderRow(
      orderStatus: 'Pending',
      orderDate: '07 Aug 2025',
      customerName: 'Thomas bwalya',
      product: '500',
      orderId: '23',
      amount: 'ZMW 1.00',
      paymentStatus: 'Not Paid',
    ),
    _OrderRow(
      orderStatus: 'Pending',
      orderDate: '06 Aug 2025',
      customerName: 'joshua sibanda',
      product: '500',
      orderId: '22',
      amount: 'ZMW 1.00',
      paymentStatus: 'Not Paid',
    ),
    _OrderRow(
      orderStatus: 'Pending',
      orderDate: '06 Aug 2025',
      customerName: 'joshua sibanda',
      product: '500',
      orderId: '21',
      amount: 'ZMW 1.00',
      paymentStatus: 'Not Paid',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            _OrdersTabs(tabController: _tabController),
            const SizedBox(height: 8),

            // Search + Filter + Sort
            Row(
              children: [
                // Search box
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFFFFFFF),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                _ToolbarButton(icon: Icons.filter_list, label: 'Filter', onTap: () {}),
                const SizedBox(width: 8),
                _ToolbarButton(icon: Icons.sort, label: 'Sort', onTap: () {}),
              ],
            ),

            const SizedBox(height: 20),

            // Table
            Expanded(
              child: _OrdersTable(
                rows: _applySearch(_applyTab(_orders)),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_OrderRow> _applySearch(List<_OrderRow> input) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return input;
    return input
        .where((r) =>
            r.customerName.toLowerCase().contains(q) ||
            r.orderId.toLowerCase().contains(q) ||
            r.product.toLowerCase().contains(q))
        .toList();
  }

  List<_OrderRow> _applyTab(List<_OrderRow> input) {
    switch (_tabController.index) {
      case 1: // Pending
        return input.where((r) => r.orderStatus.toLowerCase() == 'pending').toList();
      case 2: // Settled
        return input.where((r) => r.orderStatus.toLowerCase() == 'completed').toList();
      case 3: // Pending Transactions (not paid)
        return input.where((r) => r.paymentStatus.toLowerCase() == 'not paid').toList();
      default:
        return input;
    }
  }
}

class _OrdersTabs extends StatelessWidget {
  final TabController tabController;
  const _OrdersTabs({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelColor: isDark ? Colors.white : Colors.black87,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        indicatorColor: const Color(0xFF3B82F6),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Pending'),
          Tab(text: 'Settled'),
          Tab(text: 'Pending Transactions'),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.iconTheme.color),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _OrdersTable extends StatelessWidget {
  final List<_OrderRow> rows;
  final bool isDark;
  const _OrdersTable({required this.rows, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.transparent,
      ),
      child: Card(
        elevation: 3,
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1100),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF303642) : const Color(0xFFF9FAFB),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                  child: Row(children: const [
                    _HeaderCell('ORDER STATUS', flex: 2),
                    _HeaderCell('ORDER DATE', flex: 2),
                    _HeaderCell('CUSTOMER NAME', flex: 3),
                    _HeaderCell('PRODUCT/SERVICES', flex: 3),
                    _HeaderCell('ORDER ID', flex: 2),
                    _HeaderCell('ORDER AMOUNT', flex: 2),
                    _HeaderCell('PAYMENT STATUS', flex: 2),
                  ]),
                ),

                // Body
                if (rows.isEmpty)
                  Container(
                    height: 280,
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'No orders yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  )
                else
                  ...rows.map((r) => _OrderDataRow(row: r, isDark: isDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _OrderDataRow extends StatelessWidget {
  final _OrderRow row;
  final bool isDark;
  const _OrderDataRow({required this.row, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2A3140) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _StatusPill(
              label: row.orderStatus,
              color: row.orderStatus.toLowerCase() == 'pending'
                  ? const Color(0xFF1E0D69)
                  : const Color(0xFFE5E7EB),
              textColor: row.orderStatus.toLowerCase() == 'pending'
                  ? Colors.white
                  : Colors.black87,
              icon: row.orderStatus.toLowerCase() == 'pending'
                  ? Icons.schedule
                  : Icons.check_circle_outline,
            ),
          ),
          Expanded(flex: 2, child: Text(row.orderDate)),
          Expanded(flex: 3, child: Text(row.customerName)),
          Expanded(flex: 3, child: Text(row.product)),
          Expanded(flex: 2, child: Text(row.orderId)),
          Expanded(flex: 2, child: Text(row.amount)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(
                label: row.paymentStatus,
                color: row.paymentStatus.toLowerCase() == 'paid'
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEF3C7),
                textColor: row.paymentStatus.toLowerCase() == 'paid'
                    ? const Color(0xFF065F46)
                    : const Color(0xFF92400E),
                icon: row.paymentStatus.toLowerCase() == 'paid'
                    ? Icons.check_circle
                    : Icons.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow {
  final String orderStatus;
  final String orderDate;
  final String customerName;
  final String product;
  final String orderId;
  final String amount;
  final String paymentStatus;

  _OrderRow({
    required this.orderStatus,
    required this.orderDate,
    required this.customerName,
    required this.product,
    required this.orderId,
    required this.amount,
    required this.paymentStatus,
  });
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData icon;
  const _StatusPill({
    required this.label,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

