import 'package:flutter/material.dart';
import 'package:smart_blinds/model/item.dart';
import 'package:wifi/wifi.dart';


class Constants {
  static String ssid = "Smart Blinds";
  static String password = "SB123456789";
  static List<Item> blinds = [];
  static List<Item> scheduledBlinds = [];
  static Duration timeDiff(TimeOfDay nowTime, TimeOfDay myTime) {
    double _doubleMyTime = myTime.hour.toDouble() +
        (myTime.minute.toDouble() / 60);
    double _doubleNowTime = nowTime.hour.toDouble() +
        (nowTime.minute.toDouble() / 60);
    var diff = (_doubleMyTime - _doubleNowTime)*60;
    if (_doubleNowTime < _doubleMyTime) {
      print(diff.round());
      return Duration(minutes: diff.round());
    } else {
      return Duration(days: 1,minutes: diff.round());
    }
  }

  static Future<bool> connect() async {
    String connectedSSID = await Wifi.ssid;
    while (connectedSSID != ssid) {
      await Wifi.connection(ssid,password);
      connectedSSID = await Wifi.ssid;
    }
    return true;
  }

}