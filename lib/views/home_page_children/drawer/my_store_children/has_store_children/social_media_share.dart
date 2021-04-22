import 'dart:io';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class SharePage extends StatefulWidget {
  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {

  GlobalKey _key = new GlobalKey();
  Color grad1 = Color.fromRGBO(204, 18, 18, 1);
  Color grad2 = Color.fromRGBO(252, 8, 8, 1);
  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    this.deleteFile();
  }
//  Future<Uint8List> generateQrCode() async {
//    Uint8List result = await scanner.generateBarCode('$url/v1/storeDetails/${myStoreDetails['id']}');
//    return result;
//  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          RepaintBoundary(
            key: _key,
            child: Container(
              width: double.infinity,
              height: scrh,
              decoration: BoxDecoration(
//                gradient: RadialGradient(
//                  colors: [
//                    kPrimaryColor.withOpacity(0.7),
//                    kPrimaryColor
//                  ]
//                )
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            child: Text(
                              "Download the app and scan the code to order from ${myStoreDetails['name']}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                fontFamily: "Chewy",
                                color: kPrimaryColor
                              ),
                            ),
                          ),
                          //QR CODE
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: Percentage().calculate(num: scrw, percent: 40),
                            height: Percentage().calculate(num: scrw, percent: 40),
                            child: QrImage(
                              data: "$url/v1/storeDetails/${myStoreDetails['id']}",
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(5),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            child: Text("NOTE: Scan this code using only ekaon's QR Scanner",style: TextStyle(
                              fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey
                            ),),
                          ),
                          Container(
                            child: Text(
                                "Available on",
                              style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                  fontFamily: "Chewy",
                              ),
                            ),
                          ),
                          Image.asset("assets/images/store.png",width: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 60),)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset("assets/images/splat.png"),
                          Positioned(
                            top: scrw/5,
                            left: 15,
                            child: Container(
                              width: Percentage().calculate(num: scrw, percent: 70),
                              height: Percentage().calculate(num: scrw, percent: 50),
                              transform: Matrix4.rotationZ(-0.2),
//                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey[100],
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                    image: myStoreDetails['picture'] == null ? AssetImage("assets/images/default_store.png") : NetworkImage("https://ekaon.checkmy.dev${myStoreDetails['picture']}")
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ),
          ),
          Container(
            width: double.infinity,
            height: 60,
//            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: (){
                    Navigator.of(context).pop(null);
                  },
                  icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,color: Colors.black,),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(5))
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  child: InkWell(
                    onTap: (){
                      if(!_isLoading){
                        this.initiateShare();
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 25,
                          height: 25,
                          child: Image.asset("assets/images/share.png",color: Colors.white,),
                        ),
                        Text(" SHARE NOW",style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),)
                      ],
                    ),
                  ),
                )
              ],
            )
          ),
          _isLoading ? MyWidgets().loader() : Container()
        ],
      ),
    );
  }
  Future initiateShare() async {
    final path = await this.getDirectoryPath();
    File imageFile = File('$path/${myStoreDetails['id']}.png');
    if(!await this.checkPhotoExist(imageFile)){
      print("SAVING");
      setState(() {
        _isLoading = true;
      });
      await _capturePhoto();
    }else{
      print("Sharing");
      await this.share();
    }
  }
  Future<bool> checkPhotoExist(File file) async {
    return file.existsSync();
  }
  getDirectoryPath() async {
    Directory appDoc = await getApplicationDocumentsDirectory();
    String path = appDoc.path;
    return path;
  }
  deleteFile() async {
    final path = await this.getDirectoryPath();
    File da = File('$path/${myStoreDetails['id']}.png');
    da.deleteSync();
  }
  saveImage(ByteData data) async {

    final path = await this.getDirectoryPath();
    File imageFile = File('$path/${myStoreDetails['id']}.png');
    await imageFile.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes));
    await this.share();
//    if(!await checkPhotoExist(imageFile)){
//
//    }
  }
  share() async {
    final path = await this.getDirectoryPath();
    Share.shareFiles(['$path/${myStoreDetails['id']}.png'], text: "#Ekaon",);
    setState(() {
      _isLoading = false;
    });
  }
  Future<void> _capturePhoto() {
    setState(() {
      _isLoading = true;
    });
    return new Future.delayed(const Duration(milliseconds: 20), () async {
      RenderRepaintBoundary boundary =
      _key.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
//      Uint8List pngBytes = byteData.buffer.asUint8List();
      await saveImage(byteData);

    });
  }
}
