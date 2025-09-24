import 'package:flutter/material.dart';

class NotionLoading {
  
  /// Notion-style skeleton loading for text
  static Widget textSkeleton({
    double? width,
    double height = 16,
    BorderRadius? borderRadius,
  }) {
    return SkeletonLoader(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
  
  /// Notion-style skeleton loading for cards
  static Widget cardSkeleton({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return SkeletonLoader(
      child: Container(
        width: width,
        height: height ?? 120,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(5),
        ),
      ),
    );
  }
  
  /// Notion-style skeleton loading for circular items (avatars, icons)
  static Widget circleSkeleton({
    double size = 40,
  }) {
    return SkeletonLoader(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
    );
  }
  
  /// Notion-style table row skeleton
  static Widget tableRowSkeleton({
    int columns = 3,
    double height = 48,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: List.generate(columns, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < columns - 1 ? 16 : 0),
              child: NotionLoading.textSkeleton(),
            ),
          );
        }),
      ),
    );
  }
  
  /// Notion-style list item skeleton
  static Widget listItemSkeleton({
    bool hasLeading = true,
    bool hasTrailing = false,
    double height = 56,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (hasLeading) ...[
            NotionLoading.circleSkeleton(size: 32),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NotionLoading.textSkeleton(width: double.infinity),
                const SizedBox(height: 4),
                NotionLoading.textSkeleton(width: 120, height: 12),
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 12),
            NotionLoading.textSkeleton(width: 60),
          ],
        ],
      ),
    );
  }
  
  /// Notion-style dashboard card skeleton
  static Widget dashboardCardSkeleton({
    double? width,
    double height = 120,
  }) {
    return Builder(
      builder: (context) => Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NotionLoading.textSkeleton(width: 80, height: 12),
                NotionLoading.circleSkeleton(size: 20),
              ],
            ),
            const SizedBox(height: 12),
            NotionLoading.textSkeleton(width: 120, height: 24),
            const Spacer(),
            NotionLoading.textSkeleton(width: 100, height: 12),
          ],
        ),
      ),
    );
  }
  
  /// Notion-style button loading
  static Widget buttonLoading({
    double width = 24,
    double height = 24,
    Color? color,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }
  
  /// Notion-style page loading
  static Widget pageLoading({
    String? message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const NotionSpinner(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Builder(
              builder: (context) => Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Notion-style empty state
  static Widget emptyState({
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Builder(
          builder: (context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 48,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 24),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Notion-style spinner component
class NotionSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  
  const NotionSpinner({
    Key? key,
    this.size = 32,
    this.color,
  }) : super(key: key);
  
  @override
  State<NotionSpinner> createState() => _NotionSpinnerState();
}

class _NotionSpinnerState extends State<NotionSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CircularProgressIndicator(
            value: null,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton loader with shimmer effect
class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  
  const SkeletonLoader({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);
  
  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ?? 
        (isDark ? const Color(0xFF373C43) : const Color(0xFFE9E9E7));
    final highlightColor = widget.highlightColor ?? 
        (isDark ? const Color(0xFF454B52) : const Color(0xFFF1F1EF));
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value * 3.14159),
            ).createShader(bounds);
          },
          child: Container(
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Notion-style loading overlay
class NotionLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  
  const NotionLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            child: NotionLoading.pageLoading(message: message),
          ),
      ],
    );
  }
} 