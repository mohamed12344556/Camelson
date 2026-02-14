import 'package:bloc/bloc.dart';
import 'package:camelson/core/core.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/event_model.dart';
import '../../data/repos/event_repository.dart';

part 'plan_state.dart';

class PlanCubit extends Cubit<PlanState> {
  final EventRepository _eventRepository;

  PlanCubit({required EventRepository eventRepository})
    : _eventRepository = eventRepository,
      super(PlanInitial());

  Future<void> loadEvents({DateTime? selectedDate}) async {
    try {
      safeEmit(PlanLoading());

      final date = selectedDate ?? DateTime.now();
      final events = await _eventRepository.getEventsByDate(date);
      final userEvents = events.where((e) => e.type == EventType.user).toList();

      safeEmit(PlanLoaded(events: userEvents, selectedDate: date));
    } catch (e) {
      safeEmit(PlanError(message: e.toString()));
    }
  }

  Future<void> toggleEventCompletion(String eventId) async {
    try {
      final currentState = state;
      if (currentState is PlanLoaded) {
        final events = currentState.events;
        final eventIndex = events.indexWhere((e) => e.id == eventId);

        if (eventIndex != -1) {
          final event = events[eventIndex];
          final updatedEvent = event.copyWith(isCompleted: !event.isCompleted);

          await _eventRepository.updateEvent(updatedEvent);

          final updatedEvents = List<Event>.from(events);
          updatedEvents[eventIndex] = updatedEvent;

          safeEmit(
            PlanLoaded(
              events: updatedEvents,
              selectedDate: currentState.selectedDate,
            ),
          );
        }
      }
    } catch (e) {
      safeEmit(PlanError(message: e.toString()));
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      await _eventRepository.addEvent(event);
      loadEvents(selectedDate: (state as PlanLoaded).selectedDate);
    } catch (e) {
      safeEmit(PlanError(message: e.toString()));
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventRepository.deleteEvent(eventId);
      loadEvents(selectedDate: (state as PlanLoaded).selectedDate);
    } catch (e) {
      safeEmit(PlanError(message: e.toString()));
    }
  }

  void selectDate(DateTime date) {
    loadEvents(selectedDate: date);
  }
}
