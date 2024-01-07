import 'package:weather_app_test/models/weather/daily.dart';
import 'package:weather_app_test/models/weather/daily_together.dart';

class ForecastDaily {
  final List<DailyTogether> arrDaily;

  ForecastDaily({
    required this.arrDaily,
  });

  factory ForecastDaily.fromJson(Map<String, dynamic> json) {
    List<dynamic> data = json['forecast']['forecastday'];

    List<Daily> temp_daily = [];

    for (var index = 0; index < data.length; index++) {
      List itemData = data[index]['hour'];
      for (var item in itemData) {
        var day = Daily.fromJson(item);

        if (day.time == 12 || day.time == 23) {
          temp_daily.add(day);
        }
      }
    }

    List<DailyTogether> arrDaily = [];

    for (var i = 1; i < temp_daily.length; i += 2) {
      DailyTogether daily = DailyTogether(
        date: temp_daily[i].dt,
        humidity: (temp_daily[i - 1].humidity + temp_daily[i].humidity) / 2,
        dayTemp: temp_daily[i - 1].temp,
        nightTemp: temp_daily[i].temp,
        dayIcon: temp_daily[i - 1].icon,
        nightIcon: temp_daily[i].icon,
      );

      arrDaily.add(daily);
    }

    return ForecastDaily(
      arrDaily: arrDaily,
    );
  }
}
