import 'dart:convert';
import 'dart:io';

import 'package:TaxCollection/screens/publicMotors/publicmotormodal.dart';
import 'package:TaxCollection/services/constants.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewTask extends StatefulWidget {
  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final _formKey = GlobalKey<FormState>();
  Task task = new Task();
  DateTime selectedDate;
  bool isPosted = false;
  String tokens;
  bool isLoading = false;
  List data = List(); //edited line
  Future postData() async {
    try {
      final response = await http.post(
        'http://parking.technolemon.com/index.php?r=mobile-api-public/parking-sale-public',
        body: jsonEncode({
          "vehicle_type_id": task.vehicletype,
          "plate_number": task.platenumber,
          "owner": task.owner,
          "phone_number": task.phonenumber,
          "driver_name": task.drivername,
          "owner_number": task.ownerNumber,
          "user_token": tokens,
          "generate_month_bill": months
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
        'http://parking.technolemon.com/index.php?r=mobile-apia/vehicle-type&token=$tokens',
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            data = res['data'];
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

  Future<void> getToken() async {
    tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
  }

  @override
  void initState() {
    super.initState();
    this.getToken();
    this.getVehicleType();

    selectedDate = DateTime.now();
  }

  List<int> months = [];
  Widget _dateButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        children: [
          Container(
            height: 6.0.h,
            width: getProportionateScreenHeight(360),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey, Colors.green[50]])),
            child: Center(
                child: Text(
              'Generate Monthly Bill',
              style: TextStyle(color: Colors.black),
            )),
          ),
          getPics()
        ],
      ),
    );
  }

  getPics() {
    return InkWell(
      onTap: () {
        return showMonthPicker(
          context: context,
          firstDate: DateTime(DateTime.now().year - 1, 5),
          lastDate: DateTime(DateTime.now().year + 1, 9),
          initialDate: selectedDate ?? DateTime.now(),
          locale: Locale("en"),
        ).then((date) {
          if (date != null) {
            setState(() {
              FocusScope.of(context).requestFocus(new FocusNode());
              selectedDate = date;
              int month = int.parse(selectedDate.toString().substring(5, 7));
              months.add(month);
              months.sort();
              print(month);
              print(months);
            });
          }
        });
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: Colors.white, style: BorderStyle.solid, width: 5)),
          child: CircleAvatar(
              radius: 25,
              foregroundColor: Colors.black,
              child: SvgPicture.asset(
                'assets/icons/addpic.svg',
                height: getProportionateScreenHeight(40),
                fit: BoxFit.contain,
              )),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();

          setState(() {
            isLoading = true;
          });
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
              flex: 5,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 10,
                      shadowColor: kPrimaryColor,
                      child: Column(
                        children: <Widget>[
                          _title(),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16, right: 18, left: 18),
                            child: SafeArea(
                              child: data.isEmpty
                                  ? SpinKitDualRing(
                                      color: Colors.cyan,
                                      size: getProportionateScreenHeight(40),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                      ),
                                      child: Center(
                                        child: Container(
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
                                              border: InputBorder.none,
                                              // suffixIcon: Icon(Icons
                                              //     .arrow_drop_down_circle_rounded),
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true,
                                              labelText: "Select Vehicle Type",
                                              isDense: true,

                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            isDense: true,
                                            isExpanded: true,
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
                                                    item['name'],
                                                  ),
                                                ),
                                                value: item['id'].toString(),
                                              );
                                            }).toList(),
                                            onChanged: (newVal) {
                                              setState(() {
                                                task.vehicletype = newVal;
                                              });
                                            },
                                            value: task.vehicletype,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5, right: 16, left: 16),
                            child: Container(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                key: Key("plateNumber"),
                                onSaved: (val) => task.platenumber = val,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Plate Number",
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
                                onSaved: (val) => task.owner = val,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: Color(0xfff3f3f4),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  filled: true,
                                  labelText: "Owner",
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
                                keyboardType: TextInputType.number,
                                key: Key("owner number"),
                                onSaved: (val) => task.ownerNumber = val,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Owner Number",
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
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Driver Name",
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
                              height: getProportionateScreenHeight(70),
                              child: TextFormField(
                                key: Key("Phone number"),
                                keyboardType: TextInputType.phone,
                                onSaved: (val) => task.phonenumber = val,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Phone Number",
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
                          _dateButton(),
                          months.isEmpty
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, right: 16, left: 16),
                                  child: Card(
                                    elevation: 10,
                                    child: Container(
                                      height: getProportionateScreenHeight(150),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'List Selected Month',
                                              style: TextStyle(
                                                color: Colors.black,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                          for (var i = 0;
                                              i < months.length;
                                              i++)
                                            Expanded(
                                              child: Container(
                                                child: Row(
                                                  children: [
                                                    Text(months[i].toString() +
                                                        '/' +
                                                        DateTime.now()
                                                            .year
                                                            .toString()),
                                                    Spacer(),
                                                    IconButton(
                                                      color: Colors.pink,
                                                      icon: Icon(
                                                        Icons.close,
                                                        size: 15,
                                                      ),
                                                      onPressed: () {
                                                        print(months[i]);
                                                        print(i);
                                                        setState(() {
                                                          months.removeAt(i);
                                                        });
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          _submitButton()
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
