import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class PhotoService extends ChangeNotifier {

  File image=null;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    notifyListeners();
    image = File(pickedFile.path);
    notifyListeners();
  }

  File get consultFileState => image;



}