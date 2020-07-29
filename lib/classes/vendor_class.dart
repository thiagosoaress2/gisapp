import 'package:cloud_firestore/cloud_firestore.dart';

class VendorClass {

  String id;
  String nome;
  double comissao;
  double salario;

  VendorClass(this.id, this.nome, this.comissao, this.salario);

  VendorClass.cad(this.nome, this.comissao, this.salario);

  VendorClass.empty();

  VendorClass.erase(VendorClass vendor){
    vendor.id = null;
    vendor.nome = null;
    vendor.comissao = null;
  }

  Future<bool> addToBd(VendorClass vendor) async {

    //changeState();
    //registrando o pedido no bd dos pedidos
    DocumentReference refOrder = await Firestore.instance.collection("vendedores")
        .add({

      "nome" : vendor.nome,
      "comissao" : vendor.comissao,
      "salario" : vendor.salario,

    });

    return false;

  }

}