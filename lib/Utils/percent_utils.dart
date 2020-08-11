class PercentUtils {

  double percentFromTwoNumbers(double val1, double val2){
    //val 1 é quantos porcento de val2?
    /*
    21,60 é quanto por cento de 180?
    21,6/180 x100 = 12 (12%)
     */
    return (val1/val2)*100;

  }

  double getValueFromPercent(double val1, double val2){
    //val1 é o valor total
    //val 2 é a porcentagem
    //o resultado é: Quanto é x% de val1?

    return val1*(val2/100); //
  }

  double DescountThisPercent(double val1, double val2){
    //val 1 é o valor e val2 é a porcentagem a ser descontada
    //aplicando um desconto percentual
    /*
    Uma roupa custa R$ 180,00 em uma loja. Pagando à vista o cliente ganha um desconto de 12 %. Perguntas:
    Qual o valor a ser pago depois do desconto? Qual valor será descontado?
     */
      double descount = val1*(val2/100);
      return val1 - descount; //retorna o valor já com desconto

  }

  double addPercentageToNumber(double val1, doubleval2){
    /*
    Se um produto custava R$ 230,00 e teve um aumento de 15% no seu valor. Qual é o preço depois do reajuste?
     */
    return (val1*(15/100)+val1);
  }

}