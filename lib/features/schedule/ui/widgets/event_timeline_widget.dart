import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../data/models/event_model.dart';

class EventTimelineWidget extends StatelessWidget {
  final List<Event> events;
  final Function(String) onEventTap;
  final Function(String) onEventDelete;

  const EventTimelineWidget({
    super.key,
    required this.events,
    required this.onEventTap,
    required this.onEventDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No events for this day',
          style: TextStyle(color: Color(0xFF797979), fontSize: 16),
        ),
      );
    }

    return Timeline.tileBuilder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      theme: TimelineThemeData(
        nodePosition: 0,
        color: const Color(0xFF2F98D7),
        indicatorTheme: const IndicatorThemeData(position: 0, size: 20.0),
        connectorTheme: const ConnectorThemeData(
          color: Color(0xFFE0E0E0),
          thickness: 2.0,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        itemCount: events.length,
        contentsBuilder: (context, index) {
          final event = events[index];
          return EventCard(
            event: event,
            onTap: () => onEventTap(event.id),
            onDelete: () => onEventDelete(event.id),
          );
        },
        indicatorBuilder: (context, index) {
          final event = events[index];
          return DotIndicator(
            color: event.backgroundColor,
            child:
                event.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
          );
        },
        connectorBuilder: (context, index, type) {
          return const SolidLineConnector(color: Color(0xFFE0E0E0));
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                event.isCompleted
                    ? event.backgroundColor.withOpacity(0.3)
                    : event.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border:
                event.isCompleted
                    ? Border.all(color: event.backgroundColor, width: 2)
                    : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: TextStyle(
                        color:
                            event.isCompleted
                                ? const Color(0xFF797979)
                                : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration:
                            event.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                    ),
                  ),
                  if (event.type == EventType.user)
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color:
                            event.isCompleted
                                ? const Color(0xFF797979)
                                : Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Time',
                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                event.isCompleted,
              ),
              const SizedBox(height: 4),
              _buildInfoRow('Place', event.place, event.isCompleted),
              const SizedBox(height: 4),
              _buildInfoRow('Notes', event.notes, event.isCompleted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isCompleted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(
              color: isCompleted ? const Color(0xFF797979) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isCompleted ? const Color(0xFF797979) : Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
