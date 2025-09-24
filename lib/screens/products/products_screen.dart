import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../core/models/product.dart';
import '../../core/providers/business_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ApiService _apiService = ApiService();
  List<ProductResponse> _products = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getProducts(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
      );

      setState(() {
        _products = response.products;
        _totalPages = response.pages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load products: ${e.toString()}';
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
        title: const Text('Products'),
        backgroundColor: isDark ? const Color(0xFF374151) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Row: Title + Add button (Notion/Next-style)
          Container(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Products and Services',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _openAddProductPanel,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Products/Services'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    side: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF374151) : Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
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
                          _loadProducts();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      hint: const Text('Category'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All Categories')),
                        DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                        DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
                        DropdownMenuItem(value: 'Food', child: Text('Food')),
                        DropdownMenuItem(value: 'Books', child: Text('Books')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _currentPage = 1;
                        });
                        _loadProducts();
                      },
                    ),
                  ],
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
                              onPressed: _loadProducts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first product to get started',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ProductsGrid(products: _products),
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
                                _loadProducts();
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
                                _loadProducts();
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

  void _openAddProductPanel() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String? categoryValue;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Product/Service',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, __) {
        return Consumer(builder: (context, ref, ___) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 420,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111827) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(-6, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add Product/Service', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        // Image placeholder
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                          ),
                          child: const Center(child: Icon(Icons.image_outlined, size: 36)),
                        ),
                        const SizedBox(height: 16),
                        Text('Product/Service', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: categoryValue,
                          items: const [
                            DropdownMenuItem(value: 'Phones', child: Text('Phones')),
                            DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                            DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
                            DropdownMenuItem(value: 'Food', child: Text('Food')),
                          ],
                          onChanged: (v) => categoryValue = v,
                          decoration: const InputDecoration(hintText: 'Select category'),
                        ),
                        const SizedBox(height: 12),
                        Text('Enter Product/Service Name', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 6),
                        TextField(controller: nameController),
                        const SizedBox(height: 12),
                        Text('Enter the Selling Price', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 6),
                        TextField(controller: priceController, keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        Text('Describe the Product/Service Briefly (Optional)', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 6),
                        TextField(controller: descriptionController, maxLines: 3),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () async {
                                final name = nameController.text.trim();
                                final price = double.tryParse(priceController.text.trim());
                                if (name.isEmpty || price == null) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Name and valid price are required')),
                                  );
                                  return;
                                }
                                final business = ref.read(selectedBusinessProvider);
                                final businessId = business?.id;
                                if (businessId == null || businessId.isEmpty) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select a business first')),
                                  );
                                  return;
                                }
                                try {
                                  final created = await _apiService.createProduct(
                                    ProductCreateRequest(
                                      name: name,
                                      price: price,
                                      description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                                      category: categoryValue,
                                      businessId: businessId,
                                    ),
                                  );
                                  if (!mounted) return;
                                  setState(() {
                                    // Optimistically insert a minimal response item
                                    _products.insert(0, ProductResponse(
                                      id: created.id,
                                      productId: created.productId,
                                      businessId: created.businessId,
                                      name: created.name,
                                      price: created.price,
                                      category: created.category,
                                      image: created.image,
                                      sold: created.sold,
                                      profit: created.profit,
                                      createdAt: created.createdAt,
                                    ));
                                  });
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Product created')),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to create: $e')),
                                  );
                                }
                              },
                              child: const Text('Finish'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (context, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(anim),
          child: child,
        );
      },
    );
  }
}

class ProductsGrid extends StatelessWidget {
  final List<ProductResponse> products;

  const ProductsGrid({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: isDark ? const Color(0xFF374151) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Placeholder
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                    child: product.image != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            child: Image.network(
                              product.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                  ),
                ),

                // Product Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category ?? 'No Category',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Text('View'),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              onSelected: (value) {
                                // Handle menu actions
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 