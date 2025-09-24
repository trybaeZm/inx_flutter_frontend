import 'package:flutter/material.dart';
import '../../../core/models/notification.dart';
import '../../../core/providers/notification_provider.dart';

class NotificationFilterBar extends StatelessWidget {
  final NotificationFilter currentFilter;
  final Function(NotificationFilter) onFilterChanged;

  const NotificationFilterBar({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return _buildMobileFilterBar(theme);
    } else {
      return _buildDesktopFilterBar(theme);
    }
  }

  Widget _buildMobileFilterBar(ThemeData theme) {
    return Column(
      children: [
        // Status Filter
        _buildFilterChip(
          theme,
          label: 'Status',
          options: [
            FilterOption('All', null),
            FilterOption('Unread', 'unread'),
            FilterOption('Read', 'read'),
            FilterOption('Dismissed', 'dismissed'),
          ],
          currentValue: currentFilter.status,
          onChanged: (value) => onFilterChanged(
            currentFilter.copyWith(status: value),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Category Filter
        _buildFilterChip(
          theme,
          label: 'Category',
          options: [
            FilterOption('All', null),
            FilterOption('Sales', 'Sales'),
            FilterOption('Orders', 'Orders'),
            FilterOption('Inventory', 'Inventory'),
            FilterOption('Customers', 'Customers'),
            FilterOption('Financial', 'Financial'),
            FilterOption('System', 'System'),
            FilterOption('AI Insights', 'AI Insights'),
            FilterOption('Business Alerts', 'Business Alerts'),
          ],
          currentValue: currentFilter.category,
          onChanged: (value) => onFilterChanged(
            currentFilter.copyWith(category: value),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Priority Filter
        _buildFilterChip(
          theme,
          label: 'Priority',
          options: [
            FilterOption('All', null),
            FilterOption('Urgent', 'urgent'),
            FilterOption('High', 'high'),
            FilterOption('Normal', 'normal'),
            FilterOption('Low', 'low'),
          ],
          currentValue: currentFilter.priority,
          onChanged: (value) => onFilterChanged(
            currentFilter.copyWith(priority: value),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFilterBar(ThemeData theme) {
    return Row(
      children: [
        // Status Filter
        Expanded(
          child: _buildFilterChip(
            theme,
            label: 'Status',
            options: [
              FilterOption('All', null),
              FilterOption('Unread', 'unread'),
              FilterOption('Read', 'read'),
              FilterOption('Dismissed', 'dismissed'),
            ],
            currentValue: currentFilter.status,
            onChanged: (value) => onFilterChanged(
              currentFilter.copyWith(status: value),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Category Filter
        Expanded(
          child: _buildFilterChip(
            theme,
            label: 'Category',
            options: [
              FilterOption('All', null),
              FilterOption('Sales', 'Sales'),
              FilterOption('Orders', 'Orders'),
              FilterOption('Inventory', 'Inventory'),
              FilterOption('Customers', 'Customers'),
              FilterOption('Financial', 'Financial'),
              FilterOption('System', 'System'),
              FilterOption('AI Insights', 'AI Insights'),
              FilterOption('Business Alerts', 'Business Alerts'),
            ],
            currentValue: currentFilter.category,
            onChanged: (value) => onFilterChanged(
              currentFilter.copyWith(category: value),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Priority Filter
        Expanded(
          child: _buildFilterChip(
            theme,
            label: 'Priority',
            options: [
              FilterOption('All', null),
              FilterOption('Urgent', 'urgent'),
              FilterOption('High', 'high'),
              FilterOption('Normal', 'normal'),
              FilterOption('Low', 'low'),
            ],
            currentValue: currentFilter.priority,
            onChanged: (value) => onFilterChanged(
              currentFilter.copyWith(priority: value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    ThemeData theme, {
    required String label,
    required List<FilterOption> options,
    required String? currentValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.textTheme.labelMedium?.color?.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option.value == currentValue;
            return FilterChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onChanged(option.value);
                } else {
                  onChanged(null);
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class FilterOption {
  final String label;
  final String? value;

  FilterOption(this.label, this.value);
}

// Advanced filter drawer for mobile
class NotificationFilterDrawer extends StatefulWidget {
  final NotificationFilter currentFilter;
  final Function(NotificationFilter) onFilterChanged;
  final VoidCallback onClose;

  const NotificationFilterDrawer({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.onClose,
  }) : super(key: key);

  @override
  State<NotificationFilterDrawer> createState() => _NotificationFilterDrawerState();
}

class _NotificationFilterDrawerState extends State<NotificationFilterDrawer> {
  late NotificationFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Filter Notifications',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize your notification view',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Status Filter
                _buildFilterSection(
                  theme,
                  title: 'Status',
                  options: [
                    FilterOption('All', null),
                    FilterOption('Unread', 'unread'),
                    FilterOption('Read', 'read'),
                    FilterOption('Dismissed', 'dismissed'),
                  ],
                  currentValue: _filter.status,
                  onChanged: (value) {
                    setState(() {
                      _filter = _filter.copyWith(status: value);
                    });
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Category Filter
                _buildFilterSection(
                  theme,
                  title: 'Category',
                  options: [
                    FilterOption('All', null),
                    FilterOption('Sales', 'Sales'),
                    FilterOption('Orders', 'Orders'),
                    FilterOption('Inventory', 'Inventory'),
                    FilterOption('Customers', 'Customers'),
                    FilterOption('Financial', 'Financial'),
                    FilterOption('System', 'System'),
                    FilterOption('AI Insights', 'AI Insights'),
                    FilterOption('Business Alerts', 'Business Alerts'),
                  ],
                  currentValue: _filter.category,
                  onChanged: (value) {
                    setState(() {
                      _filter = _filter.copyWith(category: value);
                    });
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Priority Filter
                _buildFilterSection(
                  theme,
                  title: 'Priority',
                  options: [
                    FilterOption('All', null),
                    FilterOption('Urgent', 'urgent'),
                    FilterOption('High', 'high'),
                    FilterOption('Normal', 'normal'),
                    FilterOption('Low', 'low'),
                  ],
                  currentValue: _filter.priority,
                  onChanged: (value) {
                    setState(() {
                      _filter = _filter.copyWith(priority: value);
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onFilterChanged(_filter);
                  widget.onClose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    ThemeData theme, {
    required String title,
    required List<FilterOption> options,
    required String? currentValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option.value == currentValue;
            return FilterChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onChanged(option.value);
                } else {
                  onChanged(null);
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
