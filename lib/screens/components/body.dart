// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, annotate_overrides, use_key_in_widget_constructors

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:famfam/Homepage/HomePage.dart';
import 'package:famfam/models/my_order_model.dart';
import 'package:famfam/models/random_model.dart';
import 'package:famfam/models/user_model.dart';
import 'package:famfam/services/my_constant.dart';
import 'package:famfam/screens/ticktik_screen.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:famfam/models/ticktick_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:famfam/components/text_field_container.dart';
import 'package:famfam/constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:famfam/components/tickbottomsheet.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:famfam/services/my_constant.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'header_circle.dart';
import 'package:famfam/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:famfam/models/circle_model.dart';

class Body extends StatelessWidget {
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          HeaderCircle(size: size),
          Container(
            width: size.width * 1,
            height: size.height * 0.74,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(65),
                topRight: Radius.circular(65),
              ),
            ),
            child: Stack(children: <Widget>[
              Container(
                height: size.height * 0.74,
                margin: EdgeInsets.only(top: 5.0),
                decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(66),
                      topRight: Radius.circular(66),
                    )),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 34, top: 55),
                      child: Text(
                        'Let\'s input Circle ID here!',
                        style: TextStyle(
                          fontSize: 29,
                          //fontFamily: 'Merriweather',
                          fontWeight: FontWeight.bold,
                          //letterSpacing: 1.0
                          //height: 1.8
                        ),
                      ),
                    ),
                    //SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 34),
                      child: Text(
                        '\nEnter the Circle ID that you copied in here. \nThen come and have fun together.',
                        style: TextStyle(
                          fontSize: 19,
                          //fontFamily: 'Merriweather',
                          fontWeight: FontWeight.normal,
                          //letterSpacing: 1.0
                          height: 1.3,
                        ),
                      ),
                    ),
                    RoundedInputField(
                      hintText: 'Enter your Circle ID',
                      onChanged: (String value) {},
                    ),
                  ],
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}

class TodoBody extends StatefulWidget {
  final int tabSelected;
  const TodoBody({Key? key, required this.tabSelected}) : super(key: key);
  @override
  State<TodoBody> createState() => _TodoBodyState();
}

