import 'package:quantum_it/note.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class ListService {

  static Future<List<Note>> getSuggestions(String query) async{

    List<Note> noteListFuture =await getlist();

    List<Note> matches = [];
    matches.addAll(noteListFuture);
    matches.retainWhere((s) => s.title.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  static Future<List<Note>> getlist() async {

    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    await databaseHelper.initializeDatabase();
    return await databaseHelper.getNoteList();

  }

}