import 'dart:async';
import 'dart:convert';
import 'package:ekaon/services/distancer_service.dart';
import 'package:http/http.dart' as http;
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/location_observer.dart';
import 'package:ekaon/services/position_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;
class MapPage extends StatefulWidget {
  String name;
  double longitude = 0;
  double latitude = 0;
  MapPage({Key key, @required this.name, @required this.longitude, @required this.latitude}) : super(key : key);
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Set<Polyline> _polyLines = {};
  Map<PolylineId, Polyline> polylines = {};
  final Set<Marker> _markers = {};
  BitmapDescriptor bitmapIcon;
  Completer<GoogleMapController> _controller = Completer();
  _generateIcon() async{
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(5,5), devicePixelRatio: 10,),"assets/images/").then((value) => setState((){
      bitmapIcon = value;
    }));
  }
  addMarkers(Marker marker) {
    setState(() {
      _markers.add(marker);
    });
  }
  init() async {
    addMarkers(new Marker(
      markerId: MarkerId("myLocation"),
      position: LatLng(myPosition.current.latitude, myPosition.current.longitude),
      infoWindow: InfoWindow(title: "You are here"),
    ));
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: kPrimaryColor,
      points: await distanceService.getPolyLineCoordinates(myPosition.current, Position(
          latitude: widget.latitude,
          longitude: widget.longitude
      )),
    );
    setState(() {
      polylines[id] = polyline;
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _generateIcon();
    Fluttertoast.showToast(msg: "Tap the map to exit");
    setState(() {
      init();
      addMarkers(new Marker(
          markerId: MarkerId("initLocation"),
          position: LatLng(widget.latitude, widget.longitude),
          infoWindow: InfoWindow(title: widget.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    // TODO: implement build
    return myPosition != null ? GoogleMap(
      onTap: (coordinates){
        Navigator.of(context).pop(null);
      },
      polylines: Set<Polyline>.of(polylines.values),
      markers: _markers,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
//        bearing: 192.8334901395799,
          target: LatLng(widget.latitude, widget.longitude),
          tilt: 59.440717697143555,
          zoom: 19.234235263
      ),
      buildingsEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    ) : Container(
      width: double.infinity,
      child: Center(
        child: Container(
          width:  scrw/1.5,
          height: scrw/1.5,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[200],
                    offset: Offset(2,2),
                    blurRadius: 2
                )
              ]
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset("assets/images/location.png"),
                ),
              ),
              Text("Sorry we can't locate your current location, thus, we can't display your location on the map, please turn your location on.",style: TextStyle(
                  color: Colors.black54,
                  fontSize: scrw > 700 ? scrw/40 : scrw/30,
                  fontWeight: FontWeight.w400
              ),textAlign: TextAlign.center,),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                height: scrh > 700 ? scrh/15 : scrh/13,
                child: RaisedButton(
                  color: kPrimaryColor,
                  onPressed: (){
                    LocationStats().locationChecker().then((value) async {
                      var pos = await Geolocator().getCurrentPosition();
                        myPosition.manualUpdate(pos);
                    });
                  },
                  child: Center(
                    child: Text("Reconnect",style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: scrw > 700 ? scrw/40 : scrw/30
                    ),),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
//  final Set<Polyline> _polyLines = {};
//  Set<Polyline> get polyLines => _polyLines;
//  void createRoute(String encondedPoly) {
//    _polyLines.add(
//        Polyline(
//        polylineId: PolylineId(latLng.toString()),
//        width: 4,
//        points: _convertToLatLng(_decodePoly(encondedPoly)),        color: Colors.red));
//  }
  Future getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
    return await http.get(url).then((value) {
      Map data = json.decode(value.body);
      return data["routes"][0]["overview_polyline"]["points"];
    });
  }
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }
  static LatLng latLng;
  void createRoute(String encondedPoly) {
    _polyLines.add(Polyline(
        polylineId: PolylineId(latLng.toString()),
        width: 4,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.red));
  }
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }
}