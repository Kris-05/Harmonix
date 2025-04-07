import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeNotifier extends StateNotifier<int> {
  HomeNotifier() : super(0); // Default page is Home (index 0)

  void setPage(int index) {
    state = index;
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, int>((ref) => HomeNotifier());



