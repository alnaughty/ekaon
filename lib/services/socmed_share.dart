import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class SocmedShare{
   convertWidgetToImage(GlobalKey key) async {
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 4.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    String base64Image = base64Encode(pngBytes);
    return imageReturner(pngBytes);
  }
  MemoryImage imageReturner(Uint8List byteData){
     return MemoryImage(byteData);
  }


}