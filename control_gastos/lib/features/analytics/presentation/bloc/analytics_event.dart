part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class FetchMonthlySummaryEvent extends AnalyticsEvent {
  final String userId;
  final DateTime month;
  const FetchMonthlySummaryEvent({required this.userId, required this.month});
  @override
  List<Object> get props => [userId, month];
}
