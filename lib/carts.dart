import 'package:coffee_shop/apiServices.dart';
import 'package:coffee_shop/products_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'carts_table.dart';
import 'database_coffee_menue.dart';

class Carts extends StatefulWidget {
  const Carts({super.key});

  @override
  State<Carts> createState() => _CartsState();
}

class _CartsState extends State<Carts> {

  late bool isConnected ;
  // late Future<List<CartsTable>?> productsFuture;
  late Future<List<dynamic>?> productsHotFuture;
  late Future<List<dynamic>?> productsIcedFuture;

  bool isCart=true;

  late final uid;

  apiServices apiservices=apiServices();

  @override
  void initState() {
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    uid = user!.uid;
    print("UID FROM CARTS $uid");
    // productsFuture = DatabaseCoffeeMenue.getCarts(uid);
    productsHotFuture = apiservices.getFavouritesOrCard("Carts",uid,1);
    productsIcedFuture = apiservices.getFavouritesOrCard("Carts", uid,2);
    _initializeConnection();
  }

   void _initializeConnection() async {
    isConnected= await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Check Network Connection",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }



  void refreshCarts() {
    setState(() {
      // productsFuture = DatabaseCoffeeMenue.getCarts(uid);

      productsHotFuture = apiservices.getFavouritesOrCard("Favourites",uid,1);
      productsIcedFuture = apiservices.getFavouritesOrCard("Favourites", uid,2);

    });
  }
int _selectedButton=1;
  Widget build(BuildContext context) {

    return  SafeArea(child:
    Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title:Text("Carts Products"),
      ),

      body: Column(
        children: [

          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedButton = 1;
                  });
                },
                child: Text('Hot Coffee'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _selectedButton == 1 ? Colors.orange : Colors.grey,
                  foregroundColor:
                  _selectedButton == 1 ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedButton = 2;
                  });
                },
                child: Text('Iced Coffee'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _selectedButton == 2 ? Colors.orange : Colors.grey,
                  foregroundColor:
                  _selectedButton == 2 ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: _selectedButton==1 ?productsHotFuture : productsIcedFuture ,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}",style: TextStyle(color: Colors.white),));
                } else if (snapshot.hasData) {
                  final carts = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 130 / 195,
                    ),
                    itemCount: carts.length,
                    itemBuilder: (context, index) {
                      final cart = carts[index];
                      return FutureBuilder<Products?>(
                        future: apiservices.getProduct(cart.idProduct,_selectedButton),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text("Error: ${snapshot.error}",style: TextStyle(color: Colors.white),));
                          } else if (snapshot.hasData) {
                            final product = snapshot.data;
                            if (product == null) {
                              return Center(child: Text("Product not found"));
                            }

                            return GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xff2F3031),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      spreadRadius: 1,
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      product.image.toString(),
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      product.title.toString(),
                                      style: GoogleFonts.pacifico(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Best Coffee",
                                      style: GoogleFonts.pacifico(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "\$${20}",
                                      style: GoogleFonts.pacifico(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),

                                    IconButton(
                                      icon: Icon(Icons.remove_shopping_cart_outlined),
                                      color:Colors.orange,
                                      onPressed:(){
                                        if(isCart){
                                          apiservices.removeCart(cart.idProduct!,uid,_selectedButton==1?"Hot":"Iced").then((_){
                                            refreshCarts();
                                          }
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Center(child: Text("No carts details available.",style: TextStyle(color: Colors.white),));
                          }
                        },
                      );
                    },
                  );
                } else {
                  return Center(child: Text("No carts available.",style: TextStyle(color: Colors.white)));
                }
              },
            ),
          ),

          Container(
            height: 60,
            width: 100,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(
                        fontWeight: FontWeight.bold,fontSize: 20),
                  ),
                  onPressed:(){

                  } ,
                  child: Text("Buy")
              ),

          ),
        ],
      ),
    )
    );
  }
}
