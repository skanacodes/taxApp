import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:TaxCollection/screens/roadToll/roadTollreport.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import 'package:TaxCollection/services/constants.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoadTollSearch extends StatefulWidget {
  @override
  _RoadTollSearchState createState() => _RoadTollSearchState();
}

class _RoadTollSearchState extends State<RoadTollSearch> {
  String plateNo;
  String tokens;
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
        'http://parking.technolemon.com/index.php?r=mobile-api-toll/toll-moto-search&token=$tokens&plate_number=$plateNo',
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            if (res['message'] == 'Successfully') {
              data = res['motor_toll'];

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
            //  height: getProportionateScreenHeight(210),
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
                        // height: getProportionateScreenHeight(190),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Search By Plate Number',
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
                            height: getProportionateScreenHeight(200),
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
                                        left: 10, right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Plate #',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Text(
                                          'Cargo Name',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Text(
                                          'Amount',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Text(
                                          'Print',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                  for (var i = 0; i < 1; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data['Licence_plate_number'],
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            data['cargo_name'],
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            data['Amount'],
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          InkWell(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RoadTollReport(
                                                    transactionId:
                                                        data['transaction_id'],
                                                  ),
                                                )),
                                            child: Container(
                                              width:
                                                  getProportionateScreenWidth(
                                                      50),
                                              height: 40,
                                              color: Colors.cyan,
                                              child: Center(
                                                child: Text(
                                                  'Pay ',
                                                  style: TextStyle(
                                                      color: Colors.black),
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
