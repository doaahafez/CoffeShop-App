// import 'dart:convert';
//
// class Products{
//     int? id;
//     String? title;
//     String? price;
//     String? image;
//     String? description;
//     List<String>? ingredients;
//
//   Products({
//     this.id,
//     this.title,
//     this.price,
//     this.image,
//     this.description
//   });
//
//
//   Products.fromJson(Map<String, dynamic> map) {
//     id = map['id'];
//     title = map['title'];
//     price = map['price'];
//     image = map['image'];
//     ingredients = map['ingredients'] != null
//         ? List<String>.from(jsonDecode(map['ingredients']))
//         : [];
//     description=map["description"];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> map = new Map<String, dynamic>();
//     map['id'] = this.id;
//     map['title'] = this.title;
//     map['price'] = this.price;
//     map['image'] = this.image;
//     map['description'] = this.description;
//     map['ingredients'] = jsonEncode(ingredients ?? []);
//     return map;
//   }
//
// }


import 'dart:convert';

class Products {
  int? id;
  String? title;
  String? image;
  String? description;
  List<String>? ingredients;// Adjusted to be a list
  String? product_type;


  Products({
    this.id,
    this.title,
    this.image,
    this.description,
    this.ingredients,
    this.product_type,
  });

  // Create Products object from JSON map
  Products.fromJson(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    image = map['image'];
    description = map['description'];
    product_type = map['product_type'];

    // Handle ingredients field, ensuring it is a list
    if (map['ingredients'] is String) {
      ingredients = List<String>.from(jsonDecode(map['ingredients']));
    } else if (map['ingredients'] is List) {
      ingredients = List<String>.from(map['ingredients']);
    } else {
      ingredients = [];
    }

    // print("ingredients from product table => $ingredients");
  }

  // Convert Products object to JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['id'] = id;
    map['title'] = title;
    map['image'] = image;
    map['description'] = description;
    map['product_type'] = product_type;
    map['ingredients'] = jsonEncode(ingredients ?? []);
    // print("ingredients from product table => $ingredients");
    return map;
  }
}
