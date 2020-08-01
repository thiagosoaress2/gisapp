import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gisapp/Models/estoque_models.dart';
import 'package:gisapp/Utils/currency_edittext_builder.dart';
import 'package:gisapp/Utils/firebase_utils.dart';
import 'package:gisapp/Utils/photo_service.dart';
import 'package:gisapp/classes/product_class.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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

  bool aceptChanges= true;  //se for true vai deixar documentsCopy sofrer alterações.


  int page = 0;
  //0 - landing page

  bool printThis = false;

  final TextEditingController _searchController = TextEditingController();
  String query;

  String filterOptions = "nao";

  String moeda;

  //'nao' é o padrão, sem filtro
  //'falta' é para exibir itens em falta
  //'antigos' exibe os produtos em ordem de antiguidade

  List<ProductClass> _produtosEmEstoque = [];

  //List<DocumentSnapshot> documents;  //esta é a lista que recebe o snapshot
  List<DocumentSnapshot> documentsCopy; //esta lista recebe uma copia. Vamos usar pra poder alterar o conteudo da lista acima e filtrar os itens.
  bool isPrinting = false;

  int position = 0;

  bool isUpdating = false;
  bool dialogIsVisible = false;

  @override
  void initState() {
    super.initState();
    //listener da busca
    _searchController.addListener(() {
      setState(() {
        aceptChanges=true;
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
        actions: <Widget>[
          page==1 ?
          FlatButton(
            child: Icon(Icons.edit, color: Colors.white,),
            onPressed: (){
              setState(() {
                page=2;
              });
            },
          ) : Container()
        ],
      ),
      body: Stack(
        children: <Widget>[
          page == 0 ? LandingPage() : page==1 ? productDetailsPage() : page==2 ? editProductDetailPage() : Container(),
          isUpdating ? Center(child: CircularProgressIndicator(),) : Container(),
          dialogIsVisible ? Center(child: customDialogScreen(),) : Container(),
        ],
      )
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
                      List<DocumentSnapshot> documents = snapshot.data.documents.toList(); //recuperamos o querysnapshot que estamso observando

                      if(aceptChanges){
                        aceptChanges=false;
                        documentsCopy = documents;
                      }


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

  Widget productDetailsPage() {

    return Container(
      height: 700,
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[

              SizedBox(height: 16.0,),
              Container(
                margin: EdgeInsets.only(right: 16.0),
                alignment: Alignment.topRight,
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
              ), //btn fechar,

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(documentsCopy[position]["codigo"], textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.grey[500]),),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                height: 200,
                width: 200,
                child: Image.network(documentsCopy[position]["imagem"], fit: BoxFit.cover,),
              ),
              SizedBox(height: 16.0,),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                  child: createExpandable(context, "Informações de compra", "R\$ "+documentsCopy[position]["custo"].toStringAsFixed(2), documentsCopy[position]["dataCompra"], documentsCopy[position]["dataEntrega"], documentsCopy[position]["moedaCompra"], documentsCopy[position]["notaFiscal"], documentsCopy[position].documentID),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: WidgetsConstructor().makeText("Quantidade em estoque: "+documentsCopy[position]["quantidade"].toString(), documentsCopy[position]["quantidade"]==0 ? Colors.red : Colors.grey[700], 18.0, 16.0, 16.0, "no"),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: WidgetsConstructor().makeText("Descrição:\n"+documentsCopy[position]["descricao"].toString(), Colors.grey[500], 18.0, 0.0, 24.0, "no"),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 70.0,
                  width: 200.0,
                  color: Theme.of(context).primaryColor,
                  child: Text("R\$ "+documentsCopy[position]["preco"].toStringAsFixed(2), style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),)
                ),
              ),
              SizedBox(height: 36.0,),




            ],
          )
        ],
      ),
    );
  }

  Widget editProductDetailPage() {

    final TextEditingController _codigoController = TextEditingController();
    _codigoController.text = documentsCopy[position]["codigo"];
    final TextEditingController _dataCompraController = TextEditingController();
    var maskFormatterDataCompra = new MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]')});
    _dataCompraController.text = documentsCopy[position]["dataCompra"];
    final TextEditingController _dataEntregaController = TextEditingController();
    var maskFormatterDataEntrega = new MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]')});
    _dataEntregaController.text = documentsCopy[position]["dataEntrega"];
    final TextEditingController _custoController = TextEditingController();

    final TextEditingController _NotaFiscalController = TextEditingController();
    _NotaFiscalController.text = documentsCopy[position]["notaFiscal"];
    final TextEditingController _quantidadeController = TextEditingController();
    _quantidadeController.text = documentsCopy[position]["quantidade"].toString();
    final TextEditingController _descricaoController = TextEditingController();
    _descricaoController.text = documentsCopy[position]["descricao"];
    final TextEditingController _precoController = TextEditingController();

    bool updated=false;

    if(updated==false){

      updated = true;

      //setState(() {
        Future.delayed(const Duration(milliseconds: 2000), () {

          moeda = documentsCopy[position]["moedaCompra"];
          _precoController.text = "";
          String preco = documentsCopy[position]["preco"].toString();
          _precoController.text = preco;
          _custoController.text="";
          _custoController.text = documentsCopy[position]["custo"].toString();

        });

      //});
    }


    return Container(
      height: 700.0,
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.all(24.0),
        children: <Widget>[
          SizedBox(height: 16.0,),
          Container(

            alignment: Alignment.topRight,
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
                  page=1;
                });
              },
            ),
          ), //
          WidgetsConstructor().makeText("Edição de informações", Theme.of(context).primaryColor, 20.0, 16.0, 16.0, "center"),
          WidgetsConstructor().makeEditText(_codigoController, "Codigo do produto", null),
          WidgetsConstructor().makeEditTextForDateFormat(_dataCompraController, "Data da compra",maskFormatterDataCompra),
          WidgetsConstructor().makeEditTextForDateFormat(_dataEntregaController, "Data da entrega",maskFormatterDataEntrega),
          CurrencyEditTextBuilder().makeMoneyTextFormFieldSettings(_custoController, "Custo"),
          CurrencyEditTextBuilder().makeMoneyTextFormFieldSettings(_precoController, "Preço"),
          WidgetsConstructor().makeText("Moeda da compra", Colors.grey[500], 18.0, 16.0, 16.0, "no"),
          buildRadioOptions(context),
          WidgetsConstructor().makeEditText(_NotaFiscalController, "Nota fiscal", null),
          WidgetsConstructor().makeFormEditTextNumberOnly(_quantidadeController, "Quantidade", "no"),
          WidgetsConstructor().makeEditText(_descricaoController, "Descrição", null),
          SizedBox(height: 30.0,),
          Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(16.0),
            height: 70.0,
            color: Theme.of(context).primaryColor,
            child: FlatButton(
              textColor: Colors.white,
              child: WidgetsConstructor().makeSimpleText("Salvar alterações", Colors.white, 22.0),
              onPressed: (){


                Future.delayed(const Duration(milliseconds: 3000), () {
                  setState(() {
                    isUpdating=true;
                  });
                }).whenComplete((){
                  setState(() {
                    isUpdating=false;
                    _displaySnackBar(context, "Alterações salvas.");
                  });
                });
                //falta fazer o loading

                EstoqueModels produto = EstoqueModels(
                    _codigoController.text,
                    _dataCompraController.text,
                    _dataEntregaController.text,
                    double.parse(_custoController.text) ,
                    _dataEntregaController.text,
                    int.parse(_quantidadeController.text),
                    _descricaoController.text,
                    double.parse(_precoController.text),
                    moeda,
                );

                EstoqueModels.empty().saveChangesInProdc(produto, documentsCopy[position].documentID);

              },
            ),
          ), //botão de salvar
          Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(16.0),
            height: 70.0,
            color: Colors.redAccent,
            child: FlatButton(
              textColor: Colors.white,
              child: WidgetsConstructor().makeSimpleText("Excluir item", Colors.white, 22.0),
              onPressed: (){

                _showCustomDialog();

              },
            ),
          ) //botão de excluir
        ],
      ),
    );

  }



  filterList(){

    List<int> listOfRemovables=[];


    //documentsCopy = documents;
    if(documentsCopy.length==0){
      _displaySnackBar(context, "Não existem itens para a lista.");
    } else {

      if (filterOptions == "nao" && query == null || query == "") {

        //imprimir a lista completa sem fazer nada

      } else if(filterOptions == "nao" && query != null ||query != ""){
        //imprimir apenas os elementos que possuam itens da query
        documentsCopy.removeWhere((element) => !element.data['codigo'].toString().contains(query));

      } else if(filterOptions == "falta" && query == null || query == ""){
        //documentsCopy = documents;
        documentsCopy.removeWhere((element) => element.data['quantidade']!=0);

      } else if(filterOptions == "falta" && query != null || query != ""){
        //documentsCopy = documents;
        documentsCopy.removeWhere((element) => !element.data['codigo'].toString().contains(query) && element.data['quantidade']!=0);

        /*
        documentsCopy.forEach((element) {
          String x = element.data['codigo'];
          if(!x.contains(query)){
            //se o elemento possui o item buscado
            if(element.data['quantidade']!=0){
              //se a quantidade não é 0 (estamos buscando os 0, produtos em falta) remove da lista
              documentsCopy.remove(element);
            }
          }
        });
         */

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
                          ? "Relatório do estoque"
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

  Widget createExpandable(BuildContext context, String title, String custo, String dataCompra, String dataEntrega, String moedaCompra, String notaFiscal, String idProd) {
    return ExpandablePanel(
      header: Text(title),
      collapsed: Text("custo: "+custo, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,), //exibe o custo quando fechado
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Data compra: "+dataCompra, softWrap: true, ), //data compra
          SizedBox(height: 8.0,),
          Text("Data entrega: "+dataEntrega, softWrap: true, ), //data entrega
          SizedBox(height: 8.0,),
          Text("Custo: "+custo, softWrap: true, ), //custo
          SizedBox(height: 8.0,),
          Text("Moeda compra: "+moedaCompra, softWrap: true, ), //MoedaCompra
          SizedBox(height: 8.0,),
          Text("Nota fiscal: "+notaFiscal, softWrap: true, ), //NotaFiscal
          SizedBox(height: 8.0,),
          Text("Identificação do produto: "+idProd, softWrap: true, ), //IdDoProduto
          SizedBox(height: 8.0,),
        ],
      ),
      tapHeaderToExpand: true,
      hasIcon: true,
    );
  }

  Widget buildRadioOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RadioButton(
          description: "Dólar US\$",
          value: "dolar",
          groupValue: moeda,
          onChanged: (value) => setState(
                () => moeda = value,
          ),
        ),
        RadioButton(
          description: "Real R\$",
          value: "real",
          groupValue: moeda,
          onChanged: (value) => setState(
                () => moeda = value,
          ),
        ),
      ],
    );
  }

  void _showCustomDialog(){

    setState(() {
      dialogIsVisible = !dialogIsVisible; //exibe dialog

    });


  }

  Widget customDialogScreen() {


      return Container(
        height: 700.0,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            SizedBox(height: 100,),
            Flexible(
              flex: 2,
              child: Text("Você tem certeza que deseja excluir este item?", style: TextStyle(color: Colors.redAccent, fontSize: 22.0,
              ), textAlign: TextAlign.center,)

            ),
            SizedBox(height: 100,),
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(width: 20.0,),
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors.redAccent,
                      child: FlatButton(
                        child: WidgetsConstructor().makeSimpleText("Sim, excluir", Colors.white, 20.0),
                        onPressed: (){

                          setState(() {
                            //apagar do storage
                            FirebaseUtils.empty().deleteFile(documentsCopy[position]["imagem"]);
                            //apagar do firebase
                            EstoqueModels.empty().deleteProduct(documentsCopy[position].documentID);
                            _showCustomDialog(); //fecha janela
                            page=0;
                            _displaySnackBar(context, "Produto excluído");

                          });

                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0,),
                  Flexible(
                    flex: 1,
                    child: Container(
                      decoration: myBoxDecoration(),
                      child: FlatButton(
                        child: WidgetsConstructor().makeSimpleText("Cancelar", Colors.redAccent, 20.0),
                        onPressed: (){
                          _showCustomDialog();
                        },
                      ),
                    )
                  ),
                  SizedBox(width: 20.0,),
                ],
              ),
            )
          ],
        ),
      );

  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: Colors.redAccent, //
        width: 1, //                   <--- border width here
      ),
      /*
      borderRadius: BorderRadius.all(
          Radius.circular(5.0) //         <--- border radius here
      ),

       */
    );
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



