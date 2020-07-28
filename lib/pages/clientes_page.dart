import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gisapp/classes/cliente_class.dart';
import 'package:gisapp/pages/cad_new_client_page.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';

class ClientesPage extends StatefulWidget {
  @override
  _ClientesPageState createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {


  bool showClientDetails = false;

  ClienteClass cliente;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clientes cadastrados", style: TextStyle(color: Colors.white),),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => CadNewClientPage()));
        },
        child: Icon(Icons.person_add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
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
                        List<DocumentSnapshot> documents = snapshot.data.documents.reversed.toList(); //recuperamos o querysnapshot que estamso observando

                        return ListView.builder(  //aqui vamos começar a construir a listview com os itens retornados
                            itemCount: documents.length,
                            itemBuilder: (context, index){
                              return GestureDetector(
                                onTap: (){
                                  setState(() {
                                    cliente = new ClienteClass(
                                        documents[index].documentID,
                                        documents[index].data["nome"],
                                        documents[index].data["dataUltimaVenda"],
                                        documents[index].data["ultimoItem"],
                                        documents[index].data["valorDevido"],
                                        documents[index].data["vendasTotais"]);

                                    showClientDetails = !showClientDetails;  //para exibir a tela
                                    
                                  });
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin:EdgeInsets.only(top: 8.0),
                                          child: Text(documents[index].data["nome"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0, color: Colors.blueGrey)),
                                        ),
                                        Container(
                                          margin:EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                                          child: Text("última venda: ${documents[index].data["dataUltimaVenda"]}", style: TextStyle(color: Colors.grey[500])),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                    }
                  },
                ),
              ),

            ],
          ),
          showClientDetails ? _usersInfo(cliente) : Text(""),
        ],
      )


    );
  }

  Widget _usersInfo(ClienteClass cliente){
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Container(height: 60.0,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor,),
                iconSize: 50.0,
                onPressed:(){

                  setState(() {
                    showClientDetails = !showClientDetails;
                  });

                },
              )
              ,),
            WidgetsConstructor().makeText("Informações do cliente", Colors.blueAccent, 22.0, 30.0, 30.0, "center"),
            WidgetsConstructor().makeSimpleText("Nome: ${cliente.nome}", Colors.grey[700], 17.0),
            WidgetsConstructor().makeSimpleText("Valor devido: R\$ ${cliente.valorDevido.toStringAsFixed(2)}", Colors.grey[700], 17.0),
            SizedBox(height: 20.0,),
            Divider(),
            WidgetsConstructor().makeSimpleText("Última venda: ${cliente.dataUltimaVenda == "nao" ? "Não houve" : cliente.dataUltimaVenda}", Colors.grey[700], 17.0),
            WidgetsConstructor().makeSimpleText("Último item: ${cliente.ultimoItem == "nao" ? "Não houve" : cliente.ultimoItem}", Colors.grey[700], 17.0),
            Divider(),
            WidgetsConstructor().makeSimpleText("Vendas totais: R\$ ${cliente.vendasTotais.toStringAsFixed(2)}", Colors.blueGrey, 17.0),
          ],
        ),
      )
    );
  }


}

