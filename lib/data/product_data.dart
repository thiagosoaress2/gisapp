import 'package:cloud_firestore/cloud_firestore.dart';

class ProductData {

  String pId;
  String codigo;
  String dataCompra;
  String dataEntrega;
  String descricao;
  String imagem;
  String moedaCompra;
  String notaFiscal;
  double preco;
  double custo;

  ProductData();

  ProductData.fromDocument(DocumentSnapshot document){
    pId = document.documentID;
    codigo = document.data["codigo"];
    dataCompra = document.data["dataCompra"];
    dataEntrega = document.data["dataEntrega"];
    descricao = document.data["descricao"];
    imagem = document.data["imagem"];
    moedaCompra = document.data["moedaCompra"];
    notaFiscal = document.data["notaFiscal"];
    preco = document.data["preco"];
    custo = document.data["custo"];
  }

  Map<String, dynamic> toMap() {
    return{
      "productId" : pId,
      "codigo" : codigo
    };

  }

  void addToBd() async {

    Firestore.instance.collection("produtos").add(
        {
          'productId' : pId,
          'codigo' : codigo,
          'dataCompra' : dataCompra,
          'dataEntrega' : dataEntrega,
          'descricao' : descricao,
          'imagem' : imagem,
          'moedaCompra' : moedaCompra,
          'notaFiscal' : notaFiscal,
          'preco' : preco,
          'custo' : custo,
        }
    ).then((value) {
      
      Firestore.instance.collection("produtos").document(value.documentID).setData({
        'productId' : value.documentID.toString()
      });

    });

  }

}