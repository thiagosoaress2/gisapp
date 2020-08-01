import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:gisapp/classes/product_class.dart';

class FirebaseUtils {

  FirebaseUtils.empty();

  Future<String> uploadFile(String _path, String _marker, File _image, ProductClass product) async {
    //path é a pasta (se quiser mais de uma pasta no caminho alterar diretamente o código aqui.
    //marker é um marcado para o nome do arquivo. Aqui ele faz com a data em millis..mas se vários usuarios puderem usar ao mesmo tempo adicinar o uid do user.
    //o _img é o arquivo direto pego da camera ou do cel

    String fileName = DateTime.now().millisecondsSinceEpoch.toString()+_marker;
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child(_path)
        .child(fileName);
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      product.imagem = fileURL;
      //ProductClass.upLoadMap(product);
      ProductClass.empty().addToBd(product);
      return fileURL;
    });
  }

  Future<void> deleteFile(String url) async {

    FirebaseStorage.instance
        .getReferenceFromUrl(url)
        .then((reference) => reference.delete())
        .catchError((e) => print(e)
    );

  }

}