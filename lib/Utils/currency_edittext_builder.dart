import 'package:flutter/cupertino.dart';
import 'package:moneytextformfield/moneytextformfield.dart';

class CurrencyEditTextBuilder {

  //ATENÇÃO
  //Esta biblioteca utiliza moneytextformfield: ^0.3.5+1 em pucspec.yaml

  Widget makeMoneyTextFormFieldSettings (TextEditingController controller, String labelTxt){
    return MoneyTextFormField(
        settings: MoneyTextFormFieldSettings(
            controller: controller,
            moneyFormatSettings: MoneyFormatSettings(currencySymbol: "R\$"),
            appearanceSettings: AppearanceSettings(
                padding: EdgeInsets.all(15.0),
                labelText: labelTxt,
                hintText: "R\$0,00"
            )
        )
    );
  }


}