import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gisapp/Utils/permissions_service.dart';
import 'package:gisapp/Utils/photo_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';


class CadProdPage extends StatefulWidget {
  @override
  _CadProdPageState createState() => _CadProdPageState();
}

class _CadProdPageState extends State<CadProdPage> {

  bool permissions=false;

  @override
  void initState() {
    super.initState();

    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<photo>(
      create: (context) => photo(),
      child: Scaffold(
          appBar: AppBar(
            title: Text("Cadastrando peça"),
            centerTitle: true,
            backgroundColor: Theme
                .of(context)
                .primaryColor,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 30.0,),
              Container(
                height: 30.0,
                alignment: Alignment.center,
                child: Text("Upload da foto",
                  style: TextStyle(fontSize: 22.0, color: Colors.grey[500],),),
              ),
              IconButton(
                  iconSize: 70.0,
                  padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 8.0),
                  icon: Icon(Icons.photo_camera, color: Colors.blueAccent),
                  onPressed: () async {

                    if(permissions){

                      //PhotoService().getImage();
                      photo().getImage();

                    } else {

                      PermissionsService().checkCameraPermission();

                    }
                  }
              ),
          Consumer<photo>(
            builder: (context, model, child) => Center(
              child: Provider.of<photo>(context).consultFileState == null
                    ? Text('Nenhuma imagem selecionada.')
                    : Image.file(PhotoService().image),

            ),
          ),

              /*
              Consumer<PhotoService>(
              builder: (context, myModel, child){
                return Center(

                  child: PhotoService().image == null
                      ? Text('Nenhuma imagem selecionada.')
                      : Image.file(PhotoService().image),
                );
              }
              )

               */

              /*
            Center(
              child: PhotoService().image == null
                  ? Text('Nenhuma imagem selecionada.')
                  : Image.file(PhotoService().image),
            ),
             */



            ],
          )
      ),
    );
  }

  checkCameraPermissionStatus() async {
    //se o user nao tiver dado permissão, vai aparecer na tela. Se já tiver, vai retornar true

    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      //Permission.storage,
    ].request();
    print(statuses[Permission.camera]);

    if (await Permission.camera.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    }

    if(statuses[Permission.camera].toString() == "PermissionStatus.granted"){
      permissions = true;
    } else {
      permissions = false;
    }

  }

  checkPermission() async {

    permissions = await PermissionsService().checkCameraPermission();

  }



}


class photo extends ChangeNotifier {

  Future getImage() async {

    final pickedFile = await PhotoService().picker.getImage(source: ImageSource.gallery);

    PhotoService().image = File(pickedFile.path);
    notifyListeners();

  }

  File get consultFileState => PhotoService().image;

}


