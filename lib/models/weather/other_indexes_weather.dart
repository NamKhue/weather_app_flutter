class OtherIndexesWeather {
  final String uv;
  final int humidity;
  final double wind;

  OtherIndexesWeather({
    required this.uv,
    required this.humidity,
    required this.wind,
  });

  factory OtherIndexesWeather.fromJson(Map<String, dynamic> json) {
    int uvIndex = json['current']['uv'].round();
    String temp = '';

    if (uvIndex <= 2) {
      temp = 'Low';
    } else if (uvIndex <= 5) {
      temp = 'Medium';
    } else if (uvIndex <= 7) {
      temp = 'High';
    } else if (uvIndex <= 10) {
      temp = 'Very high';
    } else {
      temp = 'Extreme';
    }

    return OtherIndexesWeather(
      uv: temp,
      humidity: json['current']['humidity'].round(),
      wind: json['current']['wind_kph'],
    );
  }
}
