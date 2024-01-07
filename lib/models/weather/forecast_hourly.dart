import 'package:weather_app_test/models/weather/hourly.dart';

class ForecastHourly {
  final List hourly;

  ForecastHourly({
    required this.hourly,
  });

  factory ForecastHourly.fromJson(Map<String, dynamic> json) {
    String dateData = json['location']['localtime'];
    int currentHour = 1 +
        int.parse(dateData.substring(dateData.length - 5, dateData.length - 3));

    List<dynamic> data_of_current_day =
        json['forecast']['forecastday'][0]['hour'];

    List<Hourly> arrHourly = [];

    if (currentHour < 12) {
      for (var index = 0; index <= 12; index++) {
        var hour = Hourly.fromJson(data_of_current_day[currentHour + index]);
        arrHourly.add(hour);
      }
    } else if (currentHour >= 12) {
      for (var index = currentHour; index <= 23; index++) {
        var hour = Hourly.fromJson(data_of_current_day[index]);
        arrHourly.add(hour);
      }

      List<dynamic> data_of_the_next_day =
          json['forecast']['forecastday'][1]['hour'];

      for (var index = 0; index < (12 - (24 - (currentHour + 1))); index++) {
        var hour = Hourly.fromJson(data_of_the_next_day[index]);
        arrHourly.add(hour);
      }
    }

    return ForecastHourly(
      hourly: arrHourly,
    );
  }
}
