class VendorClass {

  String id;
  String nome;
  int comissao;
  double salario;

  VendorClass(this.id, this.nome, this.comissao, this.salario);

  VendorClass.empty();

  VendorClass.erase(VendorClass vendor){
    vendor.id = null;
    vendor.nome = null;
    vendor.comissao = null;
  }

}