import 'dart:ui';

import 'package:TaxCollection/screens/roadToll/roadTollwidget.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:TaxCollection/screens/roadToll/roadTollSearch.dart';
import 'package:TaxCollection/services/constants.dart';

import 'package:flutter/material.dart';

class RoadTollScreen extends StatefulWidget {
  static String routeName = "/roadTolls";
  @override
  _RoadTollScreenState createState() => _RoadTollScreenState();
}

class _RoadTollScreenState extends State<RoadTollScreen> {
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
          'Road Toll',
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
            RoadTollSearch(),
            RoadTollWidget(),
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
