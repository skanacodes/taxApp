import 'package:TaxCollection/screens/dashboard/dashboardScreen.dart';
import 'package:TaxCollection/screens/login/login.dart';
import 'package:TaxCollection/screens/municipal/municipalScreen.dart';
import 'package:TaxCollection/screens/privatecorporate/corporateBilling.dart';
import 'package:TaxCollection/screens/privatecorporate/privatecorporatescreen.dart';
import 'package:TaxCollection/screens/privatemotors/privateMotors.dart';
import 'package:TaxCollection/screens/publicMotors/publicmotorsscreen.dart';
import 'package:TaxCollection/screens/publicMotors/publicreportscreen.dart';
import 'package:TaxCollection/screens/roadToll/roadTollreport.dart';
import 'package:TaxCollection/screens/roadToll/roadtollscreen.dart';
import 'package:TaxCollection/screens/splash/splashscreen.dart';
import 'package:flutter/widgets.dart';
import 'package:TaxCollection/screens/privatemotors/privatemotorreport.dart';
import 'package:TaxCollection/screens/privatecorporate/privatecorporatereport.dart';
import 'package:TaxCollection/screens/municipal/municipalReportScreen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  DashboardScreen.routeName: (context) => DashboardScreen(),
  PublicMotorsScreen.routeName: (context) => PublicMotorsScreen(),
  PrivateMotorsScreen.routeName: (context) => PrivateMotorsScreen(),
  RoadTollScreen.routeName: (context) => RoadTollScreen(),
  PrivateCorporateScreen.routeName: (context) => PrivateCorporateScreen(),
  PublicReportScreen.routeName: (context) => PublicReportScreen(),
  PrivateReport.routeName: (context) => PrivateReport(),
  RoadTollReport.routeName: (context) => RoadTollReport(),
  CorporateBilling.routeName: (context) => CorporateBilling(),
  PrivateCorporateReportScreen.routeName: (context) =>
      PrivateCorporateReportScreen(),
  MunicipalScreen.routeName: (context) => MunicipalScreen(),
  MunicipalReportScreen.routeName: (context) => MunicipalReportScreen()
};
