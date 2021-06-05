import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:TaxCollection/services/constants.dart';
import 'package:TaxCollection/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PublicReportScreen extends StatefulWidget {
  static String routeName = "/publicreport";
  final String transactionId;
  PublicReportScreen({this.transactionId});

  @override
  _PublicReportScreenState createState() => _PublicReportScreenState();
}

class _PublicReportScreenState extends State<PublicReportScreen> {
  var data;
  bool isLoading = false;

  Future privatereceipt(String id) async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      print(id);
      final response = await http.get(
        'http://parking.technolemon.com//index.php?r=mobile-api-public/receive-payment&token=$tokens&transaction_id=$id',
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
          });

          print(res);
          setState(() {
            data = res['data'];
          });

          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            message('Something Went Wrong', 'error');
            print(res);
          });
          break;
        default:
          setState(() {
            // res = json.decode(response.body);
            print('df');
            message('Something Went Wrong', 'error');
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        message('Connectivity Or Server Error', 'error');
        print(res);
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
            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show();
  }

  @override
  void initState() {
    privatereceipt(widget.transactionId);

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Print Customer Bill',
          style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
        ),
      ),
      body: data == null
          ? Center(
              child: Container(
                height: getProportionateScreenHeight(400),
                child: SpinKitDualRing(
                  color: Colors.cyan,
                  size: 30,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                child: isLoading
                    ? Container(
                        height: getProportionateScreenHeight(200),
                        child: Center(
                          child: CupertinoActivityIndicator(
                            animating: true,
                            radius: 30,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              // height: isNotFpund
                              //     ? getProportionateScreenHeight(100)
                              //     : getProportionateScreenHeight(300),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 10,
                                        color: Colors.grey,
                                        spreadRadius: 3,
                                        offset: Offset.zero)
                                  ],
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20))),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          color: kPrimaryColor,
                                        ),
                                        SizedBox(
                                          width:
                                              getProportionateScreenWidth(10),
                                        ),
                                        Text(
                                          'Public Data',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Spacer(),
                                        Container(
                                          width:
                                              getProportionateScreenWidth(80),
                                          height:
                                              getProportionateScreenHeight(50),
                                          decoration: BoxDecoration(
                                              color: Colors.cyan,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () async {
                                                await prints();
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Icon(Icons.print_outlined),
                                                  Text(
                                                    'Print',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: kPrimaryColor,
                                    height: getProportionateScreenHeight(10),
                                    thickness: 1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(
                                      child: Container(
                                          height:
                                              getProportionateScreenHeight(200),
                                          width:
                                              getProportionateScreenWidth(200),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.cyan,
                                                  style: BorderStyle.solid,
                                                  width: 1)),
                                          child: Image.asset(
                                              'assets/images/logo.jpeg')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      children: [
                                        Text(
                                            '-----------------------------------------------------------'),
                                        Text(
                                          'AHA EJO HEZA',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Text(
                                          ' Socie \'te\' multservices',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Text(
                                            '-----------------------------------------------------------'),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(child: Text('Customer Code:')),
                                        Expanded(
                                            child: Text(
                                                data['customer_code']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black))),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text('Customer Name:')),
                                        Expanded(
                                            child: Text(
                                                data['owner'].toString(),
                                                style: TextStyle(
                                                    color: Colors.black))),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text('Plate Number:')),
                                        Expanded(
                                            child: Text(
                                                data['plate_number'].toString(),
                                                style: TextStyle(
                                                    color: Colors.black))),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 30,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text('Amount:')),
                                        Expanded(
                                            child: Text(
                                                data['amount'].toString(),
                                                style: TextStyle(
                                                    color: Colors.black))),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Text('Control Number:')),
                                        Expanded(
                                            child: Text(
                                                data['control_number']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black))),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 30,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text('Date:')),
                                        Expanded(
                                            child: Text(formattedDate,
                                                style: TextStyle(
                                                    color: Colors.black))),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            '----------------------------------------------------------',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        QrImage(
                                          data: data['customer_id'].toString(),
                                          version: QrVersions.auto,
                                          size: 120,
                                          gapless: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Genuine Receipt for the cash Received',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
              ),
            ),
    );
  }

  prints() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    final doc = pw.Document();

    final image = await imageFromAssetBundle('assets/images/logo.jpeg');
    final ttf =
        await fontFromAssetBundle('assets/fonts/ubuntu/Ubuntu-Regular.ttf');
    const double inch = 72.0;
    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat(7 * inch, double.infinity, marginLeft: 5),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Divider(height: 2, thickness: 3, color: PdfColors.black),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(
                  child: pw.Container(
                    height: 250,
                    width: 250,
                    decoration: pw.BoxDecoration(
                        //color: Colors.white,
                        borderRadius: pw.BorderRadius.circular(20),
                        border: pw.Border.all(
                            color: PdfColors.cyan,
                            style: pw.BorderStyle.solid,
                            width: 1)),
                    child: pw.Center(
                      child: pw.Image(image),
                    ),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                        '--------------------------------------------------------------------------',
                        style:
                            pw.TextStyle(fontSize: 20, color: PdfColors.black)),
                    pw.Text('AHA EJO HEZA',
                        style: pw.TextStyle(
                            fontSize: 25, font: ttf, color: PdfColors.black)),
                    pw.Text(' Socie \'te\' multservices',
                        style: pw.TextStyle(
                            fontSize: 20, font: ttf, color: PdfColors.black)),
                    pw.Text(
                        '--------------------------------------------------------------------------',
                        style:
                            pw.TextStyle(fontSize: 20, color: PdfColors.black)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Customer Code:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(data['customer_code'].toString(),
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Customer Name:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(data['customer_id'].toString(),
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Plate Number:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('B700',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Amount:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(data['amount'].toString(),
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Control Number:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(data['control_number'].toString(),
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Date:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(formattedDate,
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Divider(thickness: 3, color: PdfColors.black),
              pw.Container(
                height: 150,
                width: 150,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.BarcodeWidget(
                      data: data['customer_id'].toString(),
                      barcode: pw.Barcode.qrCode(),
                      color: PdfColors.black),
                ),
              ),
            ],
          );
        }));
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}
