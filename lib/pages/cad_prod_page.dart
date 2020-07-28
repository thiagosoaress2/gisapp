
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_mobx/flutter_mobx.dart' as mob;
import 'package:gisapp/Utils/firebase_utils.dart';
import 'package:gisapp/Utils/permissions_service.dart';
import 'package:gisapp/Utils/photo_service.dart';
import 'package:gisapp/classes/product_class.dart';
import 'package:gisapp/widgets/widgets_constructor.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:permission_handler/permission_handler.dart';

class CadProdPage extends StatefulWidget {
  @override
  _CadProdPageState createState() => _CadProdPageState();
}

class _CadProdPageState extends State<CadProdPage> {

  bool permissions = false;

  PhotoService photoService = PhotoService(); //objeto da classe

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  bool isUploading = false;

  final TextEditingController _codigoPecaController = TextEditingController();
  final _custoController = MoneyMaskedTextController(
      decimalSeparator: '.', thousandSeparator: ',');
  var maskFormatterDataCompra = new MaskTextInputFormatter(
      mask: '##/##/####', filter: { "#": RegExp(r'[0-9]')});
  final TextEditingController _dataCompraController = TextEditingController();
  var maskFormatterDataEntrega = new MaskTextInputFormatter(
      mask: '##/##/####', filter: { "#": RegExp(r'[0-9]')});
  final TextEditingController _dataEntregaController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _notaFiscalController = TextEditingController();
  final _precoController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  final _quantidadeController = TextEditingController();

  String moeda;


  @override
  void initState() {
    super.initState();

    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, //scafoldkey para snack
      appBar: AppBar(
        title: Text("Cadastrando peça"),
        centerTitle: true,
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      ),
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 30.0,),
              Container(
                height: 30.0,
                alignment: Alignment.center,
                child: Text("Upload da foto",
                  style: TextStyle(fontSize: 22.0, color: Colors.grey[500],),),
              ),
              IconButton(
                  iconSize: 70.0,
                  padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 8.0),
                  icon: Icon(Icons.photo_camera, color: Colors.blueAccent),
                  onPressed: () async {
                    if (permissions) {
                      photoService.getImage();
                    } else {
                      PermissionsService().checkCameraPermission();
                    }
                  }
              ),

              mob.Observer(
                builder: (_) {
                  return Center(
                      child: photoService.getState == 0
                          ? Text('Nenhuma imagem selecionada.')
                          : Container(
                        height: 150.0,
                        width: 300.0,
                        child: Image.file(photoService.image),
                      )
                  );
                },
              ),
              Form(
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        WidgetsConstructor().makeFormEditText(
                            _codigoPecaController, "Código da peça",
                            "Informe o código"),
                        WidgetsConstructor().makeFormEditTextForCurrency(
                            _custoController, "Custo", "Informe custo"),
                        WidgetsConstructor().makeText("informe moeda da compra", Theme.of(context).primaryColor, 18.0, 16.0, 0.0, "center"),
                        SizedBox(height: 16.0,),
                        buildRadioOptions(context),
                        WidgetsConstructor().makeFormEditTextForDateFormat(
                            _dataCompraController, "Data da compra",
                            maskFormatterDataCompra, "Informe a data"),
                        WidgetsConstructor().makeFormEditTextForDateFormat(
                            _dataEntregaController, "Data da Entrega",
                            maskFormatterDataEntrega, "Informe a data"),
                       Center(
                         child: isUploading ? CircularProgressIndicator() : Text(""),
                       ),
                        WidgetsConstructor().makeFormEditText(
                            _descricaoController, "Descrição",
                            "Informe descrição"),
                        WidgetsConstructor().makeFormEditText(
                            _notaFiscalController, "Nota fiscal",
                            "Informe a nota"),
                        WidgetsConstructor().makeFormEditTextForCurrency(
                            _precoController, "Preço", "Informe o preço"),
                        WidgetsConstructor().makeFormEditTextNumberOnly(_quantidadeController, "Quantidade do produto", "Informe a quantidade"),
                        SizedBox(height: 35.0,),
                        Container(height: 50.0,
                          child: RaisedButton(
                            onPressed: () async {
                              if (formKey.currentState.validate()) { //todos os campos estão ok. Agora falta verificar radio buttons e imagem

                                  if(moeda!=null){
                                    //se chegou até é pq informou todos os campos e a moeda. Falta apenas verificar imagem
                                    if(photoService.getState == 0){
                                      //aqui não informou imagem
                                      _displaySnackBar(context, "Selecione a imagem");
                                    } else {

                                      //agora ver se as datas estão ok
                                      if(_dataCompraController.text.length != 10 || _dataEntregaController.text.length != 10){
                                        _displaySnackBar(context, "Formato da data errado");

                                      } else {

                                        //atualiza para o loading
                                        setState(() {
                                          isUploading = true;
                                        });

                                        //cria o objeto que vai pro upload na class
                                        ProductClass produto = new ProductClass("not",
                                            _codigoPecaController.text,
                                            _dataCompraController.text,
                                            _dataEntregaController.text,
                                            _descricaoController.text,
                                            "not",
                                            moeda,
                                            _notaFiscalController.text,
                                            double.parse(_precoController.text),
                                            double.parse(_custoController.text),
                                            int.parse(_quantidadeController.text));


                                        //upload da foto
                                        FirebaseUtils().uploadFile("produtos", "img", photoService.image, produto).whenComplete(() {

                                          setState(() {
                                            _displaySnackBar(context, "Sucesso. As informações foram salvas!");

                                            //aqui você pode zerar tudo que tem na tela pra deixar livre novamente
                                            //photoService.image=0;
                                            _codigoPecaController.text = "";
                                            _custoController.text="";
                                            moeda=null;
                                            _dataEntregaController.text = "";
                                            _dataCompraController.text = "";
                                            _descricaoController.text = "";
                                            _notaFiscalController.text = "";
                                            _precoController.text = "";
                                            _quantidadeController.text = "";

                                            //remove o loading
                                            isUploading = false;

                                          });


                                        });

                                      }

                                    }

                                  } else { //se nao tiver escolhido moeda

                                    _displaySnackBar(context, "Informe a moeda");
                                  }

                                }

                            },
                            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                            textColor: Colors.white,
                            color: Theme
                                .of(context)
                                .primaryColor,
                            child: Text(
                              "Cadastrar peça", style: TextStyle(
                                fontSize: 18.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 50.0,),
                      ],
                    ),
                  )
              ),

            ],
          )
        ],
      ),
    );
  }

  checkCameraPermissionStatus() async {
    //se o user nao tiver dado permissão, vai aparecer na tela. Se já tiver, vai retornar true

    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      //Permission.storage,
    ].request();
    print(statuses[Permission.camera]);

    if (await Permission.camera.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    }

    if (statuses[Permission.camera].toString() == "PermissionStatus.granted") {
      permissions = true;
    } else {
      permissions = false;
    }
  }

  checkPermission() async {
    permissions = await PermissionsService().checkCameraPermission();
  }

  Widget buildRadioOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RadioButton(
          description: "Dólar US\$",
          value: "dolar",
          groupValue: moeda,
          onChanged: (value) => setState(
                () => moeda = value,
          ),
        ),
        RadioButton(
          description: "Real R\$",
          value: "real",
          groupValue: moeda,
          onChanged: (value) => setState(
                () => moeda = value,
          ),
        ),
      ],
    );
  }

  _displaySnackBar(BuildContext context, String msg) {

    final snackBar = SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 5),
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








