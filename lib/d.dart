import 'package:flutter/material.dart';

class ChatMessage {
  final String messageContent;
  final String messageType;

  ChatMessage({required this.messageContent, required this.messageType});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [
    // ChatMessage(messageContent: "Hello, John", messageType: "receiver"),
    // ChatMessage(messageContent: "Hi, Jane", messageType: "sender"),
    // ChatMessage(messageContent: "How are you?", messageType: "receiver"),
    // ChatMessage(messageContent: "I'm good, how about you?", messageType: "sender"),
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text;
    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add(ChatMessage(messageContent: text, messageType: "sender"));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body:

      Column(
        children: [
          Expanded(
            child:
            Text("fgggg")
            // ListView.builder(
            //   itemCount: messages.length,
            //   itemBuilder: (context, index) {
            //     final message = messages[index];
            //     return Container(
            //       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            //       alignment: message.messageType == "sender" ? Alignment.topRight : Alignment.topLeft,
            //       child: Container(
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(20),
            //           color: message.messageType == "sender" ? Colors.orange : Colors.grey.shade200,
            //         ),
            //         padding: EdgeInsets.all(16),
            //         child: Text(message.messageContent, style: TextStyle(color: Colors.black),),
            //       ),
            //     );
            //   },
            // ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
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



// *******************************************************************************




import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_navigatore_bar.dart';

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() => _AuthscreenState();
}

class _AuthscreenState extends State<Authscreen> {
  late final uid;

  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref().child('Users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isCorrect = true;
  bool _isEmpty = false;  // Track if fields are empty
  bool _isMessageAvailable = false;

  String _message = '';  // This will store the message to be shown

  Future<void> _submit() async {
    setState(() {
      _isEmpty = false; // Reset empty status
      _message = ''; // Reset message
      _isMessageAvailable = false; // Reset message availability
    });

    // Check for empty fields
    if (!_isLogin && _userNameController.text.isEmpty) {
      setState(() {
        _isEmpty = true;
        _message = 'Name field is empty';
      });
      return;
    }

    if (_emailController.text.isEmpty) {
      setState(() {
        _isEmpty = true;
        _message = 'Email field is empty';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _isEmpty = true;
        _message = 'Password field is empty';
      });
      return;
    }

    if (!_isLogin && _confirmPasswordController.text.isEmpty) {
      setState(() {
        _isEmpty = true;
        _message = 'Confirm Password field is empty';
      });
      return;
    }

    // Check if passwords match for registration
    if (!_isLogin && _passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _isCorrect = false;
        _isMessageAvailable = true; // Ensure that the message is displayed
        _message = 'Passwords do not match'; // Set the appropriate message
      });
      return; // Stop further execution
    }

    // Proceed only if the passwords match
    setState(() {
      _isCorrect = true;
      _isEmpty = false; // Reset empty state
    });

    try {
      if (_isLogin) {
        // Sign in logic
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          _storeLoginStatus(true);

          // Clear input fields after successful login
          _userNameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();

          // Redirect to home after successful login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BottomNavigatoreBar()), // Home screen
                (Route<dynamic> route) => false,
          );
        }
      } else {
        // Registration logic
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        userCredential.user?.updateDisplayName(_userNameController.text);

        if (userCredential.user != null) {
          _storeLoginStatus(true);
        }

        final User? user = _auth.currentUser;
        uid = user!.uid;

        _messagesRef.push().set({
          "UserUid": uid,
          'UserName': _userNameController.text,
          'email': _emailController.text,
        });

        // Show success message
        setState(() {
          _isMessageAvailable = true;
          _message = 'Register Successfully';
        });

        // Clear input fields after successful registration
        _userNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        // Redirect to home after successful registration
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigatoreBar()), // Home screen
              (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message ?? 'An error occurred';
      });
    }
  }

  Future<void> _storeLoginStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(_isLogin ? 'Login' : 'Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  if (!_isLogin)
                    TextField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.grey[800],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.grey[800],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.grey[800],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  if (!_isLogin)
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.grey[800],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
            if (_isMessageAvailable)
              Text(
                _message,
                style: TextStyle(
                  color: _isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (_isEmpty)
              Text(
                _message,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              child: Text(_isLogin ? 'Login' : 'Register'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _isMessageAvailable = false;
                  _isEmpty = false;  // Reset empty status when switching modes
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: Text(_isLogin ? 'Create an account' : 'I already have an account'),
            ),
          ],
        ),
      ),
    );
  }
}









