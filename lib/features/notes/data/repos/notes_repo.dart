import 'package:hive_ce/hive.dart';

import '../models/note_model.dart';

class NotesRepository {
  static const String _boxName = 'notes';
  Box<Note>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<Note>(_boxName);
  }

  Future<void> addNote(Note note) async {
    await _box?.put(note.id, note);
  }

  Future<void> updateNote(Note note) async {
    await _box?.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _box?.delete(id);
  }

  List<Note> getAllNotes() {
    return _box?.values.toList() ?? [];
  }

  Note? getNoteById(String id) {
    return _box?.get(id);
  }

  Future<void> clearAllNotes() async {
    await _box?.clear();
  }

  int get notesCount => _box?.length ?? 0;

  bool get isEmpty => notesCount == 0;

  List<Note> getNotesOrderedByDate() {
    final notes = getAllNotes();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }
}