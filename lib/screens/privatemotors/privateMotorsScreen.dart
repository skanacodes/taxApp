import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:TaxCollection/screens/privatemotors/privatemotorreport.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:TaxCollection/services/constants.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivateMotorsSearch extends StatefulWidget {
  @override
  _PrivateMotorsSearchState createState() => _PrivateMotorsSearchState();
}

class _PrivateMotorsSearchState extends State<PrivateMotorsSearch> {
  String plateNo;
  String tokens;
  bool isPaying = false;
  bool isFinding = false;
  bool isNotFpund = false;
  bool isClicked = false;
  var data = [];

  Future getDetailsDefault() async {
    setState(() {
      this.isClicked = true;
      this.isFinding = true;
    });
    try {
      //var headers = {"Authorization": "Bearer " + tokens};

      print(plateNo);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      final response = await http.get(
        'http://parking.technolemon.com/index.php?r=mobile-apia/private-motor-default-list&token=$tokens',
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            if (res['message'] == 'Successfully') {
              data = res['data'];

              isNotFpund = false;
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
    setState(() {
      this.isFinding = false;
    });
  }

  Future getDetails() async {
    try {
      //var headers = {"Authorization": "Bearer " + tokens};

      print(plateNo);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      final response = await http.get(
        'http://parking.technolemon.com/index.php?r=mobile-apia/private-moto-search&token=$tokens&plate_number=$plateNo',
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            if (res['message'] == 'Successfully') {
              data = res['data'];

              isNotFpund = false;
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

  Future<String> receivepayment(String id) async {
    try {
      print(plateNo);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      final response = await http.get(
        'http://parking.technolemon.com/index.php?r=mobile-apia/private-receive-payment&token=$tokens&transaction_id=$id',
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
          });
          if (res['message'] == 'Successfully') {
            print(res);
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => PrivateReport(
            //         transactionId: id,
            //       ),
            //     ));
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

  toastMessage(String indicator) {
    return Fluttertoast.showToast(
        msg: indicator == 'loading' ? "Loading....." : "An Error Occoured",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  message(String desc, String id) {
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

            String res = await receivepayment(id);
            print(res);
            Navigator.pop(context);
            if (res == 'success') {
              return Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivateReport(
                      transactionId: id,
                    ),
                  )).then((value) => setState(() async {
                    // refresh state
                    await getDetailsDefault();
                  }));
            }
            Navigator.pop(context);
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

  Future<void> getToken() async {
    tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    this.getToken();

    print(isClicked);

    this.getDetailsDefault();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            //height: getProportionateScreenHeight(210),
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
                        // height: getProportionateScreenHeight(260),
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
                                                BorderRadius.circular(3)),
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
                        ? Center(
                            child: SpinKitDualRing(
                            color: Colors.cyan,
                            size: getProportionateScreenHeight(40),
                          ))
                        : isNotFpund
                            ? Container(
                                height: getProportionateScreenHeight(100),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
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
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: kPrimaryColor,
                                    height: getProportionateScreenHeight(10),
                                    thickness: 2,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Plate #',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Hours',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Amount',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: Text(
                                              'Pay',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  for (var i = 0; i < data.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              data[i]['plate_number'] == null
                                                  ? ''
                                                  : data[i]['plate_number']
                                                      .toString(),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              data[i]['hours'].toString(),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              data[i]['price'].toString(),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: InkWell(
                                              onTap: () {
                                                message(
                                                    'Are You sure You Want To Receive Payment ?',
                                                    data[i]['transaction_id']);
                                              },
                                              child: Container(
                                                // width:
                                                //     getProportionateScreenWidth(
                                                //         80),
                                                height: 35,
                                                decoration: BoxDecoration(
                                                    color: Colors.cyan,
                                                    border: Border.all(
                                                        color: Colors.white)),

                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        Icons.payment_outlined),
                                                    Center(
                                                      child: Text(
                                                        'Pay',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ],
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
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(30, 20, 20, 10),
              // enabledBorder: outlineInputBorder,
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
