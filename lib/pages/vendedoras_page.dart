import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gisapp/Utils/currency_edittext_builder.dart';
import 'package:gisapp/classes/vendor_class.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';
import 'package:moneytextformfield/moneytextformfield.dart';

class VendedorasPage extends StatefulWidget {
  @override
  _VendedorasPageState createState() => _VendedorasPageState();
}

class _VendedorasPageState extends State<VendedorasPage> {

  String page = "land";

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _comissaoController = TextEditingController();
  //final _salarioController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  final TextEditingController _salarioController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  bool _isUploading = false;



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: Visibility(
        visible: page=="land" ? true : false,
        child: FloatingActionButton(
          child: Icon(Icons.person_add, color: Colors.white,),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: (){
            setState(() {
              page = "add";
              _salarioController.text="";
            });
          },
        ),
      ),
      appBar: AppBar(
        title: WidgetsConstructor()
            .makeSimpleText("Página das vendedoras", Colors.white, 15.0),
        centerTitle: true,
      ),
      body: page == "land" ? _landingPage()
          : page=="add" ? _addVendor()
          : page=="infos" ? _infos()
          : Container(height: 0.0, width: 0.0,)
    );
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

                                      page = "infos";

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

  Widget _addVendor(){
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
                      icon: Icon(Icons.close, color: Colors.redAccent, size: 30.0,),
                      color: Theme.of(context).primaryColor,
                      onPressed: (){
                        setState(() {
                          page="land";

                        });

                      },
                    ),
                  ),  //btn fechar

                ],
              ), //btn fechar
              Padding(
                padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
                child: Column(
                  children: <Widget>[
                    WidgetsConstructor().makeFormEditText(_nomeController, "Nome", "Informe o nome"),
                    SizedBox(height: 16.0,),
                    CurrencyEditTextBuilder().makeMoneyTextFormFieldSettings(_salarioController, "Salário"),
                    SizedBox(height: 16.0,),
                    _isUploading ? Center(child: CircularProgressIndicator(),) : Container(),
                    WidgetsConstructor().makeFormEditTextNumberOnly(_comissaoController, "Comissão", "Informe a comissão"),
                    SizedBox(height: 16.0,),
                  ],
                ),
              ),
              SizedBox(height: 24.0,),
              Container(
                height: 50.0,
                color: Theme.of(context).primaryColor,
                child: FlatButton(
                  child: WidgetsConstructor().makeSimpleText("Cadastrar", Colors.white, 20.0),
                  onPressed: (){

                    if(_formKey.currentState.validate()){

                      Future.delayed(const Duration(milliseconds: 4000), () {
                        setState(() {
                          _isUploading = !_isUploading;
                        });
                      });

                      VendorClass newVendor = VendorClass.cad(_nomeController.text, double.parse(_comissaoController.text), double.parse(_salarioController.text));
                      VendorClass.empty().addToBd(newVendor);

                        _nomeController.text="";
                        _comissaoController.text="";
                        _salarioController.text="";

                        _displaySnackBar(context, "Pronto! Informações salvas.");

                        setState(() {
                          _isUploading = !_isUploading;
                        });

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

  Widget _infos(){
    return Container(color: Colors.blueGrey, height: 500.0,);
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
