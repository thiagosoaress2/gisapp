import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gisapp/Models/resumo_vendas_model.dart';
import 'package:gisapp/Utils/dates_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ResumoVendasClass {
  final pdf = pw.Document();

  ResumoVendasModel resumoVendasModel = ResumoVendasModel();

  double calculeTotal(String tipoFiltro, String filter, List<DocumentSnapshot> document, String mesSelecionado, String mesFinal) {
    double total = 0.00;

    if (tipoFiltro == "nao") {
      if (filter == null || filter == "") {
        document.forEach((element) {
          total = element['valor'] + total;
        });
      } else {
        document.forEach((element) {
          if (element.data['cliente'].contains(filter)) {
            total = element['valor'] + total;
          }
        });
      }
    } else if (tipoFiltro == "mes") {
      if (filter == null || filter == "") {
        document.forEach((element) {
          if (element.data['data'].contains(mesSelecionado)) {
            total = element['valor'] + total;
          }
        });
      } else {
        document.forEach((element) {
          if (element.data['cliente'].contains(filter)) {
            if (element.data['data'].contains(mesSelecionado)) {
              total = element['valor'] + total;
            }
          }
        });
      }
    } else if (tipoFiltro == "duasDatas") {
    } else {
      //nunca chegará aqui
    }

    return total;
  }

  String formaPgtoFormattada(String formaPgto, List<DocumentSnapshot> list, int index) {
    String returnString;
    if (formaPgto == "avista") {
      returnString = "Dinheiro à vista";
    } else if (formaPgto == "cartaodeb") {
      returnString = "Cartão de débito à vista";
    } else if (formaPgto == "crediario") {
      returnString = "Crediário em ${list[index]['parcelas']}x";
    } else if (formaPgto == "parcelado") {
      returnString = "Parcelado em ${list[index]['parcelas']}x";
    } else {
      returnString = "Cartão de crédito em ${list[index]['parcelas']}x";
    }

    return returnString;
  }

  String retorneItensDestaVenda(List<DocumentSnapshot> list, int index) {
    List<dynamic> listProduto = list[index][
        'produtos']; //pegamos todos os valores dos arrays guardados (cada item é um array)
    int cont = 0;
    String value;
    while (cont < listProduto.length) {
      if (cont == 0) {
        value = listProduto[cont]['item'].toString();
      } else {
        value = value + ", " + listProduto[cont]['item'].toString();
      }
      cont++;
    }

    return value;
  }

  void printListInPdf(String tipoFiltro, String filter, List<DocumentSnapshot> documentsCopy, String mesSelecionado, String mesFinal) {

    //ResumoVendasModel().setPrinting();
    //ResumoVendasModel().setPage(3);
    resumoVendasModel.setPrinting();
    resumoVendasModel.setPage(3);

    int cont = 0;

    String ano;
    String mes;
    if (tipoFiltro == "nao") {
      ano = DateUtils().giveMeTheYear(DateTime.now());
      mes = DateUtils().giveMeTheMonth(DateTime.now());
    } else if (tipoFiltro == "mes") {
      var mesDateTime = DateUtils().convertDateFromString(mesSelecionado);
      ano = DateUtils().giveMeTheYear(mesDateTime);
      mes = DateUtils().giveMeTheMonth(mesDateTime);
    } else {
      //do nothing
      mes = "no";
      ano = "no";
    }

    double totalVendas = 0.00;
    double totalLiberadas = 0.00;
    double totalPendentes = 0.00;

    //vamos pegar os totais somados para adicionar ao final
    documentsCopy.forEach((element) {
      totalVendas = element.data["valor"]+totalVendas;
      //adicionar aqui o total libero e o total pendente
    });

    //iremos imprimir de 2 em 2.
    while (cont < documentsCopy.length) {
      pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(16.0),
          build: (pw.Context context) {
            return <pw.Widget>[
              pw.Header(
                  level: 0,
                  child: pw.Text(tipoFiltro == "nao"
                      ? "Relatório de venda do mês ${mes}/${ano}"
                      : tipoFiltro == "mes"
                          ? "Relatório de venda do mês ${mes}/${ano}"
                          : "Relatório de venda do periodo ${mesSelecionado} - ${mesFinal}")),

              pdfHeader(),


              //aqui acaba o cabeçalho
              pw.Divider(),

              documentsCopy.length >= cont + 1
                  ? pdfLine(documentsCopy, cont)  //coloca as informações
                  : pw.Container(),

              documentsCopy.length >= cont + 1
                  ?pw.Divider()  //coloca a linha divisória
                  :pw.Container(),

              documentsCopy.length >= cont + 2
                  ? pdfLine(documentsCopy, cont+1)
                  : pw.Container(),

              documentsCopy.length >= cont + 2
                  ?pw.Divider()
                  :pw.Container(),

              documentsCopy.length >= cont + 3
                  ? pdfLine(documentsCopy, cont+2)
                  : pw.Container(),

              documentsCopy.length >= cont + 3
                  ?pw.Divider()
                  :pw.Container(),

              documentsCopy.length >= cont + 4
                  ? pdfLine(documentsCopy, cont+3)
                  : pw.Container(),

              documentsCopy.length >= cont + 4
                  ?pw.Divider()
                  :pw.Container(),

              documentsCopy.length >= cont + 5
                  ? pdfLine(documentsCopy, cont+4)
                  : pw.Container(),

              documentsCopy.length >= cont + 5
                  ?pw.Divider()
                  :pw.Container(),

              documentsCopy.length >= cont + 6
                  ? pdfLine(documentsCopy, cont+5)
                  : pw.Container(),

              documentsCopy.length >= cont + 6
                  ?pw.Divider()
                  :pw.Container(),

              documentsCopy.length >= cont + 7
                  ? pdfLine(documentsCopy, cont+6)
                  : pw.Container(),

              documentsCopy.length >= cont + 7
                  ?pw.Divider()
                  :pw.Container(),


              documentsCopy.length >= cont + 8
                  ? pdfLine(documentsCopy, cont+7)
                  : pw.Container(),

              documentsCopy.length >= cont + 8
                  ?pw.Divider()
                  :pw.Container(),

              documentsCopy.length >= cont + 9
                  ? pdfLine(documentsCopy, cont+8)
                  : pw.Container(),

              documentsCopy.length >= cont + 9
                  ?pw.Divider()
                  :pw.Container(),

              documentsCopy.length >= cont + 10
                  ? pdfLine(documentsCopy, cont+9)
                  : pw.Container(),

              documentsCopy.length >= cont + 10
                  ?pw.Divider()
                  :pw.Container(),


              documentsCopy.length < cont+11 ? //coloca a linha final com os cálculos
                  pdfLastLine(totalVendas)
                  : pw.Container(),

            ];
          }));

      cont = cont + 10; //+2 pois vamos de 2 em 2
    }

    _savePdfFile();

  }

  //aqui define o guia, a primeira linha com os nomes das colunas
  pw.Widget pdfHeader (){

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: <pw.Widget>[

        pw.Container(
          width: 70.0,
          child: pw.Text("Data"),
        ),

        pw.Container(
          width: 70.0,
          child: pw.Text("Boleto"),
        ),

        pw.Container(
          width: 70.0,
          child: pw.Text("Valor"),
        ),

        pw.Container(
          width: 70.0,
          child: pw.Text("Liberada"),
        ),

        pw.Container(
          width: 70.0,
          child: pw.Text("Pendente"),
        ),

        pw.Container(
          width: 70.0,
          child: pw.Text("Cliente"),
        ),

        pw.Container(
          width: 70.0,
          child: pw.Text("Vendedora"),
        ),

      ],
    );

  }

  //aqui são as informações de cada linha
  pw.Widget pdfLine (List<DocumentSnapshot> documentsCopy, int cont) {
    return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: <pw.Widget>[

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            height: 30.0,
            width: 70.0,
            child: pw.Text(documentsCopy[cont].data["data"]),
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            height: 30.0,
            width: 70.0,
            child: pw.Text(documentsCopy[cont].data["nBoleto"]),
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            height: 30.0,
            width: 70.0,
            child: pw.Text(documentsCopy[cont].data["valor"].toStringAsFixed(2)),
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            height: 30.0,
            width: 70.0,
            child: pw.Text(documentsCopy[cont].data["data"]),  //este precisa entrar a liberada que ainda nao existr
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            height: 30.0,
            width: 70.0,
            child: pw.Text(documentsCopy[cont].data["data"]),  //aqui vai entrar a comissao pendente
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            height: 30.0,
            width: 70.0,
            child: pw.Text(documentsCopy[cont].data["cliente"]),
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            height: 30.0,
            width: 70.0,
            child: pw.Text(documentsCopy[cont].data["vendedora"]),
          ),

        ]);

  }

  //esta é a ultima linha do pdf onde vai exibir a somatória de alguns valores.
  //Existem elementos vazios apenas ocupando o espaço para que fiquem na mesma direção das colunas acima.
  //caso altere alguma coluna acima, alterar aqui.
  pw.Widget pdfLastLine (double totalVendas) {
    return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: <pw.Widget>[

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            width: 70.0,
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            width: 70.0,
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            width: 70.0,
            child: pw.Text(totalVendas.toStringAsFixed(2)),
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            width: 70.0,
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            width: 70.0,
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            width: 70.0,
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            width: 70.0,
          ),

        ]);

  }

  Future _savePdfFile() async {

    final _fileName = "listagem_venda_${DateTime.now().day.toString()}_${DateTime.now().month.toString()}_${DateTime.now().minute.toString()}_${DateTime.now().second.toString()}.pdf";
    File file = File("/storage/emulated/0/Download/$_fileName");
    file.writeAsBytesSync(pdf.save());

    print("Arquivo gerado");
    ///ResumoVendasModel().setPrintingDone();
    resumoVendasModel.setPrintingDone();
  }


  List<DocumentSnapshot> filterPlease(String tipoFiltro, String filter, List<DocumentSnapshot> document, String mesSelecionado, String mesFinal) {
    List<DocumentSnapshot> newList = [];

    //agora vamos repetir o filtro usado na pagina para exibir

    if (tipoFiltro == "nao") {
      if (filter == null || filter == "") {
        newList = document;
      } else {
        document.forEach((element) {
          if (element.data['cliente'].contains(filter)) {
            newList.add(element);
          }
        });
      }
    } else if (tipoFiltro == "mes") {
      if (filter == null || filter == "") {
        document.forEach((element) {
          if (element.data['data'].contains(mesSelecionado)) {
            newList.add(element);
          }
        });
      } else {
        document.forEach((element) {
          if (element.data['cliente'].contains(filter)) {
            if (element.data['data'].contains(mesSelecionado)) {
              newList.add(element);
            }
          }
        });
      }
    } else if (tipoFiltro == "duasDatas") {
      document.forEach((element) {
        if (filter == null ||
            filter == "" &&
                DateUtils().doesThisDateIsBigger(
                    element.data['data'], mesSelecionado) &&
                DateUtils()
                    .doesThisDateIsBigger(mesFinal, element.data['data'])) {
          newList.add(element);
        } else if (element.data['cliente'].contains(filter) &&
            DateUtils()
                .doesThisDateIsBigger(element.data['data'], mesSelecionado) &&
            DateUtils().doesThisDateIsBigger(mesFinal, element.data['data'])) {
          newList.add(element);
        }
      });
    } else {
      //nunca chegará aqui
    }

    return newList;
  }
}
