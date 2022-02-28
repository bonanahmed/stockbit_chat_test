import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_chat_test/controllers/message_controller.dart';
import 'package:stockbit_chat_test/controllers/status_controller.dart';
import 'package:stockbit_chat_test/utils/mqtt_manager.dart';
import 'package:stockbit_chat_test/view/add_member_page.dart';

class ChatPage extends StatefulWidget {
  final String roomId;
  final MQTTManager chatManager;

  ChatPage({Key? key, required this.roomId, required this.chatManager})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageController = Get.find<MessageController>();
  final statusController = Get.find<StatusController>();

  GetStorage getStorage = GetStorage();

  var _messageContent = "".obs;

  TextEditingController _cSendMessage = TextEditingController(text: "");
  String findReceiver() {
    String receiver = "";
    var memberList = messageController.roomList[this.widget.roomId]["member"];
    memberList.forEach((member) {
      if (member != getStorage.read("username")) receiver = member;
    });

    return receiver;
  }

  late StreamSubscription listenToStatus;

  @override
  void initState() {
    super.initState();
    if (messageController.roomList[this.widget.roomId]["roomType"] ==
        "personal")
      widget.chatManager.subscribeTo("stockbit/${findReceiver()}/status");
    else {
      List memberList =
          messageController.roomList[this.widget.roomId]["member"];
      memberList.forEach((member) {
        widget.chatManager.subscribeTo("stockbit/$member/status");
      });
    }
    if (messageController.roomList[this.widget.roomId]["roomType"] == "group")
      listenToStatus = statusController.memberStatus.listen((value) {
        messageController.updateMessage(
          {
            ...messageController.roomList[this.widget.roomId],
            "message": value["status"],
            "sender": value["username"],
            "messageType": "info",
            "messageDate": DateTime.now().toIso8601String(),
          },
        );
      });
  }

