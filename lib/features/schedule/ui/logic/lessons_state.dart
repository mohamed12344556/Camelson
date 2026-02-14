part of 'lessons_cubit.dart';

abstract class LessonsState extends Equatable {
  const LessonsState();

  @override
  List<Object?> get props => [];
}

class LessonsInitial extends LessonsState {}

class LessonsLoading extends LessonsState {}

class LessonsLoaded extends LessonsState {
  final List<Event> events;
  final DateTime selectedDate;

  const LessonsLoaded({required this.events, required this.selectedDate});

  @override
  List<Object?> get props => [events, selectedDate];
}

class LessonsError extends LessonsState {
  final String message;

  const LessonsError({required this.message});

  @override
  List<Object?> get props => [message];
}