import 'package:cloud_firestore/cloud_firestore.dart';
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


  //mobX observer para o loading
  Observable _stateOfUpload = Observable(0); //este é o estado que vai mudar para sabermos que o
  Action _changeState; //ação que vai disparar o listener

  //construtor
  ProductClass(this.pId, this.codigo, this.dataCompra, this.dataEntrega,
      this.descricao, this.imagem, this.moedaCompra, this.notaFiscal,
      this.preco, this.custo){

    _changeState = Action(_changeState);  //initial state do mobx observer
  }

  void changeState(){  //esta função vai ser chamada e vai incrementar o valor. Sempre que o valor mudar, será chamado o elemento na outra página que redesenha a tela.
    runInAction(
            () => {
          _stateOfUpload.value++
        }
    );
  }

  int get getState => _stateOfUpload.value; //retorna o valor de value em int

  //este ainda não tem o id.
  ProductClass.inicial(this.codigo, this.dataCompra, this.dataEntrega,
      this.descricao, this.imagem, this.moedaCompra, this.notaFiscal,
      this.preco, this.custo);


  ProductClass updateImageInfo(ProductClass productClass, String urlImg) {
    productClass.imagem = urlImg;
    return productClass;
  }

  ProductClass.upLoadMap(ProductClass productClass){
    addToBd(productClass);
  }

  void addToBd(ProductClass product) async {

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
          changeState();
      }).catchError((e) => (){
        changeState();
      });
    }
    );

    product.pId = refOrder.documentID;
  }
}