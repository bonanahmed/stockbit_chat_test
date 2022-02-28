import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:stockbit_chat_test/controllers/message_controller.dart';
import 'package:stockbit_chat_test/controllers/status_controller.dart';

class MQTTManager {
  // Private instance of client
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final String _topic;
  final messageController = Get.put(MessageController());
  final statusController = Get.put(StatusController());

  MQTTManager({
    required String host,
    required String topic,
    required String identifier,
  })  : _identifier = identifier,
        _host = host,
        _topic = topic;

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.autoReconnect = true;
    _client!.resubscribeOnAutoReconnect = true;
    _client!.secure = false;
    _client!.logging(on: true);

    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;
    _client!.onAutoReconnect = onAutoReconnect;
    _client!.onAutoReconnected = onAutoReconnected;
    _client!.onDisconnected = onDisconnected;
    _client!.onUnsubscribed = onUnsubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic(
            'stockbit/$_topic/status') // If you set this you must set a will message
        .withWillMessage('Offline')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.exactlyOnce)
        .withWillRetain();
    print('Stockbit Chat:Initialize Setup:Mosquitto client setup....');
    _client!.connectionMessage = connMess;
    print("Stockbit Chat:Connection Message: $connMess");
  }

  // Connection
  Future connect() async {
    assert(_client != null);
    try {
      print('Stockbit Chat:Connect:Mosquitto start client connecting....');
      return await _client!.connect();
    } on Exception catch (e) {
      print('Stockbit Chat:Connect:client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    try {
      print('Stockbit Chat:Disconnect: Disconnected Success');
      _client!.disconnect();
    } catch (e) {
      print('Stockbit Chat:Disconnected: Disconnected Error, $e');
    }
  }

// Published and subscribe
  void publish(String message, String sendTo) {
    try {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(sendTo, MqttQos.exactlyOnce, builder.payload!);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void subscribeTo(String newTopic) {
    _client!.subscribe(newTopic, MqttQos.exactlyOnce);
  }

  void unsubscribeTo(String newTopic) {
    _client!.unsubscribe(newTopic);
  }

  void listenToSubscription() {
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(
          'Stockbit Chat:Listen:Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      messageController.getData(pt, c[0].topic);
    });
  }

  /// The successful connect callback
  void onConnected() {
    print('Stockbit Chat:OnConnected:Mosquitto client connected....');
    _client!.subscribe("stockbit/$_topic", MqttQos.exactlyOnce);
    statusController.updateStatus("Connected");
    publish("Online", "stockbit/$_topic/status");
    print('Stockbit Chat:OnConnected: Client connection was sucessful');
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('Stockbit Chat:OnSubscribed:Subscription confirmed for topic $topic');
  }

  /// The subscribed callback
  void onUnsubscribed(String? topic) {
    print(
        'Stockbit Chat:OnUnSubscribed:Unsubscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('Stockbit Chat:OnDisconnected:Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print(
          'Stockbit Chat:OnDisconnected:OnDisconnected callback is solicited, this is correct');
    }
    statusController.updateStatus("Disconnected");
  }

  void onAutoReconnect() {
    print('Stockbit Chat:OnAutoReconnect:Client reconnecting');
    statusController.updateStatus("Reconnecting");
  }

  void onAutoReconnected() {
    print('Stockbit Chat:OnAutoReconnected:Client reconnection was sucessful');
    statusController.updateStatus("Connected");
  }
}
