import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixngo_customer/providers/auth_provider.dart';

// Since the path might be slightly different, let's just test that we can import provider
void main() {
  testWidgets('Customer App Smoke Test - AuthProvider initializes', (WidgetTester tester) async {
    final authProvider = AuthProvider();
    expect(authProvider.isAuthenticated, false);
    expect(authProvider.userProfile, null);
  });
}
