import 'package:flutter_riverpod/flutter_riverpod.dart';

class GestureState {
  bool isGestureNavi;

  GestureState({this.isGestureNavi = false});

  GestureState copyWith({bool? isGestureNavi}) {
    return GestureState(
      isGestureNavi: isGestureNavi ?? this.isGestureNavi,
    );
  }
}

class GestureNotifier extends StateNotifier<GestureState> {
  GestureNotifier() : super(GestureState());

  void toggleGesture() {
    print("changing Gesture");
    state = state.copyWith(isGestureNavi: !state.isGestureNavi);
  }

  void setGesture(bool value) {
    state = state.copyWith(isGestureNavi: value);
  }

  bool getGesture(){
    return state.isGestureNavi;
  }
}


final gestureProvider =
    StateNotifierProvider<GestureNotifier, GestureState>((ref) => GestureNotifier());
