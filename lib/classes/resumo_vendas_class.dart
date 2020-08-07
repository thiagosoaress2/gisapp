import 'package:cloud_firestore/cloud_firestore.dart';

class ResumoVendasClass {


  double calculeTotal(String tipoFiltro, String filter, List<DocumentSnapshot> document, String mesSelecionado, String mesFinal ){

    double total=0.00;

    if(tipoFiltro=="nao"){


      if (filter == null || filter == ""){

        document.forEach((element) {
          total = element['valor']+total;
        });
      } else {

        document.forEach((element) {
          if(element.data['cliente'].contains(filter)){
            total = element['valor']+total;
          }
        });

      }


    } else if(tipoFiltro=="mes"){


      if (filter == null || filter == ""){

        document.forEach((element) {
          if(element.data['data'].contains(mesSelecionado)){
            total = element['valor']+total;
          }
        });

      } else {


        document.forEach((element) {
          if(element.data['cliente'].contains(filter)){
            if(element.data['data'].contains(mesSelecionado)){
              total = element['valor']+total;
            }
          }
        });

      }


    } else if(tipoFiltro=="duasDatas"){

    } else {
      //nunca chegará aqui
    }

    return total;
  }



}