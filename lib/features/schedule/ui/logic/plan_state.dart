part of 'plan_cubit.dart';

abstract class PlanState extends Equatable {
  const PlanState();

  @override
  List<Object?> get props => [];
}

class PlanInitial extends PlanState {}

class PlanLoading extends PlanState {}

class PlanLoaded extends PlanState {
  final List<Event> events;
  final DateTime selectedDate;

  const PlanLoaded({required this.events, required this.selectedDate});

  @override
  List<Object?> get props => [events, selectedDate];
}

class PlanError extends PlanState {
  final String message;

  const PlanError({required this.message});

  @override
  List<Object?> get props => [message];
}