class _TodoBodyState extends State<TodoBody> with TickerProviderStateMixin {
  List<UserModel> userModels = [];
  List<UserModel> employeeModels = [];
  List<MyOrdereModel> unfinishedModels = [];
  List<MyOrdereModel> finishedModels = [];
  List<MyOrdereModel> myOrderModels = [];
  List<bool> myOrderChecked = [];

  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 3);
    tabController!.animateTo(widget.tabSelected);
    pullUserSQLID().then((value) {
      pullEmployeeData();
      pullMyOrderUnfinished();
      pullMyOrderFinished();
      pullMyOrder().then((value) {
        myOrderIsChecked();
      });
    });
  }

  Future<Null> pullMyOrderUnfinished() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? circle_id = preferences.getString('circle_id');
    String? employee_id = userModels[0].id;
    String pullMyOrderUnfinished =
        '${MyConstant.domain}/famfam/getMyOrderUnfinished.php?isAdd=true&circle_id=$circle_id&employee_id=$employee_id';
    try {
      await Dio().get(pullMyOrderUnfinished).then((value) async {
        for (var item in json.decode(value.data)) {
          MyOrdereModel model = MyOrdereModel.fromMap(item);
          setState(() {
            unfinishedModels.add(model);
          });
        }
      });
    } catch (e) {}
  }

  Future<Null> pullMyOrderFinished() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? circle_id = preferences.getString('circle_id');
    String? employee_id = userModels[0].id;
    String pullMyOrderFinished =
        '${MyConstant.domain}/famfam/getMyOrderFinished.php?isAdd=true&circle_id=$circle_id&employee_id=$employee_id';
    try {
      await Dio().get(pullMyOrderFinished).then((value) async {
        for (var item in json.decode(value.data)) {
          MyOrdereModel model = MyOrdereModel.fromMap(item);
          setState(() {
            finishedModels.add(model);
          });
        }
      });
    } catch (e) {}
  }

  Future<Null> pullMyOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? circle_id = preferences.getString('circle_id');
    String? owner_id = userModels[0].id;
    String pullMyOrder =
        '${MyConstant.domain}/famfam/getMyOrder.php?isAdd=true&circle_id=$circle_id&owner_id=$owner_id';
    try {
      await Dio().get(pullMyOrder).then((value) async {
        for (var item in json.decode(value.data)) {
          MyOrdereModel model = MyOrdereModel.fromMap(item);
          setState(() {
            myOrderModels.add(model);
          });
        }
      });
    } catch (e) {}
  }

  myOrderIsChecked() {
    for (int i = 0; i <= myOrderModels.length; i++) {
      if (myOrderModels[i].my_order_status == 'true') {
        myOrderChecked.add(true);
      } else if (myOrderModels[i].my_order_status == 'false') {
        myOrderChecked.add(false);
      }
    }
  }

  Future<Null> pullUserSQLID() async {
    final String getUID = FirebaseAuth.instance.currentUser!.uid.toString();
    String uid = getUID;
    String pullUser =
        '${MyConstant.domain}/famfam/getUserWhereUID.php?isAdd=true&uid=$uid';
    await Dio().get(pullUser).then((value) async {
      if (value.toString() == null ||
          value.toString() == 'null' ||
          value.toString() == '') {
        FirebaseAuth.instance.signOut();
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.clear();
      } else {
        for (var item in json.decode(value.data)) {
          UserModel model = UserModel.fromMap(item);
          setState(() {
            userModels.add(model);
          });
        }
      }
    });
  }

  Future<Null> pullEmployeeData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? circle_id = preferences.getString('circle_id');
    print(circle_id);
    String pullUser =
        '${MyConstant.domain}/famfam/getUserWhereCircleID.php?isAdd=true&circle_id=$circle_id';
    await Dio().get(pullUser).then((value) async {
      for (var item in json.decode(value.data)) {
        UserModel model = UserModel.fromMap(item);
        setState(() {
          employeeModels.add(model);
        });
      }
    });
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: SafeArea(
          child: Stack(
            children: [
              Text(""),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(55.0),
                  child: AppBar(
                    title: Text(
                      'All Circle \'s list',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: SvgPicture.asset(
                        "assets/icons/chevron-back-outline.svg",
                        height: 35,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: SvgPicture.asset(
                          "assets/icons/information-_1_.svg",
                          height: 30,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 29, right: 29),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF9EE6D).withOpacity(0.44),
                              borderRadius: BorderRadius.circular(19),
                            ),
                            height: 66,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TabBar(
                                controller: tabController,
                                indicator: BoxDecoration(
                                  color: Color(0xFFFFC34A),
                                  borderRadius: BorderRadius.circular(19),
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700,
                                ),
                                unselectedLabelStyle: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400),
                                labelColor: Colors.black87,
                                unselectedLabelColor: Color(0xFFA5A59D),
                                tabs: [
                                  Tab(text: 'Unfinished'),
                                  Tab(text: 'Finished'),
                                  Tab(text: 'My Order'),
                                ],
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            child: SizedBox(
                              height: 640,
                              child: TabBarView(
                                controller: tabController,
                                children: [
                                  Container(
                                    child: unfinishedModels.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Container(
                                              //height: 100,
                                              //width: 100,
                                              decoration: BoxDecoration(
                                                  //color: Colors.pink.shade700,
                                                  //borderRadius: BorderRadius.circular(30),
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  SvgPicture.asset(
                                                    "assets/icons/leaf-fall.svg",
                                                    height: 85,
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                  ),
                                                  SizedBox(
                                                    height: 1,
                                                  ),
                                                  Text(
                                                    "You don't have any list right now.",
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            child: ListView.builder(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                itemCount:
                                                    unfinishedModels.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Container(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 80,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  bottom: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Color(
                                                                0xfffFFC34A),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    10,
                                                                    10,
                                                                    10,
                                                                    10),
                                                            child: Row(
                                                                // mainAxisAlignment:
                                                                //     MainAxisAlignment
                                                                //         .spaceBetween,
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left: 6,
                                                                        right:
                                                                            2),
                                                                    child: Builder(builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return Container(
                                                                        width:
                                                                            40,
                                                                        height:
                                                                            40,
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            RoundCheckBox(
                                                                                isChecked: false,
                                                                                onTap: null),
                                                                            FlatButton(
                                                                              color: Colors.white,
                                                                              shape: RoundedRectangleBorder(
                                                                                  side: BorderSide(
                                                                                    color: Colors.transparent,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(50)),
                                                                              onPressed: () async {
                                                                                {
                                                                                  // ติ๊กถูก
                                                                                  if (userModels[0].id != unfinishedModels[index].employee_id) {
                                                                                    Fluttertoast.showToast(msg: "You can't finish other people assignment.", gravity: ToastGravity.BOTTOM);
                                                                                  } else {
                                                                                    //ทำเสร็จไป UPDATE DATABASE
                                                                                    String? my_order_id = unfinishedModels[index].my_order_id;
                                                                                    String my_order_status = 'true';
                                                                                    String apiUpdateStatusMyOrder = '${MyConstant.domain}/famfam/updateStatusMyOrder.php?isAdd=true&my_order_id=$my_order_id&my_order_status=$my_order_status';
                                                                                    await Dio().get(apiUpdateStatusMyOrder).then((value) async {
                                                                                      Navigator.pop(context);
                                                                                      await Navigator.push(context, MaterialPageRoute(builder: (context) => TodoBody(tabSelected: tabController!.index)));
                                                                                    });
                                                                                  }
                                                                                }
                                                                              },
                                                                              child: Container(),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }),
                                                                  ),
                                                                  const VerticalDivider(
                                                                    width: 20,
                                                                    thickness:
                                                                        1.5,
                                                                    indent: 5,
                                                                    endIndent:
                                                                        5,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              3,
                                                                              10,
                                                                              0),
                                                                      child:
                                                                          RaisedButton(
                                                                        color:
                                                                            Color(
                                                                          0xfffFFC34A,
                                                                        ),
                                                                        elevation:
                                                                            0,
                                                                        hoverElevation:
                                                                            0,
                                                                        focusElevation:
                                                                            0,
                                                                        highlightElevation:
                                                                            0,
                                                                        onPressed:
                                                                            () {
                                                                          descDialog(
                                                                              context,
                                                                              unfinishedModels[index].my_order_topic,
                                                                              unfinishedModels[index].my_order_desc);
                                                                        },
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              CheckMe(index, unfinishedModels),
                                                                              SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Text(
                                                                                '${unfinishedModels[index].my_order_topic}',
                                                                                style: TextStyle(
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              0,
                                                                              5,
                                                                              5,
                                                                              5),
                                                                      child:
                                                                          CircleAvatar(
                                                                        radius:
                                                                            25,
                                                                        backgroundImage:
                                                                            NetworkImage(unfinishedModels[index].employee_profile),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ),
                                  ),
                                  Container(
                                    child: finishedModels.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Container(
                                              //height: 100,
                                              //width: 100,
                                              decoration: BoxDecoration(
                                                  //color: Colors.pink.shade700,
                                                  //borderRadius: BorderRadius.circular(30),
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  SvgPicture.asset(
                                                    "assets/icons/leaf-fall.svg",
                                                    height: 85,
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                  ),
                                                  SizedBox(
                                                    height: 1,
                                                  ),
                                                  Text(
                                                    "You don't have any list right now.",
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            child: ListView.builder(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                itemCount:
                                                    finishedModels.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Container(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 80,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  bottom: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Color(
                                                                0xfffFFC34A),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    10,
                                                                    10,
                                                                    10,
                                                                    10),
                                                            child: Row(
                                                              // mainAxisAlignment:
                                                              //     MainAxisAlignment
                                                              //         .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 6,
                                                                      right: 2),
                                                                  child: Builder(builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return Container(
                                                                      width: 40,
                                                                      height:
                                                                          40,
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          RoundCheckBox(
                                                                              isChecked: true,
                                                                              onTap: null),
                                                                          FlatButton(
                                                                            shape: RoundedRectangleBorder(
                                                                                side: BorderSide(
                                                                                  color: Colors.transparent,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(50)),
                                                                            onPressed:
                                                                                () {
                                                                              {
                                                                                // ติ๊กถูก
                                                                                Fluttertoast.showToast(msg: "You have finish this assignment already.", gravity: ToastGravity.BOTTOM);
                                                                              }
                                                                            },
                                                                            child:
                                                                                Container(),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }),
                                                                ),
                                                                const VerticalDivider(
                                                                  width: 20,
                                                                  thickness:
                                                                      1.5,
                                                                  indent: 5,
                                                                  endIndent: 5,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            3,
                                                                            10,
                                                                            0),
                                                                    child:
                                                                        RaisedButton(
                                                                      color:
                                                                          Color(
                                                                        0xfffFFC34A,
                                                                      ),
                                                                      elevation:
                                                                          0,
                                                                      hoverElevation:
                                                                          0,
                                                                      focusElevation:
                                                                          0,
                                                                      highlightElevation:
                                                                          0,
                                                                      onPressed:
                                                                          () {
                                                                        descDialog(
                                                                            context,
                                                                            finishedModels[index].my_order_topic,
                                                                            finishedModels[index].my_order_desc);
                                                                      },
                                                                      child:
                                                                          Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            CheckMe(index,
                                                                                finishedModels),
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Text(
                                                                              '${finishedModels[index].my_order_topic}',
                                                                              style: TextStyle(
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.normal,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            0,
                                                                            5,
                                                                            5,
                                                                            5),
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          25,
                                                                      backgroundImage:
                                                                          NetworkImage(
                                                                              finishedModels[index].employee_profile),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ),
                                  ),
                                  Container(
                                    child: myOrderModels.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Container(
                                              //height: 100,
                                              //width: 100,
                                              decoration: BoxDecoration(
                                                  //color: Colors.pink.shade700,
                                                  //borderRadius: BorderRadius.circular(30),
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  SvgPicture.asset(
                                                    "assets/icons/leaf-fall.svg",
                                                    height: 85,
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                  ),
                                                  SizedBox(
                                                    height: 1,
                                                  ),
                                                  Text(
                                                    "You don't have any list right now.",
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            child: ListView.builder(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                itemCount: myOrderModels.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Container(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 80,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  bottom: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Color(
                                                                0xfffFFC34A),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    10,
                                                                    10,
                                                                    10,
                                                                    10),
                                                            child: Row(
                                                                // mainAxisAlignment:
                                                                //     MainAxisAlignment
                                                                //         .spaceBetween,
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left: 6,
                                                                        right:
                                                                            2),
                                                                    child: Builder(builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      for (int i =
                                                                              0;
                                                                          myOrderChecked ==
                                                                              null;
                                                                          i++) {
                                                                        sleep(Duration(
                                                                            seconds:
                                                                                1));
                                                                      }
                                                                      if (myOrderChecked[
                                                                              index] ==
                                                                          true) {
                                                                        return Container(
                                                                          width:
                                                                              40,
                                                                          height:
                                                                              40,
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              RoundCheckBox(isChecked: true, onTap: null),
                                                                              FlatButton(
                                                                                shape: RoundedRectangleBorder(
                                                                                    side: BorderSide(
                                                                                      color: Colors.transparent,
                                                                                    ),
                                                                                    borderRadius: BorderRadius.circular(50)),
                                                                                onPressed: () {
                                                                                  {
                                                                                    // ติ๊กถูก
                                                                                    Fluttertoast.showToast(msg: "You have finish this assignment already.", gravity: ToastGravity.BOTTOM);
                                                                                  }
                                                                                },
                                                                                child: Container(),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Container(
                                                                          width:
                                                                              40,
                                                                          height:
                                                                              40,
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              RoundCheckBox(isChecked: false, onTap: null),
                                                                              FlatButton(
                                                                                color: Colors.white,
                                                                                shape: RoundedRectangleBorder(
                                                                                    side: BorderSide(
                                                                                      color: Colors.transparent,
                                                                                    ),
                                                                                    borderRadius: BorderRadius.circular(50)),
                                                                                onPressed: () async {
                                                                                  {
                                                                                    // ติ๊กถูก
                                                                                    if (userModels[0].id != myOrderModels[index].employee_id) {
                                                                                      Fluttertoast.showToast(msg: "You can't finish other people assignment.", gravity: ToastGravity.BOTTOM);
                                                                                    } else {
                                                                                      //ทำเสร็จไป UPDATE DATABASE
                                                                                      String? my_order_id = myOrderModels[index].my_order_id;
                                                                                      String my_order_status = 'true';
                                                                                      String apiUpdateStatusMyOrder = '${MyConstant.domain}/famfam/updateStatusMyOrder.php?isAdd=true&my_order_id=$my_order_id&my_order_status=$my_order_status';
                                                                                      await Dio().get(apiUpdateStatusMyOrder).then((value) async {
                                                                                        Navigator.pop(context);
                                                                                        await Navigator.push(context, MaterialPageRoute(builder: (context) => TodoBody(tabSelected: tabController!.index)));
                                                                                      });
                                                                                    }
                                                                                  }
                                                                                },
                                                                                child: Container(),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }
                                                                    }),
                                                                  ),
                                                                  const VerticalDivider(
                                                                    width: 20,
                                                                    thickness:
                                                                        1.5,
                                                                    indent: 5,
                                                                    endIndent:
                                                                        5,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              3,
                                                                              10,
                                                                              0),
                                                                      child:
                                                                          RaisedButton(
                                                                        color:
                                                                            Color(
                                                                          0xfffFFC34A,
                                                                        ),
                                                                        elevation:
                                                                            0,
                                                                        hoverElevation:
                                                                            0,
                                                                        focusElevation:
                                                                            0,
                                                                        highlightElevation:
                                                                            0,
                                                                        onPressed:
                                                                            () {
                                                                          descDialog(
                                                                              context,
                                                                              myOrderModels[index].my_order_topic,
                                                                              myOrderModels[index].my_order_desc);
                                                                        },
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              CheckMe(index, myOrderModels),
                                                                              SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Text(
                                                                                '${myOrderModels[index].my_order_topic}',
                                                                                style: TextStyle(
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              0,
                                                                              5,
                                                                              5,
                                                                              5),
                                                                      child:
                                                                          CircleAvatar(
                                                                        radius:
                                                                            25,
                                                                        backgroundImage:
                                                                            NetworkImage(myOrderModels[index].employee_profile),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          addMyOrder(size, context, tabController!.index),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text CheckMe(int index, List<MyOrdereModel> model) {
    for (int i = 0; userModels == null && myOrderModels == null; i++) {
      sleep(Duration(seconds: 1));
    }
    if (model[index].owner_id == userModels[0].id &&
        model[index].employee_id == userModels[0].id) {
      return Text(
        "Me to Myself",
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
        ),
      );
    } else if (model[index].owner_id == userModels[0].id &&
        model[index].employee_id != userModels[0].id) {
      return Text(
        "Me to ${model[index].employee_fname}",
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
        ),
      );
    } else {
      return Text(
        "${model[index].owner_fname} to Myself",
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
        ),
      );
    }
  }

  Container addMyOrder(Size size, BuildContext context, int tabSelected) {
    int selectedIndex = -1;
    return Container(
      width: size.width * 0.864,
      height: size.height * 0.066,

      //color: Colors.pink,
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Color(0xFFF9EE6D)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(90.0),
                ),
              ),
            ),
            child: Text(
              '+ Add List ',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            onPressed: () {
              showModalBottomSheet(
                  // isDismissible: false,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(62.0))),
                  backgroundColor: Color(0xFFFFFFFF),
                  context: context,
                  isScrollControlled: true,
                  enableDrag: false,
                  builder: (context) => StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: Container(
                                    height: size.height * 0.595,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          //color: hexToColor("#F1E5BA"),
                                          borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(66),
                                        topRight: Radius.circular(66),
                                      )),
                                      child: Column(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.center,

                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: <Widget>[
                                          SizedBox(height: 45),
                                          Center(
                                            child: Text(
                                              'Add List to Circle',
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          SizedBox(height: 30),
                                          Text(
                                            'Title',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              //color: Color(0xFFFFFFFF),
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.021),
                                          Container(
                                            //margin: EdgeInsets.only(top: 40),
                                            //width: size.width * 0.831,

                                            child: (Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(60),
                                                  boxShadow: [
                                                    const BoxShadow(
                                                      color: Colors.black,
                                                    ),
                                                  ]),
                                              child: (TextField(
                                                controller: titleController,
                                                style: TextStyle(
                                                    fontSize: 20, height: 1.5),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Color(0xFFF8F8F8),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 20),
                                                  //border: InputBorder.none,
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60.0),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFF9EE6D),
                                                        width: 2.0),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60.0),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFF9EE6D),
                                                        width: 2.0),
                                                  ),
                                                  hintText: 'Write the title',
                                                  hintStyle: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )),
                                            )),
                                          ),
                                          SizedBox(height: size.height * 0.021),
                                          Container(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text("Description",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.021),
                                                  Container(
                                                    // width: size.width * 0.58,
                                                    // height:
                                                    //     size.height * 0.054,
                                                    child: (TextField(
                                                      controller:
                                                          descController,
                                                      textAlignVertical:
                                                          TextAlignVertical.top,
                                                      keyboardType:
                                                          TextInputType
                                                              .multiline,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          height: 1.5),
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor:
                                                            Color(0xFFF8F8F8),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        20),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      60.0),
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFF9EE6D),
                                                              width: 2.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      60.0),
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFF9EE6D),
                                                              width: 2.0),
                                                        ),
                                                        hintText:
                                                            'Write the description',
                                                        hintStyle: TextStyle(
                                                          fontSize: 20.0,
                                                        ),
                                                      ),
                                                    )),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.028),
                                                  Text(
                                                    'Who',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      //color: Color(0xFFFFFFFF),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                  Container(
                                                    height: 50,
                                                    child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount:
                                                            employeeModels
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          onSelected(
                                                              int index) {
                                                            setState(() {
                                                              selectedIndex =
                                                                  index;
                                                            });
                                                          }

                                                          return GestureDetector(
                                                            onTap: () {
                                                              onSelected(index);
                                                              print(
                                                                  'selectedIndex: $selectedIndex');
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 10),
                                                              child:
                                                                  CircleAvatar(
                                                                radius: 25,
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        employeeModels[index]
                                                                            .profileImage),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 25,
                                                                  backgroundColor: selectedIndex ==
                                                                          index
                                                                      ? Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.6)
                                                                      : Colors
                                                                          .transparent,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                  SizedBox(
                                                    height: 11,
                                                  ),
                                                  Center(
                                                    child: Container(
                                                      width: 208,
                                                      height: 60,
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(Color(
                                                                      0xFFF9EE6D)),
                                                          shape:
                                                              MaterialStateProperty
                                                                  .all(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          90.0),
                                                            ),
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          if (titleController
                                                                  .text ==
                                                              '') {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Please insert title.",
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM);
                                                          } else if (descController
                                                                  .text ==
                                                              '') {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Please insert description.",
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM);
                                                          } else if (selectedIndex ==
                                                              -1) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Please select some member.",
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM);
                                                          } else {
                                                            SharedPreferences
                                                                preferences =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            String? circle_id =
                                                                preferences
                                                                    .getString(
                                                                        'circle_id');
                                                            String? owner_id =
                                                                userModels[0]
                                                                    .id;
                                                            String?
                                                                owner_fname =
                                                                userModels[0]
                                                                    .fname;
                                                            String?
                                                                employee_id =
                                                                employeeModels[
                                                                        selectedIndex]
                                                                    .id;
                                                            String?
                                                                employee_profile =
                                                                Uri.encodeComponent(
                                                                    employeeModels[
                                                                            selectedIndex]
                                                                        .profileImage);
                                                            String?
                                                                employee_fname =
                                                                employeeModels[
                                                                        selectedIndex]
                                                                    .fname;
                                                            String
                                                                my_order_topic =
                                                                titleController
                                                                    .text;
                                                            String
                                                                my_order_desc =
                                                                descController
                                                                    .text;
                                                            String
                                                                my_order_status =
                                                                'false';
                                                            String
                                                                apiInsertMyOrder =
                                                                '${MyConstant.domain}/famfam/insertMyOrder.php?isAdd=true&circle_id=$circle_id&owner_id=$owner_id&owner_fname=$owner_fname&employee_id=$employee_id&employee_profile=$employee_profile&employee_fname=$employee_fname&my_order_topic=$my_order_topic&my_order_desc=$my_order_desc&my_order_status=$my_order_status';
                                                            await Dio()
                                                                .get(
                                                                    apiInsertMyOrder)
                                                                .then(
                                                                    (value) async {
                                                              Navigator.pop(
                                                                  context);
                                                              await Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          TodoBody(
                                                                              tabSelected: tabSelected)));
                                                            });
                                                          }
                                                        },
                                                        child: Text(
                                                          "Confirm",
                                                          style: TextStyle(
                                                              fontSize: 21,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ]),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        );
                      })).whenComplete(() {
                setState(() {});
              });
            });
      }),
    );
  }
}

