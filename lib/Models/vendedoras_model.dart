import 'package:mobx/mobx.dart';

part 'vendedoras_model.g.dart';

class VendedorasModel = _VendedorasModel with _$VendedorasModel;

abstract class _VendedorasModel with Store {

  @observable
  double totalVendas = 0.00;

  @action
  void updateTotalVendas(double value) {
    double provi = totalVendas;
    totalVendas = provi+value;
  }


}