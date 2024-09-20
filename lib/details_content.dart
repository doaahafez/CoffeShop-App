  import 'package:coffee_shop/carts_table.dart';
  import 'package:coffee_shop/products_table.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'database_coffee_menue.dart';
  import 'favourits_table.dart';
  import 'apiServices.dart';

  class DetailsContent extends StatefulWidget {
    final int id;

    // final String? name;
    final String? price;

    // final String? imageUrl;
    final int selectedButton;

    const DetailsContent({
      super.key,
      required this.id,
      // required this.name,
      required this.price,
      required this.selectedButton,
      // required this.imageUrl,
    });

    @override
    State<DetailsContent> createState() => _DetailsContentState();
  }

  class _DetailsContentState extends State<DetailsContent> {
    int cnt = 0;
    bool isFav = false;

    bool isAddToCart = false;
    late Map<String, dynamic> dataSnapshot;

    late final uId;

    // late Future<List<FavouritesTable>?> productsFuture;

    late Future<dynamic> coffeHotId;
    late Future<dynamic> coffeIcedId;

    apiServices apiservices = apiServices();

    void initState() {
      super.initState();


      final FirebaseAuth auth = FirebaseAuth.instance;

      final User? user = auth.currentUser;
      uId = user!.uid;

      print("UID FROM DETAILS $uId");

      // productsFuture = DatabaseCoffeeMenue.getFavourites(uId);

      coffeHotId = apiservices.getCoffeeHotById(widget.id);
      coffeIcedId = apiservices.getCoffeeIcedById(widget.id);
    }

    void _toggleFavorite() {
      setState(() {
        isFav = !isFav;
      });
    }

    @override
    Widget build(BuildContext context) {
      // double p=double.parse(widget.price!);
      double totalPrice = double.parse(widget.price!) * cnt;

      return SafeArea(
          child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          // iconTheme: IconThemeData(
          //   color: Colors.grey,
          // ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.grey,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: FutureBuilder(
                  future: widget.selectedButton == 1 ? coffeHotId : coffeIcedId,
                  builder: (context, snaphot) {
                    if (snaphot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snaphot.hasError) {
                      return Center(
                        child: Text("Data Has Error"),
                      );
                    } else if (snaphot.hasData) {
                      // print("ingredients: ${snaphot.data!["ingredients"]}");
                      // print("snapshot data ${snaphot.data}");

                      // dataSnapshot = snaphot.data;
                      // Products productTable = Products.fromJson(snaphot.data as Map<String, dynamic>);
                      // productTable = snaphot.data;
                      // apiservices.addProduct(snaphot.data["id"], widget.selectedButton);


                      return Center(
                        child: Column(
                          children: [
                            Image.network(
                              "${snaphot.data!["image"]}",
                              height: 300,
                              width: 300,
                            ),
                            Text(
                              "${snaphot.data!["title"]}",
                              style: GoogleFonts.pacifico(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "\$${widget.price}",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                snaphot.data!["description"],
                                style: GoogleFonts.pacifico(
                                    color: Colors.grey, fontSize: 15),
                              ),
                            ),
                            Text(
                              "Ingredients: [ ${(snaphot.data!["ingredients"] as List<dynamic>).join(", ")} ]",
                              style: GoogleFonts.aBeeZee(
                                  color: Colors.deepOrange, fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Text("no product yet");
                    }
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.minimize,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (cnt == 0) {
                                cnt = 0;
                              } else {
                                cnt--;
                              }
                            });
                          },
                        ),
                        Text("$cnt",
                            style: TextStyle(
                                backgroundColor: Colors.grey,
                                color: Colors.white)),
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              cnt++;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Text(
                      "Total Price: \$${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Volume: 60 ml",
                      style: TextStyle(color: Colors.white),
                    ))
              ]),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MaterialButton(
                      color:!isAddToCart? Color(0xff454648) : Colors.orange,
                      height: 50,
                      minWidth: 150,
                      textColor: !isAddToCart? Colors.white : Color(0xff454648),
                      onPressed: () async {
                        setState(() {
                          isAddToCart = !isAddToCart;
                        });

                        if (isAddToCart) {
                          CartsTable cartsTable =
                              new CartsTable(idProduct: widget.id, userId: uId,product_type: widget.selectedButton==1 ? "Hot":"Iced");

                          bool exist = await apiservices.check(
                              "Carts", widget.id!, uId,widget.selectedButton==1 ?"Hot":"Iced");

                          if (exist) {
                            apiservices.addCart(cartsTable);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Add to Carts"),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() {});
                                          },
                                          child: Text("ok")),
                                    ],
                                  );
                                });
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                        "product is already exist in cart page"),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() {});
                                          },
                                          child: Text("ok")),
                                    ],
                                  );
                                });
                            print("product is already exist in cart page");
                          }
                        } else {
                          CartsTable cartsTable = new CartsTable(idProduct: widget.id, userId: uId,product_type: widget.selectedButton == 1 ? "Hot":"Iced");
                          apiservices.removeCart(
                              cartsTable.idProduct!, uId,widget.selectedButton==1?"Hot":"Iced");
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Remove from Carts"),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          // DatabaseCoffeeMenue.deleteFavourite(favouritesTable);
                                          Navigator.pop(context);
                                          setState(() {});
                                        },
                                        child: Text("ok")),
                                  ],
                                );
                              });
                        }
                      },
                      child: Text("Add To Cart"),
                    ),

                    // ***********************************************************

                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xffE57734),
                          borderRadius: BorderRadius.circular(15.0)),
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_outline,
                        ),
                        color: isFav ? Colors.orange : Colors.white,
                        onPressed: () async {
                          setState(() {
                            isFav = !isFav;
                          });

                          if (isFav) {

                            FavouritesTable favouritesTable = new FavouritesTable(idProduct: widget.id, userId: uId,product_type: widget.selectedButton == 1 ? "Hot":"Iced");

                            bool exist = await apiservices.check("Favourites", widget.id!, uId, widget.selectedButton == 1 ? "Hot":"Iced");

                            if (exist) {
                              apiservices.addFavourite(favouritesTable);

                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Add to Favourits"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() {});
                                            },
                                            child: Text("ok")),
                                      ],
                                    );
                                  });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                          "product is already exist in fav page"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() {});
                                            },
                                            child: Text("ok")),
                                      ],
                                    );
                                  });
                              // print("product is already exist in fav page");
                            }
                          } else {
                            FavouritesTable favouritesTable = new FavouritesTable(idProduct: widget.id, userId: uId,product_type: widget.selectedButton == 1 ? "Hot":"Iced");
                            apiservices.removeFavourite(
                                favouritesTable.idProduct!, uId,widget.selectedButton==1?"Hot":"Iced");

                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Remove from Favourits"),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            // DatabaseCoffeeMenue.deleteFavourite(favouritesTable);
                                            Navigator.pop(context);
                                            setState(() {});
                                          },
                                          child: Text("ok")),
                                    ],
                                  );
                                });
                          }
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ));
    }
  }
