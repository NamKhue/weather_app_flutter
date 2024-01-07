import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/weather/forecast_daily.dart';
import '../models/weather/forecast_hourly.dart';
import '../models/weather/other_indexes_weather.dart';
import '../models/weather/sun.dart';
import '../models/weather/weather.dart';
import '../models/location/location.dart';

// =======================================================================
// get info current weather
Future getCurrentWeather(LocationItem location) async {
  Weather weather;

  String cityName = location.state.toLowerCase();

  String apiKey = "2ac087039f30cff26795b5c02865ed21";

  var url =
      "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    weather = Weather.fromJson(jsonDecode(response.body));

    return weather;
  } else if (response.statusCode == 401) {
    print(response.body);
  } else {
    // print(response.body);

    String countryName = location.country.toLowerCase();
    countryName.split(' ').join();

    var newUrl =
        "https://api.openweathermap.org/data/2.5/weather?q=$countryName&appid=$apiKey&units=metric";

    final newResponse = await http.get(Uri.parse(newUrl));

    if (newResponse.statusCode == 200) {
      weather = Weather.fromJson(jsonDecode(newResponse.body));

      return weather;
    } else if (newResponse.statusCode == 401) {
      print(newResponse.body);
    } else {
      print(newResponse.body);
    }
  }
}

// get info of weather pass by hour a day
Future getForecastHourly(LocationItem location, int numberOfDays) async {
  String apiKey = "c3073c0b51f4492f8b573952231908";

  ForecastHourly forecast;

  String cityName = location.country;

  var url =
      "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$cityName&days=$numberOfDays&aqi=no&alerts=no";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    forecast = ForecastHourly.fromJson(jsonDecode(response.body));

    return forecast;
  } else if (response.statusCode == 401) {
    print(response.body);
  } else {
    print(response.body);
  }
}

// get info of weather pass by days
Future getYesterdayInfo(LocationItem location) async {
  String lat = location.lat;
  String lon = location.lon;

  // print(lat);
  // print(lon);

  DateTime now = DateTime.now();
  String currentDay = now.toString().split(' ')[0];

  var endDate = int.parse(currentDay.split('-')[2]);
  endDate -= 1;
  var startDate = (endDate - 1).toString();

  if (startDate.length == 1) {
    startDate = '0$startDate';
  }

  String yesterday =
      now.toString().split(' ')[0].substring(0, currentDay.length - 2) +
          startDate;

  var endDateStr = '';
  if (endDate < 10) {
    endDateStr = '0$endDate';
  } else {
    endDateStr = endDate.toString();
  }

  currentDay =
      '${currentDay.split('-')[0]}-${currentDay.split('-')[1]}-$endDateStr';

  var urlTimezone =
      "https://api.geotimezone.com/public/timezone?latitude=$lat&longitude=$lon";

  final responseTimezone = await http.get(Uri.parse(urlTimezone));

  if (responseTimezone.statusCode == 200) {
    var jsonTimezone = jsonDecode(responseTimezone.body);

    var timezoneString = jsonTimezone['iana_timezone'];

    var urlYesterdayInfo =
        "https://archive-api.open-meteo.com/v1/archive?latitude=${lat}&longitude=${lon}&start_date=${yesterday}&end_date=${currentDay}&hourly=temperature_2m&timezone=${timezoneString}";

    final responseUrlYesterdayInfo =
        await http.get(Uri.parse(urlYesterdayInfo));

    if (responseUrlYesterdayInfo.statusCode == 200) {
      var json = jsonDecode(responseUrlYesterdayInfo.body);

      List dayData = json['hourly']['temperature_2m'];
      List mainDayData = [];

      for (var ele in dayData) {
        if (ele != null) {
          mainDayData.add(ele);
        }
      }

      if (mainDayData.isNotEmpty) {
        double minEle = mainDayData[0];
        double maxEle = mainDayData[0];

        for (var ele in mainDayData) {
          if (minEle > ele) {
            minEle = ele;
          }
          if (maxEle < ele) {
            maxEle = ele;
          }
        }

        return "$minEle $maxEle";
      } else {
        return "null";
      }
    } else if (responseUrlYesterdayInfo.statusCode == 401) {
      print(responseUrlYesterdayInfo.body);
    } else {
      print(responseUrlYesterdayInfo.body);
    }
  } else {
    print(responseTimezone.body);
  }
}

// get info of weather pass by days
Future getForecastDaily(LocationItem location, int numberOfDays) async {
  String apiKey = "c3073c0b51f4492f8b573952231908";

  ForecastDaily forecast;

  String cityName = location.country;

  var url =
      "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$cityName&days=$numberOfDays&aqi=no&alerts=no";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    forecast = ForecastDaily.fromJson(jsonDecode(response.body));

    return forecast;
  } else if (response.statusCode == 401) {
    print(response.body);
  } else {
    print(response.body);
  }
}

// get info of sunrise & sunset
Future getSunInfo(LocationItem location) async {
  Sun sunInfo;

  String lat = location.lat;
  String lon = location.lon;

  var url = "https://api.sunrisesunset.io/json?lat=$lat&lng=$lon";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    sunInfo = Sun.fromJson(jsonDecode(response.body));

    return sunInfo;
  } else if (response.statusCode == 401) {
    print(response.body);
  } else {
    print(response.body);
  }
}

// get info about other indexes of weather today
Future getOtherIndexesWeather(LocationItem location) async {
  String apiKey = "c3073c0b51f4492f8b573952231908";

  OtherIndexesWeather forecast;

  String cityName = location.country;

  var url =
      "https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$cityName&alerts=no";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    forecast = OtherIndexesWeather.fromJson(jsonDecode(response.body));

    return forecast;
  } else if (response.statusCode == 401) {
    print(response.body);
  } else {
    print(response.body);
  }
}

// get AQI info
Future getAQIData(double lat, double lon) async {
  String apiKey = "34ab494b-fa7c-4155-8f55-c2472835fdb9";

  var url =
      'http://api.airvisual.com/v2/nearest_city?lat=${lat}&lon=${lon}&key=${apiKey}';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    int result =
        jsonDecode(response.body)['data']['current']['pollution']['aqius'];

    return result;
  } else if (response.statusCode == 401) {
    print(response.body);
  } else {
    print(response.body);
  }
}
// =======================================================================
