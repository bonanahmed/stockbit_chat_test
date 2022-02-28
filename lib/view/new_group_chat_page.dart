import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stockbit_chat_test/controllers/message_controller.dart';
import 'package:stockbit_chat_test/utils/mqtt_manager.dart';

class NewGroupChatPage extends StatefulWidget {
  final MQTTManager chatManager;
  const NewGroupChatPage({Key? key, required this.chatManager})
      : super(key: key);

  @override
  _NewGroupChatPageState createState() => _NewGroupChatPageState();
}

class _NewGroupChatPageState extends State<NewGroupChatPage> {
  TextEditingController _groupName = TextEditingController(text: "");
  TextEditingController _username = TextEditingController(text: "");
  var memberList = [].obs;
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
          if (_groupName.text.isEmpty) {
            Get.snackbar("Error", "Please Fill Group Name");
          } else if (memberList.length < 2) {
            Get.snackbar("Error", "Please Add Member At least 2 Members");
          } else {
            messageController.sendMessage(
                true,
                {
                  "roomName": _groupName.text,
                  "roomType": "group",
                  // ignore: invalid_use_of_protected_member
                  "member": [...memberList.value, getStorage.read("username")],
                },
                "message",
                "info",
                "Group Has Been Created By ${getStorage.read("username")}",
                widget.chatManager);
            Get.back();
            Get.back();
          }
        },
      ),
      appBar: AppBar(
        title: Text("New Group Chat"),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _groupName,
                decoration: InputDecoration(
                    labelText: "Group Name", hintText: "Group Name"),
              )),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              "Add Member",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _username,
                    decoration: InputDecoration(
                        labelText: "Username", hintText: "Username"),
                  )),
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: TextButton(
                  onPressed: () {
                    if (_username.text.isNotEmpty) {
                      memberList.add(_username.text);
                      _username.text = "";
                    }
                  },
                  child: Text("Add Member"),
                ),
              ),
            ],
          ),
          Obx(
            () => ListView.builder(
              padding: EdgeInsets.all(15),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: memberList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memberList[index],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
