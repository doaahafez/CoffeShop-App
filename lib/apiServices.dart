import 'dart:convert';

import 'package:coffee_shop/carts_table.dart';
import 'package:coffee_shop/products_table.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'favourits_table.dart';

class apiServices {
  static const String _dbname = "CoffeeMenue_1.db";
  static const int _version = 1;
  static const String _ProductsTable = "Products";
  static const String _FavouritsTable = "Favourites";
  static const String _CartsTable = "Carts";

  final baseUrl = "https://api.sampleapis.com/coffee/";

  Future<List<dynamic>> getAllCoffeeHot(String title) async {
    final response = await http.get(Uri.parse("${baseUrl}hot"));

    if (response.statusCode == 200) {
      List<dynamic> allProducts = jsonDecode(response.body);
      String searchTitleLower = title.trim().toLowerCase();
      List<dynamic> filteredProducts = allProducts.where((product) {
        return product['title'] != null && product['title'].toString().toLowerCase().contains(searchTitleLower);
      }).toList();

      return filteredProducts;
    } else {
      throw Exception("Error Loading Coffee Hot");
    }
  }

  Future<List<dynamic>> getAllCoffeeIce(String title) async {
    final response = await http.get(Uri.parse("${baseUrl}iced"));

    if (response.statusCode == 200) {
      List<dynamic> allProducts = jsonDecode(response.body);

      String searchTitleLower = title.trim().toLowerCase();

      List<dynamic> filteredProducts = allProducts.where((product) {

        return product['title'] != null && product['title'].toString().toLowerCase().contains(searchTitleLower);
      }).toList();

      return filteredProducts;
    } else {
      throw Exception("Error Loading Coffee Iced");
    }
  }

  Future<dynamic> getCoffeeHotById(int id) async {
    final response = await http.get(Uri.parse("${baseUrl}hot/${id}"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error Loading Coffe Hot Id");
    }
  }

  Future<dynamic> getCoffeeIcedById(int id) async {
    final response = await http.get(Uri.parse("${baseUrl}iced/${id}"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error Loading Coffee Iced Id");
    }
  }

  static Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbname),
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE $_ProductsTable ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title TEXT NOT NULL, "
            "image TEXT NOT NULL, "
            "description TEXT NOT NULL, "
            "product_type TEXT NOT NULL, "
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

  Future<List<Products>?> getProducts() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> map = await db.query(_ProductsTable);
    if (map.isEmpty) {
      return null;
    }
    return List.generate(map.length, (index) => Products.fromJson(map[index]));
  }

  Future<void> addProduct(int id, int selectedButton) async {
    final response;

    if (selectedButton == 2) {
      response = await http.get(Uri.parse("${baseUrl}iced/$id"));
    } else {
      response = await http.get(Uri.parse("${baseUrl}hot/$id"));
    }

    if (response.statusCode == 200) {
      final productJson = jsonDecode(response.body) as Map<String, dynamic>;

      Products product = Products.fromJson(productJson);
      final db = await _getDB();
      await db.insert(
        _ProductsTable,
        product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      throw Exception(
          "Error Loading Coffee ${selectedButton == 2 ? "Iced" : "Hot"} Id");
    }
  }

  Future<void> addFavourite(FavouritesTable favourite) async {
    final db = await _getDB();
    db.insert(_FavouritsTable, favourite.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> addCart(CartsTable cart) async {
    final db = await _getDB();
    db.insert(_CartsTable, cart.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<dynamic>?> getFavouritesOrCard(
      String TableName, String userId, int _selectedButton) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> map;
    if (_selectedButton == 1) {
      map = await db.rawQuery(
        "SELECT * FROM $TableName WHERE userId = ? AND product_type = ?",
        [userId, 'Hot'],
      );
    } else {
      map = await db.rawQuery(
        "SELECT * FROM $TableName WHERE userId = ? AND product_type = ?",
        [userId, 'Iced'],
      );
    }

    if (map.isEmpty) {
      return null;
    }

    if (TableName == "Favourites") {
      return List.generate(
          map.length, (index) => FavouritesTable.fromJson(map[index]));
    } else {
      return List.generate(
          map.length, (index) => CartsTable.fromJson(map[index]));
    }
  }

  Future<Products?> getProduct(idproduct, _selectedButton) async {
    final map;
    if (_selectedButton == 1) {
      map = await http.get(Uri.parse("${baseUrl}hot/$idproduct"));
      print("map hot -> $map");
    } else {
      map = await http.get(Uri.parse("${baseUrl}iced/$idproduct"));
    }

    if (map.statusCode == 200) {
      final productJson = jsonDecode(map.body) as Map<String, dynamic>;

      Products product = Products.fromJson(productJson);
      return product;
    } else {
      throw Exception(
          "Error Loading Coffee ${_selectedButton == 2 ? "Iced" : "Hot"} Id");
    }
  }

  Future<void> removeFavourite(int idProduct, String userId, String productType) async {
    final db = await _getDB();
    await db.delete(
      _FavouritsTable,
      where: 'idProduct = ? AND userId = ? AND product_type = ?',
      whereArgs: [idProduct, userId, productType],
    );
  }

  Future<void> removeCart(int idProduct, String userId, String productType) async {
    final db = await _getDB();
    await db.delete(
      _CartsTable,
      where: 'idProduct = ? AND userId = ? AND product_type = ?',
      whereArgs: [idProduct, userId, productType],
    );
  }

  Future<bool> check(String _TableName, int productId, String userId, String product_type) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> map = await db.rawQuery(
      "SELECT * FROM $_TableName WHERE idProduct = ? AND userId = ? AND product_type = ?",
      [productId, userId, product_type],
    );
    if (map.isEmpty) {
      return true;
    }
    return false;
  }

  // Search
  // static Future<List<Products>?> searchInProducts(String title) async {
  //   final db = await _getDB();
  //
  //   List<Map<String, Object?>> products= await db.rawQuery("SELECT * FROM $_ProductsTable WHERE product_type = ?",
  //       ['Hot']);
  //   print("products from function searchapi --> $products");
  //
  //   final List<Map<String, dynamic>> map = await db.rawQuery("SELECT * FROM $_ProductsTable WHERE title LIKE ?", ['%$title%']);
  //   print("map from function searchapi --> $map");
  //
  //   if (map.isEmpty) {
  //     return null;
  //   }
  //
  //   return List.generate(map.length, (index) => Products.fromJson(map[index]));
  // }


}
