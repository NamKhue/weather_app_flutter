class Hourly {
  final int dt;
  final double temp;
  final String icon;
  final int current_hour;

  Hourly({
    required this.dt,
    required this.temp,
    required this.icon,
    required this.current_hour,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) {
    String tempCurrentHour = json['time'].toString();
    tempCurrentHour = tempCurrentHour.substring(
        tempCurrentHour.length - 5, tempCurrentHour.length - 3);
    int currentHourResult = int.parse(tempCurrentHour);

    return Hourly(
      dt: json['time_epoch'].toInt(),
      temp: json['temp_c'].toDouble(),
      icon: json['condition']['icon'],
      current_hour: currentHourResult,
    );
  }
}
