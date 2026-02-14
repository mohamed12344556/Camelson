import 'package:bloc/bloc.dart';
import 'package:camelson/core/core.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/event_model.dart';
import '../../data/repos/event_repository.dart';

part 'lessons_state.dart';

class LessonsCubit extends Cubit<LessonsState> {
  final EventRepository _eventRepository;

  LessonsCubit({required EventRepository eventRepository})
    : _eventRepository = eventRepository,
      super(LessonsInitial());

  Future<void> loadEvents({DateTime? selectedDate}) async {
    try {
      safeEmit(LessonsLoading());

      final date = selectedDate ?? DateTime.now();
      final events = await _eventRepository.getEventsByDate(date);
      final systemEvents = events
          .where((e) => e.type == EventType.system)
          .toList();

      safeEmit(LessonsLoaded(events: systemEvents, selectedDate: date));
    } catch (e) {
      safeEmit(LessonsError(message: e.toString()));
    }
  }

  Future<void> toggleEventCompletion(String eventId) async {
    try {
      final currentState = state;
      if (currentState is LessonsLoaded) {
        final events = currentState.events;
        final eventIndex = events.indexWhere((e) => e.id == eventId);

        if (eventIndex != -1) {
          final event = events[eventIndex];
          final updatedEvent = event.copyWith(isCompleted: !event.isCompleted);

          await _eventRepository.updateEvent(updatedEvent);

          final updatedEvents = List<Event>.from(events);
          updatedEvents[eventIndex] = updatedEvent;

          safeEmit(
            LessonsLoaded(
              events: updatedEvents,
              selectedDate: currentState.selectedDate,
            ),
          );
        }
      }
    } catch (e) {
      safeEmit(LessonsError(message: e.toString()));
    }
  }

  void selectDate(DateTime date) {
    loadEvents(selectedDate: date);
  }
}
