import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recipe_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Path to store database on device
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "recipes.db");

    // Only copy if the database doesn't exist
    if (!(await File(path).exists())) {
      // Load from asset and copy
      ByteData data = await rootBundle.load('assets/db/recipes.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
      print("Database copied from assets!");
    }

    return await openDatabase(path, readOnly: false);
  }
}

extension RecipeQueries on DatabaseHelper {
  Future<List<Recipe>> fetchAllRecipes() async {
    final db = await database;
    final maps = await db.query('recipes');
    return maps.map((map) => Recipe.fromMap(map)).toList();
  }

  Future<Recipe?> fetchRecipeById(int id) async {
    final db = await database;
    final maps = await db.query('recipes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Recipe.fromMap(maps.first);
    return null;
  }
}