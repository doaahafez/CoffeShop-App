
import 'package:flutter/material.dart';

import 'AllUsersScreen.dart';
import 'ChatScreen.dart';
import 'carts.dart';
import 'favourites.dart';
import 'homepage.dart';

class BottomNavigatoreBar extends StatefulWidget {
  const BottomNavigatoreBar({super.key});

  @override
  State<BottomNavigatoreBar> createState() => _BottomNavigatoreBarState();
}

class _BottomNavigatoreBarState extends State<BottomNavigatoreBar> {

  int selectedindex =0;

  final List <Widget> page=[
    Homepage(),
    Favourites(),
    Carts(),
    Allusersscreen(),
    // ChatScreen(),
  ];
  void onselecteditem (int index) {
    setState(() {
      selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: page[selectedindex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedindex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: TextStyle(color: Colors.grey),

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],

        onTap: onselecteditem,
      ),

    );
  }
}

