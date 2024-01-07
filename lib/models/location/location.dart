import 'package:hive/hive.dart';

part 'location.g.dart';

@HiveType(typeId: 0, adapterName: 'LocationAdapter')
class LocationItem {
  @HiveField(0)
  final String city;
  @HiveField(1)
  final String state;
  @HiveField(2)
  final String country;
  @HiveField(3)
  String lat;
  @HiveField(4)
  String lon;

  // Location({
  //   required this.city,
  //   required this.state,
  //   required this.country,
  //   required this.lat,
  //   required this.lon,
  // });

  LocationItem({
    this.city = '',
    this.state = '',
    this.country = '',
    this.lat = '',
    this.lon = '',
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    String cityName = json['locality'].toString();
    String stateName = json['city'].toString();
    String countryName = json['countryName'].toString();
    String lat = json['latitude'].toString();
    String lon = json['longitude'].toString();

    return LocationItem(
      city: cityName,
      state: stateName,
      country: countryName,
      lat: lat,
      lon: lon,
    );
  }
}
