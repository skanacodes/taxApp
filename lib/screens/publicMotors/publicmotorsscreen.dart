import 'package:TaxCollection/screens/publicMotors/publicMotorSearch.dart';
import 'package:TaxCollection/screens/publicMotors/publicMotorcat.dart';
import 'package:TaxCollection/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

class PublicMotorsScreen extends StatefulWidget {
  static String routeName = "/publicMotors";
  @override
  _PublicMotorsScreenState createState() => _PublicMotorsScreenState();
}

class _PublicMotorsScreenState extends State<PublicMotorsScreen> {
  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Public Motors',
          style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
        ),
      ),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            PublicMotorSearch(),
            NewTaskScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        showElevation: true,
        containerHeight: 50,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text(
                'Search ',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(
                Icons.search,
                color: Colors.pink,
              )),
          BottomNavyBarItem(
              title: Text(
                'Register',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(
                Icons.add,
                color: Colors.purple,
              )),
        ],
      ),
    );
  }
}
