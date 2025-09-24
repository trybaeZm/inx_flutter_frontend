import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}


