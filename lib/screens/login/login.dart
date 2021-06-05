import 'dart:convert';

//import 'package:TaxCollection/screens/dashboard/dashboardScreen.dart';
import 'package:TaxCollection/screens/dashboard/dashboardScreen.dart';
import 'package:TaxCollection/screens/login/Widget/bezierContainer.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:TaxCollection/services/usermodel.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';

import 'package:TaxCollection/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:TaxCollection/services/form_error.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/login";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isaUser = false;
  bool isLoading = false;
  String username;
  String useremail;
  String password;
  String auth = '';
  final List<String> errors = [];
  var roles = [];

  Future<void> createUser(
    String token,
    String username,
    String email,
  ) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('token', token);
      prefs.setString('username', username);

      prefs.setString('email', email);
    });
  }

  Future getUserDetails() async {
    try {
      final response = await http.post(
        'http://parking.technolemon.com/index.php?r=mobile-apia/login',
        body: jsonEncode({"username": username, "password": password}),
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          if (res['message'] == 'Login successfully') {
            setState(() {
              auth = 'success';
              useremail = res['user']['email'];
            });

            await createUser(res['user']['token'], res['user']['username'],
                res['user']['email']);
          } else if (res['message'] == 'Invalid username or password') {
            addError(error: 'Incorrect Password or Email');
          } else {
            addError(error: 'Something Went Wrong');
          }

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            addError(error: 'Something Went Wrong');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);

        addError(error: 'Server Or Network Connectivity Error');
      });
    }
  }

  void addError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  Widget _entryField(String title, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: TextFormField(
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      errors.contains('Network Problem')
                          ? removeError(
                              error: 'Server Or Network Connectivity Error')
                          : errors.contains('Incorrect Password or Email')
                              ? removeError(
                                  error: 'Incorrect Password or Email')
                              : removeError(
                                  error:
                                      'Your Not Authourized To Use This App');
                    }
                    return null;
                  },
                  validator: (value) =>
                      value == '' ? 'This  Field Is Required' : null,
                  onSaved: (value) {
                    setState(() {
                      isPassword ? password = value : username = value;
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: kPrimaryColor,
                  obscureText: isPassword,
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(30, 20, 20, 10),
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true)),
            )
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState.validate()) {
          setState(() {
            isLoading = true;
          });
          _formKey.currentState.save();
          await getUserDetails();

          if (auth == 'success') {
            Navigator.pushNamed(context, DashboardScreen.routeName,
                arguments: User(useremail: useremail, username: username));
          }
        }
        setState(() {
          isLoading = false;
        });
      },
      child: isLoading
          ? SpinKitDualRing(
              color: kPrimaryColor,
              size: 20.0.sp,
            )
          : Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [kPrimaryColor, Colors.green[50]])),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 13.0.sp, color: Colors.white),
                ),
              ),
            ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('Burundi@2021'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Municipalite',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 20.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: ' De',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: ' Bujumbura',
              style: TextStyle(
                color: kPrimaryLightColor,
              ),
            ),
          ]),
    );
  }

  Widget _title2() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Tax',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: ' Collection',
              style: TextStyle(color: Colors.black, fontSize: 15.0.sp),
            ),
            TextSpan(
              text: ' App',
              style: TextStyle(color: kPrimaryColor, fontSize: 15.0.sp),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Username"),
        _entryField("Password", isPassword: true),
      ],
    );
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .16,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 13.0.h),
                      _title(),
                      Container(
                        decoration: BoxDecoration(
                            // border: Border.all(
                            //     color: Colors.cyan,
                            //     style: BorderStyle.solid,
                            //     width: 1),
                            ),
                        height: getProportionateScreenHeight(150),
                        width: getProportionateScreenHeight(150),
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      _title2(),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      _emailPasswordWidget(),
                      FormError(errors: errors),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      _submitButton(),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      _divider(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
