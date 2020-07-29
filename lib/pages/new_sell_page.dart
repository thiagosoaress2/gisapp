import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:gisapp/classes/cliente_class.dart';
import 'package:gisapp/classes/product_class.dart';
import 'package:gisapp/classes/sell_class.dart';
import 'package:gisapp/classes/vendor_class.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';


//TO DO
//Reduzir tamanho da imagem no upload
//remover itens depois de ter sido adicionado
//Procurar pelos itens quando estiver adicionando

class NewSellPage extends StatefulWidget {
  @override
  _NewSellState createState() => _NewSellState();
}

class _NewSellState extends State<NewSellPage> {

  bool _isUploading = false;

  bool _showProducts = false;

  bool _showClients = false;

  bool _showVendors = false;

  bool _isRegisteredClient = false;

  ProductClass _produto = ProductClass.toSellProduct("nao", "nao", "nao", 0.0, "nao");

  VendorClass _vendedora = VendorClass(null, null, null, null);

  ClienteClass _cliente = ClienteClass.ClienteSell(null, null, null);

  List<ProductClass> _produtosCarrinho = [];

  var _maskFormatterDataVenda = new MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]')});
  final TextEditingController _dataVendaController = TextEditingController();

  final TextEditingController _quantidadeParcelamentos = TextEditingController();
  final _valorEntrada = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  final TextEditingController _nomeCliente = TextEditingController();
  final _totalVenda = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

  final TextEditingController _searchController = TextEditingController();
  String filter;


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

  String _formaPgto = "avista";

  double totalVenda = 0.0;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Nova venda", style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(80.0, 30.0, 80.0, 20.0),
                    alignment: Alignment.center,
                    child: FloatingActionButton(
                      child: Icon(Icons.add),
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: (){
                        setState(() {
                          //produto.pId="troca";
                          _showProducts = true;

                          //colocar a data de hoje no editfield para facilitar
                          _dataVendaController.text = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy]);
                          _quantidadeParcelamentos.text = "1";
                        });
                      },
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                      child: _produtosCarrinho.length==0
                          ? Text("Nenhum produto selecionado.", textAlign: TextAlign.center,)
                          : CadVendaScreen()

                  ),
                ],
              ),
              _showProducts
                ? ProductScreen()
                : Container(height: 0.0,width: 0.0,),
              _showClients
              ? ClientsScreen()
                  : Container(height: 0.0, width: 0.0,),
              _showVendors
              ? VendorsScreen()
                  : Container(height: 0.0, width: 0.0,),
            ], //final dos childrens da stack
          )
        ],
      ),
    );
  }

  //abre pagina para selecionar o produto
  Widget ProductScreen(){
    return Container(
        color: Colors.white,
        height: 700,
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0,),
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
                        _showProducts = false;
                      });

                    },
                  ),
                ),
                SizedBox(width: 5.0,)
              ],
            ),
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

                                  ProductClass.empty().completeProductToSell(_produto, documents[index].documentID, documents[index].data["imagem"], documents[index].data["codigo"], documents[index].data["preco"], documents[index].data["descricao"], documents[index].data["quantidade"]);
                                  _produtosCarrinho.add(_produto);
                                  _totalVenda.text = (double.parse(_totalVenda.text)+_produto.preco).toStringAsFixed(2);
                                  totalVenda = totalVenda+_produto.preco;
                                  print(totalVenda);
                                  _showProducts=false;
                                });

                              },
                              child:  Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(width: 10.0,),
                                    Image.network(documents[index].data["imagem"], width: 140.0, height: 140.0, fit: BoxFit.cover, ),
                                    SizedBox(width: 10.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        WidgetsConstructor().makeSimpleText(documents[index].data["codigo"], Theme.of(context).primaryColor, 18.0),
                                        SizedBox(height: 10.0,),
                                        Container(
                                          width: 150,
                                          child: WidgetsConstructor().makeSimpleText(documents[index].data["descricao"], Colors.grey[400], 14.0),),
                                        SizedBox(height: 10.0,),
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

                                  ProductClass.empty().completeProductToSell(_produto, documents[index].documentID, documents[index].data["imagem"], documents[index].data["codigo"], documents[index].data["preco"], documents[index].data["descricao"], documents[index].data["quantidade"]);
                                  _produtosCarrinho.add(_produto);
                                  _totalVenda.text = (double.parse(_totalVenda.text)+_produto.preco).toStringAsFixed(2);
                                  totalVenda = totalVenda+_produto.preco;
                                  print(totalVenda);
                                  _showProducts=false;
                                });

                              },
                              child:  Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(width: 10.0,),
                                    Image.network(documents[index].data["imagem"], width: 140.0, height: 140.0, fit: BoxFit.cover, ),
                                    SizedBox(width: 10.0,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        WidgetsConstructor().makeSimpleText(documents[index].data["codigo"], Theme.of(context).primaryColor, 18.0),
                                        SizedBox(height: 10.0,),
                                        Container(
                                          width: 150,
                                          child: WidgetsConstructor().makeSimpleText(documents[index].data["descricao"], Colors.grey[400], 14.0),),
                                        SizedBox(height: 10.0,),
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
                                Container(  //senao exibe esse aqui
                                  child: WidgetsConstructor().makeText("Nenhum resultado", Colors.redAccent, 18.0, 16.0, 8.0, "center"),
                                );

                          });
                  }
                },
              ),
            ),
          ],
        )
    );



  }

  Widget ClientsScreen(){
    return Container(
      color: Colors.white,
      height: 700,
      child: Column(
        children: <Widget>[
          SizedBox(height: 20.0,),
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
                      _showClients = false;
                    });
                  },
                ),
              ),
              SizedBox(width: 5.0,),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Buscar",
                hintText: "Buscar",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                )
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("clientes").snapshots(), //este é um listener para observar esta coleção
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

                                _cliente.clienteId = documents[index].documentID;
                                _cliente.nome = documents[index].data["nome"];
                                _cliente.vendasTotais = documents[index].data["vendasTotais"];
                                _nomeCliente.text = _cliente.nome;
                                _isRegisteredClient=true;
                                _showClients = false;
                              });

                            },
                            child:  Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: WidgetsConstructor().makeText(documents[index].data["nome"], Colors.blueGrey, 16.0, 4.0, 4.0, "no"),
                                )

                            ),
                          )
                              : documents[index].data['nome'].contains(filter) ?
                          GestureDetector(
                            onTap: (){
                              setState(() {

                                _cliente.clienteId = documents[index].documentID;
                                _cliente.nome = documents[index].data["nome"];
                                _cliente.vendasTotais = documents[index].data["vendasTotais"];
                                _nomeCliente.text = _cliente.nome;
                                _isRegisteredClient=true;
                                _showClients = false;
                              });

                            },
                            child:  Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: WidgetsConstructor().makeText(documents[index].data["nome"], Colors.blueGrey, 16.0, 4.0, 4.0, "no"),
                                )

                            ),
                          ) :
                          Container(  //senao exibe esse aqui
                            child: WidgetsConstructor().makeText("Nenhum resultado", Colors.redAccent, 18.0, 16.0, 8.0, "center"),
                          );
                        });
                }
              },
            ),
          ),
        ],
      ),
    );

  }

  Widget VendorsScreen(){
    return Container(
      color: Colors.white,
      height: 700,
      child: Column(
        children: <Widget>[
          SizedBox(height: 20.0,),
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
                      _showVendors = false;
                    });
                  },
                ),
              ),
              SizedBox(width: 5.0,),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("vendedores").snapshots(), //este é um listener para observar esta coleção
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
                          return GestureDetector(
                            onTap: (){
                              setState(() {

                                _vendedora.id = documents[index].documentID;
                                _vendedora.nome = documents[index].data["nome"];
                                _vendedora.comissao = documents[index].data["comissao"];

                                _showVendors = false;
                              });

                            },
                            child:  Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: WidgetsConstructor().makeText(documents[index].data["nome"], Colors.blueGrey, 16.0, 4.0, 4.0, "no"),
                                )

                            ),
                          );
                        });
                }
              },
            ),
          ),
        ],
      )
    );

  }

  Widget CadVendaScreen(){
    return Container(
        height: 500.0,
        child: Form(
          key: _formKey,
          child:  Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                WidgetsConstructor().makeSimpleText("Itens desta venda", Theme.of(context).primaryColor, 15.0),
                SizedBox(height: 16.0,),
                ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(4),
                    itemCount: _produtosCarrinho.length,
                    itemBuilder: (BuildContext context, int index) {

                      final _key = UniqueKey().toString(); //gerando uma chave única

                      return Dismissible(
                        key: Key(_key),  //passando a key

                        onDismissed: (direction) {

                          _produtosCarrinho.removeAt(index);
                          totalVenda = totalVenda-_produtosCarrinho[index].preco;
                          _totalVenda.text = totalVenda.toStringAsFixed(2);
                          _displaySnackBar(context, "Produto removido da venda");
                        },
                        background: Container(color: Colors.blueGrey),
                        child: Card(
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(_produtosCarrinho[index].codigo+" - R\$ "+_produtosCarrinho[index].preco.toStringAsFixed(2)),
                                )
                            )
                        ),
                      );
                    }
                ),
                WidgetsConstructor().makeFormEditTextForDateFormat(_dataVendaController, "Data da venda", _maskFormatterDataVenda, "Informe a data"),
                SizedBox(height: 16.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 240.0,
                      child: TextFormField(
                        controller: _nomeCliente,
                        decoration: InputDecoration(labelText: "Nome do cliente"),
                        validator: (value) {
                          if(value.isEmpty){
                            return "Informe o nome do cliente";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      color: Colors.blueAccent,
                      child: IconButton(
                        icon: Icon(Icons.person, color: Colors.white,),
                        color: Theme.of(context).primaryColor,
                        onPressed: (){
                          //exibe a tela com os clientes para escolher
                          setState(() {
                            _showClients = true;
                          });

                        },
                      ),
                    ),

                  ],
                ),

                SizedBox(height: 16.0,),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(10.0)),
                  height: 350.0,
                  child: Column(
                    children: <Widget>[
                      WidgetsConstructor().makeText("Forma de pagamento", Theme.of(context).primaryColor, 18.0, 4.0, 4.0, "center"),
                      buildRadioOptions(context),
                      Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                          child: Column(
                            children: <Widget>[
                              _formaPgto!="avista" ? WidgetsConstructor().makeFormEditTextNumberOnly(_quantidadeParcelamentos, "Nº parcelas", "Informe a quantidade de parcelas"): Text(""),
                              _formaPgto!="avista" ? WidgetsConstructor().makeFormEditTextNumberOnly(_valorEntrada, "Entrada", "Informe o valor da entrada"): Text(""),
                            ],
                          )
                      )
                    ],
                  ),
                ),
                Center(
                  child: _isUploading ? CircularProgressIndicator() : Text(""),
                ),
                SizedBox(height: 16.0,),
                WidgetsConstructor().makeEditTextForCurrency(_totalVenda, "Total da venda"),
                SizedBox(height: 16.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        width: 240.0,
                        child: Text(_vendedora.nome == null ? "Nenhuma vendedora" : _vendedora.nome)
                    ),
                    SizedBox(width: 5.0,),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      color: Colors.blueAccent,
                      child: IconButton(
                        icon: Icon(Icons.person, color: Colors.white,),
                        color: Theme.of(context).secondaryHeaderColor,
                        onPressed: (){
                          //exibe a tela com os clientes para escolher
                          setState(() {
                            _showVendors = true;
                          });

                        },
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 30.0,),
                Container(
                  height: 60.0,
                  color: Theme.of(context).primaryColor,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: WidgetsConstructor().makeSimpleText("Registrar venda", Colors.white, 20.0),
                    onPressed: () async {
                      //registrar venda
                      if (_formKey.currentState.validate()) { //
                        if(_produtosCarrinho.length!=0){
                          if(_vendedora.nome != null){

                            //se chegou até aqui pode salvar a venda
                            setState(() {
                              _isUploading = true;
                            });

                            //vamos preencher o objeto venda
                            SellClass venda = SellClass(_dataVendaController.text, formatDate(DateTime.now(), [mm, '/', yyyy]), _formaPgto, _nomeCliente.text, _isRegisteredClient ? _cliente.clienteId : "cliente sem registro" , _quantidadeParcelamentos.text==null ? 1 : int.parse(_quantidadeParcelamentos.text), double.parse(_totalVenda.text), _vendedora.nome, _vendedora.id, _produtosCarrinho, double.parse(_valorEntrada.text), totalVenda);
                            //SellClass venda = SellClass(_dataVendaController.text, formatDate(DateTime.now(), [mm, '/', yyyy]), formaPgto, _nomeCliente.text, isRegisteredClient ? cliente.clienteId : "cliente sem registro" , _quantidadeParcelamentos.text==null ? 1 : int.parse(_quantidadeParcelamentos.text), double.parse(_totalVenda.text), vendedora.nome, vendedora.id, produtosIdCarrinho);

                            SellClass.empty().addToBd(venda);

                            setState(() {
                              _isUploading = false;
                            });

                            _displaySnackBar(context, "As informações foram salvas.");

                            //agora vamos zerar tudo
                            _resetState();

                          } else {
                            _displaySnackBar(context, "Escolha a vendedora");
                          }
                        } else {
                          _displaySnackBar(context, "Nenhum produto selecionado");
                        }
                      } else {
                        _displaySnackBar(context, "Preencha todas informações");
                      }
                    },
                  ),
                ),
                SizedBox(height: 16.0,)



              ],
            ),
          ),
        )
    );
  }

  /*
  Widget CadVendaScreen(){
    return Container(
      height: 500.0,
      child: Form(
        key: _formKey,
        child:  Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              WidgetsConstructor().makeSimpleText("Itens desta venda", Theme.of(context).primaryColor, 15.0),
              SizedBox(height: 16.0,),
              ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(4),
                  itemCount: _produtosCarrinho.length,
                  itemBuilder: (BuildContext context, int index) {

                    final _key = UniqueKey().toString(); //gerando uma chave única

                    return Dismissible(
                      key: Key(_key),  //passando a key

                      onDismissed: (direction) {

                          _produtosCarrinho.removeAt(index);
                          totalVenda = totalVenda-_produtosCarrinho[index].preco;
                        _displaySnackBar(context, "Produto removido da venda");
                      },
                      background: Container(color: Colors.blueGrey),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(_produtosCarrinho[index].codigo+" - Preço etiqueta: "+_produtosCarrinho[index].preco.toStringAsFixed(2)),
                              )
                          )
                      ),
                    );
                  }
              ),
              WidgetsConstructor().makeFormEditTextForDateFormat(_dataVendaController, "Data da venda", _maskFormatterDataVenda, "Informe a data"),
              SizedBox(height: 16.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 240.0,
                    child: TextFormField(
                      controller: _nomeCliente,
                      decoration: InputDecoration(labelText: "Nome do cliente"),
                      validator: (value) {
                        if(value.isEmpty){
                          return "Informe o nome do cliente";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 5.0,),
                  Container(
                    width: 50.0,
                    height: 50.0,
                    color: Colors.blueAccent,
                    child: IconButton(
                      icon: Icon(Icons.person, color: Colors.white,),
                      color: Theme.of(context).primaryColor,
                      onPressed: (){
                        //exibe a tela com os clientes para escolher
                        setState(() {
                          _showClients = true;
                        });

                      },
                    ),
                  ),

                ],
              ),

              SizedBox(height: 16.0,),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(10.0)),
                height: 350.0,
                child: Column(
                  children: <Widget>[
                    WidgetsConstructor().makeText("Forma de pagamento", Theme.of(context).primaryColor, 18.0, 4.0, 4.0, "center"),
                    buildRadioOptions(context),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                      child: Column(
                        children: <Widget>[
                          _formaPgto!="avista" ? WidgetsConstructor().makeFormEditTextNumberOnly(_quantidadeParcelamentos, "Nº parcelas", "Informe a quantidade de parcelas"): Text(""),
                          _formaPgto!="avista" ? WidgetsConstructor().makeFormEditTextNumberOnly(_valorEntrada, "Entrada", "Informe o valor da entrada"): Text(""),
                        ],
                      )
                    )
                  ],
                ),
              ),
              Center(
                child: _isUploading ? CircularProgressIndicator() : Text(""),
              ),
              SizedBox(height: 16.0,),
              WidgetsConstructor().makeEditTextForCurrency(_totalVenda, "Total da venda"),
              SizedBox(height: 16.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      width: 240.0,
                      child: Text(_vendedora.nome == null ? "Nenhuma vendedora" : _vendedora.nome)
                  ),
                  SizedBox(width: 5.0,),
                  Container(
                    width: 50.0,
                    height: 50.0,
                    color: Colors.blueAccent,
                    child: IconButton(
                      icon: Icon(Icons.person, color: Colors.white,),
                      color: Theme.of(context).secondaryHeaderColor,
                      onPressed: (){
                        //exibe a tela com os clientes para escolher
                        setState(() {
                          _showVendors = true;
                        });

                      },
                    ),
                  ),

                ],
              ),
              SizedBox(height: 30.0,),
              Container(
                height: 60.0,
                color: Theme.of(context).primaryColor,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  child: WidgetsConstructor().makeSimpleText("Registrar venda", Colors.white, 20.0),
                  onPressed: () async {
                    //registrar venda
                    if (_formKey.currentState.validate()) { //
                      if(_produtosCarrinho.length!=0){
                        if(_vendedora.nome != null){

                          //se chegou até aqui pode salvar a venda
                          setState(() {
                            _isUploading = true;
                          });

                          //vamos preencher o objeto venda
                          SellClass venda = SellClass(_dataVendaController.text, formatDate(DateTime.now(), [mm, '/', yyyy]), _formaPgto, _nomeCliente.text, _isRegisteredClient ? _cliente.clienteId : "cliente sem registro" , _quantidadeParcelamentos.text==null ? 1 : int.parse(_quantidadeParcelamentos.text), double.parse(_totalVenda.text), _vendedora.nome, _vendedora.id, _produtosCarrinho, double.parse(_valorEntrada.text), totalVenda);
                          //SellClass venda = SellClass(_dataVendaController.text, formatDate(DateTime.now(), [mm, '/', yyyy]), formaPgto, _nomeCliente.text, isRegisteredClient ? cliente.clienteId : "cliente sem registro" , _quantidadeParcelamentos.text==null ? 1 : int.parse(_quantidadeParcelamentos.text), double.parse(_totalVenda.text), vendedora.nome, vendedora.id, produtosIdCarrinho);

                          SellClass.empty().addToBd(venda);

                          setState(() {
                            _isUploading = false;
                          });

                          _displaySnackBar(context, "As informações foram salvas.");

                          //agora vamos zerar tudo
                          _resetState();

                        } else {
                          _displaySnackBar(context, "Escolha a vendedora");
                        }
                      } else {
                        _displaySnackBar(context, "Nenhum produto selecionado");
                      }
                    } else {
                      _displaySnackBar(context, "Preencha todas informações");
                    }
                  },
                ),
              ),
              SizedBox(height: 16.0,)



            ],
          ),
        ),
      )
    );
  }
   */
  void _resetState(){

    setState(() {
      _produtosCarrinho.clear();
      _dataVendaController.text="";
      ClienteClass.ClienteSellErase(_cliente);
      VendorClass.erase(_vendedora);
      _formaPgto = "avista";
      _isRegisteredClient = false;
      _totalVenda.text="0.0";
      _quantidadeParcelamentos.text="1";
      _nomeCliente.text= "";
      _valorEntrada.text="";
      _searchController.text="";

    });
  }

  Widget buildRadioOptions(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioButton(
          description: "À vista",
          value: "avista",
          groupValue: _formaPgto,
          onChanged: (value) => setState(
                () => _formaPgto = value,
          ),
        ),
        RadioButton(

          description: "Crediário",
          value: "crediario",
          groupValue: _formaPgto,
          onChanged: (value) => setState(
                () => _formaPgto = value,
          ),
        ),
        RadioButton(

          description: "Parcelado",
          value: "parcelado",
          groupValue: _formaPgto,
          onChanged: (value) => setState(
                () => _formaPgto = value,
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
        onPressed: (){
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

}
