import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gisapp/Models/resumo_vendas_model.dart';
import 'package:gisapp/Utils/dates_utils.dart';
import 'package:gisapp/classes/resumo_vendas_class.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';


class ResumoVendasPage extends StatefulWidget {
  @override
  _ResumoVendasPageState createState() => _ResumoVendasPageState();
}

class _ResumoVendasPageState extends State<ResumoVendasPage> {



  ResumoVendasModel resumoVendasModel = ResumoVendasModel();

  final TextEditingController _searchController = TextEditingController();
  String filter;
  String tipoFiltro="nao";

  List<DocumentSnapshot> documents=[];
  List<int> positionsList=[];

  String mesSelecionado;
  String mesFinal;
  
  double total=0.00;
  bool hasTotalAlready = false;

  final TextEditingController _dateController = TextEditingController();
  var maskFormatterDataApenasMes = new MaskTextInputFormatter(mask: '##/####', filter: { "#": RegExp(r'[0-9]') });
  var maskFormatterDataCompleta = new MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]') });
  final TextEditingController _dateLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {

      setState(() {
        filter = _searchController.text;
      });


    });

  } //essa só será usada se tiver um limite de data


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: WidgetsConstructor().makeSimpleText("Resumo de vendas", Colors.white, 16.0),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.print, color: Colors.white,),
            onPressed: (){
              resumoVendasModel.setPage(3);

              List<DocumentSnapshot> listCopy = ResumoVendasClass().filterPlease(tipoFiltro, filter, documents, mesSelecionado, mesFinal);
              ResumoVendasClass().printListInPdf(tipoFiltro, filter, listCopy, mesSelecionado, mesFinal);


            },
          )
        ],
      ),
      body: Observer(
        builder: (_){
          //change page abre com codigo 1 ou 2, mas exibe informações diferentes dependneod deste valor
          return resumoVendasModel.page==0 ? landPage() : resumoVendasModel.page==1 ? changeDatePage() : resumoVendasModel.page==2 ? changeDatePage() : resumoVendasModel.page==3 ? setupPrintPage() :  Container();
        },
      ),
    );



  }

  Widget landPage(){

    return  Container(
        color: Colors.white,
        height: 700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20.0,),
            Container(
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 50.0,
                      color: Colors.amber,
                      child: FlatButton(
                        child: Text("Este mês"),
                        onPressed: (){



                          setState(() {
                            tipoFiltro="nao";
                            _dateController.text="";
                            _dateLimitController.text="";
                            total = ResumoVendasClass().calculeTotal(tipoFiltro, filter, documents, mesSelecionado, mesFinal); //ajusta o total na row no bottom da pagina
                          });




                        },
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 50.0,
                      color: Colors.redAccent,
                      child: FlatButton(
                        child: Text("Mês específico"),
                        onPressed: (){
                          resumoVendasModel.setPage(1);
                          setState(() {
                            _dateController.text="";
                            _dateLimitController.text="";
                          });

                        },
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 50.0,
                      color: Colors.amber,
                      child: FlatButton(
                        child: Text("Mês específico"),
                        onPressed: (){
                          resumoVendasModel.setPage(2);
                          setState(() {
                            _dateController.text="";
                            _dateLimitController.text="";
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            Expanded(
        child:
        tipoFiltro=="nao" ? StreamBuilder<QuerySnapshot>(
           stream: Firestore.instance.collection("vendas").where('dataQuery', isEqualTo: DateUtils().returnThisMonthAndYear()).snapshots(),
          //este é um listener para observar esta coleção
          builder: (context, snapshot) { //começar a desenhar a tela
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return Center( //caso esteja vazio ou esperando exibir um circular progressbar no meio da tela
                  child: CircularProgressIndicator(),
                );
              default: documents = snapshot.data.documents.toList(); //recuperamos o querysnapshot que estamso observando

              return ListView.builder( //aqui vamos começar a construir a listview com// os itens retornados
                  itemCount: documents.length,
                  itemBuilder: (context, index) {

                    //nao escolheu filtro por data e nao colocou nenhum parametro na busca
                    if(tipoFiltro=="nao"){

                      if(hasTotalAlready==false){
                        hasTotalAlready=true;
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          setState(() {
                            total = ResumoVendasClass().calculeTotal(tipoFiltro, filter, documents, mesSelecionado, mesFinal); //ajusta o total na row no bottom da pagina
                          });
                        });
                      }


                      return filter == null || filter == "" ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )

                          : documents[index].data['cliente'].contains(filter) ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )
                          : Container();

                    } else if(tipoFiltro=="mes"){
                      
                      return filter == null || filter == "" && documents[index].data['data'].contains(mesSelecionado)? GestureDetector(
                    //pos 0
                    //pos 1
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )

                          : documents[index].data['cliente'].contains(filter) && documents[index].data['data'].contains(mesSelecionado) ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      ) : Container();

                    } else if(tipoFiltro=="duasDatas"){

                      return filter == null || filter == "" && DateUtils().doesThisDateIsBigger(documents[index].data['data'], mesSelecionado ) && DateUtils().doesThisDateIsBigger(mesFinal, documents[index].data['data']) ? GestureDetector(
                        //pos 0
                        //pos 1
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )

                          : documents[index].data['cliente'].contains(filter)  && DateUtils().doesThisDateIsBigger(documents[index].data['data'], mesSelecionado ) && DateUtils().doesThisDateIsBigger(mesFinal, documents[index].data['data']) ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      ) : Container();

                    } else {

                      return Container();

                    }

                    //se nao tiver resultado exibe nada
                  }
                  );

            }
          },
        )
            : tipoFiltro=="mes" ? StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("vendas").where('dataQuery', isEqualTo: mesSelecionado).snapshots(),
          //este é um listener para observar esta coleção
          builder: (context, snapshot) { //começar a desenhar a tela
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return Center( //caso esteja vazio ou esperando exibir um circular progressbar no meio da tela
                  child: CircularProgressIndicator(),
                );
              default: documents = snapshot.data.documents.toList(); //recuperamos o querysnapshot que estamso observando

              return ListView.builder( //aqui vamos começar a construir a listview com// os itens retornados
                  itemCount: documents.length,
                  itemBuilder: (context, index) {

                    //nao escolheu filtro por data e nao colocou nenhum parametro na busca
                    if(tipoFiltro=="nao"){

                      if(hasTotalAlready==false){
                        hasTotalAlready=true;
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          setState(() {
                            total = ResumoVendasClass().calculeTotal(tipoFiltro, filter, documents, mesSelecionado, mesFinal); //ajusta o total na row no bottom da pagina
                          });
                        });
                      }


                      return filter == null || filter == "" ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )

                          : documents[index].data['cliente'].contains(filter) ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )
                          : Container();

                    } else if(tipoFiltro=="mes"){

                      return filter == null || filter == "" && documents[index].data['data'].contains(mesSelecionado)? GestureDetector(
                        //pos 0
                        //pos 1
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )

                          : documents[index].data['cliente'].contains(filter) && documents[index].data['data'].contains(mesSelecionado) ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      ) : Container();

                    } else if(tipoFiltro=="duasDatas"){

                      return filter == null || filter == "" && DateUtils().doesThisDateIsBigger(documents[index].data['data'], mesSelecionado ) && DateUtils().doesThisDateIsBigger(mesFinal, documents[index].data['data']) ? GestureDetector(
                        //pos 0
                        //pos 1
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )

                          : documents[index].data['cliente'].contains(filter)  && DateUtils().doesThisDateIsBigger(documents[index].data['data'], mesSelecionado ) && DateUtils().doesThisDateIsBigger(mesFinal, documents[index].data['data']) ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      ) : Container();

                    } else {

                      return Container();

                    }

                    //se nao tiver resultado exibe nada
                  }
              );

            }
          },
        ) : StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("vendas").snapshots(),
          //este é um listener para observar esta coleção
          builder: (context, snapshot) { //começar a desenhar a tela
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return Center( //caso esteja vazio ou esperando exibir um circular progressbar no meio da tela
                  child: CircularProgressIndicator(),
                );
              default: documents = snapshot.data.documents.toList(); //recuperamos o querysnapshot que estamso observando

              return ListView.builder( //aqui vamos começar a construir a listview com// os itens retornados
                  itemCount: documents.length,
                  itemBuilder: (context, index) {

                    //nao escolheu filtro por data e nao colocou nenhum parametro na busca
                    if(tipoFiltro=="nao"){

                      if(hasTotalAlready==false){
                        hasTotalAlready=true;
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          setState(() {
                            total = ResumoVendasClass().calculeTotal(tipoFiltro, filter, documents, mesSelecionado, mesFinal); //ajusta o total na row no bottom da pagina
                          });
                        });
                      }


                      return filter == null || filter == "" ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )

                          : documents[index].data['cliente'].contains(filter) ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )
                          : Container();

                    } else if(tipoFiltro=="mes"){

                      return filter == null || filter == "" && documents[index].data['data'].contains(mesSelecionado)? GestureDetector(
                        //pos 0
                        //pos 1
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )

                          : documents[index].data['cliente'].contains(filter) && documents[index].data['data'].contains(mesSelecionado) ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      ) : Container();

                    } else if(tipoFiltro=="duasDatas"){

                      return filter == null || filter == "" && DateUtils().doesThisDateIsBigger(documents[index].data['data'], mesSelecionado ) && DateUtils().doesThisDateIsBigger(mesFinal, documents[index].data['data']) ? GestureDetector(
                        //pos 0
                        //pos 1
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      )

                          : documents[index].data['cliente'].contains(filter)  && DateUtils().doesThisDateIsBigger(documents[index].data['data'], mesSelecionado ) && DateUtils().doesThisDateIsBigger(mesFinal, documents[index].data['data']) ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //click no card da lista
                            //page=1;

                          });
                        },
                        child: listCard(index),
                      ) : Container();

                    } else {

                      return Container();

                    }

                    //se nao tiver resultado exibe nada
                  }
              );

            }
          },
        ),
      ),
            SizedBox(height: 10.0,),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                child: Container(
                  height: 40.0,
                  decoration: WidgetsConstructor().myBoxDecoration(Theme.of(context).primaryColor, 2.0, 5.0),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        WidgetsConstructor().makeSimpleText("Total: ", Colors.grey, 16.0),
                        WidgetsConstructor().makeSimpleText("R\$"+total.toStringAsFixed(2), Colors.grey, 16.0),
                      ],
                    ),
                  ),
                ),
              )
            ),
          ],
        )
    );
  }

  Widget changeDatePage(){
    return Container(
        height: 600.0,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
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
                          resumoVendasModel.setPage(0);
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 8.0,),
                  WidgetsConstructor().makeText(resumoVendasModel.page==1 ? "Informe mês e ano" : "Informe data inicial e data final", Theme.of(context).primaryColor, 20.0, 16.0, 2.0, "center"),
                  WidgetsConstructor().makeSimpleText(resumoVendasModel.page==1 ? "Exemplo: mm/yyyy" : "Exemplo: 12/12/2020 - 18/12/2020", Colors.grey[300], 12.0),
                  SizedBox(height: 16.0,),
                  WidgetsConstructor().makeEditTextForDateFormat(_dateController, resumoVendasModel.page==1 ? "Mês e ano" : "Data inicial", resumoVendasModel.page==1 ? maskFormatterDataApenasMes : maskFormatterDataCompleta ),
                  resumoVendasModel.page==2 ? WidgetsConstructor().makeEditTextForDateFormat(_dateLimitController, "Data final", maskFormatterDataCompleta) : Container(),
                  SizedBox(height: 36.0,),
                  Container(
                    height: 55.0,
                    margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    color: Theme.of(context).primaryColor,
                    child: FlatButton(
                      child: WidgetsConstructor().makeSimpleText("Buscar", Colors.white, 16.0),
                      onPressed: (){
                        //clicou
                        if(resumoVendasModel.page==1){

                          resumoVendasModel.setPage(0);
                          setState(() {

                            tipoFiltro="mes";
                            mesSelecionado = _dateController.text;
                            _searchController.text=="x"; //esta sequencia é pq nao atualizava direto a busca. Entao fazend isto obriga a atualizar
                            _searchController.text=" ";
                            _searchController.text="";
                            total = ResumoVendasClass().calculeTotal(tipoFiltro, filter, documents, mesSelecionado, mesFinal);

                          });

                        } else {

                          resumoVendasModel.setPage(0);
                          setState(() {
                            tipoFiltro="duasDatas";
                            mesSelecionado = _dateController.text;
                            mesFinal = _dateLimitController.text;
                            _searchController.text=="x"; //esta sequencia é pq nao atualizava direto a busca. Entao fazend isto obriga a atualizar
                            _searchController.text=" ";
                            _searchController.text="";
                            total = ResumoVendasClass().calculeTotal(tipoFiltro, filter, documents, mesSelecionado, mesFinal);

                          });

                        }
                      },
                    ),
                  ),

                ],
              ),
            )
          ],
        )
    );
  }

  Widget setupPrintPage(){
    return Container(height: 600.0,
      child: Column(
        children: <Widget>[
          SizedBox(height: 200.0,),
          resumoVendasModel.printing == true ? Center(
            child: CircularProgressIndicator(),
          ) : Container(),

          SizedBox(height: 30.0,),
          resumoVendasModel.printing == true ? WidgetsConstructor().makeSimpleText("Aguarde, gerando arquivo", Colors.grey[700], 17.0)
          : WidgetsConstructor().makeSimpleText("Pronto!", Colors.grey[700], 17.0),
          resumoVendasModel.printing == false ? WidgetsConstructor().makeSimpleText("Você encontra o arquivo na pasta Downloads.", Colors.grey[400], 12.0)
          : Container(),
          SizedBox(height: 30.0,),
          resumoVendasModel.printing == false ? Container(
            height: 65.0,
            color: Theme.of(context).primaryColor,
            child: FlatButton(
              child: WidgetsConstructor().makeSimpleText("Fechar", Colors.white, 16.0),
              onPressed: () {
                //ResumoVendasModel().setPrinting();
                resumoVendasModel.setPage(0);
              },
            ),
          ) : Container(),
        ],
      )
    );
  }

  Widget listCard (int index){
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            WidgetsConstructor().makeText(" "+documents[index]['cliente'], Theme.of(context).primaryColor, 16.0, 5.0, 4.0, "no"),
            WidgetsConstructor().makeSimpleText("Nº boleto: "+documents[index]['nBoleto'], Colors.grey[300], 12.0),
            WidgetsConstructor().makeSimpleText("Forma de pgto: "+ResumoVendasClass().formaPgtoFormattada(documents[index]['formaPgto'], documents, index), Colors.grey[300], 12.0),
            WidgetsConstructor().makeSimpleText("Itens: "+ResumoVendasClass().retorneItensDestaVenda(documents, index), Colors.grey[300], 12.0),
            SizedBox(height: 10.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                WidgetsConstructor().makeSimpleText(" "+documents[index]['data'], Colors.grey, 15.0),
                WidgetsConstructor().makeSimpleText("R\$"+documents[index]['valor'].toStringAsFixed(2)+" ", Colors.grey, 15.0),

              ],
            ),
            SizedBox(height: 4.0,)
          ],
        ),
      ),
    );
  }


}



