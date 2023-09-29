import 'package:chat_app/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
// late String group;

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;
class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String? _username;
  String? _groupId;
  late String? _userMail;
  late String textMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    setUserNameAndGroupId();
  }
  void getCurrentUser() async{
    try{
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser?.email);
        _userMail=loggedInUser?.email;
      }
    }
    catch(e){
      print(e);
    }
  }
  Future<void> setUserNameAndGroupId() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('users') // Replace 'users' with your collection name
        .where('email', isEqualTo: _userMail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Access the first document with the matching email (there should be only one)
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = querySnapshot.docs.first;

      // Access the data from the document
      final Map<String, dynamic> userData = documentSnapshot.data()!;

      // Now, you can use 'userData' to access the fields in the document
      print('User name: ${userData['name']}');
      print('User email: ${userData['email']}');
      // _username = '${userData['name']} ${userData['batch']}';
      // _groupId = userData['group'].toString();
      setState(() {
        _username = '${userData['name']} ${userData['batch']}';
        _groupId = userData['group'].toString();
      });
      // group = _groupId;
      // showDialog(context: context, builder: (context){
      //   return AlertDialog(
      //     content: Text('Username is $_username \n GroupId is $_groupId'),
      //   );
      // });

      // Add more fields as needed
    } else {
      // No document with the matching email was found
      print('User not found.');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    messageTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: ()  {
               _auth.signOut();
            // Navigator.pushNamed(context, WelcomeScreen.id);
            // Navigator.pop(context);
               SchedulerBinding.instance.addPostFrameCallback((_) {
                 Navigator.pop(context);
               });
            //   Navigator.of(context).pop();
          },
        ),
        // leading: Builder(
        //   builder: (BuildContext context) {
        //     return IconButton(
        //       icon: Icon(Icons.logout),
        //       onPressed: () async {
        //         await _auth.signOut();
        //         Navigator.of(context).pop(); // Use Navigator.of(context).pop() here
        //       },
        //     );
        //   },
        // ),

        title: Text('MWEP $_groupId'),
        // title: _groupId.isNotEmpty ? Text('MWEP $_groupId') : Text('MWEP'), // Set the title conditionally
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(group: _groupId,username: _username,),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      // onChanged: (value) {
                      //   textMessage=value;
                      // },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // DateTime timestamp= DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);
                      Timestamp timestamp = Timestamp.now();
                      // print('timestamp is $timestamp');
                      _firestore.collection('messages$_groupId').add({
                        'sender': _username,
                        'text': messageTextController.text.trim(),
                        'timestamp':timestamp
                      });
                      messageTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                  const SizedBox(width: 15,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {

  MessageStream({
    required this.group, required this.username
  });
  String? group;
  String? username;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages$group').orderBy('timestamp').snapshots(),
        builder: (context, snapshot){
            if(!snapshot.hasData){
              return  const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent,
                ),
              );
            }
              final messages = snapshot.data?.docs.reversed;
              List<MessageBubble> messageBubbles = [];
              for(var msg in messages!){
                final messageText=msg.get('text');
                final messageSender=msg.get('sender');
                final currentUser = loggedInUser?.email;

                final messageBubble = MessageBubble(
                    text: messageText,
                    sender: messageSender,
                    isMe: username==messageSender,
                    );
                messageBubbles.add(messageBubble);
              }
              return Expanded(
                child: ListView(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  children: messageBubbles,
                ),
              );

        },
    );
  }
}



class MessageBubble extends StatelessWidget {
  late final String text;
  late final String sender;
  late final bool isMe;
  MessageBubble({required this.text, required this.sender, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(sender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54
            ),

          ),
          Material(
            elevation: 5,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(isMe?30:0), bottomLeft: Radius.circular(30), topRight: Radius.circular(30), bottomRight: Radius.circular(isMe? 0:30)),
            color: isMe?Colors.lightBlueAccent:Colors.green,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

