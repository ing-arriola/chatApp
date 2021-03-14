import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fire = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String message;


  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void getMessages () async {
    await _fire.collection('messages').snapshots().forEach((snapshot) {
      for (var message in snapshot.docs){
        print(message.data());
      }
    });
  }

  void messagesStream () async {
    await for(var snapshot in _fire.collection('messages').snapshots()){
      for (var message in snapshot.docs){
        print(message.data());
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        message=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                       messageTextController.clear();
                      _fire.collection('messages').add( {
                        'text':message,
                        'sender':loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder <QuerySnapshot> (
      stream: _fire.collection('messages').snapshots(),
      builder: (context,snapshot){
        List<MessageBubble> messageBubbles = [];
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs;
        for(var message in messages){
          final messageData = message.data();
          final messageText = messageData['text'];
          final messageSender = message['sender'];
          final messageBubble = MessageBubble(sender: messageSender, text: messageText,);
          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
              padding:
              EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              children:messageBubbles
          ),
        );
      },);
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender,this.text});
  final String text;
  final String sender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(sender,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12
          ),),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            elevation: 4,
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(text,
                style: TextStyle(
                  color:Colors.white,
                  fontSize: 15,
                ),),
            ),
          ),
        ],
      ),
    );;
  }
}

