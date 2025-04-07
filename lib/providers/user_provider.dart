import 'package:flutter_riverpod/flutter_riverpod.dart';


class User {
  final String name;
  final String email;

  User({required this.name, required this.email});
}


class LoginNotifier extends StateNotifier<User?> {
  LoginNotifier() : super(null);

  void login(String name, String email) {
    print("]n\n\n\n\n\n $email,$name \n\n\n\n\n\n");
    state = User(name: name, email: email);
  }

  void logout() {
    state = null;
  }

  // Helper getters
  String? get userName => state?.name;
  String? get userEmail => state?.email;
}


final loginProvider = StateNotifierProvider<LoginNotifier, User?>((ref) {
  return LoginNotifier();
});


final userNameProvider = Provider<String?>((ref) {
  return ref.watch(loginProvider.notifier).userName;
});

final userEmailProvider = Provider<String?>((ref) {
  return ref.watch(loginProvider.notifier).userEmail;
});
