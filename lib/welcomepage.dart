import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authScreen.dart';
import 'bottom_navigatore_bar.dart';

class Welcomepage extends StatefulWidget {
  const Welcomepage({super.key});

  @override
  State<Welcomepage> createState() => _WelcomepageState();
}

class _WelcomepageState extends State<Welcomepage> {
  bool _isLoading = true;

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn == true) {
      final FirebaseAuth auth = FirebaseAuth.instance;

      final User? user = auth.currentUser;
      final uid = user!.uid;
      final email =user!.email;

      print("UID $uid");
      print("EMAIL $email");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> BottomNavigatoreBar() ));
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authscreen()),);
    }

  }


  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });

    // _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset("assets/bg.jpg",fit: BoxFit.cover,)
          ),
          Positioned(
            top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Text("Coffee Shop",
                            style: GoogleFonts.pacifico(fontSize: 50, color: Colors.white,),
                          ),
              )
          ),
          Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(child: Text("Feeling Low? Take a Slip of Coffe",style: TextStyle(fontSize: 15,color: Colors.grey),))
          ),
          Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.orange)
                    : MaterialButton(
                  color: Color(0xffE57734),
                  textColor: Colors.white,
                  onPressed: () {
                    _checkLoginStatus();
                    // Products product = new Products(product_name: "Espresso", price: "25.00", imagUrl: "assets/icecoffee-6.jpg");
                    // DatabaseCoffeeMenue.addProduct(product);
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                    //     // BottomNavigatoreBar()
                    // Authscreen()
                    // ),);
                  },
                  child: Text(
                    "Get Started",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),

          ),
        ],
      )
    ),
      
    );
  }
}
