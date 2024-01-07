class Sun {
  final String sunrise;
  final String sunset;

  Sun({
    required this.sunrise,
    required this.sunset,
  });

  factory Sun.fromJson(Map<String, dynamic> json) {
    String stringSunrise = json['results']['sunrise'].toString();
    String stringSunset = json['results']['sunset'].toString();

    String sunrise = '', sunset = '';

    if (stringSunrise.substring(0, 2).contains(":")) {
      sunrise = '0${stringSunrise.substring(0, 4)}';
    } else {
      sunrise = stringSunrise.substring(0, 5);
    }

    if (stringSunset.substring(0, 2).contains(":")) {
      sunset = '0${stringSunset.substring(0, 4)}';
    } else {
      sunset = stringSunset.substring(0, 5);
    }

    return Sun(
      sunrise: sunrise,
      sunset: sunset,
    );
  }
}
