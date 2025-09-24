import 'package:flutter/material.dart';

/// A responsive wrapper that provides consistent responsive behavior
/// across different screen sizes while preserving the existing layout.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final bool centerContent;

  const ResponsiveWrapper({
    Key? key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.centerContent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    // Responsive padding
    final responsivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: isMobile ? 16.0 : isTablet ? 24.0 : 32.0,
      vertical: isMobile ? 16.0 : isTablet ? 20.0 : 24.0,
    );

    // Responsive max width
    final responsiveMaxWidth = maxWidth ?? (isMobile ? double.infinity : isTablet ? 800.0 : 1200.0);

    Widget content = Container(
      padding: responsivePadding,
      child: child,
    );

    // Center content on larger screens if requested
    if (centerContent && !isMobile) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
          child: content,
        ),
      );
    }

    return SafeArea(child: content);
  }
}

/// A responsive grid that automatically adjusts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1200;

        int columns;
        if (isMobile) {
          columns = mobileColumns ?? 1;
        } else if (isTablet) {
          columns = tabletColumns ?? 2;
        } else {
          columns = desktopColumns ?? 4;
        }

        final available = width - (spacing * (columns - 1));
        final itemWidth = available / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth.clamp(0, double.infinity),
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// A responsive row that stacks vertically on mobile
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final bool reverseOnMobile;

  const ResponsiveRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 16.0,
    this.reverseOnMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Stack vertically on mobile
      return Column(
        mainAxisAlignment: mainAxisAlignment == MainAxisAlignment.spaceEvenly 
            ? MainAxisAlignment.spaceEvenly 
            : mainAxisAlignment == MainAxisAlignment.spaceBetween 
                ? MainAxisAlignment.spaceBetween 
                : MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(children, spacing, true),
      );
    }

    // Use row on larger screens
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _addSpacing(children, spacing, false),
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets, double spacing, bool isVertical) {
    if (widgets.isEmpty) return [];
    if (widgets.length == 1) return widgets;

    List<Widget> result = [];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(isVertical 
            ? SizedBox(height: spacing) 
            : SizedBox(width: spacing)
        );
      }
    }
    return result;
  }
}

/// A responsive card that adjusts its layout based on screen size
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final bool useMobilePadding;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.elevation,
    this.color,
    this.borderRadius,
    this.useMobilePadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

    final responsivePadding = padding ?? EdgeInsets.all(
      isMobile ? (useMobilePadding ? 16.0 : 12.0) : isTablet ? 20.0 : 24.0,
    );

    return Card(
      elevation: elevation ?? (isMobile ? 2.0 : 4.0),
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(
          isMobile ? 8.0 : 12.0,
        ),
      ),
      child: Padding(
        padding: responsivePadding,
        child: child,
      ),
    );
  }
}

/// A responsive text widget that adjusts font size based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? mobileScale;
  final double? tabletScale;
  final double? desktopScale;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mobileScale = 0.9,
    this.tabletScale = 1.0,
    this.desktopScale = 1.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    double scale;
    if (isMobile) {
      scale = mobileScale ?? 0.9;
    } else if (isTablet) {
      scale = tabletScale ?? 1.0;
    } else {
      scale = desktopScale ?? 1.1;
    }

    final responsiveStyle = style?.copyWith(
      fontSize: style?.fontSize != null ? style!.fontSize! * scale : null,
    );

    return Text(
      text,
      style: responsiveStyle ?? style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
