import 'package:cloud_firestore/cloud_firestore.dart';

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
  int quantidade;


  //construtor
  ProductClass(this.pId, this.codigo, this.dataCompra, this.dataEntrega,
      this.descricao, this.imagem, this.moedaCompra, this.notaFiscal,
      this.preco, this.custo, this.quantidade){
  }

  ProductClass.toSellProduct(this.pId, this.imagem, this.codigo, this.preco, this.descricao);

  void completeProductToSell (ProductClass product, String _pId, String _image, String _codigo, double _preco, _descricao, _quantidade){

    product.pId = _pId;
    product.imagem = _image;
    product.codigo = _codigo;
    product.preco = _preco;
    product.descricao = _descricao;
    product.quantidade = _quantidade;
  }


  ProductClass updateImageInfo(ProductClass productClass, String urlImg) {
    productClass.imagem = urlImg;
    return productClass;
  }

  ProductClass.empty();

  ProductClass.eraseProduct(ProductClass product){
  }

  ProductClass.productToEstoque(ProductClass product, this.pId, this.preco, this.codigo, this.descricao, this.quantidade, this.imagem, this.dataEntrega);

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
      'quantidade' : product.quantidade,

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

  ProductClass.fromMap(Map<String, dynamic> map) :
        pId = map['productId']; //,
        //quantity = map['quantity'];

  ProductClass.toBeMap(ProductClass);

  Map toMap(){
    return {
      'productId': pId,
      //'quantity': quantity,
    };
  }



  static List<Map> ConvertObjectsToMap({List<ProductClass> listOfObjectsOriginal}){
    List<Map> mapProvi = [];
    listOfObjectsOriginal.forEach((ProductClass produtox) {
      Map produtoMap = produtox.toMap();
      mapProvi.add(produtoMap);
    });
    return mapProvi;
  }

}