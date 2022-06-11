import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_blinds/constants/constants.dart';
import 'package:smart_blinds/database_helper.dart';
import 'package:smart_blinds/model/item.dart';
import 'package:workmanager/workmanager.dart';


class AddNewBlind extends StatefulWidget {
  final int index;

  const AddNewBlind({Key key, this.index = -1}) : super(key: key);
  @override
  _AddNewBlindState createState() => _AddNewBlindState();
}

class _AddNewBlindState extends State<AddNewBlind> {
  bool isActive = false;
  int level = 0;


  @override
  void initState() {
    super.initState();
    isActive = widget.index == -1 ? isActive: Constants.blinds[widget.index].isEnable;
    level = widget.index == -1 ? level: Constants.blinds[widget.index].currentLevel.round();
    nameController.text = widget.index == -1 ? "": Constants.blinds[widget.index].name;
  }

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.close_rounded, size: 28, color: Theme
              .of(context)
              .primaryColorDark,),
        ),
        actions: [
          InkWell(
            onTap: () async {
              if (widget.index == -1) {
                if (_formKey.currentState.validate()) {
                  Item item = Item(
                    name: nameController.text,
                    isEnable: isActive,
                    time: TimeOfDay.now(),
                    currentLevel: level.roundToDouble(),
                    weekDays: [
                      false,
                      false,
                      false,
                      false,
                      false,
                      false,
                      false
                    ]
                  );
                  final id = await DatabaseHelper.instance.insert(item);
                  item.id = id;
                  Constants.blinds.add(item);
                  setState(() {
                    Navigator.pop(context,widget.index);
                  });
                }
              } else {
                if (_formKey.currentState.validate()) {
                  Item oldItem = Constants.blinds[widget.index];
                  Item item = Item(
                    id: oldItem.id,
                    name: nameController.text,
                    isEnable: isActive,
                    time: TimeOfDay.now(),
                    currentLevel: level.roundToDouble(),
                    weekDays: oldItem.weekDays
                  );
                  Constants.blinds[widget.index] = item;
                  await DatabaseHelper.instance.update(item);
                  setState(() {
                    Navigator.pop(context,widget.index);
                  });
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.done, size: 28, color: Theme
                  .of(context)
                  .primaryColorDark,),
            ),
          ),
        ],
        title: Text("Add New Blind",
          style: TextStyle(
              color: Theme
                  .of(context)
                  .primaryColorDark,
              fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          child: Padding(
            padding: EdgeInsets.only(top: width*0.05),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width*0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction, decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        labelText: 'Enter Blind Name',
                      ),
                      validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                      },
                    ),
                    // SizedBox(height: 20,),
                    // Container(
                    //   padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.all(Radius.circular(10)),
                    //     border: Border.all(color: Theme.of(context).primaryColor,width: 2)
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text("Activate Blind:", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16
                    //       ),),
                    //       Switch(value: isActive, onChanged: (onChanged) {
                    //         setState(() {
                    //           isActive = onChanged;
                    //         });
                    //       })
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 20,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(color: Theme.of(context).primaryColor,width: 2)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Current Level:", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16
                          ),),
                          Spacer(),
                          InkWell(
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.all(Radius.circular(5)),
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
                                    style: TextStyle(color: Colors.white, fontSize: 24),
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
                          SizedBox(width: 10,),
                          Center(
                              child: Text(
                                "$level%",
                                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),
                              )),
                          SizedBox(width: 10,),
                          InkWell(
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.all(Radius.circular(5)),
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
                                    style: TextStyle(color: Colors.white, fontSize: 24),
                                  )),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
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
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
