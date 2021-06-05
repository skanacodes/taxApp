import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:TaxCollection/screens/municipal/municipalReportScreen.dart';
import 'package:intl/intl.dart';
import 'package:TaxCollection/services/constants.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class MunicipalSearchScreen extends StatefulWidget {
  @override
  _MunicipalSearchScreenState createState() => _MunicipalSearchScreenState();
}

class _MunicipalSearchScreenState extends State<MunicipalSearchScreen> {
  String plateNo;
  List municipalOrderId = [];
  String tokens;
  String transactionId;
  bool isFinding = false;
  bool isNotFpund = false;
  bool isClicked = false;
  bool isDropingSection1 = false;
  bool isDropingSection2 = false;
  bool isDropingSection3 = false;
  var data;
  var data1;
  var data2;
  var check = [];
  bool checkboxvalue = false;
  Map<String, bool> checkboxvalues = {
    '1': false,
    '2': false,
    '3': false,
    '4': false,
    '5': false,
    '6': false,
    '7': false,
    '8': false,
    '9': false,
    '10': false,
    '11': false,
    '12': false
  };
  Future<String> generateControlNumber() async {
    try {
      print(plateNo);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      final response = await http.post(
          'http://parking.technolemon.com/index.php?r=mobile-api-municipal/generate-controlnumber',
          body: jsonEncode(
              {"municipal_order_id": municipalOrderId, "user_token": tokens}));
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
          });
          if (res['message'] == 'Saved Successfully') {
            print(res);

            transactionId = res['transaction_id'].toString();
            toastMessage('success');
            return 'success';
          } else {
            toastMessage('error');
            return 'error';
          }

          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
            toastMessage('error');
          });
          return 'error';
          break;
        default:
          setState(() {
            // res = json.decode(response.body);
            toastMessage('error');
          });
          return 'error';
          break;
      }
    } on SocketException {
      setState(() {
        toastMessage(' Connectivity or Server Error');
        var res = 'Server Error';
        print(res);
      });
      return 'error';
    }
  }

  Future<String> generateOrder(id) async {
    try {
      print(plateNo);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      final response = await http.post(
          'http://parking.technolemon.com/index.php?r=mobile-api-municipal/generate-municipal-order',
          body: jsonEncode({
            "customer_id": id,
            "generate_month_bill": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
            "user_token": tokens
          }));
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
          });
          if (res['message'] == 'Saved Successfully') {
            print(res);
            toastMessage('success');
            await getDetails();
            return 'success';
          } else {
            print(res);
            toastMessage('error');
            return 'error';
          }

          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
            toastMessage('error');
          });
          return 'error';
          break;
        default:
          setState(() {
            // res = json.decode(response.body);
            toastMessage('error');
          });
          return 'error';
          break;
      }
    } on SocketException {
      setState(() {
        toastMessage(' Connectivity or Server Error');
        var res = 'Server Error';
        print(res);
      });
      return 'error';
    }
  }

  toastMessage(String indicator) {
    return Fluttertoast.showToast(
        msg: indicator == 'success'
            ? ' Successful Generated'
            : indicator == 'loading'
                ? "Loading....."
                : "An Error Occoured",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  message(
    String desc,
  ) {
    return Alert(
      context: context,
      type: AlertType.info,
      title: 'Information',
      desc: desc,
      buttons: [
        DialogButton(
          color: kPrimaryColor,
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            toastMessage('loading');

            String res = await generateControlNumber();
            print(res);

            if (res == 'success') {
              Navigator.pop(context);
              await getDetails();
              return Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MunicipalReportScreen(
                      transactionId: transactionId,
                    ),
                  ));
            }
          },
          width: 120,
        ),
        DialogButton(
          color: Colors.cyan,
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show();
  }

  Future getDetails() async {
    try {
      //var headers = {"Authorization": "Bearer " + tokens};
      print(tokens);
      print(plateNo);
      setState(() {
        municipalOrderId = [];
        checkboxvalue = false;
        checkboxvalues = {
          '1': false,
          '2': false,
          '3': false,
          '4': false,
          '5': false,
          '6': false,
          '7': false,
          '8': false,
          '9': false,
          '10': false,
          '11': false,
          '12': false
        };
      });

      final response = await http.get(
        'http://parking.technolemon.com/index.php?r=mobile-api-municipal/municipal-moto-search&token=$tokens&plate_number=$plateNo',
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            if (res['message'] == 'Successfully') {
              data = res['motor_detail'];
              data1 = res['municipal_motor_unpaid'];
              data2 = res['municipal_motor_unpaid_bill'];
              isNotFpund = false;
              check = [];
              for (var i = 0; i < data1.length; i++) {
                check.add(data1[i]['period_month']);
              }
              print(check);
              print(data);
            } else {
              print(res);
              isNotFpund = true;
            }
            print(res);
          });
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          break;
        default:
          setState(() {
            // res = json.decode(response.body);
            print('df');
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        print(res);
      });
    }
  }

  dropcard(bool isDroping) {
    setState(() {
      isDroping = !true;
    });
  }

  Future<void> getToken() async {
    tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    this.getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            //height: getProportionateScreenHeight(220),
            child: Stack(
              children: [
                Container(
                  height: getProportionateScreenHeight(100),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            getProportionateScreenHeight(200),
                          ),
                          bottomRight: Radius.circular(
                              getProportionateScreenHeight(200)))),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 10,
                      shadowColor: kPrimaryColor,
                      child: Container(
                        // height: getProportionateScreenHeight(160),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Search Any Motor By Plate Number',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Divider(
                              color: kPrimaryColor,
                            ),
                            Container(
                              height: getProportionateScreenHeight(90),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: searchBar(),
                                  ),
                                  Expanded(
                                      child: InkWell(
                                    onTap: () async {
                                      setState(() {
                                        isClicked = true;
                                        isFinding = true;
                                      });
                                      await getDetails();
                                      setState(() {
                                        isFinding = false;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.cyan,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Center(
                                          child: Text(
                                            'Search',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          isClicked
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    // height: isNotFpund
                    //     ? getProportionateScreenHeight(100)
                    //     : getProportionateScreenHeight(300),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 10,
                              color: Colors.grey,
                              spreadRadius: 3,
                              offset: Offset.zero)
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: isFinding
                        ? Container(
                            height: getProportionateScreenHeight(100),
                            child: Center(
                                child: SpinKitDualRing(
                              color: Colors.cyan,
                              size: getProportionateScreenHeight(40),
                            )),
                          )
                        : isNotFpund
                            ? Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  height: 5.0.h,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(10),
                                      ),
                                      Text('Information: No Record Found',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isDropingSection1 = false;
                                          isDropingSection2 = false;
                                          isDropingSection3
                                              ? isDropingSection3 = false
                                              : isDropingSection3 = true;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: kPrimaryColor,
                                          ),
                                          SizedBox(
                                            width:
                                                getProportionateScreenWidth(10),
                                          ),
                                          Text(
                                            'Municipal Motor Informations',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          isDropingSection3
                                              ? Icon(
                                                  Icons.arrow_drop_up_outlined,
                                                  color: Colors.purple,
                                                  size: 25.0.sp,
                                                )
                                              : Icon(
                                                  Icons
                                                      .arrow_drop_down_outlined,
                                                  color: Colors.purple,
                                                  size: 25.0.sp,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: kPrimaryColor,
                                    height: getProportionateScreenHeight(10),
                                    thickness: 2,
                                  ),
                                  isDropingSection3
                                      ? Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Icon(
                                                  Icons.wrap_text_outlined,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 6,
                                                child: Text(
                                                    'Plate Number: ' +
                                                        data['plate_number']
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  isDropingSection3
                                      ? Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Icon(
                                                  Icons.brightness_1_outlined,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 6,
                                                child: Text(
                                                  'Owner: ' +
                                                      data['owner_name']
                                                          .toString(),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  isDropingSection3
                                      ? Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Icon(
                                                  Icons.phone,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 6,
                                                child: Text('Owner Number: ' +
                                                    data['owner_contact']
                                                        .toString()),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  isDropingSection3
                                      ? Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Icon(
                                                  Icons
                                                      .emoji_transportation_rounded,
                                                  color: Colors.pink,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 6,
                                                child: Text('Vehicle Type: ' +
                                                    data['vehicle_type']
                                                        .toString()),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Spacer(),
                                        InkWell(
                                          onTap: () {
                                            toastMessage('loading');
                                            return generateOrder(data['id']);
                                          },
                                          child: Container(
                                            // width: getProportionateScreenWidth(
                                            //     100),
                                            decoration: BoxDecoration(
                                                color: Colors.cyan,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            height: 35,

                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Generate Order',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
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
                )
              : Container(),
          isClicked
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height:
                        isFinding ? getProportionateScreenHeight(100) : null,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 10,
                              color: Colors.grey,
                              spreadRadius: 3,
                              offset: Offset.zero)
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: isFinding
                        ? Container(
                            //height: getProportionateScreenHeight(200),
                            child: Center(
                                child: SpinKitDualRing(
                              color: Colors.cyan,
                              size: getProportionateScreenHeight(40),
                            )),
                          )
                        : isNotFpund
                            ? Container()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isDropingSection3 = false;
                                          isDropingSection2 = false;
                                          isDropingSection1
                                              ? isDropingSection1 = false
                                              : isDropingSection1 = true;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: kPrimaryColor,
                                          ),
                                          SizedBox(
                                            width:
                                                getProportionateScreenWidth(10),
                                          ),
                                          Text(
                                            'Unpaid History',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          isDropingSection1
                                              ? Icon(
                                                  Icons.arrow_drop_up_outlined,
                                                  color: Colors.purple,
                                                  size: 25.0.sp,
                                                )
                                              : Icon(
                                                  Icons
                                                      .arrow_drop_down_outlined,
                                                  color: Colors.purple,
                                                  size: 25.0.sp,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: kPrimaryColor,
                                    height: getProportionateScreenHeight(10),
                                    thickness: 2,
                                  ),
                                  isDropingSection1
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Checkbox(
                                                  activeColor: Colors.pink,
                                                  value: checkboxvalue,
                                                  // onChanged: (value) => null,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      this.checkboxvalue =
                                                          value;
                                                      for (var i = 0;
                                                          i < check.length;
                                                          i++) {
                                                        checkboxvalues[
                                                                check[i]] =
                                                            checkboxvalue;
                                                        if (checkboxvalues[data1[
                                                                i]
                                                            ['period_month']]) {
                                                          municipalOrderId
                                                                  .contains(data1[
                                                                          i][
                                                                      'transaction_id'])
                                                              ? print(
                                                                  municipalOrderId)
                                                              : municipalOrderId
                                                                  .add(data1[i][
                                                                      'transaction_id']);
                                                          print(
                                                              municipalOrderId);
                                                        } else {
                                                          municipalOrderId
                                                              .remove(data1[i][
                                                                  'transaction_id']);
                                                          print(
                                                              municipalOrderId);
                                                        }
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'All',
                                                  style: TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'S/N',
                                                  style: TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Month',
                                                  style: TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Amount',
                                                  style: TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  isDropingSection1
                                      ? Divider(
                                          color: Colors.black38,
                                          height:
                                              getProportionateScreenHeight(1),
                                          thickness: 1,
                                        )
                                      : Container(),
                                  for (var i = 0; i < data1.length; i++)
                                    isDropingSection1
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Checkbox(
                                                    activeColor: Colors.pink,
                                                    value: checkboxvalues[
                                                        data1[i]
                                                            ['period_month']],
                                                    onChanged: (value) {
                                                      setState(() {
                                                        this.checkboxvalues[data1[
                                                                    i][
                                                                'period_month']] =
                                                            value;
                                                        if (checkboxvalues[data1[
                                                                i]
                                                            ['period_month']]) {
                                                          municipalOrderId
                                                                  .contains(data1[
                                                                          i][
                                                                      'transaction_id'])
                                                              ? print(
                                                                  municipalOrderId)
                                                              : municipalOrderId
                                                                  .add(data1[i][
                                                                      'transaction_id']);
                                                          print(
                                                              municipalOrderId);
                                                        } else {
                                                          municipalOrderId
                                                              .remove(data1[i][
                                                                  'transaction_id']);
                                                          print(
                                                              municipalOrderId);
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      '---',
                                                      style: TextStyle(
                                                          color: Colors.purple,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    (i + 1).toString(),
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    data1[i]['period_month']
                                                            .toString() +
                                                        "/" +
                                                        data1[i]['year']
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    data1[i]['price']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Spacer(),
                                        InkWell(
                                          onTap: () {
                                            return message(
                                              'Are You Sure Want To Generate Control Number',
                                            );
                                          },
                                          child: Container(
                                            // width: getProportionateScreenWidth(
                                            //     100),
                                            decoration: BoxDecoration(
                                                color: Colors.cyan,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            height: 30,

                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Get Control #',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    // width: getProportionateScreenWidth(
                                    //     100),
                                    height: getProportionateScreenHeight(2),
                                    color: Colors.cyan,
                                  ),
                                ],
                              ),
                  ),
                )
              : Container(),
          isClicked
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    // height: isNotFpund
                    //     ? getProportionateScreenHeight(100)
                    //     : getProportionateScreenHeight(300),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 10,
                              color: Colors.grey,
                              spreadRadius: 3,
                              offset: Offset.zero)
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: isFinding
                        ? Container(
                            height: getProportionateScreenHeight(100),
                            child: Center(
                                child: SpinKitDualRing(
                              color: Colors.cyan,
                              size: getProportionateScreenHeight(40),
                            )),
                          )
                        : isNotFpund
                            ? Container()
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isDropingSection1 = false;
                                          isDropingSection3 = false;
                                          isDropingSection2
                                              ? isDropingSection2 = false
                                              : isDropingSection2 = true;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: kPrimaryColor,
                                          ),
                                          SizedBox(
                                            width:
                                                getProportionateScreenWidth(10),
                                          ),
                                          Text(
                                            'List Of Unpaid Bills',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          isDropingSection1
                                              ? Icon(
                                                  Icons.arrow_drop_up_outlined,
                                                  color: Colors.purple,
                                                  size: 25.0.sp,
                                                )
                                              : Icon(
                                                  Icons
                                                      .arrow_drop_down_outlined,
                                                  color: Colors.purple,
                                                  size: 25.0.sp,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: kPrimaryColor,
                                    height: getProportionateScreenHeight(10),
                                    thickness: 2,
                                  ),
                                  isDropingSection2
                                      ? Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Control #',
                                                  style: TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Center(
                                                  child: Text(
                                                    'Amount',
                                                    style: TextStyle(
                                                        color: Colors.purple,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Center(
                                                  child: Text(
                                                    'Bill Id',
                                                    style: TextStyle(
                                                        color: Colors.purple,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Print',
                                                  style: TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  isDropingSection2
                                      ? Divider(
                                          color: Colors.black38,
                                          height:
                                              getProportionateScreenHeight(10),
                                          thickness: 1,
                                        )
                                      : Container(),
                                  for (var i = 0; i < data2.length; i++)
                                    isDropingSection2
                                        ? Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Card(
                                              // elevation: 10,
                                              // shadowColor: Color(0xfff3f3f4),
                                              child: Container(
                                                color: (i + 1).isEven
                                                    ? Color(0xfff3f3f4)
                                                    : Colors.white,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        data2[i][
                                                                'control_number']
                                                            .toString(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Center(
                                                        child: Text(
                                                          data2[i]['amount']
                                                                  .toString() +
                                                              'FBU',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        data2[i]['bill_number']
                                                            .toString(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.cyan,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        width:
                                                            getProportionateScreenWidth(
                                                                31),
                                                        height: 5.0.h,
                                                        child: Center(
                                                          child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            MunicipalReportScreen(
                                                                              transactionId: data2[i]['id'],
                                                                            )));
                                                              },
                                                              child: Icon(
                                                                Icons.print,
                                                                color: Colors
                                                                    .white,
                                                              )),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  Container(
                                    // width: getProportionateScreenWidth(
                                    //     100),
                                    height: getProportionateScreenHeight(2),
                                    color: Colors.cyan,
                                  ),
                                ],
                              ),
                  ),
                )
              : Container(),
          SizedBox(
            height: getProportionateScreenHeight(100),
          )
        ],
      ),
    );
  }

  searchBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
          cursorColor: kPrimaryColor,
          enabled: true,
          onChanged: (value) {
            plateNo = value;
          },
          showCursor: true,
          decoration: InputDecoration(
              enabled: true,
              hintText: 'Plate Number',
              labelText: 'Plate Number',
              // enabledBorder: outlineInputBorder,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(30, 20, 20, 10),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(
                  color: Colors.cyan,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(
                  color: Colors.black38,
                  width: 1.0,
                ),
              ),
              fillColor: Color(0xfff3f3f4),
              filled: true)),
    );
  }
}
