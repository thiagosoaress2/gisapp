// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendedoras_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$VendedorasModel on _VendedorasModel, Store {
  final _$totalVendasAtom = Atom(name: '_VendedorasModel.totalVendas');

  @override
  double get totalVendas {
    _$totalVendasAtom.reportRead();
    return super.totalVendas;
  }

  @override
  set totalVendas(double value) {
    _$totalVendasAtom.reportWrite(value, super.totalVendas, () {
      super.totalVendas = value;
    });
  }

  final _$_VendedorasModelActionController =
      ActionController(name: '_VendedorasModel');

  @override
  void updateTotalVendas(double value) {
    final _$actionInfo = _$_VendedorasModelActionController.startAction(
        name: '_VendedorasModel.updateTotalVendas');
    try {
      return super.updateTotalVendas(value);
    } finally {
      _$_VendedorasModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
totalVendas: ${totalVendas}
    ''';
  }
}
