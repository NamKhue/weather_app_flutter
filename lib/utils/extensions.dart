import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/location/location.dart';

// =======================================================================
extension StringExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstOfEach =>
      this.split(" ").map((str) => str.inCaps).join(" ");
}
// =======================================================================

// =======================================================================
// get icon of weather (for weather details box)
Image getWeatherIcon(String _icon, double size) {
  String path = 'assets/icons/';
  String imageExtension = ".png";
  return Image.asset(
    path + _icon + imageExtension,
    width: size,
    height: size,
  );
}

// convert to date
String getDateFromTimestamp(int timestamp) {
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat('EEEE').format(date);
}

// // convert int to time (hh:mm)
// String getTimeFromTimestamp(int timestamp) {
//   var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//   var formatter = new DateFormat('h:mm a');
//   return formatter.format(date);
// }
// =======================================================================

// =======================================================================
// get list of locations contains (city, state, country, lat, lon)
// by reading local json file
Future<void> readJsonFile(
    String filePath, List<LocationItem> listLocations) async {
  // var input = await File(filePath).readAsString();
  var input = await rootBundle.loadString(filePath);
  var json = jsonDecode(input);

  for (var item in json['data']) {
    LocationItem newLocation = LocationItem(
      city: item['name'],
      state: item['state_name'],
      country: item['country_name'],
      lat: item['latitude'],
      lon: item['longitude'],
    );
    listLocations.add(newLocation);
  }
}

// get list of locations contains (city, state, country, lat, lon)
// by reading local json file
Future<List<LocationItem>> readJsonForMapPage(String filePath) async {
  var input = await rootBundle.loadString(filePath);
  var json = jsonDecode(input);

  List<LocationItem> listLocations = [];

  for (var item in json) {
    LocationItem newLocation = LocationItem(
      city: item['city'],
      state: item['admin_name'],
      country: item['country'],
      lat: item['lat'],
      lon: item['lng'],
    );
    listLocations.add(newLocation);
  }

  return listLocations;
}
// =======================================================================

// =======================================================================
// get location where user is living

// get time in that place for checking to get data properly

// =======================================================================

// =======================================================================
// 
// =======================================================================
