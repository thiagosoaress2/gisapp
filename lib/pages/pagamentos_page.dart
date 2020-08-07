import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:gisapp/Models/pagamentos_models.dart';
import 'package:gisapp/Utils/currency_edittext_builder.dart';
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

  List<dynamic> datasPrestacoes;
  List<dynamic> situacaoPrestacoes;
  //var situacaoPrestacoes;
  //var datasPrestacoes;
  int positionOfData;
  String selectedDate;
  String selectedDateSituation;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  final TextEditingController _valorPagamento = TextEditingController();
  double valorPagamento = 0.0;



  @override
  void initState() {


    _searchController.addListener(() {
      setState(() {
        filter = _searchController.text;
      });
    });

    _valorPagamento.addListener(() {
      setState(() {
        valorPagamento = double.parse(_valorPagamento.text);
      });
    });
  }

  @override
  void dispose() {
    _valorPagamento.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                                child: Expanded(
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
                                            child: WidgetsConstructor()
                                                .makeSimpleText("Saldo devedor: R\$ "+documents[index]
                                                .data["saldoDevedor"].toStringAsFixed(2),
                                                Colors.grey[600], 16.0),),
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

                              ),
                            )

                                : documents[index].data['cliente'].contains(
                                filter)
                                ? //aqui faz o filtro
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  //click no card da lista
                                  page=1;
                                  positionSelectedFromDocument = index;

                                });
                              },
                              child: Card(
                                child: Expanded(
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
                                            child: WidgetsConstructor()
                                                .makeSimpleText("Saldo devedor: R\$ "+documents[index]
                                                .data["saldoDevedor"].toStringAsFixed(2),
                                                Colors.grey[600], 16.0),),
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
              //_myListOfDates(context, positionSelectedFromDocument)
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
                    page=0;
                  });
                },
              ),
            ),
            createExpandable(context, positionSelectedFromDocument),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                WidgetsConstructor().makeSimpleText("Total pago", Colors.grey, 14.0),
                WidgetsConstructor().makeSimpleText(PagamentosModels().checkPaymentsTotal(situacaoPrestacoes), Colors.grey, 14.0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget createExpandable(BuildContext context, int position) {

    //List<dynamic> datasPrestacoes = documents[position]['datasPrestacoes'];
   // List<dynamic> situacaoPrestacoes = documents[position]['situacoesPrestacoes'];

    //var teste = documents[position]['situacoesPrestacoes'];

    datasPrestacoes = documents[position]['datasPrestacoes'];
    situacaoPrestacoes = documents[position]['situacoesPrestacoes'];

    return Expanded(
      child: ListView(
        children: <Widget>[
          WidgetsConstructor().makeText("Prestações", Theme.of(context).primaryColor, 17.0, 16.0, 22.0, "center"),
          datasPrestacoes.length>0 ? _createExpandableLine(context, datasPrestacoes[0], situacaoPrestacoes[0], 0): Container(),
          Divider(),
          datasPrestacoes.length>1 ? _createExpandableLine(context, datasPrestacoes[1], situacaoPrestacoes[1], 1): Container(),
          Divider(),
          datasPrestacoes.length>2 ? _createExpandableLine(context, datasPrestacoes[2], situacaoPrestacoes[2], 2): Container(),
          Divider(),
          datasPrestacoes.length>3 ? _createExpandableLine(context, datasPrestacoes[3], situacaoPrestacoes[3], 3): Container(),
          Divider(),
          datasPrestacoes.length>4 ? _createExpandableLine(context, datasPrestacoes[4], situacaoPrestacoes[4],4): Container(),
          Divider(),
          datasPrestacoes.length>5 ? _createExpandableLine(context, datasPrestacoes[5], situacaoPrestacoes[5],5): Container(),
          Divider(),
          datasPrestacoes.length>6 ? _createExpandableLine(context, datasPrestacoes[6], situacaoPrestacoes[6],6): Container(),
          Divider(),
          datasPrestacoes.length>7 ? _createExpandableLine(context, datasPrestacoes[7], situacaoPrestacoes[7],7): Container(),
          Divider(),
          datasPrestacoes.length>8 ? _createExpandableLine(context, datasPrestacoes[8], situacaoPrestacoes[8],8): Container(),
          Divider(),
          datasPrestacoes.length>9 ? _createExpandableLine(context, datasPrestacoes[9], situacaoPrestacoes[9],9): Container(),
          Divider(),
          datasPrestacoes.length>10 ? _createExpandableLine(context, datasPrestacoes[10], situacaoPrestacoes[10], 10): Container(),
          Divider(),
          datasPrestacoes.length>11 ? _createExpandableLine(context, datasPrestacoes[11], situacaoPrestacoes[11], 11): Container(),
          Divider(),
          datasPrestacoes.length>12 ? _createExpandableLine(context, datasPrestacoes[12], situacaoPrestacoes[12], 12): Container(),
          Divider(),
          datasPrestacoes.length>13 ? _createExpandableLine(context, datasPrestacoes[13], situacaoPrestacoes[13], 13): Container(),
          Divider(),
          datasPrestacoes.length>14 ? _createExpandableLine(context, datasPrestacoes[14], situacaoPrestacoes[14], 14): Container(),
          Divider(),
          datasPrestacoes.length>15 ? _createExpandableLine(context, datasPrestacoes[15], situacaoPrestacoes[15], 15): Container(),
          Divider(),
          datasPrestacoes.length>16 ? _createExpandableLine(context, datasPrestacoes[16], situacaoPrestacoes[16], 16): Container(),
          Divider(),
          datasPrestacoes.length>17 ? _createExpandableLine(context, datasPrestacoes[17], situacaoPrestacoes[17], 17): Container(),
          Divider(),
          datasPrestacoes.length>18 ? _createExpandableLine(context, datasPrestacoes[18], situacaoPrestacoes[18], 18): Container(),
          Divider(),
          datasPrestacoes.length>19 ? _createExpandableLine(context, datasPrestacoes[19], situacaoPrestacoes[19], 19): Container(),
          Divider(),
          datasPrestacoes.length>20 ? _createExpandableLine(context, datasPrestacoes[20], situacaoPrestacoes[20], 20): Container(),
          Divider(),
          datasPrestacoes.length>21 ? _createExpandableLine(context, datasPrestacoes[21], situacaoPrestacoes[21], 21): Container(),
          Divider(),
          datasPrestacoes.length>22 ? _createExpandableLine(context, datasPrestacoes[22], situacaoPrestacoes[22], 22): Container(),
          Divider(),
          datasPrestacoes.length>23 ? _createExpandableLine(context, datasPrestacoes[23], situacaoPrestacoes[23], 23): Container(),
          Divider(),
          datasPrestacoes.length>24 ? _createExpandableLine(context, datasPrestacoes[24], situacaoPrestacoes[24], 24): Container(),
          Divider(),
          datasPrestacoes.length>25 ? _createExpandableLine(context, datasPrestacoes[25], situacaoPrestacoes[25], 25): Container(),
          Divider(),
          datasPrestacoes.length>26 ? _createExpandableLine(context, datasPrestacoes[26], situacaoPrestacoes[26], 26): Container(),
          Divider(),
          datasPrestacoes.length>27 ? _createExpandableLine(context, datasPrestacoes[27], situacaoPrestacoes[27], 27): Container(),
          Divider(),
          datasPrestacoes.length>28 ? _createExpandableLine(context, datasPrestacoes[28], situacaoPrestacoes[28], 28): Container(),
          Divider(),

        ],
      ),
    );
  }

  Widget _createExpandableLine(BuildContext context, String date, String situation, int position) {

    DateUtils().doesThisDateIsBiggerThanToday(date);
    print(DateUtils().doesThisDateIsBiggerThanToday(date));

    return GestureDetector(

      child: Padding(
        padding: EdgeInsets.fromLTRB(8.0, 18.0, 8.0, 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(date, style: TextStyle(color: DateUtils().doesThisDateIsBiggerThanToday(date) ? Colors.grey : situation!="Em aberto" ? Colors.grey[400] :  Colors.redAccent),),
            Text(situation, style: TextStyle(color: DateUtils().doesThisDateIsBiggerThanToday(date) ? Colors.grey : situation!="Em aberto" ? Colors.grey[400] : Colors.redAccent),),
          ],
        ),
      ),

      onTap: (){
        setState(() {
          page=2;
          positionOfData = position;
        });
      },

    );


  }

  Widget addPaymentPage(){

    //final TextEditingController _valorPagamento = TextEditingController();
    //double valorPagamento = 0.0;
    final TextEditingController _observacaoController = TextEditingController();


    /*
    _valorPagamento.addListener(() {
      setState(() {
        valorPagamento = double.parse(_valorPagamento.text);
      });
    });

     */

    return ListView(
      children: <Widget>[
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
        ),
        SizedBox(height: 20.0,),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              WidgetsConstructor().makeText("Você está editando pagamento para prestação com vencimento em: "+datasPrestacoes[positionOfData], Colors.grey[600], 16.0, 16.0, 16.0, "center"),
              CurrencyEditTextBuilder().makeMoneyTextFormFieldSettings(_valorPagamento, "Valor pago"),
              Padding(
                padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 40.0),
                child: WidgetsConstructor().makeEditText(_observacaoController, "Observação", null),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                height: 60.0,
                color: Theme.of(context).primaryColor,
                child: FlatButton(
                  child: WidgetsConstructor().makeSimpleText("Salvar", Colors.white, 18.0),
                  onPressed: (){
                    //salvar
                    if(_valorPagamento.text.isEmpty || _valorPagamento.text=="0.0" || _valorPagamento.text=="0,0" || _valorPagamento.text=="0,00"){
                      _displaySnackBar(context, "Informe o valor pago");
                    } else {
                      situacaoPrestacoes[positionOfData] = double.parse(_valorPagamento.text).toStringAsFixed(2);
                      PagamentosModels().updatePagamentos(documents[positionSelectedFromDocument].documentID, valorPagamento, documents[positionSelectedFromDocument].data['saldoDevedor'], situacaoPrestacoes);
                      _displaySnackBar(context, "A atualização foi salva");
                      setState(() {
                        page=0;
                      });

                    }

                    //_displaySnackBar(context, "O valor foi salvo");
                  },
                ),
              )
            ],
          ),
        )
      ],
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
