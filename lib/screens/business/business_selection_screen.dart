import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/models/business.dart';
import '../../widgets/common/notion_loading.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/business_provider.dart';
import '../../core/services/supabase_service.dart';

class BusinessSelectionScreen extends ConsumerStatefulWidget {
  const BusinessSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BusinessSelectionScreen> createState() => _BusinessSelectionScreenState();
}

class _BusinessSelectionScreenState extends ConsumerState<BusinessSelectionScreen> {
  bool _isLoading = true;
  bool _isCreating = false;
  List<Business> _businesses = [];
  String? _error;
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _companyAliasController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? _selectedIndustry;

  final List<String> _industries = [
    'Technology',
    'Healthcare',
    'Finance',
    'Education',
    'Retail',
    'Manufacturing',
    'Agriculture',
    'Transportation',
    'Energy',
    'Real Estate',
    'Entertainment',
    'Food & Beverage',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _companyAliasController.dispose();
    _registrationNumberController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinesses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Ensure API has the latest Supabase access token before calling backend
      final token = SupabaseService.client.auth.currentSession?.accessToken;
      if (token != null) {
        _apiService.setAuthToken(token);
      }

      final businesses = await _apiService.getBusinesses();
      
      setState(() {
        _businesses = businesses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load businesses: $e';
        _isLoading = false;
      });
    }
  }

  void _showCreateBusinessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Create New Business',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                
                // Business Name
                Text(
                  'Business Name',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter business name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Company Alias
                Text(
                  'Company Alias',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    'This will be used to identify your business in the system.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Industry
                Text(
                  'Industry',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedIndustry,
                  decoration: const InputDecoration(
                    hintText: 'Select industry (optional)',
                  ),
                  items: _industries.map((industry) {
                    return DropdownMenuItem(
                      value: industry,
                      child: Text(industry),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedIndustry = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Registration Number and Phone Number
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registration Number (optional)',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _registrationNumberController,
                            decoration: const InputDecoration(
                              hintText: 'REG-1234',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone Number (optional)',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneNumberController,
                            decoration: const InputDecoration(
                              hintText: 'Enter phone number',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isCreating ? null : () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isCreating ? null : _createBusiness,
                      child: _isCreating
                          ? NotionLoading.buttonLoading()
                          : const Text('Create Business'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createBusiness() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final business = await _apiService.createBusiness(
        name: _businessNameController.text.trim(),
        alias: _companyAliasController.text.trim().isNotEmpty 
            ? _companyAliasController.text.trim() 
            : null,
        industry: _selectedIndustry,
        registrationNumber: _registrationNumberController.text.trim().isNotEmpty 
            ? _registrationNumberController.text.trim() 
            : null,
        phoneNumber: _phoneNumberController.text.trim().isNotEmpty 
            ? _phoneNumberController.text.trim() 
            : null,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Business "${business.name}" created successfully!',
            ),
          ),
        );
        
        // Clear form
        _businessNameController.clear();
        _companyAliasController.clear();
        _registrationNumberController.clear();
        _phoneNumberController.clear();
        setState(() {
          _selectedIndustry = null;
        });
        
        // Optimistically append the new business to the grid
        setState(() {
          _businesses = [..._businesses, business];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create business: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: NotionLoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // New Business Button
                  ElevatedButton.icon(
                    onPressed: _showCreateBusinessModal,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('New Business'),
                  ),
                  
                  // Search and Filter
                  Row(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search business...',
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: theme.iconTheme.color,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.filter_list_rounded,
                            size: 18,
                            color: theme.iconTheme.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Business Cards Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _isLoading
                    ? _buildLoadingGrid()
                    : _error != null
                        ? _buildErrorState()
                        : _businesses.isEmpty
                            ? _buildEmptyState()
                            : _buildBusinessGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return NotionLoading.cardSkeleton();
      },
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBusinesses,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No businesses found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first business to get started',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateBusinessModal,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Business'),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: _businesses.length,
      itemBuilder: (context, index) {
        final business = _businesses[index];
        return _buildBusinessCard(business);
      },
    );
  }

  Widget _buildBusinessCard(Business business) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: () {
          // Save selected business globally and navigate
          ref.read(selectedBusinessProvider.notifier).set(business);
          context.go('/dashboard');
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      business.displayName,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: theme.iconTheme.color,
                  ),
                ],
              ),
              Text(
                business.subtitle,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 