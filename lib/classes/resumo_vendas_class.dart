
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


  String formaPgtoFormattada(String formaPgto, List<DocumentSnapshot>list, int index){

    String returnString;
      if(formaPgto=="avista"){
        returnString = "Dinheiro à vista";
      } else if(formaPgto=="cartaodeb"){
        returnString = "Cartão de débito à vista";
      } else if(formaPgto=="crediario"){
        returnString = "Crediário em ${list[index]['parcelas']}x";
      } else if(formaPgto=="parcelado"){
        returnString = "Parcelado em ${list[index]['parcelas']}x";
      } else {
        returnString = "Cartão de crédito em ${list[index]['parcelas']}x";
      }

      return returnString;

  }

  String retorneItensDestaVenda(List<DocumentSnapshot>list, int index){

    List<dynamic> listProd

  }

}