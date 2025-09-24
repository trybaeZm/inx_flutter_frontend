import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/models/customer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final ApiService _apiService = ApiService();
  List<CustomerResponse> _customers = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getCustomers(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _customers = response.customers;
        _totalPages = response.pages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load customers: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: isDark ? const Color(0xFF374151) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Add customer functionality
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF374151) : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search customers...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF4B5563) : const Color(0xFFF3F4F6),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 1;
                      });
                      _loadCustomers();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Filter functionality
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.red[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadCustomers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _customers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No customers found',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first customer to get started',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : CustomersTable(customers: _customers),
          ),

          // Pagination
          if (_totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? const Color(0xFF374151) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page $_currentPage of $_totalPages',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                                _loadCustomers();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        onPressed: _currentPage < _totalPages
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                                _loadCustomers();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class CustomersTable extends StatelessWidget {
  final List<CustomerResponse> customers;

  const CustomersTable({
    Key? key,
    required this.customers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            isDark ? const Color(0xFF4B5563) : const Color(0xFFF9FAFB),
          ),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Gender')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('Actions')),
          ],
          rows: customers.map((customer) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF3B82F6),
                        child: Text(
                          customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            customer.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'ID: ${customer.customerId}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                DataCell(Text(customer.email ?? 'N/A')),
                DataCell(Text(customer.phone ?? 'N/A')),
                DataCell(Text(customer.location ?? 'N/A')),
                DataCell(Text(customer.gender ?? 'N/A')),
                DataCell(Text(customer.createdAt?.substring(0, 10) ?? 'N/A')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // View customer details
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        tooltip: 'View',
                      ),
                      IconButton(
                        onPressed: () {
                          // Edit customer
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        onPressed: () {
                          // Delete customer
                        },
                        icon: const Icon(Icons.delete, size: 16),
                        tooltip: 'Delete',
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
} 