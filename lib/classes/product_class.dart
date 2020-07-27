import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gisapp/pages/cad_prod_page.dart';
import 'package:mobx/mobx.dart';

class ProductClass {

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


  //construtor
  ProductClass(this.pId, this.codigo, this.dataCompra, this.dataEntrega,
      this.descricao, this.imagem, this.moedaCompra, this.notaFiscal,
      this.preco, this.custo){
  }


  ProductClass updateImageInfo(ProductClass productClass, String urlImg) {
    productClass.imagem = urlImg;
    return productClass;
  }

  ProductClass.empty();

  Future<bool> addToBd(ProductClass product) async {

    //registrando o pedido no bd dos pedidos
    DocumentReference refOrder = await Firestore.instance.collection("produtos")
        .add({

      'productId': product.pId, //aqui ainda é not
      'codigo': product.codigo,
      'dataCompra': product.dataCompra,
      'dataEntrega': product.dataEntrega,
      'descricao': product.descricao,
      'imagem': product.imagem, //imagem já tem
      'moedaCompra': product.moedaCompra,
      'notaFiscal': product.notaFiscal,
      'preco': product.preco,
      'custo': product.custo,


    }).then((value) {

      final CollectionReference collectionReference = Firestore.instance.collection("produtos");
      collectionReference.document(value.documentID)
          .updateData({"productId": value.documentID.toString()})
          .whenComplete(() async {

            product.pId = value.documentID;

      }).catchError((e) => (){

      });
    }
    );

    return false;

  }
}