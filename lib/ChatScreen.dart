import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {

  final reseiverId;

  const ChatScreen({super.key,this.reseiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _TextController =TextEditingController();

  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref().child('Messages');
  // final databaseFirebase = FirebaseDatabase.instance.ref().child("Messages");

  late final uid;

  void initState() {
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    uid = user!.uid;

    print("UID FROM ChatScreen $uid");
  }

  void _sendMessage() {
    if (_TextController.text.isNotEmpty) {
      _messagesRef.push().set({
        "SenderId" : uid,
        "ReceverId": widget.reseiverId,
        'message': _TextController.text,
        "Created At": DateTime.timestamp().toString(),
        // DateTime.now().toIso8601String(),
      });
      _TextController.clear();
    }else{
      print("Complete your data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      // drawer:Drawer(
      //     child: Container(
      //       color: Color((0xff2F3031)),
      //       padding:  EdgeInsets.all(15),
      //       child: ListView(
      //         children: [
      //           Row(
      //           children: [
      //             Container(
      //               width: 70,
      //               height: 60,
      //               child: ClipRRect(
      //                 borderRadius: BorderRadius.circular(60),
      //                 child: Image.asset("assets/person.png",fit: BoxFit.cover,),
      //               ),
      //             ),
      //             Expanded(child:
      //             Column(
      //               children: [
      //                 ListTile(
      //                   title: Text("Email : ",style: TextStyle(color: Colors.white)),
      //                 ),
      //               ],
      //             ),
      //             )
      //           ],
      //         ),
      //           Divider(height:10),
      //           Row(
      //             children: [
      //               Container(
      //                 width: 70,
      //                 height: 60,
      //                 child: ClipRRect(
      //                   borderRadius: BorderRadius.circular(60),
      //                   child: Image.asset("assets/person.png",fit: BoxFit.cover,),
      //                 ),
      //               ),
      //               Expanded(child:
      //               Column(
      //                 children: [
      //                   ListTile(
      //                     title: Text("Email : ",style: TextStyle(color: Colors.white)),
      //                   ),
      //                 ],
      //               ),
      //               )
      //             ],
      //           ),
      //           Divider(height:10),
      //           Row(
      //             children: [
      //               Container(
      //                 width: 70,
      //                 height: 60,
      //                 child: ClipRRect(
      //                   borderRadius: BorderRadius.circular(60),
      //                   child: Image.asset("assets/person.png",fit: BoxFit.cover,),
      //                 ),
      //               ),
      //               Expanded(child:
      //               Column(
      //                 children: [
      //                   ListTile(
      //                     title: Text("Email : ",style: TextStyle(color: Colors.white)),
      //                   ),
      //                 ],
      //               ),
      //               )
      //             ],
      //           ),
      //       ],),
      //     )
      // ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _messagesRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> messages = [];
                  List<Map<String, dynamic>> messagesToShow = [];
                  if (snapshot.data!.snapshot.value != null) {
                    final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                    messages = data.values.map((e) => Map<String, dynamic>.from(e)).toList();
                    // messages = messages.reversed.toList();

                    for (int i = 0; i < messages.length; i++) {
                      if ((messages[i]['SenderId'] == widget.reseiverId && messages[i]['ReceverId'] == uid) ||
                          (messages[i]['SenderId'] == uid && messages[i]['ReceverId'] == widget.reseiverId)) {
                        messagesToShow.add(messages[i]);
                      }
                    }

                    messagesToShow.sort((a, b) => b['Created At'].compareTo(a['Created At']));;
                    messagesToShow = messagesToShow.reversed.toList();

                    if(messagesToShow.isEmpty){
                      return Center(child: Text("No Messages Yet"));
                    }
                    return ListView.builder(
                      itemCount: messagesToShow.length,
                      itemBuilder: (context, index) {
                        final message = messagesToShow[index]['message'];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          child: Align(
                            alignment:messagesToShow[index]["ReceverId"] == widget.reseiverId ? Alignment.topLeft : Alignment.topRight,
                            child: Card(
                              color: messagesToShow[index]["ReceverId"] == widget.reseiverId ?Colors.grey.shade200 : Colors.orangeAccent,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(message, style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No Messages Yet"));
                  }
                }else{
                  return Center(child: Text("No Message Yet"));
                }
                // return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _TextController,
                    decoration: InputDecoration(
                      hintText: "Enter message",
                      fillColor: Colors.grey[800],
                      filled: true,
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.orange),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),



    );
  }
}
