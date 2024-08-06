import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../group.dart';
import '../../history.dart';
import '../../item.dart';

class DatabaseHelper{

  // _database is an instance
  static Database? _database;

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static final itemsTable = 'items1';
  static final historyTable = 'history';
  static final group = 'groups';



  DatabaseHelper._privateConstructor();


  Future<Database> get database async{
    if(_database!=null) return _database!;
    _database=await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    String path = join(await getDatabasesPath(),'first_database.db');
    return await openDatabase(path,version: 1,onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async{
    await db.execute('CREATE TABLE IF NOT EXISTS shopping_list(user_id INTEGER, item_id INTEGER PRIMARY KEY,item_name TEXT, qty_to_buy REAL, checked INTEGER)');
    await db.execute('''
          CREATE TABLE IF NOT EXISTS $itemsTable (
            itemId INTEGER PRIMARY KEY,
            groupId INTEGER,
            itemName TEXT,
            color TEXT,
            qty INTEGER,
            unit TEXT,
            itemlimit INTEGER,
            description TEXT 
          )
          ''');
    await db.execute('''
          CREATE TABLE IF NOT EXISTS $historyTable (
            itemId INTEGER,
            dateTime TEXT,
            updating INTEGER,
            qty INTEGER,
            FOREIGN KEY (itemId) REFERENCES $itemsTable (itemId)
          )
          ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS $itemsTable (
            itemId INTEGER PRIMARY KEY,
            groupId INTEGER,
            itemName TEXT,
            color TEXT,
            qty INTEGER,
            unit TEXT,
            itemlimit INTEGER,
            description TEXT 
          )
          ''');


    await db.execute(
        'CREATE TABLE IF NOT EXISTS $group(grp_id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER ,grp_name TEXT)');

  }

  Future<void> create_tables() async{
    Database db = await instance.database;

    await db.execute(
        'CREATE TABLE IF NOT EXISTS $group(grp_id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER ,grp_name TEXT);');


  }



  Future<int> insertItemIntoShoppingList(int userId, int itemId, String itemName, double qtyToBuy, int checked) async {
    Database db = await instance.database;
    Map<String, dynamic> row = {
      'user_id': userId,
      'item_id': itemId,
      'item_name': itemName,
      'qty_to_buy': qtyToBuy,
      'checked': checked,
    };
    return await db.insert('shopping_list', row);
  }

  Future<int> insertItem(Item item) async {
    Database db = await instance.database;
    return await db.insert(itemsTable, item.toMap());
  }

  Future<int> insertHistoryRecord(HistoryRecord record) async {
    Database db = await instance.database;
    return await db.insert(historyTable, record.toMap());
  }

  Future<int> deleteAllItems() async {
    Database db = await instance.database;
    return await db.delete(itemsTable);
  }

  Future<int> deleteAllHistory() async {
    Database db = await instance.database;
    return await db.delete(historyTable);
  }

  Future<int> insertGrp(Groups grp) async {
    Database db = await instance.database;
    return await db.insert(group, grp.toMap());
  }

  Future<List<Groups>> getGroups() async {
    Database db = await instance.database;
    //return await db.query('group');
    final List<Map<String, dynamic>> maps = await db.query(group);
    return List.generate(maps.length, (i) {
      return Groups(
        grp_id: maps[i]['grp_id'],
        grp_name: maps[i]['grp_name'],
        user_id: maps[i]['user_id'],
      );
    });
  }

  Future<List<Item>> getItemsByGroupId(int groupId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM items1
      WHERE groupId = ?
    ''', [groupId]);

    return List.generate(maps.length, (i) {
      return Item(
        itemId: maps[i]['itemId'],
        groupId: maps[i]['groupId'],
        itemName: maps[i]['itemName'],
        color: maps[i]['color'],
        qty: maps[i]['qty'],
        unit: maps[i]['unit'],
        itemlimit: maps[i]['itemlimit'],
        description: maps[i]['description'],
      );
    });
  }

  Future<int?> getGrpIdByName(String grp_name) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      group,
      columns: ['grp_id'],
      where: 'grp_name = ?',
      whereArgs: [grp_name],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result[0]['grp_id'];
    }

    return null;
  }




  Future<int?> getItemIdByName(String itemName) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      itemsTable,
      columns: ['itemId'],
      where: 'itemName = ?',
      whereArgs: [itemName],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result[0]['itemId'];
    }

    return null;
  }

  Future<void> updateGroup(Groups group) async {
    Database db = await instance.database;
    await db.update(
      'groups',
      group.toMap(),
      where: 'grp_id = ?',
      whereArgs: [group.grp_id],
    );
  }

  Future<void> deleteGroup(int groupId) async {
    Database db = await instance.database;
    await db.delete(
      'groups',
      where: 'grp_id = ?',
      whereArgs: [groupId],
    );
  }

  Future<List<Item>> getAllItems() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(itemsTable);
    return List.generate(maps.length, (i) {
      return Item(
        itemId: maps[i]['itemId'],
        groupId: maps[i]['groupId'],
        itemName: maps[i]['itemName'],
        color: maps[i]['color'],
        qty: maps[i]['qty'],
        unit: maps[i]['unit'],
        itemlimit: maps[i]['itemlimit'],
        description: maps[i]['description'],
      );
    });
  }



  Future<int> addItemQty(int itemId, double? additionalQty) async {
    Database db = await instance.database;

    // Get the current quantity for the item
    Item? currentItem = await getItem(itemId);

    double newQty1=0;
    if (additionalQty==null){
      newQty1=0;
    }
    else{
      newQty1=additionalQty;
    }


    if (currentItem != null) {
      double newQty = currentItem.qty + newQty1;

      // Update the quantity in the items table
      return await db.update(
        itemsTable,
        {'qty': newQty},
        where: 'itemId = ?',
        whereArgs: [itemId],
      );
    }

    return 0;
  }


  Future<List<HistoryRecord>> getHistoryForItem(int itemId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      historyTable,
      where: 'itemId = ?',
      whereArgs: [itemId],
    );
    return List.generate(maps.length, (i) {
      return HistoryRecord(
        itemId: maps[i]['itemId'],
        dateTime: maps[i]['dateTime'],
        updating: maps[i]['updating'],
        qty: maps[i]['qty'],
      );
    });
  }
  Future<int> updateItemQty(int itemId, int newQty) async {
    Database db = await instance.database;
    return await db.update(
      itemsTable,
      {'qty': newQty}, // Column values to update
      where: 'itemId = ?', // Condition to select the correct row
      whereArgs: [itemId], // Value for the condition
    );
  }
  Future<Item?> getItem(int itemId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      itemsTable,
      where: 'itemId = ?',
      whereArgs: [itemId],
      limit: 1, // Expecting a single match since itemId should be unique
    );
    if (maps.isNotEmpty) {
      return Item(
        itemId: maps[0]['itemId'],
        groupId: maps[0]['groupId'],
        itemName: maps[0]['itemName'],
        color: maps[0]['color'],
        qty: maps[0]['qty'],
        unit: maps[0]['unit'],
        itemlimit: maps[0]['itemlimit'],
        description: maps[0]['description'],
      );
    }
    return null; // Return null if the item is not found
  }

  Future<int> deleteHistoryRecordByDateTime(String dateTime) async {
    Database db = await instance.database;
    return await db.delete(
      historyTable,
      where: "dateTime = ?",
      whereArgs: [dateTime],
    );
  }

  static Future<List<HistoryRecord>> getUniqueDailyRecords(List<HistoryRecord> records) async {
    // Sort records by dateTime
    records.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Group records by date
    var groupedByDate = <String, List<HistoryRecord>>{};
    for (var record in records) {
      var date = record.dateTime.substring(0, 10); // Extract date part: YYYY-MM-DD
      groupedByDate.putIfAbsent(date, () => []).add(record);
    }

    // Select the last record for each date
    List<HistoryRecord> uniqueDailyRecords = [];
    groupedByDate.forEach((date, records) {
      uniqueDailyRecords.add(records.last);
    });

    return uniqueDailyRecords;
  }

  /*static List<String> extractDates(List<HistoryRecord> records) {
    return records.map((record) {
      // Split the dateTime string by space (SQL datetime format) and take the first part (the date)
      return record.dateTime.split(" ")[0];
    }).toList();
      }*/





  Future<List<Map<String,dynamic>>> queryUsers() async{
    Database db=await instance.database;
    return await db.query('shopping_list');
  }

  Future<List<Map<String,dynamic>>> getShoppingListByUserId(int userId) async{
    Database db=await instance.database;
    return await db.query('shopping_list', where: 'user_id = ?',whereArgs: [userId]);
  }

  Future<int> deleteItem(int itemId) async {
    Database db = await instance.database;
    return await db.delete('shopping_list', where: 'item_id = ?', whereArgs: [itemId]);
  }

  Future<int> signIn(String email, String password) async {
    Database db = await instance.database;

    List<Map<String, dynamic>> result = await db.query(
      'users', // Replace with your user table name
      columns: ['user_id', 'email', 'password', 'other_columns'], // Replace with your user table columns
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result[0]['user_id'] as int; // Return the user_id if sign-in is successful
    }

    return 0;
  }

}