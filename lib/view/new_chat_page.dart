import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stockbit_chat_test/controllers/message_controller.dart';
import 'package:stockbit_chat_test/utils/mqtt_manager.dart';

class NewChatPage extends StatefulWidget {
  final MQTTManager chatManager;
  const NewChatPage({Key? key, required this.chatManager}) : super(key: key);

  @override
  _NewChatPageState createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  TextEditingController _message = TextEditingController(text: "");
  TextEditingController _username = TextEditingController(text: "");
  GetStorage getStorage = GetStorage();
  final messageController = Get.find<MessageController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: () {
          messageController.sendMessage(
              true,
              {
                "roomType": "personal",
                "member": [_username.text, getStorage.read("username")]
              },
              "message",
              "text",
              _message.text,
              widget.chatManager);
          Get.back();
          Get.back();
        },
      ),
      appBar: AppBar(
        title: Text("New Chat"),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: Column(
          children: [
            Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _username,
                  decoration: InputDecoration(
                      labelText: "Username", hintText: "Username"),
                )),
            Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _message,
                  decoration: InputDecoration(
                      labelText: "Message", hintText: "Message"),
                )),
          ],
        ),
      ),
    );
  }
}
