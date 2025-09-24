import 'package:flutter/material.dart';
import '../../../core/models/dashboard.dart';

class TopSellingProducts extends StatelessWidget {
  final List<TopProduct> products;

  const TopSellingProducts({
    Key? key,
    required this.products,
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
            Text(
              'Top Selling Products',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            if (products.isEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF4B5563) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'No products available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (context, index) => Divider(
                  color: isDark ? Colors.grey[700] : Colors.grey[200],
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductItem(context, product, isDark, theme);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    TopProduct product,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          // Product Image/Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF4B5563) : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: product.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.shopping_bag_outlined,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 20,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.shopping_bag_outlined,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 20,
                  ),
          ),
          
          const SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${product.quantity} • Sales: \$${product.sales.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Sales Amount (using sales instead of price)
          Text(
            '\$${product.sales.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[900],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 