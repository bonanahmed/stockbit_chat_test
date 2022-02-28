import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockbit_chat_test/utils/mqtt_manager.dart';
import 'package:stockbit_chat_test/view/new_group_chat_page.dart';

import 'new_chat_page.dart';

class NewMessagePage extends StatelessWidget {
  final MQTTManager chatManager;
  const NewMessagePage({Key? key, required this.chatManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Message"),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Get.to(NewGroupChatPage(
                  chatManager: this.chatManager,
                ));
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Icon(Icons.group)),
                    Container(child: Text("New Group Chat"))
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(NewChatPage(chatManager: this.chatManager));
              },
              child: Container(
                child: Row(
                  children: [
                    Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Icon(Icons.chat)),
                    Container(child: Text("New Chat"))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
