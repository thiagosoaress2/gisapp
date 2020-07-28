import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gisapp/classes/product_class.dart';
import 'package:gisapp/data/product_data.dart';

class SellClass {

  String data;
  String dataQuery;
  String formaPgto;
  String cliente;
  String clienteId;
  int parcelas;
  double precoEtiqueta;
  double valor;
  String vendedora;
  String vendedoraId;
  double entrada;
  List<ProductClass> produtos;
  //List<String> produtos;

  List<String> listOfProdutosId;

  SellClass(this.data, this.dataQuery, this.formaPgto, this.cliente, this.clienteId,  this.parcelas, this.valor, this.vendedora, this.vendedoraId, this.produtos, this.entrada);

  SellClass.empty();

  Future<bool> addToBd(SellClass venda) async {

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
      'produtos' : ProductClass.ConvertObjectsToMap(listOfObjectsOriginal: venda.produtos),

    });

    return false;

  }

}