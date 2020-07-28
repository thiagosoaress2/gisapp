import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteClass {

  String clienteId;
  String nome;
  String dataUltimaVenda;
  String ultimoItem;
  double valorDevido;
  double vendasTotais;

  ClienteClass(this.clienteId, this.nome, this.dataUltimaVenda, this.ultimoItem, this.valorDevido, this.vendasTotais);

  ClienteClass.empty(){

  }

  ClienteClass.ClienteSell(this.nome, this.vendasTotais, this.clienteId);

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

  ClienteClass.erase(ClienteClass cliente){
    cliente.clienteId = null;
    cliente.nome = null;
    cliente.dataUltimaVenda = null;
    cliente.ultimoItem = null;
    cliente.valorDevido = null;
    cliente.vendasTotais = null;
  }

  ClienteClass.ClienteSellErase(ClienteClass cliente){
    cliente.nome = null;
    cliente.vendasTotais = null;
    cliente.clienteId = null;
  }
}