class TickBody extends StatefulWidget {
  const TickBody({Key? key}) : super(key: key);

  @override
  State<TickBody> createState() => _TickBodyState();
}

List<UserModel> userModels = [];
List<CircleModel> circleModels = [];
List<ticktick_Model> tempticktick = [];

class List_showModel {
  final String topic;
  final String topic_id;
  final bool fav;
  List_showModel(this.topic, this.topic_id, this.fav);
}

class Product {
  final String product_name;
  final String product_id;
  Product(this.product_name, this.product_id);
}

class _TickBodyState extends State<TickBody> {
  List<List_showModel> listshow = [];
  List<Product> products = [];
  List<List_showModel> list_topic = [];
  List<Product> list_product = [];
  int count_ticktickUid = 0;
  List<ticktick_Model> ticktick_Models = [];

  @override
  void initState() {
    super.initState();
    pullUserSQLID().then((value) => pullCircle().then((value) {}));
  }

  Future<Null> pullUserSQLID() async {
    final String getUID = FirebaseAuth.instance.currentUser!.uid.toString();
    String uid = getUID;
    print('#### uid ' + getUID);
    String pullUser =
        '${MyConstant.domain}/famfam/getUserWhereUID.php?uid=$uid&isAdd=true';
    await Dio().get(pullUser).then((value) async {
      if (value.toString() == null ||
          value.toString() == 'null' ||
          value.toString() == '') {
        FirebaseAuth.instance.signOut();
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.clear();
      } else {
        for (var item in json.decode(value.data)) {
          UserModel model = UserModel.fromMap(item);
          print(item);
          setState(() {
            userModels.add(model);
          });
        }
      }
    });
  }

