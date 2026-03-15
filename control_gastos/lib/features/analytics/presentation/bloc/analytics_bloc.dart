import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/analytics/domain/entities/expense_summary.dart';
import 'package:control_gastos/features/analytics/domain/usecases/get_monthly_summary_usecase.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetMonthlySummaryUseCase getMonthlySummaryUseCase;

  AnalyticsBloc({required this.getMonthlySummaryUseCase})
      : super(const AnalyticsInitial()) {
    on<FetchMonthlySummaryEvent>(_onFetchMonthlySummary);
  }

  Future<void> _onFetchMonthlySummary(
    FetchMonthlySummaryEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getMonthlySummaryUseCase(
      MonthlySummaryParams(userId: event.userId, month: event.month),
    );
    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (summary) => emit(AnalyticsLoaded(summary)),
    );
  }
}
