import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {

  final String pId;
  final String codigo;
  final String dataCompra;
  final String dataEntrega;
  final String descricao;
  final String imagem;
  final String moedaCompra;
  final String notaFiscal;
  final double preco;
  final double custo;

  ProductModel(this.pId, this.codigo, this.dataCompra, this.dataEntrega, this.descricao, this.imagem, this.moedaCompra, this.notaFiscal, this.preco, this.custo);


  Map<String, dynamic> mapMyProduct() => {
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
  };

  void addProduct(ProductModel product){

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
    );
    
  }

}
