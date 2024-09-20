
import 'package:coffee_shop/ChatScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Allusersscreen extends StatefulWidget {
  const Allusersscreen({super.key});

  @override
  State<Allusersscreen> createState() => _AllusersscreenState();
}

class _AllusersscreenState extends State<Allusersscreen> {


  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref().child('Users');
  String? uid;

  final FirebaseAuth auth = FirebaseAuth.instance;



@override
  void initState() {
    // TODO: implement initState
    super.initState();
    final User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    } else {
      print("No user logged in");
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Users"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _messagesRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> Users = [];

                  if (snapshot.data!.snapshot.value != null) {
                    final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                    Users = data.values.map((e) => Map<String, dynamic>.from(e)).toList();

                    Users = Users.where((user) => user["UserUid"] != uid).toList();

                    print(Users[0]["UserUid"]);

                    if(Users.isEmpty){
                      return Center(child: Text("No Users Yet"));
                    }
                    return ListView.builder(
                      itemCount: Users.length,
                      itemBuilder: (context, index) {
                        final  UserName = Users[index]['UserName'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child:
                          GestureDetector(
                            child: Card(
                              color: Colors.blue[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          width: 70,
                                          height: 60,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(60),
                                            child: Image.asset("assets/person.png",fit: BoxFit.cover,),
                                          ),
                                        ),
                                        Text(UserName, style: TextStyle(fontSize: 20, color: Colors.orange,fontWeight: FontWeight.bold),),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(reseiverId:Users[index]["UserUid"],)));
                            },
                          )


                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No Users Yet"));
                  }
                }
                // else{
                //   return Center(child: Text("No User Yet"));
                // }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
