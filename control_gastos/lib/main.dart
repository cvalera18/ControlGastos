import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:control_gastos/core/config/app_theme.dart';
import 'package:control_gastos/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/categories/presentation/bloc/category_bloc.dart';
import 'package:control_gastos/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';
import 'package:control_gastos/features/incomes/presentation/bloc/income_bloc.dart';
import 'package:control_gastos/injection_container.dart';
import 'package:control_gastos/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupLocator();
  runApp(const ControlGastosApp());
}

class ControlGastosApp extends StatelessWidget {
  const ControlGastosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<ExpenseBloc>(create: (_) => getIt<ExpenseBloc>()),
        BlocProvider<CategoryBloc>(create: (_) => getIt<CategoryBloc>()),
        BlocProvider<PaymentMethodBloc>(create: (_) => getIt<PaymentMethodBloc>()),
        BlocProvider<AnalyticsBloc>(create: (_) => getIt<AnalyticsBloc>()),
        BlocProvider<GroupBloc>(create: (_) => getIt<GroupBloc>()),
        BlocProvider<IncomeBloc>(create: (_) => getIt<IncomeBloc>()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final router = createRouter(context.read<AuthBloc>());
          return MaterialApp.router(
            title: 'Control Gastos',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            locale: const Locale('es'),
          );
        },
      ),
    );
  }
}
