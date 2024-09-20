class CartsTable{
  String? userId;
  int? idCart;
  int? idProduct;
  int? quantity;
  String? product_type;

  CartsTable({
    this.userId,
    this.idCart,
    this.idProduct,
    this.quantity,
    this.product_type
  });


  CartsTable.fromJson(Map<String, dynamic> map) {
    userId = map['userId'];
    idCart = map['idCart'];
    idProduct = map['idProduct'];
    quantity = map['quantity'];
    product_type = map['product_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['userId'] = this.userId;
    map['idCart'] = this.idCart;
    map['idProduct'] = this.idProduct;
    map['quantity'] = this.quantity;
    map['product_type'] = this.product_type;
    return map;
  }



}