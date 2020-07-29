import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gisapp/classes/product_class.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';

class EstoquePage extends StatefulWidget {
  @override
  _EstoquePageState createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {

  int page=0;

  final TextEditingController _searchController = TextEditingController();
  String filter;

  List<ProductClass> _produtosEmEstoque = [];



  @override
  void initState() {
    super.initState();
    //listener da busca
    _searchController.addListener(() {
      setState(() {
        filter = _searchController.text;
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
        title: WidgetsConstructor().makeSimpleText("Estoque", Colors.white, 18.0),
        centerTitle: true,
      ),
      body: page==0 ? LandingPage() : Container(),
    );
  }

  Widget LandingPage(){

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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("produtos").snapshots(), //este é um listener para observar esta coleção
                builder: (context, snapshot){  //começar a desenhar a tela
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return  Center( //caso esteja vazio ou esperando exibir um circular progressbar no meio da tela
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> documents = snapshot.data.documents.toList(); //recuperamos o querysnapshot que estamso observando

                      return ListView.builder(  //aqui vamos começar a construir a listview com os itens retornados
                          itemCount: documents.length,
                          itemBuilder: (context, index){
                            return filter == null || filter == "" ? //se for null ou "" exibe o conteudo todo
                            GestureDetector(
                              onTap: (){
                                setState(() {

                                  print("Clicou no item");

                                });
                              },
                              child:  Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(width: 10.0,),
                                    Image.network(documents[index].data["imagem"], width: 120.0, height: 120.0, fit: BoxFit.cover, ),
                                    SizedBox(width: 10.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        WidgetsConstructor().makeSimpleText(documents[index].data["codigo"], Theme.of(context).primaryColor, 18.0),
                                        SizedBox(height: 5.0,),
                                        Container(
                                          width: 150,
                                          child: WidgetsConstructor().makeSimpleText(documents[index].data["descricao"], Colors.grey[400], 14.0),),
                                        SizedBox(height: 5.0,),
                                        WidgetsConstructor().makeSimpleText("Em estoque desde: \n${documents[index].data["dataEntrega"]}", Colors.grey[500], 14.0),
                                        SizedBox(height: 5.0,),
                                        Container(
                                          padding: EdgeInsets.all(4.0),
                                          color: Theme.of(context).primaryColor,
                                          child: WidgetsConstructor().makeSimpleText("R\$ "+documents[index].data["preco"].toStringAsFixed(2), Colors.white, 20.0),
                                        ),
                                      ],
                                    ),
                                    //exibe a quantidade de itens. Se for 1 ou 2 fica amarelo. Se for 0 fica vermelho.
                                    documents[index].data["quantidade"] > 2 ? WidgetsConstructor().makeSimpleText(documents[index].data["quantidade"].toString(), Colors.blueGrey, 15.0) :
                                    documents[index].data["quantidade"] > 0 ? WidgetsConstructor().makeSimpleText(documents[index].data["quantidade"].toString(), Colors.amber, 15.0) :
                                    WidgetsConstructor().makeSimpleText(documents[index].data["quantidade"].toString(), Colors.red, 15.0),
                                  ],
                                ),

                              ),
                            )

                                : documents[index].data['codigo'].contains(filter) ?  //aqui faz o filtro
                            GestureDetector(
                              onTap: (){
                                setState(() {

                                  print("Clicou no item");

                                });
                              },
                              child:  Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(width: 10.0,),
                                    Image.network(documents[index].data["imagem"], width: 120.0, height: 120.0, fit: BoxFit.cover, ),
                                    SizedBox(width: 10.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        WidgetsConstructor().makeSimpleText(documents[index].data["codigo"], Theme.of(context).primaryColor, 18.0),
                                        SizedBox(height: 5.0,),
                                        Container(
                                          width: 150,
                                          child: WidgetsConstructor().makeSimpleText(documents[index].data["descricao"], Colors.grey[400], 14.0),),
                                        SizedBox(height: 5.0,),
                                        WidgetsConstructor().makeSimpleText("Em estoque desde: \n${documents[index].data["dataEntrega"]}", Colors.grey[500], 14.0),
                                        SizedBox(height: 5.0,),
                                        Container(
                                          padding: EdgeInsets.all(4.0),
                                          color: Theme.of(context).primaryColor,
                                          child: WidgetsConstructor().makeSimpleText("R\$ "+documents[index].data["preco"].toStringAsFixed(2), Colors.white, 20.0),
                                        ),
                                      ],
                                    ),
                                    //exibe a quantidade de itens. Se for 1 ou 2 fica amarelo. Se for 0 fica vermelho.
                                    documents[index].data["quantidade"] > 2 ? WidgetsConstructor().makeSimpleText(documents[index].data["quantidade"].toString(), Colors.blueGrey, 15.0) :
                                    documents[index].data["quantidade"] > 0 ? WidgetsConstructor().makeSimpleText(documents[index].data["quantidade"].toString(), Colors.amber, 15.0) :
                                    WidgetsConstructor().makeSimpleText(documents[index].data["quantidade"].toString(), Colors.red, 15.0),
                                  ],
                                ),

                              ),
                            ) :  //exibe o mesmo conteudo anterior (igual, sem tirar nada) mas filtrado
                            Container(); //se nao tiver resultado exibe nada

                          });
                  }
                },
              ),
            ),
          ],
        )
    );
  }


}



