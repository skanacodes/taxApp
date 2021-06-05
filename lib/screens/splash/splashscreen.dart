import 'dart:async';
import 'package:sizer/sizer.dart';
//import 'package:TaxCollection/screens/login/login.dart';
import 'package:TaxCollection/screens/login/login.dart';
import 'package:TaxCollection/services/constants.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();

    Timer(Duration(seconds: 10), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
      // SharedPreferences.getInstance().then((prefs) {
      //   print(prefs.get('id').toString());
      //   if (prefs.get('id').toString() != 'null') {
      //     // Navigator.push(context,
      //     //     MaterialPageRoute(builder: (context) => InventoryListScreen()));
      //   } else {
      //     Navigator.push(
      //         context, MaterialPageRoute(builder: (context) => LoginScreen()));
      //   }
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    SizeConfig().init(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20.0.h,
          ),
          SizedBox(
            width: getProportionateScreenWidth(250),
            child: ColorizeAnimatedTextKit(
              onTap: () {
                print("Tap Event");
              },
              text: [
                "Municipal De Bujumbura",
                "    Tax Collection App",
              ],
              textStyle: TextStyle(
                fontSize: 15.0.sp,
                fontFamily: "Ubuntu",
              ),
              colors: [
                Colors.black,
                Colors.blue,
                Colors.yellow,
                kPrimaryColor,
              ],
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            height: 25.0.h,
            width: 40.0.w,
            child: Image.asset(
              'assets/images/logo.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 20.0.h,
          ),
          SpinKitDualRing(
            color: Colors.black54,
            size: 25.0.sp,
          )
        ],
      ),
    );
  }
}
