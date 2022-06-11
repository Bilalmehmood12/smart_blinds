import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_blinds/add_new_blind.dart';
import 'package:smart_blinds/constants/constants.dart';
import 'package:smart_blinds/database_helper.dart';
import 'package:smart_blinds/model/item.dart';
import 'package:web_socket_channel/io.dart';
import 'package:workmanager/workmanager.dart';

import 'components/custom_menu_icon_button.dart';
import 'schedule_blind.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var channel;
  bool isWifiConnected = false;
  bool isConnected = false;
  bool isLevelOpen = false;
  int currentLevel = 0;
  int i;
  bool isLongPress = false;
  double percentage;
  int drawerMenuIndex = 0;
  bool isNewMenuOpen = false;
  List<String> weekName = [
    "M",
    "T",
    "W",
    "T",
    "F",
    "S",
    "S",
  ];
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    connect();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => CustomMenuIconButton(
            color: Theme.of(context).primaryColorDark,
            onTap: () {
              setState(() {
                isLongPress = false;
              });
              Scaffold.of(context).openDrawer();
            },
            size: 20,
          ),
        ),
        title: Text(
          drawerMenuIndex == 0
              ? "Smart Blinds"
              : drawerMenuIndex == 1
                  ? "Scheduled Blinds"
                  : drawerMenuIndex == 2
                      ? "Support"
                      : "Contact",
          style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          drawerMenuIndex == 0
              ? SafeArea(
                  child: Constants.blinds.length == 0
                      ? Center(
                          child: Text(
                            "There is no blind",
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).primaryColorDark),
                          ),
                        )
                      : Container(
                          width: width,
                          height: height,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.075, vertical: 30),
                            child: Wrap(
                              spacing: width * 0.05,
                              runSpacing: width * 0.05,
                              children: List.generate(Constants.blinds.length,
                                  (index) => blindsCard(index)),
                            ),
                          ),
                        ),
                )
              : drawerMenuIndex == 1
                  ? SafeArea(
                      child: Constants.scheduledBlinds.length != 0
                          ? SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: width * 0.05, top: width * 0.05),
                                child: Wrap(
                                  runSpacing: 10,
                                  children: List.generate(
                                      Constants.scheduledBlinds.length,
                                      (index) => Slidable(
                                          key: Key(index.toString()),
                                          endActionPane: ActionPane(
                                            motion: ScrollMotion(),
                                            children: [
                                              SlidableAction(
                                                onPressed: (context) async {
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ScheduleBlind(
                                                                  index:
                                                                      index)));
                                                  setState(() {});
                                                },
                                                backgroundColor: Colors.grey,
                                                icon: Icons.edit_outlined,
                                                label: "Edit",
                                              ),
                                              SlidableAction(
                                                onPressed: (context) async {
                                                  Item scheduledItem = Constants
                                                      .scheduledBlinds[index];
                                                  await DatabaseHelper.instance
                                                      .deleteScheduled(
                                                          scheduledItem.id);
                                                  Workmanager()
                                                      .cancelByUniqueName(
                                                          scheduledItem.name +
                                                              " " +
                                                              scheduledItem.id
                                                                  .toString());
                                                  setState(() {
                                                    Constants.scheduledBlinds
                                                        .removeAt(index);
                                                  });
                                                },
                                                backgroundColor: Colors.red,
                                                icon: Icons.delete,
                                                label: "Remove",
                                              )
                                            ],
                                          ),
                                          child: scheduledBlindsCard(index))),
                                ),
                              ),
                            )
                          : SafeArea(
                              child: Container(
                              child: Center(
                                child: Text(
                                  "No task Scheduled",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 16),
                                ),
                              ),
                            )),
                    )
                  : SafeArea(child: Center()),
          isLevelOpen == false //level indicator
              ? SizedBox(
                  width: 0,
                  height: 0,
                )
              : InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    if (isLevelOpen == true) {
                      setState(() {
                        isLevelOpen = false;
                      });
                    }
                  },
                  child: Container(
                    width: width,
                    height: height,
                    color: Colors.black,
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: height * 0.1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(Constants.blinds[i].img,
                                  scale: width * 0.4 * 0.08,
                                  color: Theme.of(context).primaryColorLight),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                Constants.blinds[i].name,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontSize: 18),
                              )
                            ],
                          ),
                          SizedBox(
                            height: height * 0.025,
                          ),
                          Text(
                            "Level: ${percentage.round()}%",
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 18),
                          ),
                          SizedBox(
                            height: height * 0.025,
                          ),
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                  width: 40,
                                  height: height * 0.2,
                                  child: RotatedBox(
                                    child: FAProgressBar(
                                      maxValue: 100,
                                      currentValue: percentage,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7)),
                                      backgroundColor: Theme.of(context)
                                          .primaryColorLight
                                          .withOpacity(0.5),
                                      progressColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.8),
                                    ),
                                    quarterTurns: -1,
                                  ),
                                ),
                              ),
                              Container(
                                  width: 40,
                                  height: height * 0.245,
                                  child: RotatedBox(
                                    child: Opacity(
                                      opacity: 0.01,
                                      child: Slider(
                                        min: 0,
                                        max: 100,
                                        divisions: 100,
                                        onChanged: (value) {
                                          setState(() {
                                            percentage = value.roundToDouble();
                                          });
                                        },
                                        value: percentage,
                                      ),
                                    ),
                                    quarterTurns: -1,
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: width * 0.03,
                          ),
                          InkWell(
                            onTap: () async {
                              isWifiConnected = await Constants.connect();
                              if (isWifiConnected == true && isConnected == true) {
                                var res = await sendCmd(Constants.blinds[i].name+","+percentage.round().toString());
                                if (res == true) {
                                  Constants.blinds[i].currentLevel = percentage;
                                  await DatabaseHelper.instance
                                      .update(Constants.blinds[i]);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    'Blinds no connected.',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColorLight,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  action: SnackBarAction(
                                    label: "Reconnect",
                                    onPressed: () {
                                      connect();
                                    },
                                  ),
                                  backgroundColor: Theme.of(context).primaryColor,
                                  duration: Duration(seconds: 2),
                                ));
                              }
                              setState(() {
                                isLevelOpen = false;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Center(
                                  child: Icon(
                                Icons.done,
                                size: 26,
                                color: Theme.of(context).primaryColorLight,
                              )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
          //To add new blind
          isNewMenuOpen == true
              ? Container(
                  width: width,
                  height: height,
                  color: Theme.of(context).primaryColorLight.withOpacity(0.5),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 90,
                        right: 18,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 12),
                                  child: Text(
                                    "Schedule Blind",
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0, 3))
                                      ]),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ScheduleBlind()));
                                    setState(() {
                                      isNewMenuOpen = false;
                                    });
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle),
                                    child: Image.asset(
                                      'res/schedule.png',
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      scale: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 12),
                                  child: Text(
                                    "Add New Blind",
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0, 3))
                                      ]),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddNewBlind()));
                                    setState(() {
                                      isNewMenuOpen = false;
                                    });
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      Icons.add,
                                      size: 28,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
          isLongPress == true
              ? Positioned(
                  left: i % 2 == 1 ? width * 0.6 : width * 0.15,
                  top: (i / 2 - 0.1).round() * width * 0.45 + width * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.2),
                            blurRadius: 7,
                            spreadRadius: 0.01,
                            offset: Offset(2, 5))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              isLongPress = false;
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddNewBlind(index: i)));
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 26,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  SizedBox(
                                    width: 10,
                                    height: 0,
                                  ),
                                  Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 2,
                            color: Colors.black,
                          ),
                          InkWell(
                            onTap: () async {
                              Item item = Constants.blinds[i];
                              await DatabaseHelper.instance
                                  .deleteScheduledByName(item.name);
                              List<Item> newScheduledItem = await DatabaseHelper.instance.queryAllScheduled();
                              List<int> indexes;
                              newScheduledItem.forEach((element) {
                                var i = Constants.scheduledBlinds.indexOf(element);
                                if (i != -1) {
                                  indexes.add(i);
                                }
                              });
                              for (int i = 0; i < indexes.length; i++) {
                                Item scheduledItem = Constants.scheduledBlinds[indexes[i]];
                                Workmanager().cancelByUniqueName(scheduledItem.name+" "+scheduledItem.id.toString());
                              }
                              await DatabaseHelper.instance.delete(item.id);
                              loadData();
                              setState(() {
                                isLongPress = false;
                              });
                            },
                            splashColor: Theme.of(context).primaryColorDark,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 26,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  SizedBox(
                                    width: 10,
                                    height: 0,
                                  ),
                                  Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
        ],
      ),
      floatingActionButton: (drawerMenuIndex < 2) && (isLevelOpen == false)
          ? FloatingActionButton(
              child: Icon(
                isNewMenuOpen == false ? Icons.add : Icons.close,
                size: 28,
              ),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                isLongPress = false;
                setState(() {
                  isNewMenuOpen = !isNewMenuOpen;
                });
              },
            )
          : null,
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: CircleAvatar(
                        child: Icon(
                          Icons.person,
                          size: 50,
                        ),
                      ),
                    ),
                    Text(
                      "Ajman Ullah Khan",
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                    ),
                    Text(
                      "ajman41288@gmail.com",
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      if (drawerMenuIndex != 0) {
                        setState(() {
                          drawerMenuIndex = 0;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: drawerMenuIndex == 0
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.home_rounded,
                            color: drawerMenuIndex == 0
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColorDark,
                            size: 26,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Home",
                            style: TextStyle(
                                color: drawerMenuIndex == 0
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      if (drawerMenuIndex != 1) {
                        setState(() {
                          drawerMenuIndex = 1;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: drawerMenuIndex == 1
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          Image.asset(
                            'res/schedule.png',
                            color: drawerMenuIndex == 1
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColorDark,
                            scale: 36,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Scheduled Blinds",
                            style: TextStyle(
                                color: drawerMenuIndex == 1
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      if (drawerMenuIndex != 2) {
                        setState(() {
                          drawerMenuIndex = 2;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: drawerMenuIndex == 2
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.message_outlined,
                            color: drawerMenuIndex == 2
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColorDark,
                            size: 26,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Support",
                            style: TextStyle(
                                color: drawerMenuIndex == 2
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      if (drawerMenuIndex != 3) {
                        setState(() {
                          drawerMenuIndex = 3;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: drawerMenuIndex == 3
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.phone,
                            color: drawerMenuIndex == 3
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColorDark,
                            size: 26,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Contact Us",
                            style: TextStyle(
                                color: drawerMenuIndex == 3
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Divider(
              thickness: 1,
              color: Theme.of(context).primaryColorDark,
            ),
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 26,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Logout",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget blindsCard(index) {
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onLongPress: () {
        setState(() {
          if (isLongPress == false) {
            isLongPress = true;
            i = index;
          } else {
            isLongPress = false;
          }
        });
      },
      onTap: () async {
        if (isLongPress == true) {
          isLongPress = false;
        }
        isWifiConnected = await Constants.connect();
        if (isWifiConnected == true && isConnected == true) {
          if (Constants.blinds[index].isEnable == true) {
            Constants.blinds[index].isEnable = false;
            await DatabaseHelper.instance.update(Constants.blinds[index]);
          } else {
            {
              Constants.blinds[index].isEnable = true;
              await DatabaseHelper.instance.update(Constants.blinds[index]);
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Blinds no connected.',
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
            action: SnackBarAction(
              label: "Reconnect",
              onPressed: () {
                connect();
              },
            ),
            backgroundColor: Theme.of(context).primaryColor,
            duration: Duration(seconds: 2),
          ));
        }
        setState(() {});
      },
      child: Container(
        width: width * 0.4,
        height: width * 0.4,
        decoration: BoxDecoration(
            color: Constants.blinds[index].isEnable == true
                ? null
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Constants.blinds[index].isEnable == true
                ? null
                : Border.all(
                    width: 2,
                    style: BorderStyle.solid,
                    color: Theme.of(context).primaryColorDark),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  spreadRadius: 0.1,
                  blurRadius: 5,
                  offset: Offset(0, 4)),
            ],
            gradient: Constants.blinds[index].isEnable
                ? LinearGradient(colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.9),
                    Theme.of(context).primaryColor.withOpacity(0.7),
                    Theme.of(context).primaryColor.withOpacity(0.5),
                  ], begin: Alignment.bottomRight, end: Alignment.topLeft)
                : null),
        child: Padding(
          padding: EdgeInsets.only(
              left: width * 0.4 * 0.1, right: width * 0.4 * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: width * 0.4 * 0.15, bottom: width * 0.4 * 0.15),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(Constants.blinds[index].img,
                          scale: width * 0.4 * 0.09,
                          color: Constants.blinds[index].isEnable
                              ? Theme.of(context).primaryColorLight
                              : Theme.of(context).primaryColorDark),
                      SizedBox(
                        height: width * 0.4 * 0.15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Blind",
                            style: TextStyle(
                                color: Constants.blinds[index].isEnable
                                    ? Theme.of(context).primaryColorLight
                                    : Theme.of(context).primaryColorDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1),
                          ),
                          SizedBox(
                            height: width * 0.4 * 0.05,
                          ),
                          Text(
                            Constants.blinds[index].name,
                            style: TextStyle(
                              color: Constants.blinds[index].isEnable
                                  ? Theme.of(context).primaryColorLight
                                  : Theme.of(context).primaryColorDark,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  isLongPress = false;
                  if (isLevelOpen == false) {
                    setState(() {
                      isLevelOpen = true;
                      i = index;
                      percentage = Constants.blinds[index].currentLevel;
                    });
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: width * 0.4 * 0.1,
                      horizontal: width * 0.4 * 0.1),
                  child: Container(
                      width: 7,
                      height: width * 0.4 * 0.7,
                      child: RotatedBox(
                        child: FAProgressBar(
                          maxValue: 100,
                          currentValue: Constants.blinds[index].currentLevel,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          backgroundColor:
                              Constants.blinds[index].isEnable == true
                                  ? Theme.of(context)
                                      .primaryColorLight
                                      .withOpacity(0.3)
                                  : Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.3),
                          progressColor:
                              Constants.blinds[index].isEnable == true
                                  ? Theme.of(context).primaryColorLight
                                  : Theme.of(context).primaryColorDark,
                        ),
                        quarterTurns: -1,
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget scheduledBlindsCard(index) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Container(
        width: width * 0.9,
        height: width * 0.22,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
              width: 2,
              style: BorderStyle.solid,
              color: Theme.of(context).primaryColorDark),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 0.1,
                blurRadius: 8,
                offset: Offset(0, 3)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: width * 0.9 * 0.3333,
              child: Container(
                height: width * 0.22,
                width: width * 0.9 - width * 0.9 * 0.35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Blind",
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1),
                        ),
                        SizedBox(
                          height: width * 0.22 * 0.05,
                        ),
                        Text(
                          Constants.scheduledBlinds[index].name,
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: width * 0.22 * 0.03,
                        ),
                        Text(
                          "Level: ${Constants.scheduledBlinds[index].targetLevel.round()} %",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: width * 0.22 * 0.2),
                      child: Switch(
                          value: Constants.scheduledBlinds[index].isEnable,
                          onChanged: (val) async {
                            Constants.scheduledBlinds[index].isEnable = val;
                            await DatabaseHelper.instance.updateScheduled(
                                Constants.scheduledBlinds[index]);
                            setState(() {});
                          }),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                top: (width * 0.22 - width * 0.08) / 2,
                left: 0,
                child: Container(
                  width: width * 0.25,
                  height: width * 0.08,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(7),
                          bottomRight: Radius.circular(7)),
                      color: Theme.of(context).primaryColor),
                  child: Center(
                    child: Text(
                      Constants.scheduledBlinds[index].time.format(context),
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                )),
            Positioned(
                right: 2,
                top: width * 0.22 * 0.06,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(
                      Constants.scheduledBlinds[index].weekDays.length,
                      (i) => Container(
                        margin: EdgeInsets.only(right: 5),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Constants.scheduledBlinds[index].weekDays[i] ==
                                  false
                              ? Theme.of(context).primaryColorLight
                              : Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Constants
                                      .scheduledBlinds[index].weekDays[i] ==
                                  true
                              ? null
                              : Border.all(
                                  color: Theme.of(context).primaryColorDark),
                        ),
                        child: Center(
                          child: Text(
                            weekName[i],
                            style: TextStyle(
                                color: Constants.scheduledBlinds[index]
                                            .weekDays[i] ==
                                        false
                                    ? Theme.of(context).primaryColorDark
                                    : Theme.of(context).primaryColorLight,
                                fontSize: 11),
                          ),
                        ),
                      ),
                    )))
          ],
        ),
      ),
    );
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
            setState(() {
              if (message == "connected") {
                print("WebSocket is $message");
                isConnected = true; //message is "connected" from NodeMCU
              } else if (message == "Done") {
                print("WebSocket is $message");
              } else {
                print("WebSocket is $message");
              }
            });
          },
          onDone: () {
            //if WebSocket is disconnected
            print("WebSocket is closed");
            setState(() {
              isConnected = false;
            });
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Blinds no connected.',
          style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.w500,
              fontSize: 16),
        ),
        action: SnackBarAction(
          label: "Reconnect",
          onPressed: () {
            connect();
            sendCmd(cmd);
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: Duration(seconds: 2),
      ));
    }
    return false;
  }

  Future<void> loadData() async {
    Constants.blinds.clear();
    Constants.scheduledBlinds.clear();
    Constants.blinds = await DatabaseHelper.instance.queryAll();
    Constants.scheduledBlinds =
        await DatabaseHelper.instance.queryAllScheduled();
    setState(() {});
  }
}
