import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_chat_test/controllers/message_controller.dart';
import 'package:stockbit_chat_test/controllers/status_controller.dart';
import 'package:stockbit_chat_test/utils/mqtt_manager.dart';
import 'package:stockbit_chat_test/view/chat_page.dart';
import 'package:stockbit_chat_test/view/login_page.dart';
import 'package:stockbit_chat_test/view/new_message_page.dart';

class RoomPage extends StatefulWidget {
  final MQTTManager chatManager;
  RoomPage({Key? key, required this.chatManager}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final messageController = Get.find<MessageController>();
  final statusController = Get.find<StatusController>();

  GetStorage getStorage = GetStorage();

  String findReceiver(index) {
    String receiver = "";
    var memberList = messageController.chatList[index]["member"];

    memberList.forEach((member) {
      if (member != getStorage.read("username")) receiver = member;
    });
    return receiver;
  }

  @override
  void initState() {
    super.initState();
    widget.chatManager.listenToSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Get.to(NewMessagePage(
            chatManager: this.widget.chatManager,
          ));
        },
      ),
      appBar: AppBar(
        title: Text("Stockbit Chat"),
        actions: [
          PopupMenuButton(
              onSelected: (value) {
                if (value == 1) {
                  widget.chatManager.disconnect();
                  getStorage.remove("username");
                  messageController.roomList.value = {};
                  messageController.chatList.value = [];
                  Get.offAll(LoginPage());
                }
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Logout"),
                      value: 1,
                    ),
                  ]),
        ],
      ),
      body: Obx(
        () => Column(
          children: [
            if (statusController.showStatus.value)
              AnimatedContainer(
                duration: Duration(seconds: 1),
                alignment: AlignmentDirectional.center,
                width: MediaQuery.of(context).size.width,
                color: statusController.statusOnline.value == "Connected"
                    ? Colors.green
                    : Colors.red,
                child: Text(statusController.statusOnline.value),
              ),
            Expanded(
              child: Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  itemCount: messageController.chatList.length,
                  itemBuilder: (context, index) {
                    bool isGroup = messageController.chatList[index]
                                ['roomType'] ==
                            "personal"
                        ? false
                        : true;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => ChatPage(
                                chatManager: widget.chatManager,
                                roomId: messageController.chatList[index]
                                    ['roomId']));
                          },
                          child: Container(
                              child: Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(right: 15),
                                  width: 50,
                                  height: 50,
                                  child: Icon(messageController.chatList[index]
                                              ['roomType'] ==
                                          "personal"
                                      ? Icons.person
                                      : Icons.people)),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(isGroup
                                          ? messageController.chatList[index]
                                                  ['roomName'] ??
                                              ""
                                          : findReceiver(index)),
                                    ),
                                    Container(
                                      child: Text(isGroup
                                          ? "${messageController.chatList[index]['sender']}: ${messageController.chatList[index]['message']}"
                                          : messageController.chatList[index]
                                              ['message']),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(DateFormat('HH:mm').format(
                                          DateTime.parse(
                                              messageController.chatList[index]
                                                  ['messageDate']))),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                        ),
                        Divider()
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
