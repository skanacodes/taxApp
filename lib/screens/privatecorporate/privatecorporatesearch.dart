import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:TaxCollection/screens/privatecorporate/corporateBilling.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:TaxCollection/services/constants.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivateCorporateSearch extends StatefulWidget {
  @override
  _PrivateCorporateSearchState createState() => _PrivateCorporateSearchState();
}

class _PrivateCorporateSearchState extends State<PrivateCorporateSearch> {
  String plateNo;
  String tokens;
  var billingData;
  var pendingOrders;
  var unpaidBills;
  bool isFinding = false;
  bool isNotFpund = false;
  bool isClicked = false;
  var data;

  Future getDetails() async {
    try {
      //var headers = {"Authorization": "Bearer " + tokens};

      print(plateNo);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      final response = await http.get(
        'http://parking.technolemon.com/index.php?r=mobile-api-corporate/corporate-moto-search&token=$tokens&customer_name=$plateNo',
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);

            if (res['message'] == 'Successfully') {
              data = res['motor_detail'];

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

  Future<String> corporateBilling(var id) async {
    try {
      //var headers = {"Authorization": "Bearer " + tokens};

      print(id);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      final response = await http.get(
        'http://parking.technolemon.com/index.php?r=mobile-api-corporate/pending-bill&token=$tokens&customer_id=$id',
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          res = json.decode(response.body);
          if (res['message'] == 'Successfully') {
            print(res);
            setState(() {
              billingData = res['customer_detail'];
              pendingOrders = res['customer_corporate_pending_order'];
              unpaidBills = res['customer_corporate_unpaid_billing'];
            });
            return 'success';
          } else {
            print(res);
            return 'fail';
          }

          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          return 'fail';
          break;
        default:
          setState(() {
            // var res = json.decode(response.body);
            print('df');
          });
          return 'fail';
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        print(res);
      });
      return 'fail';
    }
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            //height: getProportionateScreenHeight(210),
            child: Stack(
              children: [
                Container(
                  height: getProportionateScreenHeight(90),
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
                        //height: getProportionateScreenHeight(200),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Search By Name',
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
                                        left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Customer Name',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '  No. of Parking',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Icon(Icons.remove_red_eye))
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
                                              data[i]['customer_name'] +
                                                  "(" +
                                                  data[i]['slot_code'] +
                                                  ")",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: Text(
                                                data[i]['no_parking'],
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () async {
                                                return Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CorporateBilling(
                                                        id: data[i]['id'],
                                                      ),
                                                    ));
                                              },
                                              child: Container(
                                                width:
                                                    getProportionateScreenWidth(
                                                        50),
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: Colors.cyan,
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 1)),
                                                child: Center(
                                                    child: Icon(Icons
                                                        .payments_rounded)),
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

  toastMessage(String indicator) {
    return Fluttertoast.showToast(
        msg: indicator == 'loading' ? "Loading....." : "An Error Occoured",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black26,
        textColor: Colors.white,
        fontSize: 16.0);
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
              hintText: 'Company Name',
              labelText: 'Name',
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
