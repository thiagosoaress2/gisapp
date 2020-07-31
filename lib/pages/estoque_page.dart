import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gisapp/Models/estoque_models.dart';
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

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  //itens da foto
  PhotoService photoService = PhotoService();

  File img;

  final pdf = pw.Document();

  int page = 0;
  //0 - landing page

  bool printThis = false;

  final TextEditingController _searchController = TextEditingController();
  String query;

  String filterOptions = "nao";

  //'nao' é o padrão, sem filtro
  //'falta' é para exibir itens em falta
  //'antigos' exibe os produtos em ordem de antiguidade

  List<ProductClass> _produtosEmEstoque = [];

  List<DocumentSnapshot> documents;  //esta é a lista que recebe o snapshot
  //List<DocumentSnapshot> documentsCopy; //esta lista recebe uma copia. Vamos usar pra poder alterar o conteudo da lista acima e filtrar os itens.
  bool isPrinting = false;

  int position = 0;

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
      key: _scaffoldKey,
      appBar: AppBar(
        title: WidgetsConstructor().makeSimpleText(
            "Estoque", Colors.white, 18.0),
        centerTitle: true,
      ),
      body: page == 0 ? LandingPage() : page==1 ? productDetails() : Container(),
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
                          filterList();

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
                  SizedBox(height: 4.0,),
                  Text("Pode demorar um pouco dependendo da quantidade de itens", style: TextStyle(color: Colors.grey[300], fontSize: 15.0),),
                  SizedBox(height: 16.0,),

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
                      documents = snapshot.data.documents
                          .toList(); //recuperamos o querysnapshot que estamso observando
                      EstoqueModels.empty().copyList(documents); //documentsCopy = documents;

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
                                    page=1;
                                    position = index;
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

  Widget productDetails() {

    return Container(
      height: 700,
      color: Colors.white,
      child: Column(
        children: <Widget>[

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 50.0,
                height: 50.0,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 30.0,
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    setState(() {
                      page=0;
                    });
                  },
                ),
              ), //btn fechar
            ],
          ),
          Container(
            height: 100,
            width: 100,
            child: Image.network(EstoqueModels.empty().documents[position]["imagem"]), //.documentsCopy[position]["imagem"]),
          ),
          SizedBox(height: 16.0,),
          Container(
            child: Text(EstoqueModels.empty().documents[position]["codigo"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.grey[500]),),
          ),

        ],
      )
    );
  }

  filterList(){

    List<int> listOfRemovables=[];


    EstoqueModels.empty().copyList(documents);// = documents;
    if(EstoqueModels.empty().documents.length==0){
      _displaySnackBar(context, "Não existem itens para a lista.");
    } else {

      if (filterOptions == "nao" && query == null || query == "") {

        //imprimir a lista completa sem fazer nada

      } else if(filterOptions == "nao" && query != null ||query != ""){
        //imprimir apenas os elementos que possuam itens da query
        EstoqueModels.empty().copyList(documents);
        //documentsCopy = documents;
        /*
      int cont=0;
      while(cont<documents.length){
        String x = documents[cont]['codigo'];
        if(!x.contains(query)){
          listOfRemovables.add(cont);
        }
      }

       */
        EstoqueModels.empty().documents.removeWhere((element) => !element.data['codigo'].toString().contains(query));

        /*
      documents.forEach((element) {
        String x = element.data['codigo'];
        if(!x.contains(query)){
          documentsCopy.remove(element);
        }
      });

       */
      } else if(filterOptions == "falta" && query == null || query == ""){
        EstoqueModels.empty().copyList(documents);
        EstoqueModels.empty().documents.forEach((element) {
          if(element.data['quantidade']!=0){
            EstoqueModels.empty().documents.remove(element);
          }
        });
      } else if(filterOptions == "falta" && query != null || query != ""){
        EstoqueModels.empty().copyList(documents);
        EstoqueModels.empty().documents.forEach((element) {
          String x = element.data['codigo'];
          if(!x.contains(query)){
            //se o elemento possui o item buscado
            if(element.data['quantidade']!=0){
              //se a quantidade não é 0 (estamos buscando os 0, produtos em falta) remove da lista
              EstoqueModels.empty().documents.remove(element);
            }
          }
        });


      }

      createPdfFile();  //monta o pdf

    }



  }

  void createPdfFile() async {
    setState(() {
      isPrinting = true;
    });

    List<PdfImage> listOfImages = [
    ]; //armazena as imagens convertidas para depois exibir no pdf
    int cont = 0;

    Uint8List targetlUinit8List;
    Uint8List originalUnit8List;


    while (cont < EstoqueModels.empty().documents.length) {
      String imageUrl = EstoqueModels.empty().documents[cont]["imagem"];

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
    while (cont < EstoqueModels.empty().documents.length) {  //o documento vai ser impresso de 10 em 10
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


                  EstoqueModels.empty().documents.length >= cont+1 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont]["dataEntrega"])
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
                            child: pw.Text(EstoqueModels.empty().documents[cont]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                EstoqueModels.empty().documents[cont]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  EstoqueModels.empty().documents.length >= cont+2 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+1]["dataEntrega"])
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
                            child: pw.Text(EstoqueModels.empty().documents[cont+1]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                EstoqueModels.empty().documents[cont+1]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+1]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  EstoqueModels.empty().documents.length >= cont+3 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+2]["dataEntrega"])
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
                            child: pw.Text(EstoqueModels.empty().documents[2]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                EstoqueModels.empty().documents[cont+2]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+2]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  EstoqueModels.empty().documents.length >= cont+4 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+3]["dataEntrega"])
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
                            child: pw.Text(EstoqueModels.empty().documents[cont+3]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                EstoqueModels.empty().documents[cont+3]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+3]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  EstoqueModels.empty().documents.length >= cont+5 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+4]["dataEntrega"])
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
                            child: pw.Text(EstoqueModels.empty().documents[cont+4]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                EstoqueModels.empty().documents[cont+4]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+4]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  EstoqueModels.empty().documents.length >= cont+6 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+5]["dataEntrega"])
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
                            child: pw.Text(EstoqueModels.empty().documents[cont+5]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                EstoqueModels.empty().documents[cont+5]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+5]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  EstoqueModels.empty().documents.length >= cont+7 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+6]["dataEntrega"])
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
                            child: pw.Text(EstoqueModels.empty().documents[cont+6]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                EstoqueModels.empty().documents[cont+6]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+6]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),

                  EstoqueModels.empty().documents.length >= cont+8 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+7]["dataEntrega"])
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
                            child: pw.Text(EstoqueModels.empty().documents[cont+7]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                EstoqueModels.empty().documents[cont+7]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+7]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),


                  EstoqueModels.empty().documents.length >= cont+9 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+8]["dataEntrega"])
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
                            child: pw.Text(EstoqueModels.empty().documents[cont+8]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                EstoqueModels.empty().documents[cont+8]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+8]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),


                  EstoqueModels.empty().documents.length >= cont+10 ?
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Divider(),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+9]["dataEntrega"])
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
                            child: pw.Text(EstoqueModels.empty().documents[cont+9]["codigo"])
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 70.0,
                            child: pw.Text(
                                EstoqueModels.empty().documents[cont+9]["preco"].toStringAsFixed(2))
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            height: 70.0,
                            width: 180.0,
                            child: pw.Text(EstoqueModels.empty().documents[cont+9]["descricao"])
                        ),
                      ]
                  ) : pw.Container(),


                ];
              }
          )
      );


      cont = cont + 10;
    }
    savePdfFile();

    setState(() {
      isPrinting = false;

      _displaySnackBar(context, "O arquivo está disponível na pasta Downloads.");
    });

  }

  Future savePdfFile() async {

    final _fileName = "listagem_estoque_${DateTime.now().day.toString()}_${DateTime.now().month.toString()}_${DateTime.now().minute.toString()}_${DateTime.now().second.toString()}.pdf";
    File file = File("/storage/emulated/0/Download/$_fileName");
    file.writeAsBytesSync(pdf.save());

    print("Arquivo gerado");
  }

  _displaySnackBar(BuildContext context, String msg) {

    final snackBar = SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: "Ok",
        onPressed: (){
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

}



