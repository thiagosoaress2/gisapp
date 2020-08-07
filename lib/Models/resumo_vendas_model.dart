import 'package:mobx/mobx.dart';

part 'resumo_vendas_model.g.dart';

class ResumoVendasModel = _ResumoVendasModel with _$ResumoVendasModel;

abstract class _ResumoVendasModel with Store {

  @observable
  int page=0;

  @observable
  String datesFilter="nao"; //0 é este mês //1 é outra data

  @observable
  String filterQuery="";

  @action
  void setFilterQuery(String query){
    filterQuery=query;
  }

  @action
  void setDatesFilter(String newFilter){
    datesFilter=newFilter;
  }

  @action
  void setPage(int newPage){
    page = newPage;
  }


  //as duas utilizaçoes de mobx abaixo funcionam mas sempre retornam 0 na pagina principal.
  /*
  //observavel
  mob.Observable _page = mob.Observable(0);

  //action
  mob.Action increment;
  mob.Action decrement;


  void _increment(){
    _page.value++;
  }

  void _decrement(){
    _page.value--;
  }

  //vinculando ação a uma função
  ResumoVendasModels(){
    increment = mob.Action(_increment);
    decrement = mob.Action(_decrement);
  }



  int get getPage => _page.value;

  void updatePage(int newPage){
    if(newPage<_page.value){ //newpage==1 page==2
      while(newPage<_page.value){
        _decrement();
      }
    } else if(newPage>_page.value){
      while(newPage>_page.value){
        _increment();
      }

    } else {
      //do nothing
    }
  }

   */

/*
  ResumoVendasModels() {
    increment = mobx.Action(_increment);
  }

  var _page = mobx.Observable(0);
  int get getPage => _page.value;
  int newValue = 0;

  void setValue(int inputedValue){
    newValue = inputedValue;
    _page.value = newValue;
    //mobx.Action increment;
  }

  //set value(int newValue) => _page.value = newValue;
  mobx.Action increment;

  void _increment() {
    _page = newValue as mobx.Observable<int>;
  }

   */


}