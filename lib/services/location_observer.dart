import 'package:fluttertoast/fluttertoast.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';


class LocationStats{
  Future<bool> locationChecker() async {
    ServiceStatus _serviceStatus = await LocationPermissions().checkServiceStatus();
    PermissionStatus _permStatus = await LocationPermissions().checkPermissionStatus();
    bool enabled = (_serviceStatus == ServiceStatus.enabled && _permStatus == PermissionStatus.granted);
    if(!enabled){
      Fluttertoast.showToast(msg: "You're location is still disabled");
    }
//    locationIsEnabled = enabled;
    return enabled;
  }
}
