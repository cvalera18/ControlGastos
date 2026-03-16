import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:control_gastos/features/analytics/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:control_gastos/features/analytics/presentation/bloc/analytics_bloc.dart';

import 'package:control_gastos/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:control_gastos/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:control_gastos/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:control_gastos/features/auth/domain/repositories/auth_repository.dart';
import 'package:control_gastos/features/auth/domain/usecases/login_usecase.dart';
import 'package:control_gastos/features/auth/domain/usecases/logout_usecase.dart';
import 'package:control_gastos/features/auth/domain/usecases/register_usecase.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:control_gastos/features/categories/data/datasources/category_local_datasource.dart';
import 'package:control_gastos/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:control_gastos/features/categories/data/repositories/category_repository_impl.dart';
import 'package:control_gastos/features/categories/domain/repositories/category_repository.dart';
import 'package:control_gastos/features/categories/domain/usecases/add_category_usecase.dart';
import 'package:control_gastos/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:control_gastos/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:control_gastos/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:control_gastos/features/categories/presentation/bloc/category_bloc.dart';

import 'package:control_gastos/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:control_gastos/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:control_gastos/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:control_gastos/features/expenses/domain/repositories/expense_repository.dart';
import 'package:control_gastos/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:control_gastos/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:control_gastos/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:control_gastos/features/expenses/domain/usecases/update_expense_usecase.dart';
import 'package:control_gastos/features/expenses/presentation/bloc/expense_bloc.dart';

import 'package:control_gastos/features/payment_methods/data/datasources/payment_method_local_datasource.dart';
import 'package:control_gastos/features/payment_methods/data/datasources/payment_method_remote_datasource.dart';
import 'package:control_gastos/features/payment_methods/data/repositories/payment_method_repository_impl.dart';
import 'package:control_gastos/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/add_payment_method_usecase.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/delete_payment_method_usecase.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/get_payment_methods_usecase.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/update_payment_method_usecase.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';

