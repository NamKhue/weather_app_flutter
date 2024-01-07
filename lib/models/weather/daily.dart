class Daily {
  final int dt;
  final int day;
  final int time;
  final double temp;
  final double humidity;
  final String icon;

  Daily({
    required this.dt,
    required this.day,
    required this.time,
    required this.temp,
    required this.humidity,
    required this.icon,
  });

  factory Daily.fromJson(Map<String, dynamic> json) {
    String stringDay = json['time'];
    String day =
        stringDay.substring(stringDay.length - 8, stringDay.length - 6);
    String timeOfDay =
        stringDay.substring(stringDay.length - 5, stringDay.length - 3);

    return Daily(
      dt: json['time_epoch'].toInt(),
      day: int.parse(day),
      time: int.parse(timeOfDay),
      temp: json['temp_c'].toDouble(),
      humidity: json['humidity'].toDouble(),
      icon: json['condition']['icon'],
    );
  }
}
