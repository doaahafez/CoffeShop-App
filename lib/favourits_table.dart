class  FavouritesTable{
  String? userId;
  int? idFav;
  int? idProduct;
  String? product_type;

  FavouritesTable({
    this.userId,
    this.idFav,
    this.idProduct,
    this.product_type
  });

  FavouritesTable.fromJson(Map<String, dynamic> map) {
    userId = map['userId'];
    idFav = map['idFav'];
    idProduct = map['idProduct'];
    product_type = map['product_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['userId'] = this.userId;
    map['idFav'] = this.idFav;
    map['idProduct'] = this.idProduct;
    map['product_type'] = this.product_type;
    return map;
  }

}