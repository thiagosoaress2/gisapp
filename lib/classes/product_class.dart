class ProductClass {

  String pId;
  String codigo;
  String dataCompra;
  String dataEntrega;
  String descricao;
  String imagem;
  String moedaCompra;
  String notaFiscal;
  double preco;
  double custo;

  //construtor
  ProductClass(this.pId, this.codigo, this.dataCompra, this.dataEntrega, this.descricao, this.imagem, this.moedaCompra, this.notaFiscal, this.preco, this.custo);

  //este ainda não tem o id.
  ProductClass.inicial(this.codigo, this.dataCompra, this.dataEntrega, this.descricao, this.imagem, this.moedaCompra, this.notaFiscal, this.preco, this.custo);

}