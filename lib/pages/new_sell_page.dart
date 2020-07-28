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

class NewSellPage extends StatefulWidget {
  @override
  _NewSellState createState() => _NewSellState();
}

class _NewSellState extends State<NewSellPage> {

  bool isUploading = false;

  bool showProducts = false;

  bool showClients = false;

  bool showVendors = false;

  bool isRegisteredClient = false;

  ProductClass produto = ProductClass.toSellProduct("nao", "nao", "nao", 0.0, "nao");

  VendorClass vendedora = VendorClass(null, null, null, null);

  ClienteClass cliente = ClienteClass.ClienteSell(null, null, null);

  List<ProductClass> produtosCarrinho = [];
  List<String> produtosIdCarrinho = [];

  var maskFormatterDataVenda = new MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]')});
  final TextEditingController _dataVendaController = TextEditingController();

  final TextEditingController _quantidadeParcelamentos = TextEditingController();
  final _valorEntrada = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  final TextEditingController _nomeCliente = TextEditingController();
  final _totalVenda = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');


  String formaPgto = "avista";

  double totalVenda = 0.0;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
                          showProducts = true;

                          //colocar a data de hoje no editfield para facilitar
                          _dataVendaController.text = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy]);
                          _quantidadeParcelamentos.text = "1";
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                      child: produto.pId=="nao"
                          ? Text("Nenhum produto selecionado.", textAlign: TextAlign.center,)
                          : CadVendaScreen()

                  ),
                ],
              ),
              showProducts
                ? ProductScreen()
                : Container(height: 0.0,width: 0.0,),
              showClients
              ? ClientsScreen()
                  : Container(height: 0.0, width: 0.0,),
              showVendors
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
      child: Expanded(
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
                      return GestureDetector(
                        onTap: (){
                          setState(() {

                            ProductClass.empty().completeProductToSell(produto, documents[index].documentID, documents[index].data["imagem"], documents[index].data["codigo"], documents[index].data["preco"], documents[index].data["descricao"], documents[index].data["quantidade"]);
                            produtosCarrinho.add(produto);
                            produtosIdCarrinho.add(documents[index].documentID);
                            _totalVenda.text = (double.parse(_totalVenda.text)+produto.preco).toStringAsFixed(2);
                            showProducts=false;
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
                      );
                    });
            }
          },
        ),
      ),
    );



  }

  Widget ClientsScreen(){
    return Container(
      color: Colors.white,
      height: 700,
      child: Expanded(
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
                      return GestureDetector(
                        onTap: (){
                          setState(() {

                            cliente.clienteId = documents[index].documentID;
                            cliente.nome = documents[index].data["nome"];
                            cliente.vendasTotais = documents[index].data["vendasTotais"];
                            _nomeCliente.text = cliente.nome;
                            isRegisteredClient=true;
                            showClients = false;
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
    );

  }

  Widget VendorsScreen(){
    return Container(
      color: Colors.white,
      height: 700,
      child: Expanded(
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

                            vendedora.id = documents[index].documentID;
                            vendedora.nome = documents[index].data["nome"];
                            vendedora.comissao = documents[index].data["comissao"];

                            showVendors = false;
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
    );

  }

  Widget CadVendaScreen(){
    return Container(
      height: 500.0,
      child: Form(
        key: formKey,
        child:  Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              WidgetsConstructor().makeSimpleText("Itens desta venda", Theme.of(context).primaryColor, 15.0),
              SizedBox(height: 16.0,),
              ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(4),
                  itemCount: produtosCarrinho.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 20,
                      child: Text(produtosCarrinho[index].codigo+" - Preço etiqueta: "+produtosCarrinho[index].preco.toStringAsFixed(2)),
                    );
                  }
              ),
              WidgetsConstructor().makeFormEditTextForDateFormat(_dataVendaController, "Data da venda", maskFormatterDataVenda, "Informe a data"),
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
                          showClients = true;
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
                          formaPgto!="avista" ? WidgetsConstructor().makeFormEditTextNumberOnly(_quantidadeParcelamentos, "Nº parcelas", "Informe a quantidade de parcelas"): Text(""),
                          formaPgto!="avista" ? WidgetsConstructor().makeFormEditTextNumberOnly(_valorEntrada, "Entrada", "Informe o valor da entrada"): Text(""),
                        ],
                      )
                    )
                  ],
                ),
              ),
              Center(
                child: isUploading ? CircularProgressIndicator() : Text(""),
              ),
              SizedBox(height: 16.0,),
              WidgetsConstructor().makeEditTextForCurrency(_totalVenda, "Total da venda"),
              SizedBox(height: 16.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      width: 240.0,
                      child: Text(vendedora.nome == null ? "Nenhuma vendedora" : vendedora.nome)
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
                          showVendors = true;
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
                    if (formKey.currentState.validate()) { //
                      if(produtosCarrinho.length!=0){
                        if(vendedora.nome != null){

                          //se chegou até aqui pode salvar a venda
                          setState(() {
                            isUploading = true;
                          });

                          //vamos preencher o objeto venda
                          SellClass venda = SellClass(_dataVendaController.text, formatDate(DateTime.now(), [mm, '/', yyyy]), formaPgto, _nomeCliente.text, isRegisteredClient ? cliente.clienteId : "cliente sem registro" , _quantidadeParcelamentos.text==null ? 1 : int.parse(_quantidadeParcelamentos.text), double.parse(_totalVenda.text), vendedora.nome, vendedora.id, produtosCarrinho, double.parse(_valorEntrada.text));
                          //SellClass venda = SellClass(_dataVendaController.text, formatDate(DateTime.now(), [mm, '/', yyyy]), formaPgto, _nomeCliente.text, isRegisteredClient ? cliente.clienteId : "cliente sem registro" , _quantidadeParcelamentos.text==null ? 1 : int.parse(_quantidadeParcelamentos.text), double.parse(_totalVenda.text), vendedora.nome, vendedora.id, produtosIdCarrinho);

                          SellClass.empty().addToBd(venda);

                          setState(() {
                            isUploading = false;
                          });

                          _displaySnackBar(context, "As informações foram salvas.");

                          //agora vamos zerar tudo




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

  void resetState(){

    setState(() {
      produtosCarrinho.clear();
      produtosIdCarrinho.clear();
      _dataVendaController.text="";
      ClienteClass.ClienteSellErase(cliente);
      VendorClass.erase(vendedora);
      formaPgto = "avista";
      isRegisteredClient = false;
      _totalVenda.text="0.0";
      _quantidadeParcelamentos.text="1";
      _nomeCliente.text= "";
      _valorEntrada.text="";

    });
  }

  Widget buildRadioOptions(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioButton(
          description: "À vista",
          value: "avista",
          groupValue: formaPgto,
          onChanged: (value) => setState(
                () => formaPgto = value,
          ),
        ),
        RadioButton(

          description: "Crediário",
          value: "crediario",
          groupValue: formaPgto,
          onChanged: (value) => setState(
                () => formaPgto = value,
          ),
        ),
        RadioButton(

          description: "Parcelado",
          value: "parcelado",
          groupValue: formaPgto,
          onChanged: (value) => setState(
                () => formaPgto = value,
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
