import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gisapp/Utils/percent_utils.dart';

class PagamentosModels {

  updatePagamentos(String id, double valorPago, double saldoDevedor, List<dynamic> situacaoPrestacoes, double valorVenda){

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


    //registro em comissoes liberadas
    double payd = valorVenda-newSaldoDevedor;
    double percentPayd = PercentUtils().percentFromTwoNumbers(payd, valorVenda);
    if(percentPayd>10.0){

      //aqui vamos criar a entrada da comissao no bd
      /*
      Firestore.instance.collection("dividas").add({

          'vendaId' : value.documentID,
          'vendedoraId' : venda.vendedoraId,
          'parcelas' : venda.parcelas,
          'clienteId' : venda.clienteId,
          'cliente' : venda.cliente,

          'datasPrestacoes' : datasPrestacoes,
          'situacoesPrestacoes' : situacaoPrestacoes,
          'valorVenda' : venda.valor,

          'saldoDevedor' : (venda.valor-venda.entrada),

          'nBoleto' : venda.nBoleto,

        });
       */

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