import 'package:cloud_firestore/cloud_firestore.dart';

class EstoqueModels {

  String codigo;
  String dataCompra;
  String dataEntrega;
  double custo;
  String notaFiscal;
  int quantidade;
  String descricao;
  double preco;
  String moeda;

  EstoqueModels(this.codigo, this.dataCompra, this.dataEntrega, this.custo, this.notaFiscal, this.quantidade, this.descricao, this.preco, this.moeda);

  EstoqueModels.empty();

  void saveChangesInProdc(EstoqueModels product, String id) async {

    Firestore.instance.collection("produtos").document(id).updateData({

      'codigo': product.codigo,
      'dataCompra': product.dataCompra,
      'dataEntrega': product.dataEntrega,
      'descricao': product.descricao,
      'moedaCompra': product.moeda,
      'notaFiscal': product.notaFiscal,
      'preco': product.preco,
      'custo': product.custo,
      'quantidade' : product.quantidade,

    });


  }

  void deleteProduct(String id){

    Firestore.instance.collection("produtos").document(id).delete().whenComplete(() => print("Apagado"));

  }



}