  Future<Null> pullCircle() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? circle_id = preferences.getString('circle_id');
    String? member_id = userModels[0].id;

    String pullCircle =
        '${MyConstant.domain}/famfam/getCircleWhereCircleIDuserID.php?isAdd=true&circle_id=$circle_id&member_id=$member_id';
    await Dio().get(pullCircle).then((value) async {
      for (var item in json.decode(value.data)) {
        CircleModel model = CircleModel.fromMap(item);
        setState(() {
          circleModels.add(model);
        });
      }
    });
    await pullDataTicktick(circle_id: circle_id, member_id: member_id);
    try {
      addDatafromstart();
    } catch (e) {}
  }

  Future<Null> pullDataTicktick({String? circle_id, String? member_id}) async {
    count_ticktickUid = 0;
    // print('#### circle_id ' + '${circle_id}');
    // print('#### member_id ' + '${member_id}');
    String pullData =
        '${MyConstant.domain}/famfam/getTickTickWhereCircleID.php?isAdd=true&circle_id=$circle_id';
    try {
      await Dio().get(pullData).then((value) async {
        for (var item in json.decode(value.data)) {
          ticktick_Model ticktick_models = ticktick_Model.fromMap(item);
          print(item);
          setState(() {
            count_ticktickUid = count_ticktickUid + 1;
            ticktick_Models.add(ticktick_models);
          });
        }
      });
    } catch (e) {}

    print('count_ticktickuid : ' + '$count_ticktickUid');
  }

  Future<Null> addDatafromstart() async {
    int num = 1;
    var arr = [];
    for (int i = 0; i <= count_ticktickUid; i++) {
      if (i == count_ticktickUid - 1) {
        String topic = ticktick_Models[i].tick_topic;
        arr.insert(0, ticktick_Models[i].ticklist_list);
        String? product = ticktick_Models[i].ticklist_list;
        String? product_id = ticktick_Models[i].tick_id;
        bool fav;
        if (ticktick_Models[i].fav_topic == 'true') {
          fav = true;
        } else {
          fav = false;
        }

        String? id = ticktick_Models[i].tick_id;
        // print('id :' + '${id}');
        // print('topic :' + topic);
        // print('list : ' + '$arr');
        // print('num : ' + '$num');

        setState(() {
          list_topic.add(List_showModel(topic, id!, fav));
          list_product.add(Product(product, product_id!));
        });
        // print(list_topic);
        break;
      }
      if (ticktick_Models[i].tick_uid == ticktick_Models[i + 1].tick_uid) {
        // print('## i : ' + ticktick_Models[i].tick_uid);
        // print('## i+1 : ' + ticktick_Models[i + 1].tick_uid);
        String? product = ticktick_Models[i].ticklist_list;
        String? product_id = ticktick_Models[i].tick_id;
        arr.insert(0, product);
        setState(() {
          list_product.add(Product(product, product_id!));
        });
        num = num + 1;
      } else {
        String topic = ticktick_Models[i].tick_topic;
        // print(i);
        String? product = ticktick_Models[i].ticklist_list;
        String? product_id = ticktick_Models[i].tick_id;
        arr.insert(0, ticktick_Models[i].ticklist_list);
        String? id = ticktick_Models[i].tick_id;
        bool fav;
        if (ticktick_Models[i].fav_topic == 'true') {
          fav = true;
        } else {
          fav = false;
        }
        // print('id :' + '${id}');
        // print('topic :' + topic);
        // print('list : ' + '$arr');
        // print('num : ' + '$num');
        setState(() {
          list_topic.add(List_showModel(topic, id!, fav));
          list_product.add(Product(product, product_id!));
        });
        arr = [];
        num = 1;
      }
    }
  }

  Future<Null> deletedlistByIDandName(
      {String? product_id, String? product_name}) async {
    String deletedDataList =
        '${MyConstant.domain}/famfam/deleteTickTickList.php?isAdd=true&tick_id=$product_id&ticklist_list=$product_name';
    await Dio().get(deletedDataList).then((value) {
      if (value.toString() == 'true') {
        print('Deleted List By ID Successed');
      }
    });
  }

  void onDismissed(String product_name, String product_id) {
    int checkEmpty = 0;
    setState(() {
      list_product.removeWhere((item) =>
          item.product_name == '$product_name' &&
          item.product_id == '$product_id');
      deletedlistByIDandName(
          product_id: product_id, product_name: product_name);

      print('deleted list successed');

      for (int i = 0; i < list_product.length; i++) {
        if (list_product[i].product_id == product_id) {
          checkEmpty = checkEmpty + 1;
          print(checkEmpty);
        }
      }
    });
    if (checkEmpty == 0) {
      print(checkEmpty);
      setState(() {
        list_topic.removeWhere((item) => item.topic_id == '$product_id');
        print('deleted topic successed');
      });
    }
  }

  Future<Null> updateFav({String? fav_topic, String? tick_id}) async {
    print('fav_topic $fav_topic');
    print('id $tick_id');
    String updateDataFav =
        '${MyConstant.domain}/famfam/updateFavTickTick.php?isAdd=true&fav_topic=$fav_topic&tick_id=$tick_id';
    await Dio().get(updateDataFav).then((value) {
      // if (value.toString() == 'true') {
      print('Updated Fav By ID Successed');
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Stack(
        children: [
          Text(""),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(55.0),
              child: AppBar(
                title: Text(
                  'All TickTic',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    var user = FirebaseAuth.instance.currentUser;
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(user),
                      ),
                    );
                    // (Route<dynamic> route) => false);
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/chevron-back-outline.svg",
                    height: 35,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/information-_1_.svg",
                      height: 30,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: Container(
                      width: 368,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5.0,
                            offset: Offset(0, 3),
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(-5, 0),
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(5, 0),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.search_sharp,
                            color: Color(0xFFFFC34A),
                          ),
                          hintText: "Search TickTic",
                          border: InputBorder.none,
                          // hintStyle: TextStyle(
                          //   color: Colors.black,
                          // ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: SizedBox(
                      height: 640,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Container(
                            //height: 100,
                            //width: 100,
                            decoration: BoxDecoration(
                                //color: Colors.pink.shade700,
                                //borderRadius: BorderRadius.circular(30),
                                ),
                            child: Container(
                                child: (list_topic.isEmpty)
                                    ? Column(children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    8)),
                                        Container(
                                          child: SvgPicture.asset(
                                            "assets/icons/leaf-fall.svg",
                                            height: 85,
                                            color:
                                                Colors.black.withOpacity(0.4),
                                          ),
                                        ),
                                        Text(
                                          "You don't have any list right now",
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w500),
                                        )
                                      ])
                                    : Expanded(
                                        child: ListView.builder(
                                            padding: const EdgeInsets.all(8),
                                            itemCount: list_topic.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              // return buildTickTick(
                                              //     list_topic[index].topic,
                                              //     list_topic[index].fav,
                                              //     list_topic[index].topic_id);

                                              return Container(
                                                  height: 150,
                                                  margin: EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Color(0xfffFFC34A),
                                                    // color: Colors.white,
                                                  ),
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            // ListTile(
                                                            //   title: Text('hi'),
                                                            // ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 15,
                                                                      top: 15),
                                                              child: Text(
                                                                  '${list_topic[index].topic}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                            // Text(
                                                            //     '${list_topic[index].fav}'),
                                                            Spacer(),

                                                            Container(
                                                              child: IconButton(
                                                                  iconSize: 22,
                                                                  icon: Icon(
                                                                    Icons
                                                                        .favorite,
                                                                  ),
                                                                  color: list_topic[
                                                                              index]
                                                                          .fav
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white,
                                                                  onPressed:
                                                                      () async {
                                                                    // bool
                                                                    //     isChecked =
                                                                    //     false;
                                                                    if (list_topic[
                                                                            index]
                                                                        .fav) {
                                                                      String
                                                                          fav_topic =
                                                                          'false';
                                                                      String
                                                                          updateDataFav =
                                                                          '${MyConstant.domain}/famfam/updateFavTickTick.php?isAdd=true&fav_topic=$fav_topic&tick_id=${list_topic[index].topic_id}';
                                                                      await Dio()
                                                                          .get(
                                                                              updateDataFav)
                                                                          .then(
                                                                              (value) {
                                                                        // if (value.toString() == 'true') {
                                                                        print(
                                                                            'Updated Fav By ID Successed change true to false');
                                                                        // }

                                                                        Navigator
                                                                            .pushReplacement(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                TickTikScreen(),
                                                                          ),
                                                                        );
                                                                      });
                                                                    } else {
                                                                      String
                                                                          fav_topic =
                                                                          'true';

                                                                      String
                                                                          updateDataFav =
                                                                          '${MyConstant.domain}/famfam/updateFavTickTick.php?isAdd=true&fav_topic=$fav_topic&tick_id=${list_topic[index].topic_id}';
                                                                      await Dio()
                                                                          .get(
                                                                              updateDataFav)
                                                                          .then(
                                                                              (value) {
                                                                        // if (value.toString() == 'true') {
                                                                        print(
                                                                            'Updated Fav By ID Successed change false to true');
                                                                        // }

                                                                        Navigator
                                                                            .pushReplacement(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                TickTikScreen(),
                                                                          ),
                                                                        );
                                                                      });
                                                                      // updateFav(
                                                                      //     fav_topic:
                                                                      //         fav_topic,
                                                                      //     tick_id:
                                                                      //         list_topic[index].topic_id);
                                                                    }
                                                                    // setState(
                                                                    //     () {
                                                                    //   // print(list_topic[
                                                                    //   //         index]
                                                                    //   //     .fav);
                                                                    //   // print(list_topic[
                                                                    //   //         index]
                                                                    //   //     .topic);
                                                                    // });
                                                                  }),
                                                            ),

                                                            // Container(
                                                            //   margin: EdgeInsets
                                                            //       .only(
                                                            //           top: 15,
                                                            //           right:
                                                            //               15),
                                                            //   child:
                                                            //       FavoriteButton(
                                                            //     iconSize: 30,
                                                            //     iconDisabledColor:
                                                            //         Colors
                                                            //             .white,
                                                            //     valueChanged:
                                                            //         (_isFavorite) {
                                                            //       print(
                                                            //           'Is Favorite $_isFavorite ${list_topic[index].topic_id}');
                                                            //       // updateFav(
                                                            //       //     fav_topic:
                                                            //       //         fav_topic,
                                                            //       //     tick_id:
                                                            //       //         list_topic[index].topic_id);
                                                            //     },
                                                            //   ),
                                                            // ),
                                                          ],
                                                        ),
                                                        Expanded(
                                                            child: ListView
                                                                .builder(
                                                                    scrollDirection:
                                                                        Axis
                                                                            .horizontal,
                                                                    itemCount:
                                                                        list_product
                                                                            .length,
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index2) {
                                                                      if (list_topic[index]
                                                                              .topic_id ==
                                                                          list_product[index2]
                                                                              .product_id) {}
                                                                      return Container(
                                                                          child: (list_topic[index].topic_id == list_product[index2].product_id)
                                                                              ? Wrap(children: <Widget>[
                                                                                  Container(
                                                                                      margin: EdgeInsets.only(left: 15, top: 20),
                                                                                      child: Row(children: [
                                                                                        Container(
                                                                                          child: RoundCheckBox(
                                                                                            size: 22,
                                                                                            uncheckedColor: Colors.white,
                                                                                            checkedColor: Colors.green,
                                                                                            onTap: (selected) {
                                                                                              print('selected ' + list_product[index2].product_id);
                                                                                              print('selected ' + list_product[index2].product_name);

                                                                                              onDismissed(list_product[index2].product_name, list_product[index2].product_id);
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(right: 10, left: 10),
                                                                                          child: Text('${list_product[index2].product_name}'),
                                                                                        )
                                                                                      ]))
                                                                                ])
                                                                              : SizedBox.shrink());
                                                                    }))
                                                      ]));
                                            })))),
                      ),
                    ),
                  ),
                  TicBotSheet(size: size),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TicBotSheet extends StatefulWidget {
  final Size size;

  TicBotSheet({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  State<TicBotSheet> createState() => _TicBotSheetState();
}

class _TicBotSheetState extends State<TicBotSheet> {
  final _TickBodyState pulldata = new _TickBodyState();

  Future<Null> insertTickTick({String? topic, List<String>? arr}) async {
    var uuid = Uuid();

    String tick_uid = uuid.v1();
    String member_id = userModels[0].id!;
    String circle_id = circleModels[0].circle_id!;

    String? tick_id;

    String ticklist = arr![0];
    String insertTicklistData =
        '${MyConstant.domain}/famfam/insertTickTick.php?isAdd=true&tick_uid=$tick_uid&circle_id=$circle_id&user_id=$member_id&tick_topic=$topic&ticklist_list=$ticklist&fav_topic=false';
    await Dio().get(insertTicklistData).then((value) async {
      print('push');

      String pullDataticktick =
          '${MyConstant.domain}/famfam/getTickTickWhereUID.php?isAdd=true&tick_uid=$tick_uid';
      await Dio().get(pullDataticktick).then((value) async {
        for (var item in json.decode(value.data)) {
          ticktick_Model model = ticktick_Model.fromMap(item);

          setState(() {
            tempticktick.add(model);
            tick_id = model.tick_id;
          });
        }
        // restartListshow.restartListShowTopic(topic!, tick_id!);
        // restartListshow.restartListShowProduct(tick_id!, ticklist);
      }).then((value) async {
        int i = 1;
        print(tick_id);
        for (i; i < arr.length; i++) {
          print('i = ' + '$i');
          String ticklist = arr[i];
          String insertTicklistData =
              '${MyConstant.domain}/famfam/insertTickTickWithID.php?isAdd=true&user_id=$member_id&tick_topic=$topic&ticklist_list=$ticklist&circle_id=$circle_id&tick_uid=$tick_uid&tick_id=$tick_id&fav_topic=false';
          await Dio().get(insertTicklistData);

          // restartListshow.restartListShowProduct(tick_id!, ticklist);
        }
      });
      print('inserted ticklist successed');
      // pulldata.pullDataTicktick();
      // pulldata.addDatafromstart();
      // restartListshow.restartListShow(topic!, tick_id!, ticklist, tick_id!);
    });
  }

  final TextEditingController topicController = TextEditingController();
  final TextEditingController listController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.size.width * 0.864,
          height: widget.size.height * 0.066,

          //color: Colors.pink,

          child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFFF9EE6D)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90.0),
                  ),
                ),
              ),
              child: Text(
                '+ Add TickTic ',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              onPressed: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(62.0))),
                    backgroundColor: Color(0xFFFFFFFF),
                    context: context,
                    isScrollControlled: true,
                    enableDrag: false,
                    builder: (context) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: Container(
                                    height: widget.size.height * 0.595,
                                    child: Container(
                                      width: widget.size.width * 0.84,
                                      decoration: BoxDecoration(
                                          //color: hexToColor("#F1E5BA"),
                                          borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(66),
                                        topRight: Radius.circular(66),
                                      )),
                                      child: Column(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 45),
                                          Center(
                                            child: Text(
                                              'Add TickTic to Circle',
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          SizedBox(height: 30),
                                          Text(
                                            'Topic',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  widget.size.height * 0.021),
                                          Container(
                                            //margin: EdgeInsets.only(top: 40),
                                            //width: size.width * 0.831,

                                            child: (Container(
                                              decoration: BoxDecoration(
                                                //color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                // boxShadow: [
                                                //   const BoxShadow(
                                                //     color: Colors.black,
                                                //   ),
                                                // ]
                                              ),
                                              child: (TextField(
                                                style: TextStyle(
                                                    fontSize: 20, height: 1.5),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 20),
                                                  //border: InputBorder.none,
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            23.0),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFF9EE6D),
                                                        width: 2.0),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            23.0),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFF9EE6D),
                                                        width: 2.0),
                                                  ),
                                                  hintText: 'Ex. Shopping',
                                                  hintStyle: TextStyle(
                                                    fontSize: 20.0,
                                                  ),
                                                ),
                                                controller: topicController,
                                              )),
                                            )),
                                          ),
                                          SizedBox(
                                              height:
                                                  widget.size.height * 0.021),
                                          Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Listing",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                SizedBox(
                                                    height: widget.size.height *
                                                        0.021),
                                                Container(
                                                  child: (TextField(
                                                    textAlignVertical:
                                                        TextAlignVertical.top,
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        height: 1.5),
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      // contentPadding:
                                                      //     EdgeInsets.symmetric(
                                                      //         vertical: 10,
                                                      //         horizontal: 20),

                                                      //border: InputBorder.none,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30.0),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFF9EE6D),
                                                            width: 2.0),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30.0),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFF9EE6D),
                                                            width: 2.0),
                                                      ),
                                                      hintText:
                                                          'Ex. มาม่า, สบู่, ไข่, นม',
                                                      hintStyle: TextStyle(
                                                        fontSize: 20.0,
                                                      ),
                                                    ),
                                                    controller: listController,
                                                  )),
                                                ),
                                                SizedBox(
                                                    height: widget.size.height *
                                                        0.04),
                                                Center(
                                                    child: Container(
                                                  width: 208,
                                                  height: 60,
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Color(
                                                                  0xFFF9EE6D)),
                                                      shape:
                                                          MaterialStateProperty
                                                              .all(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      90.0),
                                                        ),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      print('##Topic : ' +
                                                          topicController.text);
                                                      print('##List : ' +
                                                          listController.text);
                                                      var list_text =
                                                          listController.text;
                                                      var arr =
                                                          list_text.split(",");
                                                      print(arr.length);
                                                      await insertTickTick(
                                                          topic: topicController
                                                              .text,
                                                          arr: arr);
                                                      Navigator.pop(context);
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              TickTikScreen(),
                                                        ),
                                                      );

                                                      listController.text = '';
                                                      topicController.text = '';
                                                    },
                                                    child: Text(
                                                      "Confirm",
                                                      style: TextStyle(
                                                          fontSize: 21,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ));
              }),
        )
      ],
    );
  }
}

