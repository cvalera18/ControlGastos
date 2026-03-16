import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:control_gastos/features/analytics/presentation/pages/analytics_page.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/auth/presentation/pages/login_page.dart';
import 'package:control_gastos/features/auth/presentation/pages/register_page.dart';
import 'package:control_gastos/features/expenses/presentation/pages/add_expense_page.dart';
import 'package:control_gastos/features/expenses/presentation/pages/expense_list_page.dart';
import 'package:control_gastos/features/payment_methods/presentation/pages/payment_method_page.dart';
import 'package:control_gastos/features/categories/presentation/pages/category_manage_page.dart';
import 'package:control_gastos/features/groups/presentation/pages/group_list_page.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/groups/presentation/pages/group_detail_page.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = authBloc.state;
      if (authState is AuthInitial || authState is AuthLoading) return null;

      final isOnAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (authState is AuthAuthenticated && isOnAuthPage) return '/home';
      if (authState is AuthUnauthenticated && !isOnAuthPage) return '/login';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/home', builder: (_, __) => const ExpenseListPage()),
      GoRoute(
        path: '/add-expense',
        builder: (_, state) => AddExpensePage(existingExpense: state.extra as Expense?),
      ),
      GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsPage()),
      GoRoute(path: '/payment-methods', builder: (_, __) => const PaymentMethodPage()),
      GoRoute(path: '/categories', builder: (_, __) => const CategoryManagePage()),
      GoRoute(path: '/groups', builder: (_, __) => const GroupListPage()),
      GoRoute(
        path: '/groups/:id',
        builder: (_, state) => GroupDetailPage(
          groupId: state.pathParameters['id']!,
          groupName: state.extra as String? ?? '',
        ),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
