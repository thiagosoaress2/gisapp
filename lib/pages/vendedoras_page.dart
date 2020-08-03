import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gisapp/Utils/currency_edittext_builder.dart';
import 'package:gisapp/classes/vendor_class.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';
import 'package:group_radio_button/group_radio_button.dart';

class VendedorasPage extends StatefulWidget {
  @override
  _VendedorasPageState createState() => _VendedorasPageState();
}

class _VendedorasPageState extends State<VendedorasPage> {
  bool landPageVisible = true;
  bool infoPageVisible = false;
  bool addPageVisible = false;
  bool extratoPageVisible = false;

  bool showUpdateScreenPopup = false;  //exibe o popup pra atualizar o salario e comissão em infoScreen

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _comissaoController = TextEditingController();
  final TextEditingController _salarioController = TextEditingController();

  final TextEditingController _infos_nomeController = TextEditingController();
  final TextEditingController _infos_comissaoController =
      TextEditingController();
  final TextEditingController _infos_salarioController =
      TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  bool _isUploading = false;

  VendorClass vendedora;

  int modalidade=0;
  // 1 - salario+comissao
  // 2 - comissao apenas se for maior que o salário

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: Visibility(
          visible: landPageVisible ? true : false,
          child: FloatingActionButton(
            child: Icon(
              Icons.person_add,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                addPageVisible = true;
                landPageVisible = false;
                _salarioController.text = "";
                modalidade=0;
              });
            },
          ),
        ),
        appBar: AppBar(
          title: WidgetsConstructor()
              .makeSimpleText("Página das vendedoras", Colors.white, 15.0),
          centerTitle: true,
        ),
        body: landPageVisible
            ? _landingPage()
            : addPageVisible
                ? _addVendor()
                : infoPageVisible
                    ? _infos()
                  : extratoPageVisible
                      ? _calculosPage()
                    : Container(height: 0.0, width: 0.0,
                      ));
  }

  Widget _landingPage() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 50.0,
        ),
        Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.white,
            height: 500,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection("vendedores")
                        .snapshots(), //este é um listener para observar esta coleção
                    builder: (context, snapshot) {
                      //começar a desenhar a tela
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Center(
                            //caso esteja vazio ou esperando exibir um circular progressbar no meio da tela
                            child: CircularProgressIndicator(),
                          );
                        default:
                          List<DocumentSnapshot> documents = snapshot
                              .data.documents
                              .toList(); //recuperamos o querysnapshot que estamso observando

                          return ListView.builder(
                              //aqui vamos começar a construir a listview com os itens retornados
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      infoPageVisible = true;

                                      vendedora = VendorClass(documents[index].documentID, documents[index]["nome"], documents[index]["comissao"], documents[index]["salario"],  documents[index]["modalidade"]);

                                      populateVendorsInfo();

                                      landPageVisible = false;
                                    });
                                  },
                                  child: Card(
                                      child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: WidgetsConstructor().makeText(
                                        documents[index].data["nome"],
                                        Colors.blueGrey,
                                        16.0,
                                        4.0,
                                        4.0,
                                        "no"),
                                  )),
                                );
                              });
                      }
                    },
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _addVendor() {
    return ListView(
      children: <Widget>[
        Form(
          key: _formKey,
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
                          landPageVisible = true;
                          addPageVisible = false;
                          modalidade = 0;
                        });
                      },
                    ),
                  ), //btn fechar
                ],
              ), //btn fechar
              Padding(
                padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
                child: Column(
                  children: <Widget>[
                    WidgetsConstructor().makeFormEditText(
                        _nomeController, "Nome", "Informe o nome"),
                    SizedBox(
                      height: 16.0,
                    ),
                    CurrencyEditTextBuilder().makeMoneyTextFormFieldSettings(
                        _salarioController, "Salário"),
                    SizedBox(
                      height: 16.0,
                    ),
                    _isUploading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container(),
                    WidgetsConstructor().makeFormEditTextNumberOnly(
                        _comissaoController, "Comissão", "Informe a comissão"),
                    SizedBox(
                      height: 16.0,
                    ),
                    WidgetsConstructor().makeSimpleText("Modalidade", Theme.of(context).primaryColor, 16.0),
                    SizedBox(height: 8.0,),
                    buildRadioOptions(context),  //radios buttons

                  ],
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              Container(
                height: 50.0,
                color: Theme.of(context).primaryColor,
                child: FlatButton(
                  child: WidgetsConstructor()
                      .makeSimpleText("Cadastrar", Colors.white, 20.0),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      if (_salarioController.text.isEmpty ||
                          _salarioController.text == "0.0") {
                        _displaySnackBar(context, "Informe o salário");
                      } else {

                        if(modalidade!=0){

                          Future.delayed(const Duration(milliseconds: 4000), () {
                            setState(() {
                              _isUploading = !_isUploading;
                            });
                          });

                          VendorClass newVendor = VendorClass.cad(
                              _nomeController.text,
                              double.parse(_comissaoController.text),
                              double.parse(_salarioController.text),
                              modalidade
                          );
                          VendorClass.empty().addToBd(newVendor);

                          _nomeController.text = "";
                          _comissaoController.text = "";
                          _salarioController.text = "";
                          modalidade = 0;

                          _displaySnackBar(
                              context, "Pronto! Informações salvas.");

                          setState(() {
                            _isUploading = !_isUploading;
                          });

                        } else {
                         _displaySnackBar(context, "Informe a modalidade");
                        }

                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _infos() {
    return Stack(
      children: <Widget>[
        ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
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
                              landPageVisible = true;
                              infoPageVisible = false;
                            });
                          },
                        ),
                      ), //btn fechar
                    ],
                  ), //btn fechar
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 16.0,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  WidgetsConstructor()
                      .makeEditText(_infos_nomeController, "Nome", null),
                  SizedBox(
                    height: 35.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidgetsConstructor().makeText(
                          "Comissão: ${vendedora.comissao.toString()} \%",
                          Colors.grey[600],
                          18.0,
                          30.0,
                          4.0,
                          "no"),
                      Container(
                        height: 45.0,
                        width: 45.0,
                        color: Theme.of(context).primaryColor,
                        child: IconButton(
                          onPressed: (){
                            setState(() {
                              showUpdateScreenPopup=true;
                            });

                          },
                          icon: Icon(
                            Icons.mode_edit,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 35.0,
                  ),
                  WidgetsConstructor().makeText(
                      "Salário: R\$${vendedora.salario.toStringAsFixed(2)}",
                      Colors.grey[600],
                      18.0,
                      30.0,
                      4.0,
                      "no"),
                  SizedBox(height: 8.0,),
                  Text(vendedora.modalidade==1 ? "Salário + comissão" : "Comissão se for maior que salário"),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 24.0),
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      child: FlatButton(
                        child: WidgetsConstructor().makeSimpleText("Calcular comissão", Colors.white, 18.0),
                        onPressed: (){
                          setState(() {
                            setState(() {
                              extratoPageVisible=true;
                              infoPageVisible=false;
                            });

                          });

                        },
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        showUpdateScreenPopup ? _popup_salario_comissao_update() : Container(),
      ],
    );
  }

  Widget _popup_salario_comissao_update() {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: ListView(
            children: <Widget>[

              Container(
                height: 500.0,
                width: 400.0,
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
                                showUpdateScreenPopup = false;
                              });
                            },
                          ),
                        ), //btn fechar
                      ],
                ),
                    WidgetsConstructor().makeText("Edição de informações", Theme.of(context).primaryColor, 20.0, 16.0, 8.0, "center"),
                    SizedBox(height: 8.0,),
                    TextField(
                      controller: _infos_comissaoController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                      decoration: InputDecoration(labelText: "Nova comissão"),
                    ),
                    SizedBox(height: 8.0,),
                    CurrencyEditTextBuilder().makeMoneyTextFormFieldSettings(_infos_salarioController, "Novo salário"),
                    SizedBox(height: 8.0,),
                    WidgetsConstructor().makeSimpleText("Modalidade", Theme.of(context).primaryColor, 16.0),
                    SizedBox(height: 8.0,),
                    buildRadioOptions(context),  //radios buttons
                    Container(
                      color: Theme.of(context).primaryColor,
                      height: 50.0,
                      child: FlatButton(
                        child: WidgetsConstructor().makeSimpleText("Salvar alterações", Colors.white, 18.0),
                        onPressed: (){
                          vendedora.comissao = double.parse(_infos_comissaoController.text);
                          vendedora.salario = double.parse(_infos_salarioController.text);
                          VendorClass.empty().updateClienteInfo(vendedora);
                          _displaySnackBar(context, "As informações foram salvas!");
                          setState(() {
                            showUpdateScreenPopup = false;
                          });
                        },

                      )
                    )

                  ],
                ),
              ),

            ],
          ),
        )
      ),
    );
  }

  void populateVendorsInfo() {
    _infos_nomeController.text = vendedora.nome;
    _infos_comissaoController.text = vendedora.comissao.toString();
    _infos_salarioController.text = vendedora.salario.toString();

    print(vendedora.comissao.toStringAsFixed(2));
    print(vendedora.salario.toStringAsFixed(2));
  }

  Widget _calculosPage(){

    String queryCriteria = "esteMes";

    return Container(
      height: 700.0,
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
                      infoPageVisible = true;
                      extratoPageVisible = false;
                    });
                  },
                ),
              ), //btn fechar
            ],
          ),
          //Container(color: Colors.amber, height: 500.0,)
          Container(
            height: 500,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(width: 4.0,),
                    Flexible(
                      flex: 1,
                      child: Container(
                        height: 50.0,
                        color: Colors.amber,
                        child: FlatButton(
                          child: WidgetsConstructor().makeSimpleText("Este mês", Colors.black, 14.0),
                          onPressed: (){
                            setState(() {
                              queryCriteria = "esteMes";
                            });

                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        height: 50.0,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        height: 50.0,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(width: 4.0,),
                  ],
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                    //vou precisar criar o campo dataQueryVendor e colocar data+id
                        .collection("vendas").where("vendedoraId", isEqualTo: vendedora.id)
                        .snapshots(), //este é um listener para observar esta coleção
                    builder: (context, snapshot) {
                      //começar a desenhar a tela
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Center(
                            //caso esteja vazio ou esperando exibir um circular progressbar no meio da tela
                            child: CircularProgressIndicator(),
                          );
                        default:
                          List<DocumentSnapshot> documents = snapshot.data.documents.toList(); //recuperamos o querysnapshot que estamso observando
                          List<DocumentSnapshot> documentThisMonth = documents;
                          documentThisMonth.forEach((element) { 
                            element["dataQuery"].toString().contains(DateTime.now().month.toString()+"/"+DateTime.now().year.toString());
                          });

                          return ListView.builder(
                            //aqui vamos começar a construir a listview com os itens retornados
                              itemCount: documentThisMonth.length,
                              itemBuilder: (context, index) {
                                if(queryCriteria=="esteMes"){
                                  print("entrou no if");
                                  print(DateTime.now().month.toString()+"/"+DateTime.now().year.toString());
                                  print(documents[index].data['dataQuery'].toString());
                                  return documents[index].data['data'].toString().contains(DateTime.now().month.toString()+"/"+DateTime.now().year.toString())
                                      ?  GestureDetector(
                                    onTap: () {
                                      setState(() {


                                        //exibir os detalhes desta venda

                                      });
                                    },
                                    child: Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              WidgetsConstructor().makeText(documents[index].data["cliente"], Colors.blueGrey, 16.0, 4.0, 4.0, "no"),
                                              WidgetsConstructor().makeSimpleText(documents[index].data["data"], Colors.blueGrey[300], 15.0),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      WidgetsConstructor().makeSimpleText("Entrada: "+documents[index].data["entrada"].toStringAsFixed(2), Colors.blueGrey[300], 15.0),
                                                      WidgetsConstructor().makeSimpleText("Total da venda: "+documents[index].data["valor"].toStringAsFixed(2), Theme.of(context).primaryColor, 15.0),

                                                      //adicionar aqui o valor já pago
                                                      //criar uma área de pagamentos
                                                      //la o usuario vai poder adicionar os pagamentos feitos

                                                    ],
                                                  ),

                                                ],
                                              ),

                                            ],
                                          ),
                                        )
                                    ),
                                  ) : Container(color: Colors.red,);
                                } else {
                                  //aqui ficarão os outros filtros
                                  return Container(color: Colors.red,);
                                }

                              });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRadioOptions(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioButton(
          description: "Salário + comissão",
          value: 1,
          groupValue: modalidade,
          onChanged: (value) => setState(
                () => modalidade = value,
          ),
        ),
        RadioButton(

          description: "Comissão se maior que salário",
          value: 2,
          groupValue: modalidade,
          onChanged: (value) => setState(
                () => modalidade = value,
          ),
        ),
      ],
    );
  }

  _displaySnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: "Ok",
        onPressed: () {
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }



}
