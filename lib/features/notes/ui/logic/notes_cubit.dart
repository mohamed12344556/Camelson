import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/core.dart';
import '../../data/models/note_model.dart';
import '../../data/repos/notes_repo.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository _repository;
  final Uuid _uuid = const Uuid();

  NotesCubit(this._repository) : super(NotesInitial());

  Future<void> loadNotes() async {
    try {
      safeEmit(NotesLoading());
      final notes = _repository.getNotesOrderedByDate();
      if (notes.isEmpty) {
        safeEmit(NotesEmpty());
      } else {
        safeEmit(NotesLoaded(notes));
      }
    } catch (e) {
      safeEmit(NotesError(e.toString()));
    }
  }

  Future<void> addNote({required String title, required String content}) async {
    try {
      final now = DateTime.now();
      final note = Note(
        id: _uuid.v4(),
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addNote(note);
      // فورا بعد الإضافة، حمل البيانات الجديدة
      await loadNotes();
    } catch (e) {
      safeEmit(NotesError(e.toString()));
    }
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      final existingNote = _repository.getNoteById(id);
      if (existingNote != null) {
        final updatedNote = existingNote.copyWith(
          title: title,
          content: content,
          updatedAt: DateTime.now(),
        );
        await _repository.updateNote(updatedNote);
        // فورا بعد التحديث، حمل البيانات الجديدة
        await loadNotes();
      } else {
        safeEmit(NotesError('Note not found'));
      }
    } catch (e) {
      safeEmit(NotesError(e.toString()));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      // فورا بعد الحذف، حمل البيانات الجديدة
      await loadNotes();
    } catch (e) {
      safeEmit(NotesError(e.toString()));
    }
  }

  Note? getNoteById(String id) {
    try {
      return _repository.getNoteById(id);
    } catch (e) {
      safeEmit(NotesError(e.toString()));
      return null;
    }
  }

  // New method to check if notes exist and navigate accordingly
  bool hasNotes() {
    try {
      return _repository.notesCount > 0;
    } catch (e) {
      return false;
    }
  }

  // Method to get current notes without changing state
  List<Note> getCurrentNotes() {
    final currentState = state;
    if (currentState is NotesLoaded) {
      return currentState.notes;
    }
    return _repository.getNotesOrderedByDate();
  }
}
