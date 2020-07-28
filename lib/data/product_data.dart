import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gisapp/classes/product_class.dart';

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

  void addToBd(ProductClass product) async {

    Firestore.instance.collection("produtos").add(
        {
          'productId' : product.pId,
          'codigo' : product.codigo,
          'dataCompra' : product.dataCompra,
          'dataEntrega' : product.dataEntrega,
          'descricao' : product.descricao,
          'imagem' : product.imagem,
          'moedaCompra' : product.moedaCompra,
          'notaFiscal' : product.notaFiscal,
          'preco' : product.preco,
          'custo' : product.custo,
        }
    ).then((value) {
      
      Firestore.instance.collection("produtos").document(value.documentID).setData({
        'productId' : value.documentID.toString()
      });

    });

  }

}