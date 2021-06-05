import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:TaxCollection/screens/dashboard/dashboarduicomponents.dart';
import 'package:TaxCollection/screens/dashboard/drawer.dart';
import 'package:TaxCollection/services/constants.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:TaxCollection/services/usermodel.dart';
import 'package:sizer/sizer.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "/dashboard";
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // int totalVerified;
  // int totalUnVerified;
  // int totalExpired;
  // String stationName;
  // int totalCreatedTp;
  Map<String, double> dataMap;
  // bool isLoading = false;
  // String email;
  // String roles;

  // Future dataStatus() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     setState(() {});
  //     var headers = {"Authorization": "Bearer " + tokens};

  //     final response = await http.get(
  //         'http://41.59.227.103:9092/api/v1/tp-status/$checkpointId/$rolename/$zoneId/$stationId',
  //         headers: headers);
  //     var res;

  //     print(response.statusCode);
  //     switch (response.statusCode) {
  //       case 201:
  //         res = json.decode(response.body);

  //         setState(() {
  //           print(res);
  //           print(stationame);
  //           email = em;
  //           stationName = stationame;
  //           roles = rolename;
  //           totalCreatedTp = res['data'][0]['totalCreatedTp'];
  //           totalUnVerified = res['data'][0]['totalUnVerified'];
  //           totalVerified = res['data'][0]['totalVerified'];
  //           totalExpired = res['data'][0]['totalExpired'];
  //           print(totalCreatedTp);
  //           print(totalUnVerified);
  //           print(totalExpired);
  //           print(totalVerified);
  //           dataMap = {
  //             "Expired Tp": 400,
  //             "Created Tp": totalCreatedTp.toDouble(),
  //             "Unverified Tp": totalUnVerified.toDouble(),
  //             "Verified Tp": totalVerified.toDouble(),
  //           };
  //           isLoading = false;
  //         });
  //         break;

  //       case 401:
  //         setState(() {
  //           res = json.decode(response.body);
  //           isLoading = false;
  //           print(res);
  //         });
  //         break;
  //       default:
  //         setState(() {
  //           res = json.decode(response.body);
  //           isLoading = false;
  //           print(res);
  //         });
  //         break;
  //     }
  //   } on SocketException {
  //     setState(() {
  //       var res = 'Server Error';
  //       isLoading = false;
  //       print(res);
  //     });
  //   }
  // }

  Widget list(String title, String subtitle) {
    return Card(
      elevation: 10,
      shadowColor: kPrimaryColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryColor,
          child: Icon(
            Icons.file_present,
            color: Colors.black,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios_outlined),
      ),
    );
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final User arguments = ModalRoute.of(context).settings.arguments;
    String username = arguments.username.toString();
    String useremail = arguments.useremail.toString();
    return Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          title: Text(
            ' Dashboard',
            style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
          ),
          backgroundColor: kPrimaryColor,
          actions: [popBar(useremail)],
        ),
        body: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              height: 70.0.h,
              child: Stack(
                children: [
                  Container(
                    height: getProportionateScreenHeight(250),
                    width: double.infinity,
                    color: kPrimaryColor,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 10, 0),
                      child: Text(
                        'Logged In As: $username',
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: DashboardUiComponents())
                ],
              ),
            ),
          ]),
        ));
  }

  popBar(String email) {
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: PopupMenuButton(
        tooltip: 'Menu',
        child: Icon(
          Icons.more_vert,
          size: 28.0,
          color: Colors.black,
        ),
        offset: Offset(20, 40),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.supervised_user_circle_rounded,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    email.toString(),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Location: ",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
