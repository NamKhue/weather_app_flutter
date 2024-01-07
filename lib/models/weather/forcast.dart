import 'package:weather_app_test/models/weather/daily.dart';
import 'package:weather_app_test/models/weather/hourly.dart';

class Forecast {
  final List<Hourly> hourly;
  final List<Daily> daily;

  Forecast({
    required this.hourly,
    required this.daily,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    List<dynamic> hourlyData = json['hourly'];
    List<dynamic> dailyData = json['daily'];

    List<Hourly> hourly = [];
    List<Daily> daily = [];

    hourlyData.forEach((item) {
      var hour = Hourly.fromJson(item);
      hourly.add(hour);
    });

    dailyData.forEach((item) {
      var day = Daily.fromJson(item);
      daily.add(day);
    });

    return Forecast(hourly: hourly, daily: daily);
  }
}
