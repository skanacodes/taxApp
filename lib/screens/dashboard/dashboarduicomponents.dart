import 'package:TaxCollection/screens/municipal/municipalScreen.dart';
import 'package:TaxCollection/screens/privatecorporate/privatecorporatescreen.dart';
import 'package:TaxCollection/screens/privatemotors/privateMotors.dart';
import 'package:TaxCollection/screens/publicMotors/publicmotorsscreen.dart';
import 'package:TaxCollection/screens/roadToll/roadtollscreen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:TaxCollection/services/constants.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DashboardUiComponents extends StatefulWidget {
  final String role;
  DashboardUiComponents({this.role});
  @override
  _DashboardUiComponentsState createState() => _DashboardUiComponentsState();
}

class _DashboardUiComponentsState extends State<DashboardUiComponents> {
  Widget gridTile(
    String title,
    Icon icon,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: getProportionateScreenHeight(50),
        width: getProportionateScreenWidth(152),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: 2, color: Color(0xfff3f3f4), offset: Offset.zero),
            ],
            border: Border.all(
                color: Colors.cyan[500], style: BorderStyle.solid, width: 1),
            borderRadius: BorderRadius.circular(10)),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: icon),
            Expanded(child: SizedBox()),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            )
          ],
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0.h,
      width: getProportionateScreenWidth(350),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: kPrimaryColor, blurRadius: 10, offset: Offset.zero)
          ],
          border: Border.all(
              color: Colors.black26, style: BorderStyle.solid, width: 1)),
      child: AnimationLimiter(
        child: Align(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 0,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 2,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                delay: const Duration(milliseconds: 375),
                curve: Curves.easeOutQuad,
                duration: const Duration(milliseconds: 600),
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => PublicMotorsScreen()));
                  },
                  child: gridTile(
                    'Dashboard',
                    Icon(
                      Icons.bar_chart_sharp,
                      size: getProportionateScreenHeight(70),
                      color: Colors.cyan,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PublicMotorsScreen()));
                  },
                  child: gridTile(
                      'Public Transport',
                      Icon(
                        Icons.emoji_transportation_outlined,
                        size: getProportionateScreenHeight(70),
                        color: Colors.green[300],
                      )),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivateMotorsScreen()));
                  },
                  child: gridTile(
                      'Private Transport',
                      Icon(
                        Icons.airport_shuttle_rounded,
                        size: getProportionateScreenHeight(70),
                        color: Colors.red[300],
                      )),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MunicipalScreen()));
                  },
                  child: gridTile(
                      'Catre Municipal',
                      Icon(
                        Icons.meeting_room_outlined,
                        size: getProportionateScreenHeight(70),
                        color: Colors.blue,
                      )),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivateCorporateScreen()));
                  },
                  child: gridTile(
                      'Private Company',
                      Icon(
                        Icons.flip_to_back_rounded,
                        size: getProportionateScreenHeight(70),
                        color: Colors.pink,
                      )),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RoadTollScreen()));
                  },
                  child: gridTile(
                      'Road Barrier',
                      Icon(
                        Icons.edit_road_outlined,
                        size: getProportionateScreenHeight(70),
                        color: Colors.purple,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
