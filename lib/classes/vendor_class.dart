import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class VendorClass {

  String id;
  String nome;
  double comissao;
  double salario;
  int modalidade;

  VendorClass(this.id, this.nome, this.comissao, this.salario, this.modalidade);

  VendorClass.cad(this.nome, this.comissao, this.salario, this.modalidade);

  final pdf = pw.Document();

  VendorClass.empty();

  VendorClass.erase(VendorClass vendor){
    vendor.id = null;
    vendor.nome = null;
    vendor.comissao = null;
    vendor.modalidade = null;
  }

  Future<bool> addToBd(VendorClass vendor) async {

    //changeState();
    //registrando o pedido no bd dos pedidos
    DocumentReference refOrder = await Firestore.instance.collection("vendedores")
        .add({

      "nome" : vendor.nome,
      "comissao" : vendor.comissao,
      "salario" : vendor.salario,
      "modalidade" : vendor.modalidade,

    });

    return false;

  }

  Future<bool> updateClienteInfo(VendorClass vendor) async {

    Firestore.instance
        .collection('vendedores')
        .document(vendor.id)
        .updateData({
      "comissao" : vendor.comissao,
      'salario' : vendor.salario,
      "modalidade" : vendor.modalidade,
    });
  }

  //agora a parte de impressao de pdf
  void printListInPdf(String queryCriteria, List<DocumentSnapshot> documentsCopy, String selectedDate, String vendedora) {

    int cont = 0;

    String ano;
    String mes;
    String dateSearch;
    if (queryCriteria == "esteMes") {
      dateSearch = DateTime.now().month.toString()+"/"+DateTime.now().year.toString();
    } else {
      dateSearch = selectedDate;
    }

    double totalComissao = 0.00;

    //vamos pegar os totais somados para adicionar ao final
    documentsCopy.forEach((element) {
      totalComissao = element.data["comissao"]+totalComissao;
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
                  child: pw.Text("Comissões liberadas para $dateSearch")),

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
              pdfLastLine(totalComissao)
                  : pw.Container(),

            ];
          }));

      cont = cont + 10; //+2 pois vamos de 2 em 2
    }

    _savePdfFile(vendedora);

  }

  //cabeçalho
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
          child: pw.Text("Cliente"),
        ),

        pw.Container(
          width: 70.0,
          child: pw.Text("Venda"),
        ),

        pw.Container(
          width: 70.0,
          child: pw.Text("Comissao liberada"),
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
            child: pw.Text(documentsCopy[cont].data["cliente"]),
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
            child: pw.Text(documentsCopy[cont].data["comissao"].toStringAsFixed(2)),  //este precisa entrar a liberada que ainda nao existr
          ),

        ]);

  }

  //esta é a ultima linha do pdf onde vai exibir a somatória de alguns valores.
  //Existem elementos vazios apenas ocupando o espaço para que fiquem na mesma direção das colunas acima.
  //caso altere alguma coluna acima, alterar aqui.
  pw.Widget pdfLastLine (double totalComissao) {
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
          ),

          pw.Container(
            padding: pw.EdgeInsets.all(8.0),
            width: 70.0,
            child: pw.Text(totalComissao.toStringAsFixed(2)),
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

  Future _savePdfFile(String vendedora) async {

    final _fileName = "Comissao_liberada_${vendedora}_${DateTime.now().day.toString()}_${DateTime.now().month.toString()}_${DateTime.now().minute.toString()}_${DateTime.now().second.toString()}.pdf";
    File file = File("/storage/emulated/0/Download/$_fileName");
    file.writeAsBytesSync(pdf.save());

    print("Arquivo gerado");
    ///ResumoVendasModel().setPrintingDone();
    //resumoVendasModel.setPrintingDone();
  }

}