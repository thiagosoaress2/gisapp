
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gisapp/classes/product_class.dart';

class SellClass {

  String data;
  String dataQuery;
  String formaPgto;
  String cliente;
  String clienteId;
  int parcelas;
  double precoEtiqueta;
  double valor; //valor da venda
  String vendedora;
  String vendedoraId;
  double entrada;
  double totalSemDesconto;
  List<ProductClass> produtos;
  //List<String> produtos;

  List<String> listOfProdutosId;

  SellClass(this.data, this.dataQuery, this.formaPgto, this.cliente, this.clienteId,  this.parcelas, this.valor, this.vendedora, this.vendedoraId, this.produtos, this.entrada, this.totalSemDesconto);

  SellClass.empty();

  Future<bool> addToBd(SellClass venda) async {

    updateProductQuantity(venda.produtos); //remove 1 valor de cada no estoque

    //registrando o pedido no bd dos pedidos
    DocumentReference refOrder = await Firestore.instance.collection("vendas")
        .add({

      'data' : venda.data,
      'dataQuery' : venda.dataQuery,
      'formaPgto' : venda.formaPgto,
      'cliente' : venda.cliente,
      'clienteId' : venda.clienteId,
      'parcelas' : venda.parcelas,
      'valor' : venda.valor,
      'vendedora' : venda.vendedora,
      'vendedoraId' : venda.vendedoraId,
      'entrada' : venda.entrada,
      'totalSemDesconto' : venda.totalSemDesconto,
      'produtos' : ProductClass.ConvertObjectsToMap(listOfObjectsOriginal: venda.produtos),

    });

    return false;

  }

  Future<void> updateProductQuantity(List<ProductClass> produtos){

    produtos.forEach((element) {
      if(element.quantidade == 0){
        //do nothing
      } else {

        Firestore.instance.collection('produtos')
            .document(element.pId)
            .updateData({
          "quantidade" : element.quantidade-1,

        });

      }
    });

  }

}