  @override
  void dispose() {
    super.dispose();
    if (messageController.roomList[this.widget.roomId]["roomType"] ==
        "personal")
      widget.chatManager.unsubscribeTo("stockbit/${findReceiver()}/status");
    else {
      List memberList =
          messageController.roomList[this.widget.roomId]["member"];
      memberList.forEach((member) {
        widget.chatManager.unsubscribeTo("stockbit/$member/status");
      });
    }
    if (messageController.roomList[this.widget.roomId]["roomType"] == "group")
      listenToStatus.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (messageController.roomList[this.widget.roomId]["roomType"] ==
                  "group" &&
              messageController.roomList[this.widget.roomId]["member"]
                  .contains(getStorage.read("username")))
            PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 1:
                      Get.to(AddMemberPage(
                        chatManager: widget.chatManager,
                        roomData:
                            messageController.roomList[this.widget.roomId],
                      ));
                      break;
                    case 2:
                      messageController.roomList[this.widget.roomId]["member"]
                          .remove(getStorage.read("username"));
                      messageController.sendMessage(
                          false,
                          {
                            ...messageController.roomList[this.widget.roomId],
                            "member": messageController
                                .roomList[this.widget.roomId]["member"]
                          },
                          "message",
                          "info",
                          "${getStorage.read("username")} Left",
                          widget.chatManager);
                      messageController.updateMessage(
                        {
                          ...messageController.roomList[this.widget.roomId],
                          "member": messageController
                              .roomList[this.widget.roomId]["member"],
                          "message": "${getStorage.read("username")} Left",
                          "sender": getStorage.read("username"),
                          "messageType": "info",
                          "messageDate": DateTime.now().toIso8601String(),
                        },
                      );

                      break;
                    default:
                  }
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text("Invite Member"),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: Text("Leave Group"),
                        value: 2,
                      ),
                    ]),
        ],
        title: Obx(
          () => Container(
            child: Row(
              children: [
                Container(
                    margin: EdgeInsets.only(right: 15),
                    width: 30,
                    height: 30,
                    child: Icon(messageController.roomList[this.widget.roomId]
                                ["roomType"] ==
                            "personal"
                        ? Icons.person
                        : Icons.people)),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: Text(messageController
                                          .roomList[this.widget.roomId]
                                      ["roomType"] ==
                                  "personal"
                              ? findReceiver()
                              : messageController.roomList[this.widget.roomId]
                                  ["roomName"])),
                      messageController.roomList[this.widget.roomId]
                                  ["roomType"] ==
                              "personal"
                          ? Container(
                              child: Text(
                              statusController.rivalStatus.value,
                              style: TextStyle(fontSize: 12),
                            ))
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                messageController.roomList[this.widget.roomId]
                                        ["member"]
                                    .join(","),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(
              () => SizedBox(
                child: ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  itemCount: messageController
                      .roomList[this.widget.roomId]["chat"].length,
                  itemBuilder: (context, index) {
                    if (messageController.roomList[this.widget.roomId]["chat"]
                            [index]["messageType"] !=
                        "info") {
                      if (messageController.roomList[this.widget.roomId]["chat"]
                              [index]["sender"] ==
                          getStorage.read("username"))
                        return TextChatWidget(
                          data: messageController.roomList[this.widget.roomId]
                              ["chat"][index],
                          me: true,
                          isGroup:
                              messageController.roomList[this.widget.roomId]
                                          ["roomType"] ==
                                      "group"
                                  ? true
                                  : false,
                        );
                      else
                        return TextChatWidget(
                          data: messageController.roomList[this.widget.roomId]
                              ["chat"][index],
                          me: false,
                          isGroup:
                              messageController.roomList[this.widget.roomId]
                                          ["roomType"] ==
                                      "group"
                                  ? true
                                  : false,
                        );
                    } else {
                      return TextInfoWidget(
                        data: messageController.roomList[this.widget.roomId]
                            ["chat"][index],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Obx(
            () => (messageController.roomList[this.widget.roomId]["member"]
                    .contains(getStorage.read("username")))
                ? Container(
                    color: Colors.grey[200],
                    padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            // height: 35,
                            child: TextField(
                              // keyboardType: TextInputType.multiline,
                              minLines:
                                  1, //Normal textInputField will be displayed
                              maxLines:
                                  5, // when user presses enter it will adapt to it
                              expands: false,
                              controller: _cSendMessage,
                              decoration: InputDecoration(
                                  // suffixIcon: InkWell(
                                  //     onTap: () {
                                  //       // _showImage(context);
                                  //     },
                                  //     child: Icon(Icons.camera_alt_outlined)),
                                  fillColor: Colors.white,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(15, 15, 15, 15),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 5))),
                              onChanged: (value) {
                                _messageContent.value = value;
                              },
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: (_messageContent.value == "" ||
                                  _messageContent.value[0] == " ")
                              ? null
                              : () {
                                  messageController.sendMessage(
                                      false,
                                      messageController
                                          .roomList[this.widget.roomId],
                                      "message",
                                      "text",
                                      _messageContent.value,
                                      widget.chatManager);
                                  _messageContent.value = "";
                                  _cSendMessage.text = "";
                                },
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 25,
                          ),
                          style: ElevatedButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(5),
                            primary: Theme.of(context)
                                .primaryColor, // <-- Button color
                            onPrimary: Colors.white, // <-- Splash color
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: AlignmentDirectional.center,
                    color: Colors.grey,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Text("You no longer participants"),
                  ),
          )
        ],
      ),
    );
  }
}

class TextChatWidget extends StatelessWidget {
  const TextChatWidget(
      {Key? key, required this.data, required this.me, required this.isGroup})
      : super(key: key);

  final Map<String, dynamic> data;
  final bool me;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: me
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      margin: me
          ? EdgeInsets.fromLTRB(75, 7.5, 10, 7.5)
          : EdgeInsets.fromLTRB(10, 7.5, 75, 7.5),
      child: Container(
          decoration: BoxDecoration(
              color: me ? Theme.of(context).primaryColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(5)),
          padding: EdgeInsets.fromLTRB(7.5, 5, 7.5, 5),
          child: Column(
            crossAxisAlignment:
                me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (isGroup)
                Container(
                  child: Text(
                    data['sender'],
                    style: TextStyle(
                        color: me ? Colors.white : Colors.black, fontSize: 10),
                  ),
                ),
              Container(
                  width: data['message'].length < 4 ? 30 : null,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 2.5),
                  child: Text(
                    data['message'],
                    style: TextStyle(color: me ? Colors.white : Colors.black),
                  )),
              Container(
                child: Text(
                  DateFormat('HH:mm')
                      .format(DateTime.parse(data['messageDate'])),
                  style: TextStyle(
                      color: me ? Colors.white : Colors.black, fontSize: 8),
                ),
              ),
            ],
          )),
    );
  }
}

class TextInfoWidget extends StatelessWidget {
  const TextInfoWidget({Key? key, required this.data}) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      alignment: AlignmentDirectional.center,
      child: Container(
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.fromLTRB(7.5, 5, 7.5, 5),
          child: Column(
            children: [
              Container(
                  width: data['message'].length < 4 ? 30 : null,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 2.5),
                  child: Text(
                    data['message'],
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  )),
            ],
          )),
    );
  }
}
