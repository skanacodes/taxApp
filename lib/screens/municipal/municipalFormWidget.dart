import 'package:TaxCollection/screens/municipal/municipalForm.dart';
import 'package:TaxCollection/screens/publicMotors/publicmotorFormScreen.dart';
import 'package:TaxCollection/services/constants.dart';

import 'package:TaxCollection/services/size_config.dart';
import 'package:flutter/material.dart';

class MunicipalFormWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: getProportionateScreenHeight(400),
        child: Column(
          children: <Widget>[
            Container(
              height: getProportionateScreenHeight(140),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: getProportionateScreenHeight(100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(100),
                          bottomRight: Radius.circular(100)),
                      color: kPrimaryColor,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        elevation: 20,
                        child: ListTile(
                            tileColor: Colors.white,
                            title: Text(
                              'Catre Municipal Registration',
                              style: TextStyle(color: Colors.black),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.pink,
                              child: Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Adding the form here
            MunicipalForm()
          ],
        ),
      ),
    );
  }
}
