import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stockbit_chat_test/controllers/message_controller.dart';
import 'package:stockbit_chat_test/utils/mqtt_manager.dart';

class AddMemberPage extends StatefulWidget {
  final MQTTManager chatManager;
  final Map roomData;
  const AddMemberPage(
      {Key? key, required this.chatManager, required this.roomData})
      : super(key: key);

  @override
  _AddMemberPageState createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  TextEditingController _username = TextEditingController(text: "");
  var memberList = [].obs;
  GetStorage getStorage = GetStorage();

  final messageController = Get.find<MessageController>();

  @override
  void initState() {
    super.initState();
    memberList.value = widget.roomData["member"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invite Member"),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
        children: [
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
                      if (memberList.length < 2) {
                        Get.snackbar(
                            "Error", "Please Add Member At least 2 Members");
                      } else {
                        messageController.sendMessage(
                            false,
                            {
                              ...widget.roomData,
                              "member": [
                                // ignore: invalid_use_of_protected_member
                                ...memberList.value,
                                _username.text.removeAllWhitespace
                              ],
                            },
                            "message",
                            "info",
                            "${_username.text.removeAllWhitespace} Has Joined The Group",
                            widget.chatManager);

                        Get.back();
                      }
                    }
                  },
                  child: Text("Invite"),
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
