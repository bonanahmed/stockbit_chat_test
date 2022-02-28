import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stockbit_chat_test/utils/mqtt_manager.dart';
import 'package:stockbit_chat_test/view/room_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late MQTTManager chatManager;
  late MQTTManager onlineManager;

  TextEditingController _usernameController = TextEditingController(text: "");

  void _configureAndConnect() async {
    MQTTManager chatManager = MQTTManager(
      host: "broker.hivemq.com",
      topic: _usernameController.text,
      identifier: _usernameController.text,
    );
    GetStorage getStorage = GetStorage();
    getStorage.write("username", _usernameController.text);
    chatManager.initializeMQTTClient();
    chatManager.connect().then((value) {
      Get.offAll(RoomPage(
        chatManager: chatManager,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.width * 0.5,
              child: Image(
                image: AssetImage("assets/src/img/stockbit-bibit-icon.png"),
              ),
            ),
            Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextField(
                  decoration: InputDecoration(hintText: "Username"),
                  controller: _usernameController,
                )),
            Container(
              width: double.infinity,
              child: TextButton(
                child: Text("Login"),
                onPressed: () {
                  if (_usernameController.text.isEmpty)
                    Get.snackbar("Error", "Please Fill Username First");
                  else
                    _configureAndConnect();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
