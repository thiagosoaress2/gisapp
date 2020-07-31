import 'package:cloud_firestore/cloud_firestore.dart';

class EstoqueModels {

  List<DocumentSnapshot> documents;

  void copyList(List<DocumentSnapshot> documentOriginal){
    documents = documentOriginal;
  }



}