import 'package:coffee_shop/database_coffee_menue.dart';
import 'package:coffee_shop/products_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apiServices.dart';
import 'authScreen.dart';
import 'details_content.dart';
import 'favourits_table.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late bool isFav;

  // late int productId;

  late bool isConnected = false;

  // bool isFav = false;
  late Future<List<dynamic>?> productsHotDBFuture = Future.value(null);
  late Future<List<dynamic>?> productsIcedDBFuture = Future.value(null);

  // late Future<List<dynamic>> coffeeHotFuture;
  // late Future<List<dynamic>> coffeeIceFuture;

  late Future<List<dynamic>> coffeeHotFuture = Future.value([]);
  late Future<List<dynamic>> coffeeIceFuture = Future.value([]);

  final FirebaseAuth auth = FirebaseAuth.instance;

  // String? uid;

  late final uid;
  late final email;
  late final userName;

  apiServices apiservices = apiServices();

  void initState() {
    super.initState();
// Initialize Firebase user
    final User? user = FirebaseAuth.instance.currentUser;
    uid = user!.uid;
    email = user.email;
    userName = user.displayName;
    _initializeData();
  }

  void _initializeData() async {
    isConnected = await InternetConnectionChecker().hasConnection;
    // internentConnection
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

      // Fetch data From DataBase
      productsHotDBFuture =
          DatabaseCoffeeMenue.searchInProducts(searchTextController.text, 1);
      productsIcedDBFuture =
          DatabaseCoffeeMenue.searchInProducts(searchTextController.text, 2);
    } else {
      // Fetch data From APIS
      coffeeHotFuture = apiservices.getAllCoffeeHot(searchTextController.text);
      coffeeIceFuture = apiservices.getAllCoffeeIce(searchTextController.text);
    }
    // coffeeHotFuture = apiservices.getAllCoffeeHot(searchTextController.text);
    // coffeeIceFuture = apiservices.getAllCoffeeIce(searchTextController.text);

    // Wait for the data to be fetched
    List<dynamic> coffeeHotList = await coffeeHotFuture;
    List<dynamic> coffeeIcedList = await coffeeIceFuture;
    //
    // // Process the data
    // for (int i = 0; i < coffeeHotList.length; i++) {
    //   final productData = coffeeHotList[i];
    //
    //   final product = Products.fromJson({
    //     ...productData,
    //     'product_type': 'Hot',
    //   });
    //
    //   await DatabaseCoffeeMenue.addProduct(product);
    // }
    //
    // for (int i = 0; i < coffeeIcedList.length; i++) {
    //   final productData = coffeeHotList[i];
    //
    //   final product = Products.fromJson({
    //     ...productData,
    //     'product_type': 'Iced',
    //   });
    //
    //   await DatabaseCoffeeMenue.addProduct(product);
    // }


    // If you need to update the UI after processing the data, use setState()
    setState(() {
      // Update any state variables if necessary
    });
  }

  void refreshSerch() {
    setState(() {
      if (isConnected) {
        coffeeHotFuture =
            apiservices.getAllCoffeeHot(searchTextController.text);
        coffeeIceFuture =
            apiservices.getAllCoffeeIce(searchTextController.text);
      } else {
        productsHotDBFuture =
            DatabaseCoffeeMenue.searchInProducts(searchTextController.text, 1);
        productsIcedDBFuture =
            DatabaseCoffeeMenue.searchInProducts(searchTextController.text, 2);
      }
    });
  }

  TextEditingController searchTextController = TextEditingController();
  int _selectedButton = 1;

  @override
  Widget build(BuildContext context) {
    Map<int, bool> favoriteStatus = {};
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff28292A),
        actions: [
          Icon(
            Icons.notifications,
            color: Colors.grey,
            size: 30,
          ),
        ],
        iconTheme: IconThemeData(color: Colors.grey),
      ),
      drawer: Drawer(
          child: Container(
        color: Color((0xff2F3031)),
        padding: EdgeInsets.all(15),
        child: ListView(
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      "assets/bg.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("Name:\n $userName",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              ],
            ),
            ListTile(
              title: Text(
                "homepage",
                style: TextStyle(color: Colors.orange),
              ),
              leading: Icon(Icons.home, color: Colors.orange),
              onTap: () {},
            ),
            ListTile(
              title: Text("Account", style: TextStyle(color: Colors.orange)),
              leading: Icon(Icons.account_box, color: Colors.orange),
              onTap: () {},
            ),
            ListTile(
              title: Text("Order", style: TextStyle(color: Colors.orange)),
              leading: Icon(Icons.shopping_basket, color: Colors.orange),
              onTap: () {},
            ),
            ListTile(
              title: Text("About Us", style: TextStyle(color: Colors.orange)),
              leading: Icon(Icons.quiz_outlined, color: Colors.orange),
              onTap: () {},
            ),
            ListTile(
              title: Text("Contact Us", style: TextStyle(color: Colors.orange)),
              leading: Icon(Icons.phone, color: Colors.orange),
              onTap: () {},
            ),
            ListTile(
              title: Text("SignOut", style: TextStyle(color: Colors.orange)),
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.orange,
              ),
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.clear();
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Authscreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      )),
      body: Column(
        children: [
          Text(
            "It‘s a Great Day for Coffee",
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            width: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Color(0xff454648),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: searchTextController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Find Your Coffee',
                prefixIcon: Icon(
                  Icons.search,
                  size: 30,
                  color: Colors.grey,
                ),
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Color(0xff454648)),
                ),
              ),
              onChanged: (text) {
                refreshSerch();
              },
            ),
          ),
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
              future: isConnected
                  ? (_selectedButton == 1 ? coffeeHotFuture : coffeeIceFuture)
                  : (_selectedButton == 1
                      ? productsHotDBFuture
                      : productsIcedDBFuture),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(color: Colors.white),
                  ));
                } else if (snapshot.hasData) {
                  final products = snapshot.data!;

                  // print("snapshot data -> ${products.length}");

                  if (products.length == 0) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: ListView(
                        shrinkWrap: true,
                        // Ensures the ListView takes up only the space it needs
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 70),
                            child: Row(
                              children: [
                                Text(
                                  "Nothing Found  ",
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  " \"${searchTextController.text}\" ",
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),

                          SizedBox(height: 10),
                          // Adds spacing between text and image
                          Center(
                            child: Image.asset("assets/search_notFound.png"),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 130 / 195,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        int productId = isConnected?  product["id"] : product.id;
                         print("productId => $productId");
                         isFav =  favoriteStatus[productId] ?? false;
                         // print("products length -> ${products.length}");
                        print("$isFav  ==> ${favoriteStatus[productId]}" );


                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsContent(
                                  id: productId,
                                  selectedButton: _selectedButton,
                                  price: "20",
                                ),
                              ),
                            );
                          },
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
                                  height: 200,
                                  width: 170,
                                  child: isConnected
                                      ? Image.network(
                                          product["image"],
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.orange,
                                        ),
                                ),

                                // Container(
                                //   height: 200,
                                //   width: 170,
                                //   child: isConnected
                                //       ? CachedNetworkImage(
                                //     imageUrl: product["image"],
                                //     fit: BoxFit.cover,
                                //     placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                //     errorWidget: (context, url, error) => Icon(Icons.error),
                                //     useOldImageOnUrlChange: true,  // Ensures cached image is used if URL changes and internet is unavailable
                                //   )
                                //
                                //       : Image.asset('assets/person.png', fit: BoxFit.cover), // Show local image when offline
                                // ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "${isConnected ? product["title"] : product.title}",
                                      style: GoogleFonts.pacifico(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),

                                    Container(
                                      height: 29,
                                      child: IconButton(
                                        icon: Icon(
                                          favoriteStatus[productId] == true
                                              ? Icons.favorite
                                              : Icons.favorite_outline,
                                        ),
                                        color: favoriteStatus[productId] == true
                                            ? Colors.red // Change color when favorite
                                            : Colors.orange, // Default color

                                        onPressed: ()  {
                                          // Print all entries
                                          favoriteStatus.forEach((id, status) {
                                            print("ID $id: $status");
                                          });

                                          setState(() {
                                            // Toggle the favorite status for the specific product
                                            favoriteStatus[productId] = !(favoriteStatus[productId] ?? false);
                                          });

                                          // if (favoriteStatus[productId] == true) {
                                          //   FavouritesTable favouritesTable = new FavouritesTable(
                                          //       idProduct: productId, userId: uid);
                                          //
                                          //   bool exist = await apiservices.check(
                                          //       "Favourites",
                                          //       productId,
                                          //       uid,
                                          //       _selectedButton == 1 ? "Hot" : "Iced");
                                          //
                                          //   if (!exist) {
                                          //     await apiservices.addFavourite(favouritesTable);
                                          //
                                          //     showDialog(
                                          //         context: context,
                                          //         builder: (context) {
                                          //           return AlertDialog(
                                          //             title: Text("Added to Favourites"),
                                          //             actions: [
                                          //               ElevatedButton(
                                          //                   onPressed: () {
                                          //                     Navigator.pop(context);
                                          //                     setState(() {});
                                          //                   },
                                          //                   child: Text("OK")),
                                          //             ],
                                          //           );
                                          //         });
                                          //   }
                                          //   else {
                                          //     showDialog(
                                          //         context: context,
                                          //         builder: (context) {
                                          //           return AlertDialog(
                                          //             title: Text("Product is already in favorites"),
                                          //             actions: [
                                          //               ElevatedButton(
                                          //                   onPressed: () {
                                          //                     Navigator.pop(context);
                                          //                     setState(() {});
                                          //                   },
                                          //                   child: Text("OK")),
                                          //             ],
                                          //           );
                                          //         });
                                          //   }
                                          // }

                                          // else {
                                          //   FavouritesTable favouritesTable = new FavouritesTable(
                                          //       idProduct: productId, userId: uid);
                                          //   await apiservices.removeFavourite(
                                          //       favouritesTable.idProduct!, uid,
                                          //       _selectedButton == 1 ? "Hot" : "Iced");
                                          //
                                          //   showDialog(
                                          //       context: context,
                                          //       builder: (context) {
                                          //         return AlertDialog(
                                          //           title: Text("Removed from Favourites"),
                                          //           actions: [
                                          //             ElevatedButton(
                                          //                 onPressed: () {
                                          //                   Navigator.pop(context);
                                          //                   setState(() {});
                                          //                 },
                                          //                 child: Text("OK")),
                                          //           ],
                                          //         );
                                          //       });
                                          // }
                                        },
                                      ),
                                    )


                                  ],
                                ),
                                Text(
                                  "\$${20}",
                                  style: GoogleFonts.pacifico(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                } else {
                  return Center(
                      child: Text("No products available.",
                          style: TextStyle(color: Colors.white)));
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xff28292A),
    ));
  }
}
