// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_sell_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$NewSellModel on _NewSellModel, Store {
  final _$pageAtom = Atom(name: '_NewSellModel.page');

  @override
  String get page {
    _$pageAtom.reportRead();
    return super.page;
  }

  @override
  set page(String value) {
    _$pageAtom.reportWrite(value, super.page, () {
      super.page = value;
    });
  }

  final _$valorEntradaVariableAtom =
      Atom(name: '_NewSellModel.valorEntradaVariable');

  @override
  double get valorEntradaVariable {
    _$valorEntradaVariableAtom.reportRead();
    return super.valorEntradaVariable;
  }

  @override
  set valorEntradaVariable(double value) {
    _$valorEntradaVariableAtom.reportWrite(value, super.valorEntradaVariable,
        () {
      super.valorEntradaVariable = value;
    });
  }

  final _$totalVendaAtom = Atom(name: '_NewSellModel.totalVenda');

  @override
  double get totalVenda {
    _$totalVendaAtom.reportRead();
    return super.totalVenda;
  }

  @override
  set totalVenda(double value) {
    _$totalVendaAtom.reportWrite(value, super.totalVenda, () {
      super.totalVenda = value;
    });
  }

  final _$isUploadingAtom = Atom(name: '_NewSellModel.isUploading');

  @override
  bool get isUploading {
    _$isUploadingAtom.reportRead();
    return super.isUploading;
  }

  @override
  set isUploading(bool value) {
    _$isUploadingAtom.reportWrite(value, super.isUploading, () {
      super.isUploading = value;
    });
  }

  final _$_NewSellModelActionController =
      ActionController(name: '_NewSellModel');

  @override
  void setPage(String newPage) {
    final _$actionInfo = _$_NewSellModelActionController.startAction(
        name: '_NewSellModel.setPage');
    try {
      return super.setPage(newPage);
    } finally {
      _$_NewSellModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateTotalVenda(double newTotal) {
    final _$actionInfo = _$_NewSellModelActionController.startAction(
        name: '_NewSellModel.updateTotalVenda');
    try {
      return super.updateTotalVenda(newTotal);
    } finally {
      _$_NewSellModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateIsUploading() {
    final _$actionInfo = _$_NewSellModelActionController.startAction(
        name: '_NewSellModel.updateIsUploading');
    try {
      return super.updateIsUploading();
    } finally {
      _$_NewSellModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
page: ${page},
valorEntradaVariable: ${valorEntradaVariable},
totalVenda: ${totalVenda},
isUploading: ${isUploading}
    ''';
  }
}
