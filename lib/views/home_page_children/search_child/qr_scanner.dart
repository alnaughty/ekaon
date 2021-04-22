import 'dart:io';

import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/store.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerPage extends StatefulWidget {
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        qrText = scanData;
        _isLoading = true;
        this.controller.pauseCamera();
      });
      print(qrText);
      await getDetails();
    });
  }
  getDetails() async {
    await Store().details(qrText).then((value) {
      if(value != null){
        Navigator.pushReplacement(context, PageTransition(child: StoreDetailsPage(data: value),type: PageTransitionType.leftToRightWithFade ));
      }
      setState(() {
        _isLoading = false;
        this.controller.resumeCamera();
      });
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    this.controller.dispose();
  }
  var qrText = '';
  bool _isLoading = false;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: Platform.isIOS,
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.red,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 60,
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                onPressed: ()=>Navigator.of(context).pop(null),
                icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,color: Colors.white54,),
              ),
            ),
            _isLoading ? MyWidgets().loader() : Container()
          ],
        ),
      ),
    );
  }
}
