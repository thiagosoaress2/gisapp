import 'package:cloud_firestore/cloud_firestore.dart';

class EstoqueModels {

  List<DocumentSnapshot> documents;

  EstoqueModels.empty();

  void copyList(List<DocumentSnapshot> documentOriginal){
    documents = documentOriginal;
  }

  //List<DocumentSnapshot> get getDoc => documents;

  List<DocumentSnapshot> getDoc (){

    print("lero");
    return documents;
  }

}