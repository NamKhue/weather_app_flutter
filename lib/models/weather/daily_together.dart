class DailyTogether {
  final int date;
  final double humidity;
  final String dayIcon;
  final String nightIcon;
  final double dayTemp;
  final double nightTemp;

  DailyTogether({
    required this.date,
    required this.humidity,
    required this.dayTemp,
    required this.nightTemp,
    required this.dayIcon,
    required this.nightIcon,
  });
}
