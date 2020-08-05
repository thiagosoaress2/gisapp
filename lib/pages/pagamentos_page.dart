import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';
import 'package:gisapp/Utils/dates_utils.dart';

class PagamentosPage extends StatefulWidget {
  @override
  _PagamentosPageState createState() => _PagamentosPageState();
}

class _PagamentosPageState extends State<PagamentosPage> {

  int page = 0;
  //0 é landpage;
  //1 é infos detalhadas das divididas
  //2 é a janela que exibe o edittext para o user incluir o valor pago

  final TextEditingController _searchController = TextEditingController();
  String filter;

  List<DocumentSnapshot> documents=[];
  int positionSelectedFromDocument;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: WidgetsConstructor().makeText(
            "Pagamentos em aberto", Colors.white, 16.0, 0.0, 0.0, "no"),
        centerTitle: true,
      ),
      body: page == 0 ? landPage() : page==1 ? infoDebtsPage() : page==2 ? addPaymentPage() : Container(),
    );
  }


  Widget landPage() {
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
                stream: Firestore.instance.collection("dividas").snapshots(),
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

                      return ListView
                          .builder( //aqui vamos começar a construir a listview com os itens retornados
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            return filter == null || filter == ""
                                ? //se for null ou "" exibe o conteudo todo
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  //click no card da lista
                                  page=1;
                                  positionSelectedFromDocument = index;

                                });
                              },
                              child: Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(width: 10.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        WidgetsConstructor().makeSimpleText("Cliente: "+
                                            documents[index].data["cliente"],
                                            Theme
                                                .of(context)
                                                .primaryColor, 18.0),
                                        SizedBox(height: 10.0,),
                                        Container(
                                          width: 150,
                                          child: WidgetsConstructor()
                                              .makeSimpleText("Saldo devedor: R\$ "+documents[index]
                                              .data["saldoDevedor"].toStringAsFixed(2),
                                              Colors.grey[400], 14.0),),
                                        Container(
                                          width: 150,
                                          child: WidgetsConstructor()
                                              .makeSimpleText("Parcelado em "+documents[index]
                                              .data["parcelas"].toString()+" x",
                                              Colors.grey[400], 14.0),
                                        ),
                                        SizedBox(height: 10.0,),
                                        //createExpandable(context, index),
                                        //createExpandable(context, index),


                                      ],
                                    ),
                                  ],
                                ),

                              ),
                            )

                                : documents[index].data['cliente'].contains(
                                filter)
                                ? //aqui faz o filtro
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  //click

                                });
                              },
                              child: Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(width: 10.0,),
                                    Image.network(
                                      documents[index].data["imagem"],
                                      width: 140.0,
                                      height: 140.0,
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
                                        SizedBox(height: 10.0,),
                                        Container(
                                          width: 150,
                                          child: WidgetsConstructor()
                                              .makeSimpleText(documents[index]
                                              .data["descricao"],
                                              Colors.grey[400], 14.0),),
                                        SizedBox(height: 10.0,),
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
                                            .toString(), Colors.blueGrey, 15.0)
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
                                : //exibe o mesmo conteudo anterior (igual, sem tirar nada) mas filtrado
                            Container(); //se nao tiver resultado exibe nada
                          });
                  }
                },
              ),
            ),
            SizedBox(height: 150,),
          ],
        )
    );
  }

  Widget infoDebtsPage(){
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            createExpandable(context, positionSelectedFromDocument)
          ],
        ),
      ),
    );
  }

  Widget addPaymentPage(){

    return Container(
      color: Colors.redAccent,
    );

  }

  Widget createExpandable(BuildContext context, int position) {

    List<dynamic> datasPrestacoes = documents[position]['datasPrestacoes'];
    List<dynamic> situacaoPrestacoes = documents[position]['situacoesPrestacoes'];

    return ExpandablePanel(
      header: Text("Ver detalhes das prestações"),
      collapsed: Text("Exibir +", softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,), //exibe o custo quando fechado
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WidgetsConstructor().makeSimpleText("Vencimentos: ", Colors.grey[600], 15.0),
          SizedBox(height: 16.0,),
          datasPrestacoes.length>0 ? _createExpandableLine(context, datasPrestacoes[0], situacaoPrestacoes[0]): Container(),
          datasPrestacoes.length>1 ? _createExpandableLine(context, datasPrestacoes[1], situacaoPrestacoes[1]): Container(),
          datasPrestacoes.length>2 ? _createExpandableLine(context, datasPrestacoes[2], situacaoPrestacoes[2]): Container(),
          datasPrestacoes.length>3 ? _createExpandableLine(context, datasPrestacoes[3], situacaoPrestacoes[3]): Container(),
          datasPrestacoes.length>4 ? _createExpandableLine(context, datasPrestacoes[4], situacaoPrestacoes[4]): Container(),
          datasPrestacoes.length>5 ? _createExpandableLine(context, datasPrestacoes[5], situacaoPrestacoes[5]): Container(),
          datasPrestacoes.length>6 ? _createExpandableLine(context, datasPrestacoes[6], situacaoPrestacoes[6]): Container(),
          datasPrestacoes.length>7 ? _createExpandableLine(context, datasPrestacoes[7], situacaoPrestacoes[7]): Container(),
          datasPrestacoes.length>8 ? _createExpandableLine(context, datasPrestacoes[8], situacaoPrestacoes[8]): Container(),
          datasPrestacoes.length>9 ? _createExpandableLine(context, datasPrestacoes[9], situacaoPrestacoes[9]): Container(),
          datasPrestacoes.length>10 ? _createExpandableLine(context, datasPrestacoes[10], situacaoPrestacoes[10]): Container(),
          datasPrestacoes.length>11 ? _createExpandableLine(context, datasPrestacoes[11], situacaoPrestacoes[11]): Container(),
          datasPrestacoes.length>12 ? _createExpandableLine(context, datasPrestacoes[12], situacaoPrestacoes[12]): Container(),
          datasPrestacoes.length>13 ? _createExpandableLine(context, datasPrestacoes[13], situacaoPrestacoes[13]): Container(),
          datasPrestacoes.length>14 ? _createExpandableLine(context, datasPrestacoes[14], situacaoPrestacoes[14]): Container(),
          datasPrestacoes.length>15 ? _createExpandableLine(context, datasPrestacoes[15], situacaoPrestacoes[15]): Container(),
          datasPrestacoes.length>16 ? _createExpandableLine(context, datasPrestacoes[16], situacaoPrestacoes[16]): Container(),
          datasPrestacoes.length>17 ? _createExpandableLine(context, datasPrestacoes[17], situacaoPrestacoes[17]): Container(),
          datasPrestacoes.length>18 ? _createExpandableLine(context, datasPrestacoes[18], situacaoPrestacoes[18]): Container(),
          datasPrestacoes.length>19 ? _createExpandableLine(context, datasPrestacoes[19], situacaoPrestacoes[19]): Container(),
          datasPrestacoes.length>20 ? _createExpandableLine(context, datasPrestacoes[20], situacaoPrestacoes[20]): Container(),
          datasPrestacoes.length>21 ? _createExpandableLine(context, datasPrestacoes[21], situacaoPrestacoes[21]): Container(),
          datasPrestacoes.length>22 ? _createExpandableLine(context, datasPrestacoes[22], situacaoPrestacoes[22]): Container(),
          datasPrestacoes.length>23 ? _createExpandableLine(context, datasPrestacoes[23], situacaoPrestacoes[23]): Container(),
          datasPrestacoes.length>24 ? _createExpandableLine(context, datasPrestacoes[24], situacaoPrestacoes[24]): Container(),
          datasPrestacoes.length>25 ? _createExpandableLine(context, datasPrestacoes[25], situacaoPrestacoes[25]): Container(),
          datasPrestacoes.length>26 ? _createExpandableLine(context, datasPrestacoes[26], situacaoPrestacoes[26]): Container(),
          datasPrestacoes.length>27 ? _createExpandableLine(context, datasPrestacoes[27], situacaoPrestacoes[27]): Container(),
          datasPrestacoes.length>28 ? _createExpandableLine(context, datasPrestacoes[28], situacaoPrestacoes[28]): Container(),



        ],
      ),
      tapHeaderToExpand: true,
      hasIcon: true,
    );
  }

  Widget _createExpandableLine(BuildContext context, String date, String situation) {

    DateUtils().doesThisDateIsBiggerThanToday(date);
    print(DateUtils().doesThisDateIsBiggerThanToday(date));

      return GestureDetector(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.0, 18.0, 8.0, 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(date, style: TextStyle(color: DateUtils().doesThisDateIsBiggerThanToday(date) ? Colors.grey : Colors.redAccent),),
              Text(situation, style: TextStyle(color: DateUtils().doesThisDateIsBiggerThanToday(date) ? Colors.grey : Colors.redAccent),),
            ],
          ),
        ),

        onTap: () {
          setState(() {
            //page=3;
            print(date);
          });

        },

      );
  }





}
