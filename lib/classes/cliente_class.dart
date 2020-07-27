import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteClass {

  String nome;
  String dataUltimaVenda;
  String ultimoItem;
  double valorDevido;
  double vendasTotais;

  ClienteClass(this.nome, this.dataUltimaVenda, this.ultimoItem, this.valorDevido, this.vendasTotais);

  ClienteClass.empty(){

  }

  Future<bool> addToBd(ClienteClass cliente) async {

    //changeState();
    //registrando o pedido no bd dos pedidos
    DocumentReference refOrder = await Firestore.instance.collection("clientes")
        .add({

      "nome" : cliente.nome,
      "dataUltimaVenda" : "nao",
      "ultimoItem" : "nao",
      "valorDevido" : 0.0,
      "vendasTotais" : 0.0,

    });

    return false;

  }
}