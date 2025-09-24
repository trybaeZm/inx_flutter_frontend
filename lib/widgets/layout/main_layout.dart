import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/business_provider.dart';
import '../../core/theme/app_theme.dart';
import '../common/app_navbar.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final Set<String> _expandedKeys = {};
  bool _sidebarOpen = true; // Notion-style: open by default
  bool _showEdgeHandle = false; // shows » handle when collapsed and hovered at edge
  bool _hoverSidebarVisible = false; // transient overlay when collapsed
  bool _pointerInsideHoverPanel = false;

  // Desktop navigation items (full sidebar)
  final List<NavigationItem> _navigationItems = [
    NavigationItem(keyId: 'overview', icon: Icons.dashboard_rounded, label: 'Overview', route: '/dashboard'),
    NavigationItem(keyId: 'lennyai', icon: Icons.psychology_alt_rounded, label: 'LennyAi', route: '/lennyai'),
    NavigationItem(
      keyId: 'insights',
      icon: Icons.insights_rounded,
      label: 'Insights',
      children: [
        NavigationItem(keyId: 'insights-overview', label: 'Overview', route: '/insights'),
        NavigationItem(keyId: 'insights-sales', label: 'Sales Analytics', route: '/sales-analytics'),
        NavigationItem(keyId: 'insights-customer', label: 'Customer Analytics', route: '/customer-analytics'),
      ],
    ),
    NavigationItem(keyId: 'products', icon: Icons.shopping_bag_rounded, label: 'Products/Services', route: '/products'),
    NavigationItem(keyId: 'orders', icon: Icons.receipt_long_rounded, label: 'Orders', route: '/orders'),
    NavigationItem(
      keyId: 'aiAgents',
      icon: Icons.smart_toy_outlined,
      label: 'Ai agents',
      children: [
        NavigationItem(keyId: 'aiAgents-list', label: 'Agents', route: '/ai-agents'),
        NavigationItem(keyId: 'whatsapp', label: 'Whats app sales agent', route: '/whatsapp'),
      ],
    ),
    NavigationItem(keyId: 'notifications', icon: Icons.notifications_rounded, label: 'Notifications', route: '/notifications'),
    NavigationItem(keyId: 'wallet', icon: Icons.account_balance_wallet_rounded, label: 'Wallet', route: '/wallet'),
    NavigationItem(keyId: 'settings', icon: Icons.settings_rounded, label: 'Settings', route: '/settings'),
  ];

  // Mobile navigation items (simplified for bottom nav)
  final List<NavigationItem> _mobileNavigationItems = [
    NavigationItem(keyId: 'overview', icon: Icons.dashboard_rounded, label: 'Overview', route: '/dashboard'),
    NavigationItem(keyId: 'lennyai', icon: Icons.psychology_alt_rounded, label: 'LennyAi', route: '/lennyai'),
    NavigationItem(keyId: 'orders', icon: Icons.receipt_long_rounded, label: 'Orders', route: '/orders'),
    NavigationItem(keyId: 'products', icon: Icons.shopping_bag_rounded, label: 'Products', route: '/products'),
    NavigationItem(keyId: 'more', icon: Icons.more_horiz_rounded, label: 'More', route: null),
  ];

  // Additional navigation items for the "More" menu
  final List<NavigationItem> _moreMenuItems = [
    NavigationItem(keyId: 'insights', icon: Icons.insights_rounded, label: 'Insights', route: '/insights'),
    NavigationItem(keyId: 'customers', icon: Icons.people_rounded, label: 'Customers', route: '/customers'),
    NavigationItem(keyId: 'sales', icon: Icons.trending_up_rounded, label: 'Sales', route: '/sales'),
    NavigationItem(keyId: 'wallet', icon: Icons.account_balance_wallet_rounded, label: 'Wallet', route: '/wallet'),
    NavigationItem(keyId: 'settings', icon: Icons.settings_rounded, label: 'Settings', route: '/settings'),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _updateSelectedIndex() {
    final currentRoute = GoRouterState.of(context).uri.path;
    final index = _mobileNavigationItems.indexWhere((item) => 
        item.route != null && item.route == currentRoute);
    if (index != -1) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update selected index when route changes
    _updateSelectedIndex();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedBusiness = ref.watch(selectedBusinessProvider);
    
    // Responsive breakpoints
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    // Auto-close sidebar on mobile
    if (isMobile && _sidebarOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _sidebarOpen = false);
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppNavbar(
        title: 'Inxource',
        subtitle: selectedBusiness?.displayName ?? '',
        showMenuButton: isMobile || isTablet, // Show menu button on mobile/tablet
        showPrimaryAction: !isMobile, // Hide primary action on mobile to save space
        primaryActionLabel: 'Create Order Link',
        onMenuPressed: () {
          if (isMobile) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            setState(() => _sidebarOpen = !_sidebarOpen);
          }
        },
      ),
      drawer: isMobile ? _buildMobileDrawer(isDark) : null,
      body: _buildBody(isMobile, isTablet, isDesktop, isDark),
      bottomNavigationBar: isMobile ? _buildBottomNavigation() : null,
    );
  }

  Widget _buildBody(bool isMobile, bool isTablet, bool isDesktop, bool isDark) {
    if (isMobile) {
      // Mobile: Full-width content with bottom navigation
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: widget.child,
      );
    }

    // Desktop/Tablet: Sidebar + content layout
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: _sidebarOpen ? (isTablet ? 240 : 280) : 0,
              color: isDark ? NotionColors.darkSurface : NotionColors.lightSurface,
              child: _sidebarOpen
                  ? SafeArea(child: _buildMenuList(isDark, isDrawer: false))
                  : const SizedBox.shrink(),
            ),
            
            // Main content
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: widget.child,
              ),
            ),
          ],
        ),

        // Edge hover handle when collapsed (desktop only)
        if (!_sidebarOpen && isDesktop)
          Align(
            alignment: Alignment.centerLeft,
            child: MouseRegion(
              onEnter: (_) => setState(() => _showEdgeHandle = true),
              onExit: (_) => setState(() => _showEdgeHandle = false),
              child: AnimatedOpacity(
                opacity: _showEdgeHandle ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _sidebarOpen = true),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? NotionColors.darkHover : NotionColors.lightHover,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.keyboard_double_arrow_right_rounded,
                          size: 18,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Far-left hotspot to reveal temporary overlay when collapsed (desktop only)
        if (!_sidebarOpen && isDesktop)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 12,
            child: MouseRegion(
              opaque: false,
              onEnter: (_) => setState(() => _hoverSidebarVisible = true),
              onExit: (_) {
                if (!_pointerInsideHoverPanel) {
                  setState(() => _hoverSidebarVisible = false);
                }
              },
              child: const SizedBox.shrink(),
            ),
          ),

        // Transient overlay sidebar (desktop only)
        if (!_sidebarOpen && _hoverSidebarVisible && isDesktop)
          Positioned(
            left: 8,
            top: 72,
            bottom: 72,
            width: 272,
            child: MouseRegion(
              onEnter: (_) => setState(() => _pointerInsideHoverPanel = true),
              onExit: (_) => setState(() {
                _pointerInsideHoverPanel = false;
                _hoverSidebarVisible = false;
              }),
              child: Material(
                color: isDark ? NotionColors.darkSurface : NotionColors.lightSurface,
                elevation: 12,
                borderRadius: BorderRadius.circular(12),
                child: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Menu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => setState(() {
                                _sidebarOpen = true;
                                _hoverSidebarVisible = false;
                              }),
                              child: Icon(
                                Icons.keyboard_double_arrow_right_rounded,
                                size: 20,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: _buildMenuList(isDark, isDrawer: false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileDrawer(bool isDark) {
    return Drawer(
      child: Container(
        color: isDark ? NotionColors.darkSurface : NotionColors.lightSurface,
        child: Column(
          children: [
            // Drawer header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? NotionColors.darkHover : NotionColors.lightHover,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business_rounded,
                      color: Theme.of(context).iconTheme.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inxource',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Business Management',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Navigation items
            Expanded(
              child: _buildMenuList(isDark, isDrawer: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        final item = _mobileNavigationItems[index];
        if (item.route != null) {
          setState(() => _selectedIndex = index);
          context.go(item.route!);
        } else if (item.keyId == 'more') {
          // Show drop-up menu for "More" option
          _showMoreMenu();
        }
      },
      selectedItemColor: NotionColors.blue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 8,
      items: _mobileNavigationItems.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }

  void _showMoreMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + button.size.width - 200, // Right-aligned
        position.dy - 20, // Above the button
        position.dx + button.size.width,
        position.dy,
      ),
      items: _moreMenuItems.map((item) {
        return PopupMenuItem<String>(
          value: item.route,
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[300] 
                    : Colors.grey[700],
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedRoute) {
      if (selectedRoute != null) {
        context.go(selectedRoute);
      }
    });
  }

  Widget _buildMenuList(bool isDark, {bool isDrawer = false}) {
    final theme = Theme.of(context);
    final items = isDrawer ? _navigationItems : _navigationItems;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Header (only for desktop)
        if (!isDrawer)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Close sidebar  Ctrl+\\',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() {
                      _sidebarOpen = false;
                      _hoverSidebarVisible = true;
                    }),
                    child: Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      size: 20,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Navigation items
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: items
                  .map((item) => _buildNavTile(item, isDark, isDrawer: isDrawer))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavTile(NavigationItem item, bool isDark, {bool isDrawer = false, int depth = 0}) {
    final bool hasChildren = (item.children != null && item.children!.isNotEmpty);
    final bool expanded = _expandedKeys.contains(item.keyId);
    final bool isSelected = false; // selection highlighting can be refined with route matching
    final Color iconColor = isSelected
        ? (isDark ? Colors.blue[400]! : Colors.blue[600]!)
        : (isDark ? Colors.grey[400]! : Colors.grey[600]!);

    final tile = ListTile(
      contentPadding: EdgeInsets.only(
        left: isDrawer ? 16.0 + depth * 16.0 : 12.0 + depth * 16.0, 
        right: isDrawer ? 16 : 12
      ),
      leading: item.icon != null
          ? Icon(item.icon, color: iconColor, size: 20)
          : SizedBox(width: 20),
      title: Text(
        item.label,
        style: TextStyle(
          fontSize: isDrawer ? 16 : 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? (isDark ? Colors.white : Colors.grey[900]) : (isDark ? Colors.grey[300] : Colors.grey[700]),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: hasChildren
          ? Icon(expanded ? Icons.expand_less : Icons.expand_more, color: iconColor, size: 20)
          : null,
      selected: isSelected,
      selectedTileColor: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        if (hasChildren) {
          setState(() {
            if (expanded) {
              _expandedKeys.remove(item.keyId);
            } else {
              _expandedKeys.add(item.keyId);
            }
          });
        } else if (item.route != null) {
          context.go(item.route!);
          if (isDrawer) Navigator.of(context).pop();
        }
      },
    );

    if (!hasChildren) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: isDrawer ? 16 : 12, 
          vertical: 4
        ), 
        child: tile
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDrawer ? 16 : 12, 
        vertical: 4
      ),
      child: Column(
        children: [
          tile,
          if (expanded)
            ...item.children!
                .map((child) => _buildNavTile(child, isDark, isDrawer: isDrawer, depth: depth + 1))
                .toList(),
        ],
      ),
    );
  }
}

class NavigationItem {
  final String keyId;
  final IconData? icon;
  final String label;
  final String? route;
  final List<NavigationItem>? children;

  NavigationItem({
    required this.keyId,
    this.icon,
    required this.label,
    this.route,
    this.children,
  });
}