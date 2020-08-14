import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gisapp/Utils/dates_utils.dart';
import 'package:gisapp/Utils/percent_utils.dart';

class PagamentosModels {

  updatePagamentos(String id, double valorPago, double saldoDevedor, List<dynamic> situacaoPrestacoes, double valorVenda, String vendedoraId
      , String clienteId, String cliente){

    print("saldo devedor original: "+saldoDevedor.toStringAsFixed(2));
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


    updateComissaoLiberada(id, valorPago, saldoDevedor, situacaoPrestacoes, valorVenda, vendedoraId, clienteId, cliente, newSaldoDevedor);

  }

  void updateComissaoLiberada(String id, double valorPago, double saldoDevedor, List<dynamic> situacaoPrestacoes, double valorVenda, String vendedoraId, String clienteId, String cliente, double newSaldoDevedor){

    print("Valor venda: "+valorVenda.toStringAsFixed(2));
    print("Valor newSaldoDevedor: "+newSaldoDevedor.toStringAsFixed(2));

    //registro em comissoes liberadas
    double payd = valorVenda-newSaldoDevedor;
    print("payd" +payd.toStringAsFixed(2));
    double percentPayd = PercentUtils().percentFromTwoNumbers(payd, valorVenda);
    if(percentPayd>=10){

      double comissao = PercentUtils().getValueFromPercent(valorPago, 4.0); //esses 4.0 vao vir da classe vendedora

      //aqui vamos criar a entrada da comissao no bd
      Firestore.instance.collection("comissaoLiberada").add({
        'vendaId' : id,
        'vendedoraId' : vendedoraId,
        'clienteId' : clienteId,
        'data' : DateUtils().giveMeTheDateToday(),
        'comissao' : comissao,
        'cliente' : cliente,
        'valor' : valorPago,

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