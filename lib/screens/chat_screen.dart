import 'dart:async';

import 'package:chat_socket_io/models/chat_message.dart';
import 'package:chat_socket_io/services/socket_service.dart';
import 'package:chat_socket_io/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _chatTfController;
  List<ChatMessageModel> _chatMessages;
  ScrollController _chatLVController;
  String _userStatus = "Connecting...";
  Color _statusColor = Colors.red;

  @override
  void initState() {
    _chatLVController = ScrollController(initialScrollOffset: 0.0);
    _chatTfController = TextEditingController();
    _chatMessages = List();
    initializeSocket();
    super.initState();
  }

  void initializeSocket(){
    SocketService().createSocketConnection();
    SocketService.socket.on('connect', (data) {
      setState(() {
        _statusColor = Colors.lightGreen;
        _userStatus = 'Connected';
      });
    });
    SocketService.socket.on('disconnect', (data) {
      setState(() {
        _statusColor = Colors.red;
        _userStatus = 'Disconnected';
      });
    });
    SocketService.socket.on('connect_error', (data) {
      setState(() {
        _statusColor = Colors.red;
        _userStatus = 'Connecting...';
        Toast.show(
            'Please restart the application or server!! Connection refused!!',
            context);
      });
    });
    SocketService.socket.on('receive_message', (data) {
      ChatMessageModel receiveChatModel = ChatMessageModel.fromJson(data);
      receiveChatModel.fromMe = false;
      addMsgToUI(receiveChatModel);
    });
  }

  _chatBubble(ChatMessageModel chatMessageModel) {
    bool fromMe = chatMessageModel.fromMe;
    Alignment alignment = fromMe ? Alignment.topRight : Alignment.topLeft;
    Alignment chatArrowAlignment =
        fromMe ? Alignment.topRight : Alignment.topLeft;
    TextStyle textStyle = TextStyle(
      fontSize: 16.0,
      color: fromMe ? Colors.white : Colors.black54,
    );
    Color chatBgColor = fromMe ? Colors.blue : Colors.black12;
    EdgeInsets edgeInsets = fromMe
        ? EdgeInsets.fromLTRB(5, 5, 15, 5)
        : EdgeInsets.fromLTRB(15, 5, 5, 5);
    EdgeInsets margins = fromMe
        ? EdgeInsets.fromLTRB(80, 5, 0, 5)
        : EdgeInsets.fromLTRB(0, 5, 80, 5);

    return Container(
      margin: margins,
      child: Align(
        alignment: alignment,
        child: Column(
          children: <Widget>[
            CustomPaint(
              painter: ChatBubble(
                color: chatBgColor,
                alignment: alignment,
              ),
              child: Container(
                margin: EdgeInsets.all(10.0),
                padding: edgeInsets,
                child: Text(
                  chatMessageModel.message,
                  style: textStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _chatList() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          cacheExtent: 100,
          controller: _chatLVController,
          reverse: false,
          shrinkWrap: true,
//          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          itemCount: null == _chatMessages ? 0 : _chatMessages.length,
          itemBuilder: (context, index) {
            ChatMessageModel chatMessage = _chatMessages[index];
            return _chatBubble(
              chatMessage,
            );
          },
        ),
      ),
    );
  }

  _bottomChatArea() {
    return Container(
      padding: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          _chatTextArea(),
          SizedBox(width: 6.0,),
          CircleAvatar(
            radius: 23.0,
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: () async {
                _sendButtonTap();
              },
            ),
          ),
        ],
      ),
    );
  }

  _chatTextArea() {
    return Expanded(
      child: TextField(
        controller: _chatTfController,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(10.0),
          hintText: 'Type message...',
        ),
      ),
    );
  }

  _chatListScrollToBottom() {
    Timer(Duration(milliseconds: 100), () {
      if (_chatLVController.hasClients) {
        _chatLVController.animateTo(
          _chatLVController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.decelerate,
        );
      }
    });
  }

  void addMsgToUI(ChatMessageModel chatMessage){
    setState(() {
      _chatMessages.add(chatMessage);
    });
    _chatListScrollToBottom();
  }

  _sendButtonTap() {
    if (_chatTfController.text.isEmpty) {
      return;
    }
    ChatMessageModel chatModel = ChatMessageModel(
      chatId: 0,
      message: _chatTfController.text,
      fromMe: true,
    );
     addMsgToUI(chatModel);
    _chatTfController.clear();
    SocketService.socket.emit('send_message', [chatModel.toJson()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/virat.png'),
            backgroundColor: Colors.amberAccent,
          ),
          title: Text(
            "User",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            _userStatus,
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          trailing: CircleAvatar(
            backgroundColor: _statusColor,
            radius: 6,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _chatList(),
                _bottomChatArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
