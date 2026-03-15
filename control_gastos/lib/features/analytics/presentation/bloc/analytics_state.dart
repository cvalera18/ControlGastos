part of 'analytics_bloc.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final MonthlySummary summary;
  const AnalyticsLoaded(this.summary);
  @override
  List<Object> get props => [summary];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);
  @override
  List<Object> get props => [message];
}
