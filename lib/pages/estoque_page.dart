import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gisapp/Utils/photo_service.dart';
import 'package:gisapp/classes/product_class.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

class EstoquePage extends StatefulWidget {
  @override
  _EstoquePageState createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {


  //itens da foto
  PhotoService photoService = PhotoService();

  File img;


  final pdf = pw.Document();


  int page = 0;

  bool printThis = false;

  final TextEditingController _searchController = TextEditingController();
  String query;

  String filterOptions = "nao";

  //'nao' é o padrão, sem filtro
  //'falta' é para exibir itens em falta
  //'antigos' exibe os produtos em ordem de antiguidade

  List<ProductClass> _produtosEmEstoque = [];

  List<DocumentSnapshot> documentsCopy;
  bool isPrinting = false;

  @override
  void initState() {
    super.initState();
    //listener da busca
    _searchController.addListener(() {
      setState(() {
        query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: WidgetsConstructor().makeSimpleText(
            "Estoque", Colors.white, 18.0),
        centerTitle: true,
      ),
      body: page == 0 ? LandingPage() : Container(),
    );
  }

  Widget LandingPage() {
    return Container(
        color: Colors.white,
        height: 700,
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0,),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField( //searchcontroller
                controller: _searchController,
                decoration: InputDecoration(
                    labelText: "Buscar",
                    hintText: "Buscar",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                height: 60.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(color: Colors.amber, child: FlatButton(
                        child: Text("Em falta"),
                        onPressed: () {
                          setState(() {
                            filterOptions = "falta";
                          });
                        }
                        ,)
                        ,),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(color: Theme
                          .of(context)
                          .primaryColor, child: FlatButton(
                        child: Text("Imprimir lista"),
                        onPressed: () async {

                          printThis = true;
                          pdfNewTry2();

                          //pdfNewTry();

                        }
                        ,)
                        ,),
                    ),
                  ],
                ),
              ),
            ),
            isPrinting ? Center(
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 8.0,),
                  Text("Aguarde, gerando relatório", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.0),),
                  SizedBox(height: 8.0,),
                ],
              )
            ) : Container(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("produtos")
                    .snapshots(),
                //este é um listener para observar esta coleção
                builder: (context, snapshot) { //começar a desenhar a tela
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center( //caso esteja vazio ou esperando exibir um circular progressbar no meio da tela
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> documents = snapshot.data.documents
                          .toList(); //recuperamos o querysnapshot que estamso observando
                      documentsCopy = documents;

                      return ListView
                          .builder( //aqui vamos começar a construir a listview com os itens retornados
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            if (filterOptions == "nao") {
                              return query == null || query == ""
                                  ? //se nao tiver opções de filtragem e nao tiver busca
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    print("Clicou no item");
                                  });
                                },
                                child: Card(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      SizedBox(width: 10.0,),
                                      Image.network(
                                        documents[index].data["imagem"],
                                        width: 120.0,
                                        height: 120.0,
                                        fit: BoxFit.cover,),
                                      SizedBox(width: 10.0,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          WidgetsConstructor().makeSimpleText(
                                              documents[index].data["codigo"],
                                              Theme
                                                  .of(context)
                                                  .primaryColor, 18.0),
                                          SizedBox(height: 5.0,),
                                          Container(
                                            width: 150,
                                            child: WidgetsConstructor()
                                                .makeSimpleText(documents[index]
                                                .data["descricao"],
                                                Colors.grey[400], 14.0),),
                                          SizedBox(height: 5.0,),
                                          WidgetsConstructor().makeSimpleText(
                                              "Em estoque desde: \n${documents[index]
                                                  .data["dataEntrega"]}",
                                              Colors.grey[500], 14.0),
                                          SizedBox(height: 5.0,),
                                          Container(
                                            padding: EdgeInsets.all(4.0),
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
                                            child: WidgetsConstructor()
                                                .makeSimpleText("R\$ " +
                                                documents[index].data["preco"]
                                                    .toStringAsFixed(2),
                                                Colors.white, 20.0),
                                          ),
                                        ],
                                      ),
                                      //exibe a quantidade de itens. Se for 1 ou 2 fica amarelo. Se for 0 fica vermelho.
                                      documents[index].data["quantidade"] > 2
                                          ? WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.blueGrey,
                                          15.0)
                                          :
                                      documents[index].data["quantidade"] > 0
                                          ? WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.amber, 15.0)
                                          :
                                      WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.red, 15.0),
                                    ],
                                  ),

                                ),
                              )
                                  : documents[index].data['codigo'].contains(
                                  query) ?
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    print("Clicou no item");
                                  });
                                },
                                child: Card(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      SizedBox(width: 10.0,),
                                      Image.network(
                                        documents[index].data["imagem"],
                                        width: 120.0,
                                        height: 120.0,
                                        fit: BoxFit.cover,),
                                      SizedBox(width: 10.0,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          WidgetsConstructor().makeSimpleText(
                                              documents[index].data["codigo"],
                                              Theme
                                                  .of(context)
                                                  .primaryColor, 18.0),
                                          SizedBox(height: 5.0,),
                                          Container(
                                            width: 150,
                                            child: WidgetsConstructor()
                                                .makeSimpleText(documents[index]
                                                .data["descricao"],
                                                Colors.grey[400], 14.0),),
                                          SizedBox(height: 5.0,),
                                          WidgetsConstructor().makeSimpleText(
                                              "Em estoque desde: \n${documents[index]
                                                  .data["dataEntrega"]}",
                                              Colors.grey[500], 14.0),
                                          SizedBox(height: 5.0,),
                                          Container(
                                            padding: EdgeInsets.all(4.0),
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
                                            child: WidgetsConstructor()
                                                .makeSimpleText("R\$ " +
                                                documents[index].data["preco"]
                                                    .toStringAsFixed(2),
                                                Colors.white, 20.0),
                                          ),
                                        ],
                                      ),
                                      //exibe a quantidade de itens. Se for 1 ou 2 fica amarelo. Se for 0 fica vermelho.
                                      documents[index].data["quantidade"] > 2
                                          ? WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.blueGrey,
                                          15.0)
                                          :
                                      documents[index].data["quantidade"] > 0
                                          ? WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.amber, 15.0)
                                          :
                                      WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.red, 15.0),
                                    ],
                                  ),

                                ),
                              )
                                  : Container();
                            } else if (filterOptions == "falta") {
                              return documents[index].data['quantidade'] == 0 &&
                                  query == null || query == ""
                                  ? //se nao tiver opções de filtragem e nao tiver busca
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    print("Clicou no item");
                                  });
                                },
                                child: Card(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      SizedBox(width: 10.0,),
                                      Image.network(
                                        documents[index].data["imagem"],
                                        width: 120.0,
                                        height: 120.0,
                                        fit: BoxFit.cover,),
                                      SizedBox(width: 10.0,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          WidgetsConstructor().makeSimpleText(
                                              documents[index].data["codigo"],
                                              Theme
                                                  .of(context)
                                                  .primaryColor, 18.0),
                                          SizedBox(height: 5.0,),
                                          Container(
                                            width: 150,
                                            child: WidgetsConstructor()
                                                .makeSimpleText(documents[index]
                                                .data["descricao"],
                                                Colors.grey[400], 14.0),),
                                          SizedBox(height: 5.0,),
                                          WidgetsConstructor().makeSimpleText(
                                              "Em estoque desde: \n${documents[index]
                                                  .data["dataEntrega"]}",
                                              Colors.grey[500], 14.0),
                                          SizedBox(height: 5.0,),
                                          Container(
                                            padding: EdgeInsets.all(4.0),
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
                                            child: WidgetsConstructor()
                                                .makeSimpleText("R\$ " +
                                                documents[index].data["preco"]
                                                    .toStringAsFixed(2),
                                                Colors.white, 20.0),
                                          ),
                                        ],
                                      ),
                                      //exibe a quantidade de itens. Se for 1 ou 2 fica amarelo. Se for 0 fica vermelho.
                                      documents[index].data["quantidade"] > 2
                                          ? WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.blueGrey,
                                          15.0)
                                          :
                                      documents[index].data["quantidade"] > 0
                                          ? WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.amber, 15.0)
                                          :
                                      WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.red, 15.0),
                                    ],
                                  ),

                                ),
                              )
                                  : documents[index].data['quantidade'] == 0 &&
                                  documents[index].data['codigo'].contains(
                                      query) ?
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    print("Clicou no item");
                                  });
                                },
                                child: Card(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      SizedBox(width: 10.0,),
                                      Image.network(
                                        documents[index].data["imagem"],
                                        width: 120.0,
                                        height: 120.0,
                                        fit: BoxFit.cover,),
                                      SizedBox(width: 10.0,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          WidgetsConstructor().makeSimpleText(
                                              documents[index].data["codigo"],
                                              Theme
                                                  .of(context)
                                                  .primaryColor, 18.0),
                                          SizedBox(height: 5.0,),
                                          Container(
                                            width: 150,
                                            child: WidgetsConstructor()
                                                .makeSimpleText(documents[index]
                                                .data["descricao"],
                                                Colors.grey[400], 14.0),),
                                          SizedBox(height: 5.0,),
                                          WidgetsConstructor().makeSimpleText(
                                              "Em estoque desde: \n${documents[index]
                                                  .data["dataEntrega"]}",
                                              Colors.grey[500], 14.0),
                                          SizedBox(height: 5.0,),
                                          Container(
                                            padding: EdgeInsets.all(4.0),
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
                                            child: WidgetsConstructor()
                                                .makeSimpleText("R\$ " +
                                                documents[index].data["preco"]
                                                    .toStringAsFixed(2),
                                                Colors.white, 20.0),
                                          ),
                                        ],
                                      ),
                                      //exibe a quantidade de itens. Se for 1 ou 2 fica amarelo. Se for 0 fica vermelho.
                                      documents[index].data["quantidade"] > 2
                                          ? WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.blueGrey,
                                          15.0)
                                          :
                                      documents[index].data["quantidade"] > 0
                                          ? WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.amber, 15.0)
                                          :
                                      WidgetsConstructor().makeSimpleText(
                                          documents[index].data["quantidade"]
                                              .toString(), Colors.red, 15.0),
                                    ],
                                  ),

                                ),
                              )
                                  : Container();
                            } else {
                              return Container();
                            }
                          });
                  }
                },
              ),
            ),
          ],
        )
    );
  }


  void pdfNewTry2() async {
    setState(() {
      isPrinting = true;
    });

    List<PdfImage> listOfImages = [
    ]; //armazena as imagens convertidas para depois exibir no pdf
    int cont = 0;

    Uint8List targetlUinit8List;
    Uint8List originalUnit8List;


    while (cont < documentsCopy.length) {
      String imageUrl = documentsCopy[cont]["imagem"];

      http.Response response2 = await http.get(imageUrl);
      originalUnit8List = response2.bodyBytes;

      ui.Image originalUiImage = await decodeImageFromList(originalUnit8List);
      ByteData originalByteData = await originalUiImage.toByteData();
      print(
          'original image ByteData size is ${originalByteData.lengthInBytes}');

      var codec = await ui.instantiateImageCodec(originalUnit8List,
          targetHeight: 150, targetWidth: 150);
      //targetHeight: (height/ratio).toInt(), targetWidth: (width/ratio).toInt());
      var frameInfo = await codec.getNextFrame();
      ui.Image targetUiImage = frameInfo.image;

      ByteData targetByteData =
      await targetUiImage.toByteData(format: ui.ImageByteFormat.png);
      print('target image ByteData size is ${targetByteData.lengthInBytes}');
      targetlUinit8List = targetByteData.buffer.asUint8List();


      final image = PdfImage.file(
        pdf.document,
        bytes: targetlUinit8List,
      );

      listOfImages.add(image);
      cont++;
    }


    cont = 0;
    while (cont < documentsCopy.length) {  //o documento vai ser impresso de 10 em 10
      pdf.addPage(
          pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              margin: pw.EdgeInsets.all(16.0),

              build: (pw.Context context) {
                return <pw.Widget>[
                  pw.Header(
                      level: 0,
                      child: pw.Text(filterOptions == "nao"
                          ? "Relatório do estoque completo"
                          : filterOptions == "falta"
                          ? "Relatório dos itens em falta"
                          : "Relatório ordenado por antiguidade")
                  ),
                  //pw.Image(image)
                  pw.Row(
                    //crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[

                        pw.Container(
                          width: 70.0,
                          child: pw.Text("Data"),
                        ),
                        pw.Container(
                          width: 70.0,
                        ),
                        pw.Container(
                          width: 70.0,
                          child: pw.Text("Código"),
                        ),
                        pw.Container(
                          width: 70.0,
                          child: pw.Text("Valor"),
                        ),
                        pw.Container(
                          width: 180.0,
                          child: pw.Text("Descrição"),
                        ),

                      ]
                  ),
                  pw.Divider(),


                  documentsCopy.length >= cont+1 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont]["dataEntrega"])
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.AspectRatio(
                              aspectRatio: 1 / 0.5,
                              child: pw.Image(listOfImages[cont])),

                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                documentsCopy[cont]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(documentsCopy[cont]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  documentsCopy.length >= cont+2 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+1]["dataEntrega"])
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.AspectRatio(
                              aspectRatio: 1 / 0.5,
                              child: pw.Image(listOfImages[cont+1])),

                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+1]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                documentsCopy[cont+1]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(documentsCopy[cont+1]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  documentsCopy.length >= cont+3 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+2]["dataEntrega"])
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.AspectRatio(
                              aspectRatio: 1 / 0.5,
                              child: pw.Image(listOfImages[cont+2])),

                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[2]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                documentsCopy[cont+2]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(documentsCopy[cont+2]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  documentsCopy.length >= cont+4 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+3]["dataEntrega"])
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.AspectRatio(
                              aspectRatio: 1 / 0.5,
                              child: pw.Image(listOfImages[cont+3])),

                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+3]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                documentsCopy[cont+3]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(documentsCopy[cont+3]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  documentsCopy.length >= cont+5 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+4]["dataEntrega"])
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.AspectRatio(
                              aspectRatio: 1 / 0.5,
                              child: pw.Image(listOfImages[cont+4])),

                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+4]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                documentsCopy[cont+4]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(documentsCopy[cont+4]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  documentsCopy.length >= cont+6 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+5]["dataEntrega"])
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.AspectRatio(
                              aspectRatio: 1 / 0.5,
                              child: pw.Image(listOfImages[cont+5])),

                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+5]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                documentsCopy[cont+5]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(documentsCopy[cont+5]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  documentsCopy.length >= cont+7 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+6]["dataEntrega"])
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.AspectRatio(
                              aspectRatio: 1 / 0.5,
                              child: pw.Image(listOfImages[cont+6])),

                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+6]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                documentsCopy[cont+6]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(documentsCopy[cont+6]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  documentsCopy.length >= cont+8 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+7]["dataEntrega"])
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.AspectRatio(
                              aspectRatio: 1 / 0.5,
                              child: pw.Image(listOfImages[cont+7])),

                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+7]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                documentsCopy[cont+7]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(documentsCopy[cont+7]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),


                  documentsCopy.length >= cont+9 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+8]["dataEntrega"])
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.AspectRatio(
                              aspectRatio: 1 / 0.5,
                              child: pw.Image(listOfImages[cont+8])),

                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+8]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                documentsCopy[cont+8]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(documentsCopy[cont+8]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),


                  documentsCopy.length >= cont+10 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+9]["dataEntrega"])
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.AspectRatio(
                              aspectRatio: 1 / 0.5,
                              child: pw.Image(listOfImages[cont+9])),

                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(documentsCopy[cont+9]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                documentsCopy[cont+9]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(documentsCopy[cont+9]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),


                ];
              }
          )
      );


      cont = cont + 10;
    }
    savePdf();

    setState(() {
      isPrinting = false;
    });

  }

  /*  este é o que esta funcionando
  void pdfNewTry2() async {

    setState(() {
      isPrinting = true;
    });

    List<PdfImage> listOfImages = [];  //armazena as imagens convertidas para depois exibir no pdf
    int cont=0;

    Uint8List targetlUinit8List;
    Uint8List originalUnit8List;


    while (cont<documentsCopy.length){

    String imageUrl = documentsCopy[cont]["imagem"];

    http.Response response2 = await http.get(imageUrl);
    originalUnit8List = response2.bodyBytes;

    ui.Image originalUiImage = await decodeImageFromList(originalUnit8List);
    ByteData originalByteData = await originalUiImage.toByteData();
    print('original image ByteData size is ${originalByteData.lengthInBytes}');

    var codec = await ui.instantiateImageCodec(originalUnit8List,
        targetHeight: 150, targetWidth: 150);
        //targetHeight: (height/ratio).toInt(), targetWidth: (width/ratio).toInt());
    var frameInfo = await codec.getNextFrame();
    ui.Image targetUiImage = frameInfo.image;

    ByteData targetByteData =
    await targetUiImage.toByteData(format: ui.ImageByteFormat.png);
    print('target image ByteData size is ${targetByteData.lengthInBytes}');
    targetlUinit8List = targetByteData.buffer.asUint8List();


      final image = PdfImage.file(
        pdf.document,
        bytes: targetlUinit8List,
      );

      listOfImages.add(image);
      cont++;
    }


    pdf.addPage(
        pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(16.0),

            build: (pw.Context context) {
              return <pw.Widget>[
                pw.Header(
                    level: 0,
                    child: pw.Text(filterOptions=="nao" ? "Relatório do estoque completo" : filterOptions=="falta" ? "Relatório dos itens em falta" : "Relatório ordenado por antiguidade")
                ),
                //pw.Image(image)
                pw.Row(
                    //crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[

                      pw.Container(
                        width: 70.0,
                        child: pw.Text("Data"),
                      ),
                      pw.Container(
                        width: 70.0,
                      ),
                      pw.Container(
                        width: 70.0,
                        child: pw.Text("Código"),
                      ),
                      pw.Container(
                        width: 70.0,
                        child: pw.Text("Valor"),
                      ),
                      pw.Container(
                        width: 180.0,
                        child: pw.Text("Descrição"),
                      ),

                    ]
                ),
                pw.Divider(),


                documentsCopy.length>=1 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.Text(documentsCopy[0]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[0])),

                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                          child: pw.Text(documentsCopy[0]["codigo"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                          child: pw.Text(documentsCopy[0]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 180.0,
                          child: pw.Text(documentsCopy[0]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=2 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[1]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[1])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[1]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[1]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[1]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=3 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[2]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[2])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[2]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[2]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[2]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=4 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[3]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[3])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[3]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[3]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[3]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=5 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[4]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[4])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[4]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[4]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[4]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=6 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[5]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[5])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[5]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[5]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[5]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=7 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[6]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[6])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[6]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[6]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[6]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=8 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[7]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[7])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[7]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[7]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[7]["descricao"])
                      ),
                    ]
                ) : pw.Container(),


                documentsCopy.length>=9 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[8]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[8])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[8]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[8]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[8]["descricao"])
                      ),
                    ]
                ) : pw.Container(),


                documentsCopy.length>=10 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[9]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[9])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[9]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[9]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[9]["descricao"])
                      ),
                    ]
                ) : pw.Container(),


                documentsCopy.length>=11 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[10]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[10])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[10]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[10]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[10]["descricao"])
                      ),
                    ]
                ) : pw.Container(),


                documentsCopy.length>=12 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[11]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[11])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[11]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[11]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[11]["descricao"])
                      ),
                    ]
                ) : pw.Container(),


                documentsCopy.length>=13 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[12]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[12])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[12]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[12]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[12]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=14 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[13]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[13])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[13]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[13]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[13]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=15 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[14]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[14])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[14]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[14]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[14]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=16 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[15]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[15])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[15]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[15]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[15]["descricao"])
                      ),
                    ]
                ) : pw.Container(),

                documentsCopy.length>=17 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[16]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[16])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[16]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[16]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[16]["descricao"])
                      ),
                    ]
                ) : pw.Container(),


                documentsCopy.length>=18 ?
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Divider(),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[19]["dataEntrega"])
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        height: 70.0,
                        width: 70.0,
                        child: pw.AspectRatio(
                            aspectRatio: 1/0.5,
                            child: pw.Image(listOfImages[19])),

                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[19]["codigo"])
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 70.0,
                          child: pw.Text(documentsCopy[19]["preco"].toStringAsFixed(2))
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          height: 70.0,
                          width: 180.0,
                          child: pw.Text(documentsCopy[19]["descricao"])
                      ),
                    ]
                ) : pw.Container(),






              ];
            }
        )
    );

    savePdf();

    setState(() {
      isPrinting = false;
    });

  }


   */
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  void pdfNewTry() async {

    List<String> listOfUrl = [];



    int cont=0;
    while(cont<documentsCopy.length){
      listOfUrl.add(documentsCopy[cont]["imagem"].toString());
      cont++;
    }

    List<Uint8List> listOfUint8 = [];
    cont=0;
    while (cont<documentsCopy.length){

      http.Response response = await http.get(
          listOfUrl[cont]
      );
      response.bodyBytes;
      final Uint8List list = response.bodyBytes.buffer.asUint8List();
      listOfUint8.add(list);
      cont++;
    }

    cont=0;
    List<PdfImage> listOfImages = [];

    while(cont<documentsCopy.length){

      final image = PdfImage.file(pdf.document, bytes: listOfUint8[cont]);
      listOfImages.add(image);
      cont++;
    }

    cont=0;
    while (cont<documentsCopy.length){

      createPage();

      //para imprimri 2 por páginacttt
      cont=cont+2;


    }








    /*
    while (cont<documentsCopy.length){
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(8.0),

          build: (pw.Context context){
            return <pw.Widget>[
              pw.Header(
                level: 0,
                child: pw.Text(filterOptions=="nao" ? "Relatório do estoque completo" : filterOptions=="falta" ? "Relatório dos itens em falta" : "Relatório ordenado por antiguidade", style: pw.TextStyle(fontSize: 20.0)),
              ),
              pw.Row(
                children: <pw.Widget>[
                  pw.AspectRatio(
                      aspectRatio: 2/1,
                      child: pw.Image(listOfImages[cont])),
                  pw.Text(
                    documentsCopy[cont]["codigo"], style: pw.TextStyle(fontSize: 20.0),
                  ),
                ],
              ),

            ];
          }
        )
      );

      //para imprimri 2 por páginacttt
      cont=cont+2;
    }



     */

    /*
    pdf.addPage(
        pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(16.0),

            build: (pw.Context context) {
              return <pw.Widget>[
                pw.Header(
                    level: 0,
                    child: pw.Text(filterOptions=="nao" ? "Relatório do estoque completo" : filterOptions=="falta" ? "Relatório dos itens em falta" : "Relatório ordenado por antiguidade")
                ),
                //pw.Image(image)


                /*
                pw.AspectRatio(
                    aspectRatio: 2/1,
                    child: pw.Image(image)),
                 */


              ];
            }
        )
    );

     */

    //savePdf();
  }


  Future savePdf() async {

    final _fileName = "listagem_estoque_${DateTime.now().day.toString()}_${DateTime.now().month.toString()}_${DateTime.now().minute.toString()}_${DateTime.now().second.toString()}.pdf";
    File file = File("/storage/emulated/0/Download/$_fileName");
    file.writeAsBytesSync(pdf.save());

    print("Arquivo gerado");
  }


  //backup
  /*
  void pdfNewTry() async {

    Uint8List targetlUinit8List;
    Uint8List originalUnit8List;

    String url = "https://firebasestorage.googleapis.com/v0/b/guby-5eaac.appspot.com/o/produtos%2F1596030308423img?alt=media&token=b7f6d6e9-3b1d-42b7-9bc7-cc030b973157";

    String imageUrl = url;

    /*
    http.Response response2 = await http.get(imageUrl);
    originalUnit8List = response2.bodyBytes;

    ui.Image originalUiImage = await decodeImageFromList(originalUnit8List);
    ByteData originalByteData = await originalUiImage.toByteData();
    print('original image ByteData size is ${originalByteData.lengthInBytes}');

    print(originalUiImage.height);
    print(originalUiImage.width);

    //int height = originalUiImage.height;
    //int width = originalUiImage.width;
    //int ratio = 85;

    //int cont = 0;
    //while (cont<1000){

    //}

    var codec = await ui.instantiateImageCodec(originalUnit8List,
        //targetHeight: 50, targetWidth: 50);
        targetHeight: (height/ratio).toInt(), targetWidth: (width/ratio).toInt());
    var frameInfo = await codec.getNextFrame();
    ui.Image targetUiImage = frameInfo.image;

    ByteData targetByteData =
    await targetUiImage.toByteData(format: ui.ImageByteFormat.png);
    print('target image ByteData size is ${targetByteData.lengthInBytes}');
    targetlUinit8List = targetByteData.buffer.asUint8List();

    PdfImage image = new PdfImage(
        pdf.document,
        image: targetlUinit8List,
        width: (height/ratio).toInt(),
        height: (width/ratio).toInt());


     */

    http.Response response = await http.get(
        url
    );
    response.bodyBytes; //Uint8List

    final Uint8List list = response.bodyBytes.buffer.asUint8List();


    final image = PdfImage.file(
      pdf.document,
      bytes: list,
    );


    /*
    final image = PdfImage.file(
      pdf.document,
      bytes: list,
    );

     */


    /*
    PdfImage image = new PdfImage(
        pdf.document,
        image: list,
        width: 50,
        height: 50);
     */

    pdf.addPage(
        pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(16.0),

            build: (pw.Context context) {
              return <pw.Widget>[
                pw.Header(
                    level: 0,
                    child: pw.Text(filterOptions=="nao" ? "Relatório do estoque completo" : filterOptions=="falta" ? "Relatório dos itens em falta" : "Relatório ordenado por antiguidade")
                ),
                //pw.Image(image)
              pw.AspectRatio(
              aspectRatio: 2/1,
              child: pw.Image(image)),



              ];
            }
        )
    );

    savePdf();
  }


  Future savePdf() async {
    //Directory documentDirectory = await getExternalStorageDirectory();


    //Directory documentDirectory = await getApplicationDocumentsDirectory();
    //String documentPath = documentDirectory.path;

    //File file = File("$documentPath/example.pdf");
    final _fileName = "listagem_estoque_${DateTime.now().day.toString()}_${DateTime.now().month.toString()}_${DateTime.now().minute.toString()}_${DateTime.now().second.toString()}.pdf";
    //File file = File("/storage/emulated/0/Download/example.pdf");
    File file = File("/storage/emulated/0/Download/$_fileName");

    file.writeAsBytesSync(pdf.save());

    print("Arquivo gerado");
  }

   */


  Future<String> networkImageToBase64(String imageUrl) async {
    http.Response response = await http.get(imageUrl);
    final bytes = response?.bodyBytes;
    return (bytes != null ? base64Encode(bytes) : null);
  }


  Future <pw.Page> createPage(){

    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Row(children: <pw.Widget>[
        pw.Expanded(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Container(
                      padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Text('Parnella Charlesbois',
                                textScaleFactor: 2,
                                style: pw.Theme.of(context)
                                    .defaultTextStyle
                                    .copyWith(fontWeight: pw.FontWeight.bold)),
                            pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                            pw.Text('Electrotyper',
                                textScaleFactor: 1.2,
                                style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: <pw.Widget>[
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: <pw.Widget>[
                                        pw.Text('568 Port Washington Road'),
                                        pw.Text('Nordegg, AB T0M 2H0'),
                                        pw.Text('Canada, ON'),
                                      ]),
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: <pw.Widget>[
                                        pw.Text('+1 403-721-6898'),
                                      ]),
                                  pw.Padding(padding: pw.EdgeInsets.zero)
                                ]),
                          ])),
                ])),
        pw.Container(
          height: double.infinity,
          width: 2,
          margin: const pw.EdgeInsets.symmetric(horizontal: 5),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.ClipOval(
              child: pw.Container(
                width: 100,
                height: 100,
              ),
            ),
            pw.Column(children: <pw.Widget>[

            ]),
            pw.BarcodeWidget(
              data: 'Parnella Charlesbois',
              width: 60,
              height: 60,
              barcode: pw.Barcode.qrCode(),
            ),
          ],
        )
      ]),
    ));
    //return pdf.save();


  }



}



