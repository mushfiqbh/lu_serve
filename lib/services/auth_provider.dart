import 'package:flutter/material.dart';
import 'package:lu_serve/services/auth_service.dart';

/// Provides a single shared [AuthService] instance throughout the widget tree.
class AuthProvider extends InheritedNotifier<AuthService> {
  const AuthProvider({
    super.key,
    required AuthService authService,
    required super.child,
  }) : super(notifier: authService);

  /// Convenient accessor: returns the [AuthService] from the nearest
  /// [AuthProvider] ancestor.
  static AuthService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AuthProvider>();
    assert(provider != null, 'No AuthProvider found in context');
    return provider!.notifier!;
  }

  /// Read-only access (does not register a dependency for rebuilds).
  static AuthService read(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<AuthProvider>();
    assert(provider != null, 'No AuthProvider found in context');
    return provider!.notifier!;
  }
}
