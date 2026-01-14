import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/di/service_locator.dart';
import '../../services/auth_service.dart';

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return getIt<AuthService>();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Auth State Provider (for auth state changes)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// User Display Name Provider
final userDisplayNameProvider = Provider<String>((ref) {
  return ref.watch(authServiceProvider).displayName;
});

/// User Email Provider
final userEmailProvider = Provider<String>((ref) {
  return ref.watch(authServiceProvider).email;
});

/// Auth State Notifier for login/logout actions
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AsyncValue.data(_authService.currentUser));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp(String email, String password, String? fullName) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }
}

/// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