import 'package:control_gastos/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:control_gastos/features/groups/data/repositories/group_repository_impl.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_repository.dart';
import 'package:control_gastos/features/groups/domain/usecases/add_group_expense_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/create_group_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/get_group_expenses_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/get_groups_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/join_group_usecase.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<firebase_auth.FirebaseAuth>(firebase_auth.FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Auth datasources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(auth: getIt(), firestore: getIt()),
  );
  getIt.registerSingleton<AuthLocalDataSource>(
    AuthLocalDataSourceImpl(getIt()),
  );

  // Auth repository
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(remote: getIt(), local: getIt()),
  );

  // Auth usecases
  getIt.registerSingleton<LoginUseCase>(LoginUseCase(getIt()));
  getIt.registerSingleton<RegisterUseCase>(RegisterUseCase(getIt()));
  getIt.registerSingleton<LogoutUseCase>(LogoutUseCase(getIt()));

  // Auth BLoC
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(loginUseCase: getIt(), registerUseCase: getIt(), logoutUseCase: getIt()),
  );

  // Expense datasources
  getIt.registerSingleton<ExpenseRemoteDataSource>(
    ExpenseRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<ExpenseLocalDataSource>(
    ExpenseLocalDataSourceImpl(getIt()),
  );

  // Expense repository
  getIt.registerSingleton<ExpenseRepository>(
    ExpenseRepositoryImpl(remote: getIt(), local: getIt()),
  );

  // Expense usecases
  getIt.registerSingleton<GetExpensesUseCase>(GetExpensesUseCase(getIt()));
  getIt.registerSingleton<AddExpenseUseCase>(AddExpenseUseCase(getIt()));
  getIt.registerSingleton<UpdateExpenseUseCase>(UpdateExpenseUseCase(getIt()));
  getIt.registerSingleton<DeleteExpenseUseCase>(DeleteExpenseUseCase(getIt()));

  // Expense BLoC
  getIt.registerFactory<ExpenseBloc>(
    () => ExpenseBloc(
      getExpensesUseCase: getIt(),
      addExpenseUseCase: getIt(),
      updateExpenseUseCase: getIt(),
      deleteExpenseUseCase: getIt(),
    ),
  );

  // Category datasources
  getIt.registerSingleton<CategoryRemoteDataSource>(
    CategoryRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<CategoryLocalDataSource>(
    CategoryLocalDataSourceImpl(getIt()),
  );

  // Category repository
  getIt.registerSingleton<CategoryRepository>(
    CategoryRepositoryImpl(remote: getIt(), local: getIt()),
  );

  // Category usecases
  getIt.registerSingleton<GetCategoriesUseCase>(GetCategoriesUseCase(getIt()));
  getIt.registerSingleton<AddCategoryUseCase>(AddCategoryUseCase(getIt()));
  getIt.registerSingleton<UpdateCategoryUseCase>(UpdateCategoryUseCase(getIt()));
  getIt.registerSingleton<DeleteCategoryUseCase>(DeleteCategoryUseCase(getIt()));

  // Category BLoC
  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(
      getCategoriesUseCase: getIt(),
      addCategoryUseCase: getIt(),
      updateCategoryUseCase: getIt(),
      deleteCategoryUseCase: getIt(),
    ),
  );

  // PaymentMethod datasources
  getIt.registerSingleton<PaymentMethodRemoteDataSource>(
    PaymentMethodRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<PaymentMethodLocalDataSource>(
    PaymentMethodLocalDataSourceImpl(getIt()),
  );

  // PaymentMethod repository
  getIt.registerSingleton<PaymentMethodRepository>(
    PaymentMethodRepositoryImpl(remote: getIt(), local: getIt()),
  );

  // PaymentMethod usecases
  getIt.registerSingleton<GetPaymentMethodsUseCase>(GetPaymentMethodsUseCase(getIt()));
  getIt.registerSingleton<AddPaymentMethodUseCase>(AddPaymentMethodUseCase(getIt()));
  getIt.registerSingleton<UpdatePaymentMethodUseCase>(UpdatePaymentMethodUseCase(getIt()));
  getIt.registerSingleton<DeletePaymentMethodUseCase>(DeletePaymentMethodUseCase(getIt()));

  // PaymentMethod BLoC
  getIt.registerFactory<PaymentMethodBloc>(
    () => PaymentMethodBloc(
      getPaymentMethodsUseCase: getIt(),
      addPaymentMethodUseCase: getIt(),
      updatePaymentMethodUseCase: getIt(),
      deletePaymentMethodUseCase: getIt(),
    ),
  );

  // Analytics
  getIt.registerSingleton<GetMonthlySummaryUseCase>(GetMonthlySummaryUseCase(getIt()));
  getIt.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(getMonthlySummaryUseCase: getIt()),
  );

  // Group datasource
  getIt.registerSingleton<GroupRemoteDataSource>(
    GroupRemoteDataSourceImpl(getIt()),
  );

  // Group repository
  getIt.registerSingleton<GroupRepository>(
    GroupRepositoryImpl(remote: getIt()),
  );

  // Group usecases
  getIt.registerSingleton<GetGroupsUseCase>(GetGroupsUseCase(getIt()));
  getIt.registerSingleton<CreateGroupUseCase>(CreateGroupUseCase(getIt()));
  getIt.registerSingleton<JoinGroupUseCase>(JoinGroupUseCase(getIt()));
  getIt.registerSingleton<GetGroupExpensesUseCase>(GetGroupExpensesUseCase(getIt()));
  getIt.registerSingleton<AddGroupExpenseUseCase>(AddGroupExpenseUseCase(getIt()));

  // Group BLoC
  getIt.registerFactory<GroupBloc>(
    () => GroupBloc(
      getGroupsUseCase: getIt(),
      createGroupUseCase: getIt(),
      joinGroupUseCase: getIt(),
      getGroupExpensesUseCase: getIt(),
      addGroupExpenseUseCase: getIt(),
    ),
  );
}
