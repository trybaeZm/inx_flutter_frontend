import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotionColors {
  // Light mode colors
  static const Color lightBackground = Color(0xFFFFFFFF); // Main window
  static const Color lightSurface = Color(0xFFF7F6F3); // Sidebar / subtle surfaces
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE9E9E7);
  static const Color lightDivider = Color(0xFFE9E9E7);
  static const Color lightHover = Color(0xFFF1F1EF); // Hover state
  static const Color lightPressed = Color(0xFFE9E9E7);
  
  // Dark mode colors (Notion)
  static const Color darkBackground = Color(0xFF191919); // Main window per request
  static const Color darkSurface = Color(0xFF333333); // Sidebar / panels
  static const Color darkCardBackground = Color(0xFF373C3F);
  static const Color darkBorder = Color(0xFF3F4448); // Hover/outline
  static const Color darkDivider = Color(0xFF3F4448);
  static const Color darkHover = Color(0xFF3F4448);
  static const Color darkPressed = Color(0xFF454B52);
  
  // Text colors
  static const Color lightTextPrimary = Color(0xFF37352F);
  static const Color lightTextSecondary = Color(0xFF787774);
  static const Color lightTextTertiary = Color(0xFF9B9B9B);
  
  static const Color darkTextPrimary = Color(0xFFD4D4D4);
  static const Color darkTextSecondary = Color(0xFF9B9B9B);
  static const Color darkTextTertiary = Color(0xFF6F6F6F);
  
  // Accent palette (Notion)
  static const Color gray = Color(0xFF787774);
  static const Color brown = Color(0xFF9F6B53);
  static const Color orange = Color(0xFFD9730D);
  static const Color yellow = Color(0xFFCB912F);
  static const Color green = Color(0xFF448361);
  static const Color blue = Color(0xFF337EA9); // Light accent example
  static const Color purple = Color(0xFF9065B0);
  static const Color pink = Color(0xFFC14C8A);
  static const Color red = Color(0xFFD44C47);

  // Dark accent approximations
  static const Color blueDarkAccent = Color(0xFF447ACB);
  static const Color redDark = Color(0xFFBE524B);
  static const Color greenDark = Color(0xFF4F9768);
  static const Color yellowDark = Color(0xFFC19138);
  static const Color orangeDark = Color(0xFFCB7B37);
  static const Color purpleDark = Color(0xFF865DBB);
  static const Color pinkDark = Color(0xFFBA4A78);
  static const Color brownDark = Color(0xFFA27763);
  static const Color grayDark = Color(0xFF9B9B9B);
  
  // Light callout backgrounds
  static const Color calloutGrayLight = Color(0xFFF1F1EF);
  static const Color calloutBrownLight = Color(0xFFF4EEEE);
  static const Color calloutOrangeLight = Color(0xFFFAEBDD);
  static const Color calloutYellowLight = Color(0xFFFBF3DB);
  static const Color calloutGreenLight = Color(0xFFEDF3EC);
  static const Color calloutBlueLight = Color(0xFFE7F3F8);
  static const Color calloutPurpleLight = Color(0xFFF6F3F9);
  static const Color calloutPinkLight = Color(0xFFFAF1F5);
  static const Color calloutRedLight = Color(0xFFFDEBEC);

  // Dark callout backgrounds
  static const Color calloutGrayDark = Color(0xFF252525);
  static const Color calloutBrownDark = Color(0xFF2E2724);
  static const Color calloutOrangeDark = Color(0xFF36291F);
  static const Color calloutYellowDark = Color(0xFF372E20);
  static const Color calloutGreenDark = Color(0xFF242B26);
  static const Color calloutBlueDark = Color(0xFF1F282D);
  static const Color calloutPurpleDark = Color(0xFF2A2430);
  static const Color calloutPinkDark = Color(0xFF2E2328);
  static const Color calloutRedDark = Color(0xFF332523);
  
  // Status colors
  static const Color success = green;
  static const Color warning = yellow;
  static const Color error = red;
  static const Color info = blue;
}

class NotionTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color scheme
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: NotionColors.gray,
      onPrimary: Colors.white,
      secondary: NotionColors.lightTextSecondary,
      onSecondary: Colors.white,
      surface: NotionColors.lightSurface,
      onSurface: NotionColors.lightTextPrimary,
      background: NotionColors.lightBackground,
      onBackground: NotionColors.lightTextPrimary,
      error: NotionColors.error,
      onError: Colors.white,
      outline: NotionColors.lightBorder,
      surfaceVariant: NotionColors.lightCardBackground,
      onSurfaceVariant: NotionColors.lightTextSecondary,
    ),
    
    // Scaffold theme
    scaffoldBackgroundColor: NotionColors.lightBackground,
    
    // Card theme
    cardTheme: CardTheme(
      color: NotionColors.lightCardBackground,
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.zero,
    ),
    
    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: NotionColors.lightBackground,
      foregroundColor: NotionColors.lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: NotionColors.lightTextPrimary,
      ),
      iconTheme: const IconThemeData(color: NotionColors.lightTextSecondary),
      actionsIconTheme: const IconThemeData(color: NotionColors.lightTextSecondary),
    ),

    drawerTheme: const DrawerThemeData(backgroundColor: NotionColors.lightSurface),
    
    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NotionColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: NotionColors.lightTextSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: NotionColors.lightTextPrimary,
        side: const BorderSide(color: NotionColors.lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NotionColors.lightBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: NotionColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: NotionColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: NotionColors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: NotionColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      hintStyle: GoogleFonts.inter(
        color: NotionColors.lightTextTertiary,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.inter(
        color: NotionColors.lightTextSecondary,
        fontSize: 14,
      ),
    ),
    
    // List tile theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      dense: true,
      horizontalTitleGap: 12,
      minLeadingWidth: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      tileColor: Colors.transparent,
      selectedTileColor: NotionColors.lightHover,
      textColor: NotionColors.lightTextPrimary,
      iconColor: NotionColors.lightTextSecondary,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: NotionColors.lightTextPrimary,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 13,
        color: NotionColors.lightTextSecondary,
      ),
    ),
    
    // Divider theme
    dividerTheme: const DividerThemeData(space: 1),
    
    // Text theme
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: NotionColors.lightTextPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: NotionColors.lightTextPrimary,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: NotionColors.lightTextPrimary,
        height: 1.3,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: NotionColors.lightTextPrimary,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: NotionColors.lightTextPrimary,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: NotionColors.lightTextPrimary,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: NotionColors.lightTextPrimary,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: NotionColors.lightTextPrimary,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: NotionColors.lightTextPrimary,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: NotionColors.lightTextPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: NotionColors.lightTextPrimary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: NotionColors.lightTextSecondary,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: NotionColors.lightTextPrimary,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: NotionColors.lightTextSecondary,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: NotionColors.lightTextTertiary,
        height: 1.4,
      ),
    ),
    
    // Icon theme
    iconTheme: const IconThemeData(
      color: NotionColors.lightTextSecondary,
      size: 20,
    ),
    
    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: NotionColors.gray,
      linearTrackColor: NotionColors.lightBorder,
      circularTrackColor: NotionColors.lightBorder,
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: NotionColors.lightHover,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: NotionColors.lightTextPrimary,
      ),
      side: const BorderSide(color: NotionColors.lightBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    
    // Dialog theme
    dialogTheme: DialogTheme(
      backgroundColor: NotionColors.lightCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: NotionColors.lightTextPrimary,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: NotionColors.lightTextPrimary,
      ),
    ),
    
    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: NotionColors.darkBackground,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color scheme
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: NotionColors.grayDark,
      onPrimary: Colors.white,
      secondary: NotionColors.darkTextSecondary,
      onSecondary: Colors.white,
      surface: NotionColors.darkSurface,
      onSurface: NotionColors.darkTextPrimary,
      background: NotionColors.darkBackground,
      onBackground: NotionColors.darkTextPrimary,
      error: NotionColors.error,
      onError: Colors.white,
      outline: NotionColors.darkBorder,
      surfaceVariant: NotionColors.darkCardBackground,
      onSurfaceVariant: NotionColors.darkTextSecondary,
    ),
    
    // Scaffold theme
    scaffoldBackgroundColor: NotionColors.darkBackground,
    
    // Card theme
    cardTheme: CardTheme(
      color: NotionColors.darkCardBackground,
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.zero,
    ),
    
    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: NotionColors.darkBackground,
      foregroundColor: NotionColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: NotionColors.darkTextPrimary,
      ),
      iconTheme: const IconThemeData(color: NotionColors.darkTextSecondary),
      actionsIconTheme: const IconThemeData(color: NotionColors.darkTextSecondary),
    ),

    drawerTheme: const DrawerThemeData(backgroundColor: NotionColors.darkSurface),
    
    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NotionColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: NotionColors.darkTextSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: NotionColors.darkTextPrimary,
        side: const BorderSide(color: NotionColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NotionColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: NotionColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: NotionColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: NotionColors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: NotionColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      hintStyle: GoogleFonts.inter(
        color: NotionColors.darkTextTertiary,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.inter(
        color: NotionColors.darkTextSecondary,
        fontSize: 14,
      ),
    ),
    
    // List tile theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      dense: true,
      horizontalTitleGap: 12,
      minLeadingWidth: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      tileColor: Colors.transparent,
      selectedTileColor: NotionColors.darkHover,
      textColor: NotionColors.darkTextPrimary,
      iconColor: NotionColors.darkTextSecondary,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: NotionColors.darkTextPrimary,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 13,
        color: NotionColors.darkTextSecondary,
      ),
    ),
    
    // Divider theme
    dividerTheme: const DividerThemeData(space: 1),
    
    // Text theme
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: NotionColors.darkTextPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: NotionColors.darkTextPrimary,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: NotionColors.darkTextPrimary,
        height: 1.3,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: NotionColors.darkTextPrimary,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: NotionColors.darkTextPrimary,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: NotionColors.darkTextPrimary,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: NotionColors.darkTextPrimary,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: NotionColors.darkTextPrimary,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: NotionColors.darkTextPrimary,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: NotionColors.darkTextPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: NotionColors.darkTextPrimary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: NotionColors.darkTextSecondary,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: NotionColors.darkTextPrimary,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: NotionColors.darkTextSecondary,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: NotionColors.darkTextTertiary,
        height: 1.4,
      ),
    ),
    
    // Icon theme
    iconTheme: const IconThemeData(
      color: NotionColors.darkTextSecondary,
      size: 20,
    ),
    
    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: NotionColors.grayDark,
      linearTrackColor: NotionColors.darkBorder,
      circularTrackColor: NotionColors.darkBorder,
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: NotionColors.darkHover,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: NotionColors.darkTextPrimary,
      ),
      side: const BorderSide(color: NotionColors.darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    
    // Dialog theme
    dialogTheme: DialogTheme(
      backgroundColor: NotionColors.darkCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: NotionColors.darkTextPrimary,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: NotionColors.darkTextPrimary,
      ),
    ),
    
    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: NotionColors.lightBackground,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: NotionColors.lightTextPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );
} 