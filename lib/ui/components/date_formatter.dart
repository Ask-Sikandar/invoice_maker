

class DateFormatter{
  static String dateFormat(DateTime t){
    return "${t.year.toString()}/${t.month.toString()}/${t.day.toString()}";
  }
}