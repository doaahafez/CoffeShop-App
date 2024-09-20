import 'package:coffee_shop/apiServices.dart';
import 'package:coffee_shop/products_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'database_coffee_menue.dart';
import 'favourits_table.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  late bool isConnected;
  bool isFav=true;
  late final uid;
  apiServices apiservices = apiServices();

  // late Future<List<FavouritesTable>?> productsFuture;

  // late Future<List<FavouritesTable>?> productsHotFuture;
  // late Future<List<FavouritesTable>?> productsIcedFuture;
  late Future<List<dynamic>?> productsHotFuture;
  late Future<List<dynamic>?> productsIcedFuture;

  @override
  void initState() {
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    uid = user!.uid;

    print("UID FROM FAV $uid");

    // productsFuture = apiservices.getFavourites(uid,_selectedButton);

    productsHotFuture = apiservices.getFavouritesOrCard("Favourites",uid,1);
    productsIcedFuture = apiservices.getFavouritesOrCard("Favourites", uid,2);
    _connection();
  }


  void _connection() async{
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

  void refreshFavourites() {
    setState(() {
      // productsFuture = apiservices.getFavourites(uid,_selectedButton) ;

      productsHotFuture = apiservices.getFavouritesOrCard("Favourites",uid,1);
      productsIcedFuture = apiservices.getFavouritesOrCard("Favourites",uid,2);

    });
  }
  int _selectedButton = 1;
  Widget build(BuildContext context) {
    return
      SafeArea(
          child: Scaffold(
          backgroundColor: Colors.black,
        appBar: AppBar(
          title:Text("Favourits Products"),
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
                    future:_selectedButton==1 ? productsHotFuture : productsIcedFuture,

                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error favourite: ${snapshot.error}",style: TextStyle(color: Colors.white),));
                      } else if (snapshot.hasData) {
                        final favourites = snapshot.data!;

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 130 / 195,
                          ),
                          itemCount: favourites.length,
                          itemBuilder: (context, index) {
                            final favourite = favourites[index];
                            return FutureBuilder<Products?>(
                              // future: apiservices.getProduct(favourite.idProduct),
                              future: apiservices.getProduct(favourite.idProduct,_selectedButton),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  // print(snapshot.error);
                                  return Center(child: Text("Error product: ${snapshot.error}",style: TextStyle(color: Colors.white),));
                                } else if (snapshot.hasData) {

                                  // print('Type of productsFuture: ${productsFuture.runtimeType}');

                                  final product = snapshot.data;

                                  if (product == null) {
                                    return Center(child: Text("Product not found",style: TextStyle(color: Colors.white)));
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
                                          Container(
                                            height: 130,
                                            width: 170,
                                            child: Image.network(
                                              product.image.toString(),
                                              fit: BoxFit.cover,
                                            ),
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
                                            icon: Icon(Icons.favorite),
                                            color:Colors.orange,
                                            onPressed:(){
                                              apiservices.removeFavourite(favourite.idProduct!, uid, favourite.product_type!).then((_) {
                                                refreshFavourites();
                                              });
                                            },

                                          ),

                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(child: Text("No favourites details available.",style: TextStyle(color: Colors.white),));
                                }
                              },
                            );
                          },
                        );
                      } else {
                        // print("snapshot.data from fav page ${snapshot.data}");

                        return Center(child: Text("No favourites available.",style: TextStyle(color: Colors.white)));
                      }
                    },
                  ),
                ),
              ],
            ),

      )
    );
  }
}





