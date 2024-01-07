import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

import '../models/location/location.dart';
import '../utils/extensions.dart';
import '../utils/getAPI.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //================================================================================
  // List<LocationItem> _list = [];
  // List<WeightedLatLng> data = [];
  // MapController map_controller = MapController();
  //================================================================================

  //================================================================================
  // load data of locations via local json file
  void _loadData(List<LocationItem> list) async {
    // load list contains all cities, states, countries
    list = await readJsonForMapPage('assets/database/vietnam_db.json');

    print(list[0].city);
  }
  //================================================================================

  void getAQIIndex(double lat, double lon, int aqiIndex) async {
    aqiIndex = await getAQIData(lat, lon);
  }

  Widget loadMap() {
    return FutureBuilder(
      future: readJsonForMapPage('assets/database/vietnam_db.json'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<LocationItem> _list = snapshot.data!;
          List<Marker> markers = [];

          for (int index = 0; index < _list.length; index++) {
            //
            int aqiIndex = 0;
            getAQIIndex(
              double.parse(_list[index].lat),
              double.parse(_list[index].lon),
              aqiIndex,
            );

            markers.add(
              Marker(
                alignment: Alignment.topCenter,
                width: 110,
                height: 80,
                point: LatLng(double.parse(_list[index].lat),
                    double.parse(_list[index].lon)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'AQI: 54',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
            );
          }

          return FlutterMap(
            // mapController: map_controller,
            options: MapOptions(
              minZoom: 13,
              initialCenter: LatLng(
                double.parse(_list[0].lat),
                double.parse(_list[0].lon),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: markers),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  //================================================================================
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // load data
    // List<LocationItem> list = [];
    // _loadData(list);
  }
  //================================================================================

  //================================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 78,
        backgroundColor: Colors.deepPurple[300],
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Map'),
      ),
      body: loadMap(),
    );
  }
}
