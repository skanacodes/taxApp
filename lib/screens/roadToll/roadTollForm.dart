import 'dart:convert';
import 'dart:io';
import 'package:TaxCollection/screens/publicMotors/publicmotormodal.dart';
import 'package:TaxCollection/services/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoadTollForm extends StatefulWidget {
  @override
  _RoadTollFormState createState() => _RoadTollFormState();
}

class _RoadTollFormState extends State<RoadTollForm> {
  final _formKey = GlobalKey<FormState>();
  Task task = new Task();
  DateTime selectedDate;
  bool isPosted = false;

  bool isLoading = false;
  List data = List(); //edited line
  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Fill',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryLightColor,
          ),
          children: [
            TextSpan(
              text: ' Registration ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0.sp,
              ),
            ),
            TextSpan(
              text: ' Form',
              style: TextStyle(
                color: Colors.green[200],
                fontSize: 15.0.sp,
              ),
            ),
          ]),
    );
  }

  Future postData() async {
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    try {
      final response = await http.post(
        'http://parking.technolemon.com/index.php?r=mobile-api-toll/road-toll-sale',
        body: jsonEncode({
          "cargo_charge_id": task.cargoCharge,
          "quantity": task.quantity,
          "plate_number": task.licencePlateNumber,
          "driver_name": task.drivername,
          "user_token": tokens
        }),
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            if (res['message'] == 'Saved Successfully') {
              print(res);

              message('Details Successsfull Saved', 'success');
            } else if (res['message'] == 'Plate Number Already exists') {
              print(res);

              message('Plate Number Already exists', 'error');
            } else {
              print(res);

              message('Error Processing Request', 'error');
            }
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            message('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        message('Server Or Connectivity Error', 'error');
      });
    }
  }

  message(
    String desc,
    String type,
  ) {
    return Alert(
      context: context,
      type: type == 'success' ? AlertType.success : AlertType.error,
      title: 'Information',
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            if (type == 'success') {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
          width: 120,
        )
      ],
    ).show();
  }

  Future getVehicleType() async {
    try {
      //var headers = {"Authorization": "Bearer " + tokens};

      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      final response = await http.get(
        'http://parking.technolemon.com/index.php?r=mobile-api-corporate/cargo-charge&token=$tokens',
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            data = res['cargo_data'];
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
            res = json.decode(response.body);
            print(res);
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

  // Future<void> getToken() async {
  //   tokens = await SharedPreferences.getInstance()
  //       .then((prefs) => prefs.getString('token'));
  // }

  @override
  void initState() {
    super.initState();
    //  this.getToken();
    this.getVehicleType();
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();

          setState(() {
            isLoading = true;
          });
          print(task.cargoCharge);
          await postData();
          // isPosted
          //     ? _formKey.currentState.reset()
          //     : _formKey.currentState.dispose();
          setState(() {
            isLoading = false;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 0, right: 16, left: 16, bottom: 18),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 14),
                    blurRadius: 35,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [kPrimaryColor, Colors.green[50]])),
          child: Center(
            child: Text(
              'Save',
              style: TextStyle(fontSize: 15.0.sp, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
                child: SpinKitDualRing(
              color: Colors.cyan,
              size: 40,
            )),
          )
        : Form(
            key: _formKey,
            child: Expanded(
              child: ListView(
                children: <Widget>[
                  Card(
                    elevation: 10,
                    shadowColor: kPrimaryColor,
                    child: Column(
                      children: <Widget>[
                        _title(),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, right: 18, left: 18),
                          child: SafeArea(
                            child: data.isEmpty
                                ? SpinKitDualRing(
                                    color: Colors.cyan,
                                    size: getProportionateScreenHeight(40),
                                  )
                                : Container(
                                    child: new DropdownButtonFormField(
                                      itemHeight: 50,
                                      decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.cyan,
                                            ),
                                          ),
                                          fillColor: Color(0xfff3f3f4),
                                          filled: true,
                                          isDense: true,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              30, 10, 15, 10),
                                          labelText: "Select Cargo Charge",
                                          border: InputBorder.none),
                                      isExpanded: true,
                                      isDense: true,
                                      validator: (value) => value == null
                                          ? "This Field is Required"
                                          : null,
                                      items: data.map((item) {
                                        return new DropdownMenuItem(
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Color(0xfff3f3f4),
                                              border: Border(
                                                bottom: BorderSide(
                                                    width: 1,
                                                    color: kPrimaryColor),
                                              ),
                                            ),
                                            child: new Text(
                                              item['cargo_data'].toString(),
                                            ),
                                          ),
                                          value: item['id'].toString(),
                                        );
                                      }).toList(),
                                      onChanged: (newVal) {
                                        setState(() {
                                          task.cargoCharge = newVal;
                                        });
                                      },
                                      value: task.cargoCharge,
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, right: 16, left: 16),
                          child: Container(
                            child: TextFormField(
                              key: Key("Quantity"),
                              keyboardType: TextInputType.phone,
                              onSaved: (val) => task.quantity = int.parse(val),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.cyan,
                                  ),
                                ),
                                fillColor: Color(0xfff3f3f4),
                                filled: true,
                                labelText: "Enter Quantity",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(30, 10, 15, 10),
                              ),
                              validator: (value) {
                                if (value.isEmpty)
                                  return "This Field Is Required";
                                return null;
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, right: 16, left: 16),
                          child: Container(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              key: Key("plateNumber"),
                              onSaved: (val) => task.licencePlateNumber = val,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.cyan,
                                  ),
                                ),
                                fillColor: Color(0xfff3f3f4),
                                filled: true,
                                labelText: "Enter Licence Plate Number",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(30, 10, 15, 10),
                              ),
                              validator: (value) {
                                if (value.isEmpty)
                                  return "This Field Is Required";
                                return null;
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, right: 16, left: 16),
                          child: Container(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              key: Key("Driver Name"),
                              onSaved: (val) => task.drivername = val,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Colors.cyan,
                                  ),
                                ),
                                fillColor: Color(0xfff3f3f4),
                                filled: true,
                                labelText: "Enter Driver Name",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(30, 10, 15, 10),
                              ),
                              validator: (value) {
                                if (value.isEmpty)
                                  return "This Field Is Required";
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(20),
                        ),
                        _submitButton()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
