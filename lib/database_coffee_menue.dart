import 'package:coffee_shop/carts_table.dart';
import 'package:coffee_shop/products_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'favourits_table.dart';

class DatabaseCoffeeMenue {
  static const String _dbname = "CoffeeMenuee_3.db";
  static const int _version = 1;
  static const String _ProductsTable = "Products";
  static const String _FavouritsTable = "Favourites";
  static const String _CartsTable = "Carts";

  static Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbname),
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE $_ProductsTable ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title TEXT NOT NULL, "
            "image TEXT NOT NULL, "
            "description TEXT NOT NULL, "
            "product_type TEXT, "
            "ingredients TEXT NOT NULL);");

        await db.execute("CREATE TABLE $_FavouritsTable ("
            "idFav INTEGER PRIMARY KEY AUTOINCREMENT,"
            "userId TEXT NOT NULL,"
            "idProduct INTEGER,"
            "product_type TEXT);");

        await db.execute("CREATE TABLE $_CartsTable ("
            "idCart INTEGER PRIMARY KEY AUTOINCREMENT,"
            "userId TEXT NOT NULL,"
            "idProduct INTEGER,"
            " quantity INTEGER,"
            " product_type TEXT"
            ");");
      },
      version: _version,
    );
  }

  // _ProductsTable

  // databse
  static Future<void> addProduct(Products product) async {
    final db = await _getDB();
    await db.insert(
      _ProductsTable,
      product.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Products>?> getProducts() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> map = await db.query(_ProductsTable);
    if (map.isEmpty) {
      return null;
    }
    return List.generate(map.length, (index) => Products.fromJson(map[index]));
  }

  static Future<List<Products>?> getProductsHot() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> map = await db.rawQuery(
      "SELECT * FROM $_ProductsTable WHERE product_type = ?",
      ['Hot'],
    );
    if (map.isEmpty) {
      return null;
    }
    return List.generate(map.length, (index) => Products.fromJson(map[index]));
  }

  static Future<List<Products>?> getProductsIced() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> map = await db.rawQuery(
      "SELECT * FROM $_ProductsTable WHERE product_type = ?",
      ['Iced'],
    );
    if (map.isEmpty) {
      return null;
    }
    return List.generate(map.length, (index) => Products.fromJson(map[index]));
  }

  static Future<Products?> getProduct(idproduct) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> map = await db
        .rawQuery("SELECT * FROM $_ProductsTable WHERE id = $idproduct");
    // or
    // final List<Map<String, dynamic>> map = await db.query(
    //   _ProductsTable,
    //   where: 'id_product = ?',
    //   whereArgs: [id_product],
    // );

    if (map.isEmpty) {
      return null;
    }
    return Products.fromJson(map.first);
  }

  // _FavouritesTable
  static Future<void> addFavourite(FavouritesTable favourite) async {
    final db = await _getDB();
    db.insert(_FavouritsTable, favourite.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<FavouritesTable>?> getFavourites(String userId) async {
    final db = await _getDB();

    final List<Map<String, dynamic>> map = await db.rawQuery(
      "SELECT * FROM $_FavouritsTable WHERE userId = ?",
      [userId],
    );

    if (map.isEmpty) {
      return null;
    }
    return List.generate(
        map.length, (index) => FavouritesTable.fromJson(map[index]));
  }

  static Future<void> removeFavourite(int productId, String userId) async {
    final db = await _getDB();
    await db.delete(
      _FavouritsTable,
      where: 'idProduct = ? AND userId = ?',
      whereArgs: [productId, userId],
    );
  }

  // _CartsTable
  static Future<void> addCart(CartsTable cart) async {
    final db = await _getDB();
    db.insert(_CartsTable, cart.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<CartsTable>?> getCarts(String userId) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> map = await db.rawQuery(
      "SELECT * FROM $_CartsTable WHERE userId = ?",
      [userId],
    );

    if (map.isEmpty) {
      return null;
    }
    return List.generate(
        map.length, (index) => CartsTable.fromJson(map[index]));
  }

  // static Future<void> removeFromCart(CartsTable cart) async{
  //   final db =await _getDB();
  //   await db.delete(_CartsTable,where: 'idCart = ?' ,whereArgs: [cart.idCart]);
  //
  // }

  static Future<void> removeFromCart(int productId, String userId) async {
    final db = await _getDB();
    await db.delete(
      _CartsTable,
      where: 'idProduct = ? AND userId = ?',
      whereArgs: [productId, userId],
    );
  }

  // Search
  // static Future<List<Products>?> searchInProducts(String title) async{
  //   final db=await _getDB();
  //
  //   final List<Map<String,dynamic>> map = await db.rawQuery("SELECT * FROM $_ProductsTable WHERE product_name LIKE ?", ['%$title%']);
  //   if (map.isEmpty) {
  //     return null;
  //   }
  //   return List.generate(map.length, (index) => Products.fromJson(map[index]));
  // }

  static Future<List<dynamic>?> searchInProducts(
      String title, int SelectedBtn) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> map;

    if (SelectedBtn == 1) {
      map = await db.rawQuery(
          "SELECT * FROM $_ProductsTable WHERE product_type = ? AND title LIKE ?",
          ["Hot", '%$title%']);
    } else {
      map = await db.rawQuery(
          "SELECT * FROM $_ProductsTable WHERE product_type = ? AND title LIKE ?",
          ["Iced", '%$title%']);
    }

    // List<Map<String, Object?>> products= await db.rawQuery("SELECT * FROM $_ProductsTable WHERE product_type = ?",
    //     ['Hot']);
    // print("products from function searchDB --> $products");

    print("map from function searchDB --> $map");

    if (map.isEmpty) {
      return null;
    }

    return List.generate(map.length, (index) => Products.fromJson(map[index]));
  }

//   check if product add in fav or cart

  static Future<bool> check(
      String _TableName, int productId, String userId) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> map = await db.rawQuery(
      "SELECT * FROM $_TableName WHERE idProduct = ? AND userId = ?",
      [productId, userId],
    );
    if (map.isEmpty) {
      return true;
    }
    return false;
  }
}