class VoteRandomBody extends StatefulWidget {
  const VoteRandomBody({Key? key}) : super(key: key);

  @override
  _VoteRandomBodyState createState() => _VoteRandomBodyState();
}

class _VoteRandomBodyState extends State<VoteRandomBody> {
  List<UserModel> userModels = [];

  final List<String> topicPoll = <String>[];
  List<randomModel> topicRandom = [];
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    pullAllRandom();
  }

  Future<Null> pullAllRandom() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? circle_id = preferences.getString('circle_id');
    String pullAllRandom =
        '${MyConstant.domain}/famfam/getRandomAll.php?isAdd=true&circle_id=$circle_id';
    try {
      await Dio().get(pullAllRandom).then((value) async {
        for (var item in json.decode(value.data)) {
          randomModel model = randomModel.fromMap(item);
          setState(() {
            topicRandom.add(model);
          });
        }
      });
    } catch (e) {}
  }

  // String polltopic;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Stack(
          children: [
            Text(""),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: AppBar(
                  leading: Transform.translate(
                    offset: Offset(0, 12),
                    child: IconButton(
                      icon: Icon(
                        Icons.navigate_before_rounded,
                        color: Colors.black,
                        size: 40,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(user)));
                      },
                    ),
                  ),
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  title: Transform.translate(
                    offset: Offset(0, 12),
                    child: Text(
                      "Vote & Random",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 29, right: 29),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF9EE6D).withOpacity(0.44),
                              borderRadius: BorderRadius.circular(19),
                            ),
                            height: 66,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TabBar(
                                indicator: BoxDecoration(
                                  color: Color(0xFFFFC34A),
                                  borderRadius: BorderRadius.circular(19),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.grey.shade400,
                                  //     blurRadius: 5.0,
                                  //     offset: Offset(0, 3),
                                  //   ),
                                  // ],
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700,
                                ),
                                unselectedLabelStyle: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400),
                                labelColor: Colors.black87,
                                unselectedLabelColor: Color(0xFFA5A59D),
                                tabs: [
                                  Tab(text: 'Vote'),
                                  Tab(text: 'Random'),
                                ],
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            child: SizedBox(
                              height: 640,
                              child: TabBarView(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height,
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 560,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.864,
                                          decoration: BoxDecoration(
                                              // color: Colors.pink.shade200,
                                              //borderRadius: BorderRadius.circular(30),
                                              ),
                                          child: Builder(builder: (context) {
                                            return topicPoll.isEmpty
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      SvgPicture.asset(
                                                        "assets/icons/leaf-fall.svg",
                                                        height: 85,
                                                        color: Colors.black
                                                            .withOpacity(0.4),
                                                      ),
                                                      SizedBox(
                                                        height: 1,
                                                      ),
                                                      Text(
                                                        "No POLL is going on right now.",
                                                        style: TextStyle(
                                                          color: Colors.black
                                                              .withOpacity(0.5),
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : ListView.builder(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    shrinkWrap: true,
                                                    itemCount: topicPoll.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text('bruh');
                                                    },
                                                  );
                                          }),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.66,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.864,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Color(0xFFF9EE6D)),
                                                  shape:
                                                      MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              90.0),
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Create poll',
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                                onPressed: () {
                                                  openDialogPoll(context);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height,
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 560,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.864,
                                          decoration: BoxDecoration(
                                              // color: Colors.pink.shade200,
                                              //borderRadius: BorderRadius.circular(30),
                                              ),
                                          child: Builder(builder: (context) {
                                            return topicRandom.isEmpty
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      SvgPicture.asset(
                                                        "assets/icons/leaf-fall.svg",
                                                        height: 85,
                                                        color: Colors.black
                                                            .withOpacity(0.4),
                                                      ),
                                                      SizedBox(
                                                        height: 1,
                                                      ),
                                                      Text(
                                                        "No RANDOM is going on right now.",
                                                        style: TextStyle(
                                                          color: Colors.black
                                                              .withOpacity(0.5),
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : ListView.builder(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        topicRandom.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Container(
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                                height: 180,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            10),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            249,
                                                                            234,
                                                                            184),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Color.fromARGB(
                                                                              138,
                                                                              209,
                                                                              209,
                                                                              209),
                                                                          offset: Offset(
                                                                              1,
                                                                              -1),
                                                                          blurRadius:
                                                                              10),
                                                                      BoxShadow(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              255,
                                                                              255),
                                                                          offset: Offset(
                                                                              -5,
                                                                              -5),
                                                                          blurRadius:
                                                                              5),
                                                                    ]),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          10,
                                                                          10),
                                                                  child: Row(
                                                                      // mainAxisAlignment:
                                                                      //     MainAxisAlignment
                                                                      //         .spaceBetween,
                                                                      children: <
                                                                          Widget>[
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(
                                                                            left:
                                                                                6,
                                                                            right:
                                                                                2,
                                                                          ),
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              width: 341,
                                                                              child: Row(
                                                                                // mainAxisAlignment: MainAxisAlignment.,
                                                                                children: [
                                                                                  Align(
                                                                                    alignment: Alignment.topRight,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.fromLTRB(0, 18, 5, 5),
                                                                                      child: CircleAvatar(
                                                                                        radius: 28,
                                                                                        backgroundImage: NetworkImage(topicRandom[index].user_profile),
                                                                                        // child: Image.network(
                                                                                        //   // "assets/images/new-mia.png",
                                                                                        //   topicRandom[index].user_profile,
                                                                                        //   fit: BoxFit.cover,
                                                                                        // ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 5, top: 10),
                                                                                    child: Container(
                                                                                      width: 230,
                                                                                      child: Text(
                                                                                        topicRandom[index].random_topic,
                                                                                        maxLines: 2,
                                                                                        overflow: TextOverflow.ellipsis,

                                                                                        // "ข้าวเย็นกินไรดีนะ",
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontSize: 17,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Align(
                                                                                      alignment: Alignment.topRight,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(bottom: 30),
                                                                                        child: PopUpMen(
                                                                                          menuList: [
                                                                                            PopupMenuItem(
                                                                                              child: ListTile(
                                                                                                leading: Icon(
                                                                                                  Icons.delete_rounded,
                                                                                                ),
                                                                                                title: Text("Delete"),
                                                                                                onTap: () {
                                                                                                  print('## You Click Delete form index = $index');
                                                                                                  confirmDialogDelete(context, topicRandom[index]);
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                          icon: SvgPicture.asset(
                                                                                            "assets/icons/menu-dots.svg",
                                                                                            height: 20,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 15,
                                                                            ),
                                                                            Text(
                                                                              "Result:",
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 16,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              height: 40,
                                                                              width: size.width / 1.3,
                                                                              margin: EdgeInsets.only(top: 7),
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                                color: Color.fromARGB(255, 255, 255, 255),
                                                                              ),
                                                                              child: Center(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(bottom: 5),
                                                                                  child: Text(
                                                                                    topicRandom[index].random_final,

                                                                                    // "กระเพาหมูกรอบ",
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontSize: 18,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ]),
                                                                )),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                          }),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.66,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.864,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Color(0xFFF9EE6D)),
                                                  shape:
                                                      MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              90.0),
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Create Random',
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                                onPressed: () {
                                                  openDialogRandom(context);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Null> confirmDialogDelete(
    BuildContext context, randomModel topicRandom) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Are you sure you want to delete this random?'),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
      content: Row(
        children: [
          Expanded(
            child: FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: FlatButton(
              onPressed: () async {
                String? random_id = topicRandom.random_id;
                String deleteRandom =
                    '${MyConstant.domain}/famfam/deleteRandomWhereRandomID.php?isAdd=true&random_id=$random_id';

                await Dio().get(deleteRandom).then((value) async {
                  Navigator.pop(context);
                  await Navigator.pushReplacementNamed(
                      context, ('/voterandom'));
                });
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Color(0xFFFFC34A), fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class PopUpMen extends StatefulWidget {
  final List<PopupMenuEntry> menuList;
  final Widget? icon;

  const PopUpMen({Key? key, required this.menuList, this.icon})
      : super(key: key);

  @override
  State<PopUpMen> createState() => _PopUpMenState();
}

class _PopUpMenState extends State<PopUpMen> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: ((context) => widget.menuList),
      icon: widget.icon,
    );
  }
}

Future openDialogPoll(BuildContext context) => showDialog(
    context: context,
    builder: (context) {
      bool check123 = false, check1234 = false;
      TextEditingController topicController = TextEditingController();
      TextEditingController option1Controller = TextEditingController();
      TextEditingController option2Controller = TextEditingController();
      TextEditingController option3Controller = TextEditingController();
      TextEditingController option4Controller = TextEditingController();
      TextEditingController option5Controller = TextEditingController();
      return StatefulBuilder(builder: (context, setState) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: [
                      Center(
                        child: Text(
                          'Create Poll',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: -6,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: CircleAvatar(
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 30,
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Topic',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Start -- TextField Topic
                  TextFormField(
                    controller: topicController,
                    minLines: 3,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 20, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Enter a poll question',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      //border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 190, 190, 186),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide:
                            BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                      ),
                    ),
                  ),
                  // End -- TextField Topic

                  SizedBox(height: 20),
                  // Text(
                  //   'Options',
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.black,
                  //   ),
                  // ),
                  // SizedBox(height: 10),

                  // Start -- TextField Option 1
                  TextFormField(
                    onChanged: (value) {
                      if (value.isNotEmpty &&
                          option2Controller.text.isNotEmpty &&
                          option3Controller.text.isNotEmpty) {
                        setState(
                          () {
                            check123 = true;
                          },
                        );
                      } else {
                        setState(
                          () {
                            check123 = false;
                          },
                        );
                      }
                    },
                    controller: option1Controller,
                    minLines: 1,
                    maxLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 20, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Option 1',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      //border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 190, 190, 186),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide:
                            BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                      ),
                    ),
                  ),
                  // End -- TextField Option 1

                  SizedBox(height: 15),

                  // Start -- TextField Option 2
                  TextFormField(
                    onChanged: (value) {
                      if (option1Controller.text.isNotEmpty &&
                          value.isNotEmpty &&
                          option3Controller.text.isNotEmpty) {
                        setState(
                          () {
                            check123 = true;
                          },
                        );
                      } else {
                        setState(
                          () {
                            check123 = false;
                          },
                        );
                      }
                    },
                    controller: option2Controller,
                    minLines: 1,
                    maxLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 20, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Option 2',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      //border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 190, 190, 186),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide:
                            BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                      ),
                    ),
                  ),
                  // End -- TextField Option 2

                  SizedBox(height: 15),

                  // Start -- TextField Option 3
                  TextFormField(
                    onChanged: (value) {
                      if (option1Controller.text.isNotEmpty &&
                          option2Controller.text.isNotEmpty &&
                          value.isNotEmpty) {
                        setState(
                          () {
                            check123 = true;
                          },
                        );
                      } else {
                        setState(
                          () {
                            check123 = false;
                          },
                        );
                      }
                    },
                    controller: option3Controller,
                    minLines: 1,
                    maxLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 20, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Option 3',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      //border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 190, 190, 186),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide:
                            BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                      ),
                    ),
                  ),
                  // End -- TextField Option 3

                  SizedBox(height: 15),

                  // Start -- TextField Option 4
                  Visibility(
                    visible: check123,
                    child: TextFormField(
                      onChanged: (value) {
                        if (check123 == true && value != null) {
                          setState(
                            () {
                              check1234 = true;
                            },
                          );
                        } else {
                          setState(
                            () {
                              check1234 = false;
                            },
                          );
                        }
                      },
                      controller: option4Controller,
                      minLines: 1,
                      maxLines: 1,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(fontSize: 20, height: 1.5),
                      decoration: InputDecoration(
                        hintText: 'Option 4',
                        hintStyle: TextStyle(
                          fontSize: 20.0,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        //border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 190, 190, 186),
                              width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide:
                              BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  // End -- TextField Option 4

                  SizedBox(height: 15),

                  // Start -- TextField Option 5
                  Visibility(
                    visible: check1234,
                    child: TextFormField(
                      controller: option5Controller,
                      minLines: 1,
                      maxLines: 1,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(fontSize: 20, height: 1.5),
                      decoration: InputDecoration(
                        hintText: 'Option 5',
                        hintStyle: TextStyle(
                          fontSize: 20.0,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        //border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 190, 190, 186),
                              width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide:
                              BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  // End -- TextField Option 5

                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.066,
                        width: MediaQuery.of(context).size.width * 0.864,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFFF9EE6D)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(90.0),
                              ),
                            ),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          onPressed: () {
                            if (option1Controller.text != null) {
                              if (option2Controller != null) {
                                if (option3Controller != null) {}
                              }
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    });

Future openDialogRandom(BuildContext context) => showDialog(
    context: context,
    builder: (context) {
      List<UserModel> userModels = [];
      bool check123 = false, check1234 = false;
      TextEditingController topicController = TextEditingController();
      TextEditingController option1Controller = TextEditingController();
      TextEditingController option2Controller = TextEditingController();
      TextEditingController option3Controller = TextEditingController();
      TextEditingController option4Controller = TextEditingController();
      TextEditingController option5Controller = TextEditingController();

      return StatefulBuilder(builder: (context, setState) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: [
                      Center(
                        child: Text(
                          'Create Random',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: -6,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: CircleAvatar(
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 30,
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Topic',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Start -- TextField Topic
                  TextFormField(
                    controller: topicController,
                    minLines: 3,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 20, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Enter a random problem',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      //border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 190, 190, 186),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide:
                            BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                      ),
                    ),
                  ),
                  // End -- TextField Topic

                  SizedBox(height: 40),
                  // Text(
                  //   'Options',
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.black,
                  //   ),
                  // ),
                  // SizedBox(height: 10),

                  // Start -- TextField Option 1
                  TextFormField(
                    onChanged: (value) {
                      if (value.isNotEmpty &&
                          option2Controller.text.isNotEmpty &&
                          option3Controller.text.isNotEmpty) {
                        setState(
                          () {
                            check123 = true;
                          },
                        );
                      } else {
                        setState(
                          () {
                            check123 = false;
                          },
                        );
                      }
                    },
                    controller: option1Controller,
                    minLines: 1,
                    maxLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 20, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Option 1',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      //border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 190, 190, 186),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide:
                            BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Start -- TextField Option 2
                  TextFormField(
                    onChanged: (value) {
                      if (option1Controller.text.isNotEmpty &&
                          value.isNotEmpty &&
                          option3Controller.text.isNotEmpty) {
                        setState(
                          () {
                            check123 = true;
                          },
                        );
                      } else {
                        setState(
                          () {
                            check123 = false;
                          },
                        );
                      }
                    },
                    controller: option2Controller,
                    minLines: 1,
                    maxLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 20, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Option 2',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      //border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 190, 190, 186),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide:
                            BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                      ),
                    ),
                  ),
                  // End -- TextField Option 2

                  SizedBox(height: 10),

                  // Start -- TextField Option 3
                  TextFormField(
                    onChanged: (value) {
                      if (option1Controller.text.isNotEmpty &&
                          option2Controller.text.isNotEmpty &&
                          value.isNotEmpty) {
                        setState(
                          () {
                            check123 = true;
                          },
                        );
                      } else {
                        setState(
                          () {
                            check123 = false;
                          },
                        );
                      }
                    },
                    controller: option3Controller,
                    minLines: 1,
                    maxLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 20, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Option 3',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      //border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 190, 190, 186),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide:
                            BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                      ),
                    ),
                  ),
                  // End -- TextField Option 3

                  SizedBox(height: 10),

                  // Start -- TextField Option 4
                  Visibility(
                    visible: check123,
                    child: TextFormField(
                      onChanged: (value) {
                        if (check123 == true && value != null) {
                          setState(
                            () {
                              check1234 = true;
                            },
                          );
                        } else {
                          setState(
                            () {
                              check1234 = false;
                            },
                          );
                        }
                      },
                      controller: option4Controller,
                      minLines: 1,
                      maxLines: 1,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(fontSize: 20, height: 1.5),
                      decoration: InputDecoration(
                        hintText: 'Option 4',
                        hintStyle: TextStyle(
                          fontSize: 20.0,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        //border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 190, 190, 186),
                              width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide:
                              BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  // End -- TextField Option 4

                  SizedBox(height: 10),

                  // Start -- TextField Option 5
                  Visibility(
                    visible: check1234,
                    child: TextFormField(
                      controller: option5Controller,
                      minLines: 1,
                      maxLines: 1,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(fontSize: 20, height: 1.5),
                      decoration: InputDecoration(
                        hintText: 'Option 5',
                        hintStyle: TextStyle(
                          fontSize: 20.0,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        //border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 190, 190, 186),
                              width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide:
                              BorderSide(color: Color(0xFFF9EE6D), width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  // End -- TextField Option 5

                  SizedBox(height: 10),
                  // End -- TextField Option 1

                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.066,
                        width: MediaQuery.of(context).size.width * 0.864,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFFF9EE6D)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(90.0),
                              ),
                            ),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          onPressed: () async {
                            List<String> random_options = [];
                            String random_summary;
                            final String getUID = FirebaseAuth
                                .instance.currentUser!.uid
                                .toString();
                            String uid = getUID;
                            String pullUser =
                                '${MyConstant.domain}/famfam/getUserWhereUID.php?isAdd=true&uid=$uid';
                            await Dio().get(pullUser).then((value) async {
                              if (value.toString() == null ||
                                  value.toString() == 'null' ||
                                  value.toString() == '') {
                                FirebaseAuth.instance.signOut();
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                preferences.clear();
                              } else {
                                for (var item in json.decode(value.data)) {
                                  UserModel model = UserModel.fromMap(item);
                                  setState(() {
                                    userModels.add(model);
                                  });
                                }
                              }
                            });

                            Future<Null> pushRandomToSQL(final_option) async {
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              String user_id = userModels[0].id!;
                              String user_profile = Uri.encodeComponent(
                                  userModels[0].profileImage);
                              String circle_id =
                                  preferences.getString('circle_id')!;
                              String random_topic = topicController.text;
                              String random_final = final_option;
                              String insertRandom =
                                  '${MyConstant.domain}/famfam/insertRandom.php?isAdd=true&user_id=$user_id&user_profile=$user_profile&circle_id=$circle_id&random_topic=$random_topic&random_final=$random_final';
                              await Dio().get(insertRandom).then((value) => {
                                    Navigator.popAndPushNamed(
                                        context, '/voterandom')
                                  });
                            }

                            if (option1Controller.text != '') {
                              if (option2Controller.text != '') {
                                if (option3Controller.text != '') {
                                  if (check123 == true) {
                                    if (option4Controller.text != '') {
                                      if (check1234 == true) {
                                        if (option5Controller.text != '') {
                                          random_options
                                              .add(option1Controller.text);
                                          random_options
                                              .add(option2Controller.text);
                                          random_options
                                              .add(option3Controller.text);
                                          random_options
                                              .add(option4Controller.text);
                                          random_options
                                              .add(option5Controller.text);
                                          random_summary =
                                              (random_options..shuffle()).first;
                                          pushRandomToSQL(random_summary);
                                        } else if (option5Controller.text ==
                                            '') {
                                          random_options
                                              .add(option1Controller.text);
                                          random_options
                                              .add(option2Controller.text);
                                          random_options
                                              .add(option3Controller.text);
                                          random_options
                                              .add(option4Controller.text);
                                          random_summary =
                                              (random_options..shuffle()).first;
                                          pushRandomToSQL(random_summary);
                                        }
                                      }
                                    } else if (option4Controller.text == '') {
                                      random_options
                                          .add(option1Controller.text);
                                      random_options
                                          .add(option2Controller.text);
                                      random_options
                                          .add(option3Controller.text);
                                      random_summary =
                                          (random_options..shuffle()).first;
                                      pushRandomToSQL(random_summary);
                                    }
                                  }
                                } else if (option3Controller.text == '') {
                                  random_options.add(option1Controller.text);
                                  random_options.add(option2Controller.text);
                                  random_summary =
                                      (random_options..shuffle()).first;
                                  pushRandomToSQL(random_summary);
                                }
                              } else if (option2Controller.text == '') {
                                if (option3Controller.text != '') {
                                  random_options.add(option1Controller.text);
                                  random_options.add(option3Controller.text);
                                  random_summary =
                                      (random_options..shuffle()).first;
                                  pushRandomToSQL(random_summary);
                                } else if (option3Controller.text == '') {
                                  pushRandomToSQL(option1Controller.text);
                                }
                              }
                            } else if (option1Controller.text == '') {
                              if (option2Controller.text != '') {
                                if (option3Controller.text != '') {
                                  random_options.add(option2Controller.text);
                                  random_options.add(option3Controller.text);
                                  random_summary =
                                      (random_options..shuffle()).first;
                                  pushRandomToSQL(random_summary);
                                } else if (option3Controller.text == '') {
                                  pushRandomToSQL(option2Controller.text);
                                }
                              } else if (option2Controller.text == '') {
                                if (option3Controller.text != '') {
                                  pushRandomToSQL(option3Controller.text);
                                } else if (option3Controller.text == '') {
                                  Fluttertoast.showToast(
                                      msg: "Please insert atleast one option",
                                      gravity: ToastGravity.BOTTOM);
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    });

Future descDialog(BuildContext context, String title, String desc) =>
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Center(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: [
                          Center(
                            child: Text(
                              title,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                          ),
                          // Positioned(
                          //   right: 0,
                          //   top: -6,
                          //   child: InkResponse(
                          //     onTap: () {
                          //       Navigator.of(context).pop();
                          //     },
                          //     child: CircleAvatar(
                          //       child: Icon(
                          //         Icons.close,
                          //         color: Colors.black,
                          //         size: 30,
                          //       ),
                          //       backgroundColor: Colors.transparent,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        width: MediaQuery.of(context).size.height * 0.5,
                        height: MediaQuery.of(context).size.height * 0.15,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(49, 204, 204, 204),
                          border: Border.all(
                            color: Color(0xFFF9EE6D),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20.0),
                            topRight: const Radius.circular(20.0),
                            bottomLeft: const Radius.circular(20.0),
                            bottomRight: const Radius.circular(20.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15, left: 15, right: 15, bottom: 15),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              desc,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.066,
                            width: MediaQuery.of(context).size.width * 0.864,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
