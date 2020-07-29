import 'package:flutter/material.dart';
import 'package:gisapp/classes/cliente_class.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';

class CadNewClientPage extends StatefulWidget {
  @override
  _CadNewClientState createState() => _CadNewClientState();
}

class _CadNewClientState extends State<CadNewClientPage> {

  final TextEditingController _nameController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: WidgetsConstructor().makeSimpleText("Novo cliente", Colors.white, 18.0),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 30.0,),
            WidgetsConstructor().makeEditText(_nameController, "Nome do cliente", null),
            Center(
              child: isUploading ? CircularProgressIndicator() : Text(""),
            ),
            SizedBox(height: 25.0,),
            Container(
              color: Theme.of(context).primaryColor,
              height: 45.0,
              child: RaisedButton(
               child: WidgetsConstructor().makeSimpleText("teste", Colors.white, 18.0),
                color: Colors.transparent,
                onPressed: () async {
                    //save data to bd
                  if(_nameController.text.isEmpty){
                    _displaySnackBar(context, 'Informe o nome do cliente.');


                  //_displaySnackBar(context, "Informe o nome do cliente.");
                  } else {


                    ClienteClass cliente = ClienteClass(null, _nameController.text, "nao", "nao", 0.0, 0.0);
                    print(cliente.nome);

                    setState(() {
                      isUploading = true;
                    });

                      ClienteClass.empty().addToBd(cliente).whenComplete(() {

                        setState(() {
                          _nameController.text="";
                          isUploading = false;
                          _displaySnackBar(context, 'Sucesso. As informações foram salvas.');
                        });

                      });





                  }

                },

              ),
            ),

          ],
        ),
      )
    );
  }


  _displaySnackBar(BuildContext context, String msg) {

    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 3),
      ),
    );
  }

}


