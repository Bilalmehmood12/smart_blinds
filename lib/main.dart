import 'package:flutter/material.dart';
import 'package:smart_blinds/constants/constants.dart';
import 'package:smart_blinds/splash_screen.dart';
import 'package:web_socket_channel/io.dart';
import 'package:workmanager/workmanager.dart';

import 'model/item.dart';

var channel;
bool isWifiConnected = false;
bool isConnected = false;

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    print("Background Task: $taskName");
    Item item = Constants.scheduledBlinds[inputData['index']];
    if (item.weekDays[DateTime.now().weekday] == true) {
      if (isWifiConnected == true && isConnected == true) {
        sendCmd(item.name+","+item.targetLevel.round().toString());
        return Future.value(true);
      } else {
        connect();
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Smart Blinds",
    home: SplashScreen(),
    theme: ThemeData(
      primaryColor: Colors.blueAccent,
      primaryColorLight: Colors.white,
      primaryColorDark: Colors.black54,
    ),

  ));
}
connect() async {
  if (isWifiConnected == false) {
    isWifiConnected = await Constants.connect();
  }
  if (isConnected == false) {
    await channelConnect(); //connect to WebSocket wth NodeMCU
  }
}

channelConnect() async {
  //function to connect
  if (isWifiConnected == true) {
    try {
      channel = IOWebSocketChannel.connect(
          "ws://192.168.0.1:81"); //channel IP : Port
      channel.stream.listen(
            (message) {
              print(message);

              if (message == "connected") {
                print("WebSocket is $message");
                isConnected = true; //message is "connected" from NodeMCU
              } else if (message == "Done") {
                print("WebSocket is $message");
              } else {
                print("WebSocket is $message");
              }
            },
        onDone: () {
          //if WebSocket is disconnected
          print("WebSocket is closed");
          isConnected = false;
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to WebSocket.");
    }
  } else {
    isWifiConnected = await Constants.connect();
    channelConnect();
  }
}

Future<bool> sendCmd(String cmd) async {
  if (isConnected == true && isWifiConnected == true) {
    await channel.sink.add(cmd); //sending Command to NodeMCU
    return true;
  } else {
    connect();
  }
  return false;
}
