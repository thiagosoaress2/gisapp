import 'package:cloud_firestore/cloud_firestore.dart';

class VendorClass {

  String id;
  String nome;
  double comissao;
  double salario;
  int modalidade;

  VendorClass(this.id, this.nome, this.comissao, this.salario, this.modalidade);

  VendorClass.cad(this.nome, this.comissao, this.salario, this.modalidade);

  VendorClass.empty();

  VendorClass.erase(VendorClass vendor){
    vendor.id = null;
    vendor.nome = null;
    vendor.comissao = null;
    vendor.modalidade = null;
  }

  Future<bool> addToBd(VendorClass vendor) async {

    //changeState();
    //registrando o pedido no bd dos pedidos
    DocumentReference refOrder = await Firestore.instance.collection("vendedores")
        .add({

      "nome" : vendor.nome,
      "comissao" : vendor.comissao,
      "salario" : vendor.salario,
      "modalidade" : vendor.modalidade,

    });

    return false;

  }

  Future<bool> updateClienteInfo(VendorClass vendor) async {

    Firestore.instance
        .collection('vendedores')
        .document(vendor.id)
        .updateData({
      "comissao" : vendor.comissao,
      'salario' : vendor.salario,
      "modalidade" : vendor.modalidade,
    });
  }

}