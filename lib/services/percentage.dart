class Percentage{
  double calculate({double num, double percent}) {
    double percentage = percent / 100;
    return num * percentage;
  }

  double percent({double hundredPercent, double toParse}){
    double percent = toParse / hundredPercent;
    return percent * 100;
  }
}