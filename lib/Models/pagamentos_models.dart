import 'package:cloud_firestore/cloud_firestore.dart';

class PagamentosModels {

  updatePagamentos(String id, double valorPago, double saldoDevedor, List<dynamic> situacaoPrestacoes){

    double newSaldoDevedor = saldoDevedor-valorPago;

    if(newSaldoDevedor<=0.0){
      Firestore.instance.collection('dividas').document(id).delete();
    } else {
      Firestore.instance.collection('dividas')
          .document(id)
          .updateData({

        "saldoDevedor" : newSaldoDevedor,
        "situacoesPrestacoes" : situacaoPrestacoes,

      });
    }

  }

  String checkPaymentsTotal(List<dynamic> list){

    double total = 0.00;
    for (var value in list) {
      if(value!="Em aberto"){
        total = double.parse(value)+total;
      }
    }

    return total.toStringAsFixed(2);

  }

}