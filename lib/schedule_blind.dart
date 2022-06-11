import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_blinds/constants/constants.dart';
import 'package:smart_blinds/database_helper.dart';
import 'package:smart_blinds/model/item.dart';
import 'package:workmanager/workmanager.dart';

class ScheduleBlind extends StatefulWidget {
  final int index;

  const ScheduleBlind({Key key, this.index = -1}) : super(key: key);
  @override
  _ScheduleBlindState createState() => _ScheduleBlindState();
}

class _ScheduleBlindState extends State<ScheduleBlind> {
  bool isRepeat = false;
  bool isTimePick = false;
  int level = 0;
  TimeOfDay timeOfDay;
  String selectedBlind = "Select a blind...";
  List<String> items = [];
  List<String> week = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  List<bool> weekDays = [];
  List<bool> weekDay = [];

  @override
  void initState() {
    super.initState();
    initialValues();
  }

  initialValues() {
    items.add(selectedBlind);
    Constants.blinds.forEach((element) {
      items.add(element.name);
    });
    widget.index == -1
        ? week.forEach((element) {
            weekDays.add(false);
          })
        : weekDays = Constants.scheduledBlinds[widget.index].weekDays;
    weekDay = weekDays;
    timeOfDay = widget.index == -1
        ? TimeOfDay.now()
        : Constants.scheduledBlinds[widget.index].time;
    level = widget.index == -1
        ? level
        : Constants.scheduledBlinds[widget.index].targetLevel.round();
    selectedBlind = widget.index == -1
        ? selectedBlind
        : Constants.scheduledBlinds[widget.index].name;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.keyboard_backspace_rounded,
            size: 28,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        actions: [
          InkWell(
            onTap: () async {
              if ((selectedBlind != "Select a blind...") &&
                  (weekDays.contains(true))) {
                if (widget.index == -1) {
                  Item item = Item(
                      isEnable: true,
                      name: selectedBlind,
                      isSchedule: true,
                      time: timeOfDay,
                      targetLevel: level.roundToDouble(),
                      weekDays: weekDays);
                  final id = await DatabaseHelper.instance.insertScheduled(item);
                  item.id = id;
                  Constants.scheduledBlinds.add(item);
                  print("Background task added ${timeOfDay.format(context)}");
                  Workmanager().registerPeriodicTask(
                      item.name +
                          " "+item.id.toString(),
                      "Scheduled Task",
                      inputData: {'index': 0},
                      initialDelay:
                          Constants.timeDiff(TimeOfDay.now(), timeOfDay),
                      frequency: Duration(minutes: 15),
                      constraints: Constraints(networkType: NetworkType.connected));
                } else {
                  Item oldItem = Constants.scheduledBlinds[widget.index];
                  Item item = Item(
                      id: oldItem.id,
                      isEnable: oldItem.isEnable,
                      name: selectedBlind,
                      isSchedule: true,
                      time: timeOfDay,
                      targetLevel: level.roundToDouble(),
                      weekDays: weekDays);
                  Constants.scheduledBlinds[widget.index] = item;
                  await DatabaseHelper.instance.updateScheduled(item);
                  print("Background task added ${timeOfDay.format(context)}");
                  Workmanager().registerPeriodicTask(
                      item.name +
                          " "+item.id.toString(),
                      "Scheduled Task",
                      inputData: {'index': widget.index},
                      initialDelay:
                      Constants.timeDiff(TimeOfDay.now(), timeOfDay),
                      frequency: Duration(days: 1),
                      constraints: Constraints(networkType: NetworkType.connected));
                }
                Navigator.pop(context);
              } else if (selectedBlind == "Select a blind...") {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "Please select a blind",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ));
              } else if (!weekDays.contains(true)) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "Please select the days to repeat",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.done,
                size: 28,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ),
        ],
        title: Text(
          "Schedule Blind",
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
          SafeArea(
            child: Container(
              width: width,
              height: height,
              child: Padding(
                padding: EdgeInsets.only(top: width * 0.05),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButton(
                                isExpanded: true,
                                value: selectedBlind,
                                icon: Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    selectedBlind = value;
                                  });
                                },
                                items: items
                                    .map((e) => DropdownMenuItem(
                                          child: Text(
                                            e,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          value: e,
                                        ))
                                    .toList()),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Target Level:",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16),
                            ),
                            Spacer(),
                            InkWell(
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12.withOpacity(0.2),
                                        blurRadius: 7,
                                        spreadRadius: 0.01,
                                        offset: Offset(2, 5))
                                  ],
                                ),
                                child: Center(
                                    child: Text(
                                  "-",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24),
                                )),
                              ),
                              onTap: () {
                                if (level > 5) {
                                  setState(() {
                                    level = level - 5;
                                  });
                                }
                              },
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Center(
                                child: Text(
                              "$level%",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18),
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12.withOpacity(0.2),
                                        blurRadius: 7,
                                        spreadRadius: 0.01,
                                        offset: Offset(2, 5))
                                  ],
                                ),
                                child: Center(
                                    child: Text(
                                  "+",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24),
                                )),
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              onTap: () {
                                if (level < 100) {
                                  setState(() {
                                    level = level + 5;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          TimeOfDay pickedTime = await showTimePicker(
                              context: context, initialTime: timeOfDay);
                          if (pickedTime != null) {
                            setState(() {
                              timeOfDay = pickedTime;
                            });
                          }
                        },
                        child: Container(
                            padding: EdgeInsets.only(
                                top: 15, bottom: 15, left: 10, right: 10),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 2)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${timeOfDay.format(context)}",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isRepeat = !isRepeat;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Repeat",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          isRepeat == true
              ? Container(
                  width: width,
                  height: height,
                  color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                  child: SafeArea(
                    child: Container(
                      child: Column(
                        children: [
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorLight,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Column(
                                      children: List.generate(
                                          week.length,
                                          (index) => Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    week[index],
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColorDark),
                                                  ),
                                                  Checkbox(
                                                      value: weekDay[index],
                                                      onChanged: (onChanged) {
                                                        setState(() {
                                                          weekDay[index] =
                                                              onChanged;
                                                        });
                                                      })
                                                ],
                                              )),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 20, right: 20, bottom: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                isRepeat = false;
                                                weekDays = weekDay;
                                              });
                                            },
                                            child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                              ),
                                              child: Center(
                                                  child: Text("OK",
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorLight,
                                                          fontSize: 16))),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                isRepeat = false;
                                                weekDay = weekDays;
                                              });
                                            },
                                            child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                    fontSize: 16),
                                              )),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
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
                  height: 0,
                  width: 0,
                ),
        ],
      ),
      extendBodyBehindAppBar: true,
    );
  }

  void hello() {
    DateTime dateTime = DateTime.now();
    dateTime.weekday;
  }
}
