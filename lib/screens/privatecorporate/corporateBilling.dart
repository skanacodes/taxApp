import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:TaxCollection/screens/privatecorporate/privatecorporatereport.dart';
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

class CorporateBilling extends StatefulWidget {
  static String routeName = '/corporatebilling';

  final String id;
  CorporateBilling({this.id});
  @override
  _CorporateBillingState createState() => _CorporateBillingState();
}

class _CorporateBillingState extends State<CorporateBilling> {
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
  int sum = 0;
  int sumUnpaid = 0;
  int tax = 0;
  int total = 0;
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
      print(municipalOrderId);
      final response = await http.post(
          'http://parking.technolemon.com/index.php?r=mobile-api-corporate/generate-controlnumber',
          body: jsonEncode(
              {"customer_id": municipalOrderId, "user_token": tokens}));
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
          });
          print(res);
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

  Future<String> generateOrder(String id) async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      final response = await http.post(
          'http://parking.technolemon.com/index.php?r=mobile-api-corporate/generate-customer-order',
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
            await getDetails();
            toastMessage('success');

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
      tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      String id;
      setState(() {
        id = widget.id;
      });
      print(tokens);
      print(widget.id);
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
        'http://parking.technolemon.com/index.php?r=mobile-api-corporate/pending-bill&token=$tokens&customer_id=$id',
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
              data = res['customer_detail'];
              data1 = res['customer_corporate_pending_order'];
              data2 = res['customer_corporate_unpaid_billing'];
              isNotFpund = false;
              check = [];
              for (var i = 0; i < data1.length; i++) {
                sum = sum + int.parse(data1[i]['total_amount']);
                check.add(data1[i]['month']);
                check.sort();
              }
              for (var i = 0; i < data2.length; i++) {
                sumUnpaid = sumUnpaid + int.parse(data2[i]['amount']);
                total = sumUnpaid + tax;
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

  // Future<void> getToken() async {
  //   tokens = await SharedPreferences.getInstance()
  //       .then((prefs) => prefs.getString('token'));
  // }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    // this.getToken();
    this.getDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Corporate Billing',
          style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: kPrimaryColor,
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(10),
                                      ),
                                      Text(
                                        'Private Company Informations',
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
                                              Icons.arrow_drop_down_outlined,
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
                                                'Customer Name:' +
                                                    data['customer_name']
                                                        .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
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
                                              'Phone Number: ' +
                                                  data['phone_number']
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
                                            child: Text('Contact Person: ' +
                                                data['contact_personal']
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
                                              Icons.format_list_numbered,
                                              color: Colors.purple,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Text('No. Of Parking: ' +
                                                data['no_parking'].toString()),
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
                                              Icons.code_rounded,
                                              color: Colors.amberAccent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Text('Slot Code: ' +
                                                data['slot_code'].toString()),
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
                                        return generateOrder(
                                            data['customer_id']);
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
                                            padding: const EdgeInsets.all(8.0),
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
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: isFinding ? getProportionateScreenHeight(100) : null,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: kPrimaryColor,
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(10),
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
                                              Icons.arrow_drop_down_outlined,
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
                                                  this.checkboxvalue = value;
                                                  for (var i = 0;
                                                      i < check.length;
                                                      i++) {
                                                    checkboxvalues[check[i]] =
                                                        checkboxvalue;
                                                    if (checkboxvalues[data1[i]
                                                        ['month']]) {
                                                      municipalOrderId.contains(
                                                              data1[i]['id'])
                                                          ? print(
                                                              municipalOrderId)
                                                          : municipalOrderId
                                                              .add(data1[i]
                                                                  ['id']);
                                                      print(municipalOrderId);
                                                    } else {
                                                      municipalOrderId.remove(
                                                          data1[i]['id']);
                                                      print(municipalOrderId);
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
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'S/N',
                                              style: TextStyle(
                                                  color: Colors.purple,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Month',
                                              style: TextStyle(
                                                  color: Colors.purple,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Amount',
                                              style: TextStyle(
                                                  color: Colors.purple,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              isDropingSection1
                                  ? Divider(
                                      color: Colors.black38,
                                      height: getProportionateScreenHeight(1),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Checkbox(
                                                activeColor: Colors.pink,
                                                value: checkboxvalues[data1[i]
                                                    ['month']],
                                                onChanged: (value) {
                                                  setState(() {
                                                    this.checkboxvalues[data1[i]
                                                        ['month']] = value;
                                                    if (checkboxvalues[data1[i]
                                                        ['month']]) {
                                                      municipalOrderId.contains(
                                                              data1[i]['id'])
                                                          ? print(
                                                              municipalOrderId)
                                                          : municipalOrderId
                                                              .add(data1[i]
                                                                  ['id']);
                                                      print(municipalOrderId);
                                                    } else {
                                                      municipalOrderId.remove(
                                                          data1[i]['id']);
                                                      print(municipalOrderId);
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
                                                data1[i]['month'].toString() +
                                                    "/" +
                                                    data1[i]['year'].toString(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                data1[i]['total_amount']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                              isDropingSection1
                                  ? Divider(
                                      color: Colors.black38,
                                      height: getProportionateScreenHeight(1),
                                      thickness: 1,
                                    )
                                  : Container(),
                              isDropingSection1
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Container(
                                        height: 40,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                flex: 1, child: Container()),
                                            Expanded(
                                                flex: 1, child: Container()),
                                            Expanded(
                                                flex: 1, child: Container()),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'SubTotal',
                                                style: TextStyle(
                                                  color: kPrimaryLightColor,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                sum.toString(),
                                                style: TextStyle(
                                                    color: kPrimaryLightColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              isDropingSection1
                                  ? Divider(
                                      color: Colors.black38,
                                      height: getProportionateScreenHeight(1),
                                      thickness: 1,
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
                                            padding: const EdgeInsets.all(8.0),
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
            ),
            Padding(
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: kPrimaryColor,
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(10),
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
                                              Icons.arrow_drop_down_outlined,
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
                                            flex: 2,
                                            child: Center(
                                              child: Text(
                                                'Date ',
                                                style: TextStyle(
                                                    color: Colors.purple,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Control #',
                                              style: TextStyle(
                                                  color: Colors.purple,
                                                  fontWeight: FontWeight.bold),
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
                                            flex: 2,
                                            child: Text(
                                              'Print',
                                              style: TextStyle(
                                                  color: Colors.purple,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              isDropingSection2
                                  ? Divider(
                                      color: Colors.black38,
                                      height: getProportionateScreenHeight(10),
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
                                                  flex: 2,
                                                  child: Center(
                                                    child: Text(
                                                      '',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    data2[i]['control_number']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black),
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
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.cyan,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
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
                                                                    builder:
                                                                        (context) =>
                                                                            PrivateCorporateReportScreen(
                                                                              transactionId: data2[i]['id'],
                                                                            )));
                                                          },
                                                          child: Icon(
                                                            Icons.print,
                                                            color: Colors.white,
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
                              isDropingSection2
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5, top: 0, bottom: 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              '----------------------------------------------------------',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              isDropingSection2
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5, top: 0, bottom: 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              '----------------------------------------------------------',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              isDropingSection2
                                  ? Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Card(
                                        // elevation: 10,
                                        // shadowColor: Color(0xfff3f3f4),
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'SubTotal',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Center(
                                                  child: Text(
                                                    sumUnpaid.toString() +
                                                        'FBU',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              isDropingSection2
                                  ? Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Card(
                                        // elevation: 10,
                                        // shadowColor: Color(0xfff3f3f4),
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Tax',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Center(
                                                  child: Text(
                                                    tax.toString(),
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              isDropingSection2
                                  ? Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Card(
                                        // elevation: 10,
                                        // shadowColor: Color(0xfff3f3f4),
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Total',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Center(
                                                  child: Text(
                                                    total.toString() + 'FBU',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              isDropingSection2
                                  ? Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Card(
                                        // elevation: 10,
                                        // shadowColor: Color(0xfff3f3f4),
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Balance Due',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Center(
                                                  child: Text(
                                                    total.toString() + 'FBU',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.black),
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
            ),
            SizedBox(
              height: getProportionateScreenHeight(100),
            )
          ],
        ),
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
