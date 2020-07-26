import 'package:flutter/material.dart';
import 'package:gisapp/pages/cad_prod_page.dart';
import 'package:gisapp/pages/index_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gisá Basilio", style: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.only(top: 16.0),  //o padding top é obrigatório pois no iphone existem elementos no alto da tela e poderiam tampar
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Text('Opções',style: TextStyle(color: Colors.white, fontSize: 30.0), textAlign: TextAlign.start,),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            InkWell( //item 1 inicio
              onTap: (){ //click
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => HomePage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: _drawLine(Icons.home, "Início", Theme.of(context).primaryColor, context),
              ),
            ),
            InkWell( //item 2 Cadastrar peça
              onTap: (){ //click
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CadProdPage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: _drawLine(Icons.add, "Cadastrar peça", Theme.of(context).primaryColor, context),
              ),
            ), InkWell( //item 3 Registrar venda
              onTap: (){ //click
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CadProdPage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: _drawLine(Icons.shopping_cart, "Cadastrar peça", Theme.of(context).primaryColor, context),
              ),
            ),InkWell( //item 4 Situação vendedoras
              onTap: (){ //click
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => IndexPage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: _drawLine(Icons.format_list_numbered, "Situação das vendedoras", Theme.of(context).primaryColor, context),
              ),
            ),InkWell( //item 5 Gerar arquivo
              onTap: (){ //click
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => IndexPage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: _drawLine(Icons.print, "Gerar arquivo", Theme.of(context).primaryColor, context),
              ),
            ),
          ],
        ),
      ),
      body: Container(color: Colors.white,
        child: Center(
          child: Image.asset("images/gisalogo.png", height: 200,),
        )
        ,),
    );

  }

  Widget _drawLine(IconData icon, String text, Color color, BuildContext context){

    return Material(

      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          Container(
            height: 60.0,
            child: Row(
              children: <Widget>[
                Icon(
                  icon, size: 32.0,
                  color : Theme.of(context).primaryColor,
                ),
                SizedBox(width: 32.0,),
                Text(
                  text, style: TextStyle(fontSize: 16.0,
                  color : Theme.of(context).primaryColor,

                ),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );

  }

}

