import 'package:permission_handler/permission_handler.dart';

class PermissionsService {


  Future<bool> checkCameraPermission() async {
    //se o user nao tiver dado permissão, vai aparecer na tela. Se já tiver, vai retornar true

    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();
    print(statuses[Permission.camera]);

    if (await Permission.camera.isPermanentlyDenied || await Permission.storage.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    }

    if(statuses[Permission.camera].toString() == "PermissionStatus.granted" && statuses[Permission.storage].toString() == "PermissionStatus.granted"){
      return true;
    } else {
      return false;
    }

  }

}