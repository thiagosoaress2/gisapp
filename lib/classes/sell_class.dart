
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:gisapp/classes/product_class.dart';
import 'package:intl/intl.dart';

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
  String nBoleto; //vai ser sempre numero mas vamos registrar como string pois sao numeros longos
  List<ProductClass> produtos;
  //List<String> produtos;

  List<String> listOfProdutosId;

  SellClass(this.data, this.dataQuery, this.formaPgto, this.cliente, this.clienteId,  this.parcelas, this.valor, this.vendedora, this.vendedoraId, this.produtos, this.entrada, this.totalSemDesconto, this.nBoleto);

  SellClass.empty();

  Future<void> addToBd(SellClass venda) async {

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
      'nBoleto' : venda.nBoleto,
      'produtos' : ProductClass.ConvertObjectsToMap(listOfObjectsOriginal: venda.produtos),

    }).then((value) {

      if(venda.parcelas!=1){

        List<String> datasPrestacoes = _getPrestacoes(venda.parcelas, venda.data, venda);
        List<String> situacaoPrestacoes = _getSituacaoPrestacoes(datasPrestacoes);

        Firestore.instance.collection("dividas").add({

          'vendaId' : value.documentID,
          'vendedoraId' : venda.vendedoraId,
          'parcelas' : venda.parcelas,
          'clienteId' : venda.clienteId,
          'cliente' : venda.cliente,

          'datasPrestacoes' : datasPrestacoes,
          'situacoesPrestacoes' : situacaoPrestacoes,

          'saldoDevedor' : (venda.valor-venda.entrada),

          'nBoleto' : venda.nBoleto,

        });

      }


    });
    //return false;

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

  List<String> _getPrestacoes(int quant, String data, SellClass venda){

    List<String> datas=[];
    String lastDate;
    int cont=0;
    while(cont<quant){

      if(cont==0){
        datas.add(_returnMe30DaysFromThisDate(data));
        lastDate = datas[0];
      } else {
        datas.add(_returnMe30DaysFromThisDate(lastDate));
        lastDate = datas[cont];
      }

      cont++;

    }

    return datas;

  }

  String _convertStringFromDate(DateTime strDate) {
    final newDate = formatDate(strDate, [dd, '/', mm, '/', yyyy]);
    return newDate;
  }

  DateTime _convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate.split('/').reversed.join());
    return todayDate;
  }

  String _returnMe30DaysFromThisDate(String strDate){
    DateTime theDate = _convertDateFromString(strDate);
    var thirtyDaysFromNow = theDate.add(new Duration(days: 30));
    String formattedDate = _convertStringFromDate(thirtyDaysFromNow);
    return formattedDate;
  }

  List<String> _getSituacaoPrestacoes(List<String> datas){

    List<String> prestacoesSit=[];
    int cont=0;
    while(cont<datas.length){
      prestacoesSit.add('Em aberto');
      cont++;
    }

    return prestacoesSit;

  }


}