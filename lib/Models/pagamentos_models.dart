import 'package:cloud_firestore/cloud_firestore.dart';

class PagamentosModels {

  updatePagamentos(String id, double valorPago, double saldoDevedor, List<String> situacaoPrestacoes){

    double newSaldoDevedor = saldoDevedor-valorPago;

    /*
    Firestore.instance.collection('dividas')
        .document(id).collection("situacoesPrestacoes").document(arrayPosition)
        .updateData({
        "teste" : valorPago.toStringAsFixed(2),

    });

     */

    Firestore.instance.collection('dividas')
        .document(id)
        .updateData({

      "saldoDevedor" : newSaldoDevedor,
      "situacoesPrestacoes" : situacaoPrestacoes,

    });

  }

}