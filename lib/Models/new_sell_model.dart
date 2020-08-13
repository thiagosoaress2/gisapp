import 'package:gisapp/pages/new_sell_page.dart';
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
  //client - pagina para selecionar o cliente
  //vendors - selecionar vendedor

  @action
  void setPage(String newPage){
    page = newPage;
  }

  @observable
  double valorEntradaVariable = 0.0;


  @observable
  double totalVenda=0.00;

  @action
  void updateTotalVenda (double newTotal){
    totalVenda = newTotal;
  }

  @observable
  bool isUploading = false;

  @action
  void updateIsUploading (){
    isUploading = !isUploading;
  }

}