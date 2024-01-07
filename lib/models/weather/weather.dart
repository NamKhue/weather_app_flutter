class Weather {
  final double temp;
  final double feelsLike;
  final double low;
  final double high;
  final String description;
  final String icon;
  final double lat;
  final double lon;

  Weather({
    required this.temp,
    required this.feelsLike,
    required this.low,
    required this.high,
    required this.description,
    required this.icon,
    required this.lat,
    required this.lon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temp: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      low: json['main']['temp_min'].toDouble(),
      high: json['main']['temp_max'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      lat: json['coord']['lat'].toDouble(),
      lon: json['coord']['lon'].toDouble(),
    );
  }
}
