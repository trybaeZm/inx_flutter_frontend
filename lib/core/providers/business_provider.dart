import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';

class SelectedBusinessNotifier extends StateNotifier<Business?> {
  SelectedBusinessNotifier() : super(null);

  void set(Business business) => state = business;
  void clear() => state = null;
}

final selectedBusinessProvider =
    StateNotifierProvider<SelectedBusinessNotifier, Business?>((ref) {
  return SelectedBusinessNotifier();
});


