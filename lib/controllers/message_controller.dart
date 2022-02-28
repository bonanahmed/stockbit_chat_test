import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stockbit_chat_test/controllers/status_controller.dart';
import 'package:stockbit_chat_test/utils/mqtt_manager.dart';
import 'package:uuid/uuid.dart';

class MessageController extends GetxController {
  final statusController = Get.put(StatusController());
  GetStorage getStorage = GetStorage();
  var roomList = {}.obs;
  var chatList = [].obs;
  void getData(var value, var topic) {
    if (topic.contains("status")) {
      statusController.updateStatusRival(value);
      statusController.updateMemberStatus(value, topic);
    } else {
      var jsonValue1 = jsonDecode(value);
      var jsonValue2;
      if (jsonValue1.runtimeType == String) {
        jsonValue2 = jsonDecode(jsonValue1);
      } else {
        jsonValue2 = jsonValue1;
      }
      String infoType = jsonValue2['infoType'];
      if (infoType == "message") {
        updateMessage(jsonValue2);
      }
    }
  }

  void updateMessage(messageData) {
    String roomId = messageData["roomId"];
    var uuid = Uuid();
    var dataChat = [];
    if (roomList[roomId] == null) {
      roomList[roomId] = {
        "roomId": messageData["roomId"],
        "roomName": messageData["roomName"],
        "roomType": messageData["roomType"],
        "sender": messageData["sender"],
        "messageType": messageData["messageType"],
        "message": messageData["message"],
        "messageDate": messageData["messageDate"],
        "member": messageData["member"],
      };
    } else {
      dataChat = roomList[roomId]['chat'];
      roomList[roomId] = {
        ...roomList[roomId],
        "sender": messageData["sender"],
        "messageType": messageData["messageType"],
        "message": messageData["message"],
        "messageDate": messageData["messageDate"],
        "member": messageData["member"],
      };
    }
    dataChat.insert(0, {
      "id": uuid.v1(),
      "sender": messageData["sender"],
      "messageType": messageData["messageType"],
      "message": messageData["message"],
      "messageDate": messageData["messageDate"],
      "member": messageData["member"],
    });
    roomList[roomId]['chat'] = dataChat;
    var tempList = [];
    roomList.forEach((k, v) => tempList.add({"roomId": k, ...v}));
    chatList.value = tempList;
  }

  void sendMessage(bool isNew, var roomData, String infoType,
      String messageType, String messageContent, MQTTManager chatManager) {
    var uuid = Uuid();
    var id = uuid.v1();
    var message = {
      "infoType": infoType,
      "roomId": isNew ? id : roomData['roomId'],
      "roomName": isNew
          ? roomData["roomType"] == "group"
              ? roomData['roomName']
              : id
          : roomData['roomName'],
      "roomType": roomData['roomType'],
      "sender": getStorage.read("username"),
      "member": roomData['member'],
      "messageType": messageType,
      "message": messageContent,
      "messageDate": DateTime.now().toIso8601String(),
    };
    print(message);
    var encodedMessage = jsonEncode(message);
    List memberList = message['member'];
    memberList.forEach((element) {
      chatManager.publish(encodedMessage, "stockbit/$element");
    });
  }
}
