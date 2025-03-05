import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const folderTable = 'folderTable';
  static const columnFolderId = '_folderId';
  static const columnFolderName = 'folderName';
  static const columnTimestamp = 'timestamp';

  static const cardTable = 'cardTable';
  static const columnCardId = '_cardId';
  static const columnCardName = 'cardName';
  static const columnSuit = 'suit';
  static const columnUrl = 'imageURL';
  static const columnCardFolderId = 'folderId';

  late Database _db;

  // this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $folderTable (
        $columnFolderId INTEGER PRIMARY KEY,
        $columnFolderName TEXT NOT NULL,
        $columnTimestamp NOT NULL
      );

      CREATE TABLE $cardTable (
        $columnCardId INTEGER PRIMARY KEY,
        $columnCardName TEXT NOT NULL,
        $columnSuit TEXT NOT NULL,
        $columnUrl TEXT NOT NULL,
        $columnCardFolderId INTEGER,
        FOREIGN KEY ($columnCardFolderId) REFERENCES $folderTable ($columnFolderId)
      );
    ''');
  }

  // Insert a folder
  Future<int> insertFolder(Map<String, dynamic> row) async {
    return await _db.insert(folderTable, row);
  }

  // Insert a card and associate it with a folder
  Future<int> insertCard(Map<String, dynamic> row) async {
    return await _db.insert(cardTable, row);
  }

  // Assign a card to a folder (update the folderId)
  Future<int> assignCardToFolder(int cardId, int folderId) async {
    return await _db.update(
      cardTable,
      {columnCardFolderId: folderId},
      where: '$columnCardId = ?',
      whereArgs: [cardId],
    );
  }

  // Remove a card from a folder (set folderId to null)
  Future<int> removeCardFromFolder(int cardId) async {
    return await _db.update(
      cardTable,
      {columnCardFolderId: null},
      where: '$columnCardId = ?',
      whereArgs: [cardId],
    );
  }

  // Remove a card (delete from the database)
  Future<int> deleteCard(int cardId) async {
    return await _db.delete(
      cardTable,
      where: '$columnCardId = ?',
      whereArgs: [cardId],
    );
  }

  // Delete a folder (also deletes cards associated with the folder)
  Future<int> deleteFolder(int folderId) async {
    // First, remove all cards associated with this folder
    await _db.delete(
      cardTable,
      where: '$columnCardFolderId = ?',
      whereArgs: [folderId],
    );
    // Then, delete the folder itself
    return await _db.delete(
      folderTable,
      where: '$columnFolderId = ?',
      whereArgs: [folderId],
    );
  }

  // Get all cards in a specific folder
  Future<List<Map<String, dynamic>>> getCardsInFolder(int folderId) async {
    return await _db.query(
      cardTable,
      where: '$columnCardFolderId = ?',
      whereArgs: [folderId],
    );
  }

  // Get all folders
  Future<List<Map<String, dynamic>>> getAllFolders() async {
    return await _db.query(folderTable);
  }

  // Query all rows from the folder table
  Future<List<Map<String, dynamic>>> queryAllFolders() async {
    return await _db.query(folderTable);
  }

  // Query all rows from the card table
  Future<List<Map<String, dynamic>>> queryAllCards() async {
    return await _db.query(cardTable);
  }
}
