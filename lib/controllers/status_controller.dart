import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StatusController extends GetxController {
  GetStorage getStorage = GetStorage();
  var statusOnline = "Disconnected".obs;
  var showStatus = false.obs;
  var rivalStatus = "Offline".obs;
  var memberStatus = {}.obs;
  void updateStatus(value) {
    statusOnline.value = value;
    showStatus.value = true;
    if (statusOnline.value == "Connected")
      Timer(Duration(seconds: 5), () {
        showStatus.value = false;
      });
  }

  void updateStatusRival(value) {
    rivalStatus.value = value;
  }

  void updateMemberStatus(var value, String topic) {
    var topicSplit = topic.split("/");
    if (topicSplit[1] != getStorage.read("username")) {
      memberStatus.value = {
        "username": topicSplit[1],
        "status": "${topicSplit[1]} Is $value"
      };
    }
  }
}
