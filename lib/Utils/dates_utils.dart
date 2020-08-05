import 'package:date_format/date_format.dart';

//needs to add date_format: ^1.0.8 to pubspec.yaml

class DateUtils {

  String _convertStringFromDate(DateTime strDate) {
    final newDate = formatDate(strDate, [dd, '/', mm, '/', yyyy]);
    return newDate;
  }

  DateTime _convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate.split('/').reversed.join());
    return todayDate;
  }

  String _returnMeXDaysInFutureFromThisDate(String strDate, int daysToAdd){
    DateTime theDate = _convertDateFromString(strDate);
    var thirtyDaysFromNow = theDate.add(new Duration(days: daysToAdd));
    String formattedDate = _convertStringFromDate(thirtyDaysFromNow);
    return formattedDate;
  }

  bool doesThisDateIsBigger (String date1, String date2){
    var date1Formatted = _convertDateFromString(date1);
    var date2Formatted = _convertDateFromString(date2);

    final difference = date2Formatted.difference(date1Formatted).inDays;

    if (difference>=0){
      return false; //data 1 é maior
    } else {
      return true; //data2 é maior
    }
  }

  bool doesThisDateIsBiggerThanToday (String date){

    var dateFormatted = _convertDateFromString(date);
    var today = DateTime.now();

    final difference = today.difference(dateFormatted).inDays;
    print (date);
    print("Difference é "+difference.toString());

    if(difference>=0){
      return false;  //data informada é maior do que hoje
    } else {
      return true; //data informada é menor do que hoje
    }


  }

}