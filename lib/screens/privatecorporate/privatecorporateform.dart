import 'dart:convert';

import 'package:TaxCollection/screens/publicMotors/publicmotormodal.dart';
import 'package:TaxCollection/services/constants.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class PrivateCorporateForm extends StatefulWidget {
  @override
  _PrivateCorporateFormState createState() => _PrivateCorporateFormState();
}

class _PrivateCorporateFormState extends State<PrivateCorporateForm> {
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
        'http://parking.technolemon.com/index.php?r=mobile-api-corporate/parking-sale-corporate',
        body: jsonEncode({
          "customer_name": task.customerName,
          "phone_number": task.phonenumber,
          "contact_personal": task.contactperson,
          "contact_number": task.contactnumber,
          "slot_code": task.slotcode,
          "no_parking": task.noOfParking,
          "generate_month_bill": months,
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

  Future<void> getToken() async {
    tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
  }

  @override
  void initState() {
    super.initState();
    this.getToken();

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

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Fill',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 20.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryLightColor,
          ),
          children: [
            TextSpan(
              text: ' Registration ',
              style: TextStyle(color: Colors.black, fontSize: 20.0.sp),
            ),
            TextSpan(
              text: ' Form',
              style: TextStyle(color: Colors.green[200], fontSize: 20.0.sp),
            ),
          ]),
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
          print(task.customerName);
          print(task.phonenumber);
          print(task.contactperson);
          print(task.contactnumber);
          print(task.slotcode);
          print(task.noOfParking);
          print(months);

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
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 10,
                      shadowColor: kPrimaryColor,
                      child: Column(
                        children: <Widget>[
                          // Padding(
                          //   padding:
                          //       const EdgeInsets.only(top: 16, right: 18, left: 18),
                          //   child: SafeArea(
                          //     child: data.isEmpty
                          //         ? SpinKitDualRing(
                          //             color: Colors.cyan,
                          //             size: getProportionateScreenHeight(40),
                          //           )
                          //         : Container(
                          //             decoration: BoxDecoration(
                          //               color: Colors.white,
                          //               borderRadius:
                          //                   BorderRadius.all(Radius.circular(30)),
                          //             ),
                          //             child: Center(
                          //               child: new DropdownButtonFormField(
                          //                 itemHeight: 50,
                          //                 decoration: InputDecoration(
                          //                   focusedBorder: OutlineInputBorder(
                          //                     borderRadius:
                          //                         BorderRadius.circular(10.0),
                          //                     borderSide: BorderSide(
                          //                       color: Colors.cyan,
                          //                     ),
                          //                   ),
                          //                   enabledBorder: OutlineInputBorder(
                          //                     borderRadius:
                          //                         BorderRadius.circular(10.0),
                          //                     borderSide: BorderSide(
                          //                       color: Colors.black38,
                          //                       width: 1.0,
                          //                     ),
                          //                   ),
                          //                   fillColor: Color(0xfff3f3f4),
                          //                   filled: true,
                          //                   labelText: "Select Vehicle Type",
                          //                   border: OutlineInputBorder(
                          //                     borderRadius:
                          //                         new BorderRadius.circular(10),
                          //                   ),
                          //                   isDense: true,
                          //                 ),
                          //                 isDense: true,
                          //                 validator: (value) => value == null
                          //                     ? "This Field is Required"
                          //                     : null,
                          //                 items: data.map((item) {
                          //                   return new DropdownMenuItem(
                          //                     child: new Text(item['name']),
                          //                     value: item['id'].toString(),
                          //                   );
                          //                 }).toList(),
                          //                 onChanged: (newVal) {
                          //                   setState(() {
                          //                     task.vehicletype = newVal;
                          //                   });
                          //                 },
                          //                 value: task.vehicletype,
                          //               ),
                          //             ),
                          //           ),
                          //   ),
                          // ),
                          _title(),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 16, left: 16),
                            child: Container(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                key: Key("customername"),
                                onSaved: (val) => task.customerName = val,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Customer Name",
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
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Enter Phone Number",
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
                                onSaved: (val) => task.contactperson = val,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Enter Contact Person",
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
                                key: Key("contactnumber"),
                                onSaved: (val) => task.contactnumber = val,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Contact Number",
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
                                top: 16, right: 16, left: 16),
                            child: Container(
                              child: TextFormField(
                                key: Key("SlotCode"),
                                keyboardType: TextInputType.phone,
                                onSaved: (val) =>
                                    task.slotcode = int.parse(val),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Enter Slot Code",
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
                                top: 16, right: 16, left: 16),
                            child: Container(
                              child: TextFormField(
                                key: Key("noParking"),
                                keyboardType: TextInputType.phone,
                                onSaved: (val) =>
                                    task.noOfParking = int.parse(val),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Enter Number of Parking",
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
