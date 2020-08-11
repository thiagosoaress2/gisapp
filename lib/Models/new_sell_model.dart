import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'new_sell_model.g.dart';

class NewSellModel = _NewSellModel with _$NewSellModel;

abstract class _NewSellModel with Store {

  /*
  bool _isUploading = false;

  bool _showProducts = false;

  bool _showClients = false;

  bool _showVendors = false;

  bool _isRegisteredClient = false;
   */

  @observable
  String page="land";
  //as paginas serão:
  //land - pagina principal
  //product - pagina que exibe os produtos para escolher

  @observable
  final TextEditingController _dataVendaController = TextEditingController();

  @action
  void updateDataVenda(String data){
    _dataVendaController.text = data;
  }

  @observable
  double valorEntradaVariable = 0.0;

  @action
  void setPage(String newPage){
    page = newPage;
  }

}