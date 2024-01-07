import 'dart:async';
import 'dart:math';

import 'package:shimmer/shimmer.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:http/http.dart';
import 'package:weather_app_test/screens/manage_locations_page.dart';
import 'package:worldtime/worldtime.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../provider/dark_theme_provider.dart';
import 'package:weather_app_test/models/weather/forecast_daily.dart';
import 'package:weather_app_test/models/weather/forecast_hourly.dart';
import 'package:weather_app_test/models/weather/other_indexes_weather.dart';
import 'package:weather_app_test/models/weather/sun.dart';
import 'package:weather_app_test/models/weather/weather.dart';
import 'package:weather_app_test/models/location/location.dart';

import '../utils/extensions.dart';
import '../utils/clipper.dart';
import '../utils/getAPI.dart';
//================================================================================

//================================================================================
class HomePage extends StatefulWidget {
  //================================================================================
  // final List<LocationItem> locations;
  LocationItem selectedLocation;
  // final BuildContext context;

  // const HomePage(this.locations, this.context, {super.key});
  HomePage(this.selectedLocation, {super.key});
  // const HomePage({super.key});
  //================================================================================

  //================================================================================
  @override
  _HomePageState createState() =>
      // ignore: no_logic_in_create_state
      // _HomePageState(this.locations, this.context);
      // _HomePageState(this.selectedLocation);
      _HomePageState();
  //================================================================================
}

class _HomePageState extends State<HomePage> {
  //================================================================================
  // _HomePageState(List<LocationItem> locations, BuildContext context)
  //     : this.locations = locations,
  //       this.context = context,
  //       this.location = locations[0];
  // _HomePageState(LocationItem selectedLocation);
  // _HomePageState();
  //================================================================================

  //================================================================================
  // list of currently locations
  List<LocationItem> _currentlyLocationsList = [];

  // favorite location
  LocationItem _favLocation = LocationItem();
  //================================================================================

  //================================================================================
  // detect user's current location
  Position? position;
  //================================================================================

  //================================================================================
  // GLOBAL KEY
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  //     GlobalKey<RefreshIndicatorState>();
  //================================================================================

  //================================================================================
  // updating stuff
  bool isChangeSelectedLocation = false;
  bool loading = false;
  final int totalSec = 10;
  late int runningSec = totalSec;
  //================================================================================

  //================================================================================
  // add new location
  void addLocationToHive(LocationItem location) {
    Box currentlyLocationsBox = Hive.box('currently_locations');
    currentlyLocationsBox.add(location);
  }
  //================================================================================

  //================================================================================
  bool checkExistedInCurrentlyLocationsBox(LocationItem location) {
    final Box tempBox = Hive.box('currently_locations');

    for (int index = 0; index < tempBox.length; index++) {
      LocationItem tempLocation = tempBox.getAt(index);
      if (location.city == tempLocation.city) {
        return true;
      }
    }

    return false;
  }
  //================================================================================

  //================================================================================
  void dataFromHivebox() {
    final Box currentlyLocationsBox = Hive.box('currently_locations');
    final Box favLocationBox = Hive.box('fav_location');

    _currentlyLocationsList = [];

    // setup list of currently locations
    if (currentlyLocationsBox.isNotEmpty) {
      setState(() {
        for (var index = 0; index < currentlyLocationsBox.length; index++) {
          LocationItem temp = currentlyLocationsBox.getAt(index);

          _currentlyLocationsList.add(LocationItem(
            city: temp.city,
            state: temp.state,
            country: temp.country,
            lat: temp.lat,
            lon: temp.lon,
          ));
        }
      });
    } else {
      print('currently is empty');
    }

    // setup fav location
    if (favLocationBox.isNotEmpty) {
      setState(() {
        _favLocation = favLocationBox.getAt(0);
      });
    } else {
      print('fav is empty');
      //
      _favLocation = LocationItem();
    }
  }
  //================================================================================

  //================================================================================
  @override
  void dispose() {
    // Hive.close();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    dataFromHivebox();

    // Timer.periodic(const Duration(seconds: 1), (Timer timeFirstTimeLaunchApp) {
    //   // firstValueAfterLaunchingApp == '' &&
    //   if (widget.selectedLocation.country != '') {
    //     print('lan dau cua em');
    //     dataFromHivebox();
    //     timeFirstTimeLaunchApp.cancel();
    //   }
    // });
    // if (widget.selectedLocation.country != '') {
    //   print('rong');
    //   dataFromHivebox();
    // } else {
    //   print('co data');
    //   // neu ton tai thi goi hive box
    //   Future.delayed(const Duration(seconds: 10), () {
    //     dataFromHivebox();
    //   });
    // }
  }
  //================================================================================

  //================================================================================
  @override
  Widget build(BuildContext context) {
    //
    // dataFromHivebox();

    return Scaffold(
      key: _scaffoldKey,
      appBar: _appBarHomePage(),
      drawer: _drawerHomePage(context),
      body: SizedBox(
        width: 460,
        child: Stack(
          children: [
            ListView(
              children: <Widget>[
                //
                // Center(
                //   child: SwitchListTile(
                //     title: const Text('theme'),
                //     secondary: Icon(themeState.getDarkTheme
                //         ? Icons.dark_mode_outlined
                //         : Icons.light_mode_outlined),
                //     onChanged: (bool value) {
                //       themeState.setDarkTheme = value;
                //     },
                //     value: themeState.getDarkTheme,
                //   ),
                // ),

                //
                currentWeatherView(widget.selectedLocation),
                forcastViewsHourly(widget.selectedLocation),
                forcastViewsDaily(widget.selectedLocation),
                infoAboutSun(widget.selectedLocation),
                infoAboutOtherIndexes(widget.selectedLocation),
                pageFooter(),
                //
              ],
            ),
          ],
        ),
      ),
    );
  }

  //================================================================================
  AppBar _appBarHomePage() {
    return AppBar(
      // backgroundColor: Colors.transparent,
      backgroundColor: Colors.deepPurple[300],
      toolbarHeight: 78,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Container(
        margin: const EdgeInsets.only(right: 55),
        child: Center(
          child: Column(
            children: [
              Text(
                widget.selectedLocation.city,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "${widget.selectedLocation.country}  ${widget.selectedLocation.state}",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //================================================================================

  //================================================================================
  // DRAWER
  Drawer _drawerHomePage(BuildContext context) {
    return Drawer(
      width: 300,
      child: Container(
        color: Colors.deepPurple[300],
        child: Column(
          children: [
            //
            const SizedBox(height: 50),
            //
            // button 'Manage locations'
            GestureDetector(
              onTap: () {
                // Navigator.pushNamed(context, '/manage_locations');

                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return ManageLocationsPage(widget.selectedLocation);
                }));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 233, 132, 206),
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.only(
                    top: 12, bottom: 12, left: 40, right: 40),
                child: const Text(
                  'Manage locations',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            //
            const SizedBox(height: 15),
            //
            // // button 'Maps for AQI'
            // GestureDetector(
            //   onTap: () {
            //     Navigator.pushNamed(context, '/map');
            //   },
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: const Color.fromARGB(255, 233, 132, 206),
            //       borderRadius: BorderRadius.circular(40),
            //     ),
            //     padding: const EdgeInsets.only(
            //         top: 12, bottom: 12, left: 40, right: 40),
            //     child: const Text(
            //       'Open map',
            //       style: TextStyle(
            //         fontSize: 18,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            //
            const SizedBox(height: 15),
            //
            // dot line
            Container(
              margin: const EdgeInsets.only(left: 19),
              height: 10,
              width: MediaQuery.of(context).size.width,
              child: Flex(
                direction: Axis.horizontal,
                children: List.generate(
                  33,
                  (index) => const Text(
                    "- ",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            //
            // 2 lists
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
              child: Column(
                children: <Widget>[
                  //
                  // fav location
                  favLocationDrawer(),
                  //
                  Container(
                    margin: const EdgeInsets.only(left: 3, right: 0),
                    height: 44,
                    width: MediaQuery.of(context).size.width,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: List.generate(
                        33,
                        (index) => const Text(
                          "- ",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  //
                  // list of currently locations
                  _currentlyLocationsDrawer(),
                ],
              ),
              //   ],
              // ),
            ),
          ],
        ),
      ),
    );
  }

  Column favLocationDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            SizedBox(width: 15),
            Icon(
              Icons.star,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 5),
            Text(
              'Favorite location',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        //
        const SizedBox(height: 10),
        //
        _favLocation.country != ''
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 50,
                child: FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Weather _favWeather = snapshot.data;
                      if (_favWeather == null) {
                        return const Text("Error getting weather");
                      } else {
                        return GestureDetector(
                          onTap: () {
                            final Box currentlyLocationsBox =
                                Hive.box('currently_locations');
                            if (!checkExistedInCurrentlyLocationsBox(
                                _favLocation)) {
                              currentlyLocationsBox.add(_favLocation);
                            }

                            if (_favLocation.city !=
                                widget.selectedLocation.city) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) {
                                return HomePage(_favLocation);
                              }));
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (_favLocation.city)
                                        .toLowerCase()
                                        .capitalizeFirstOfEach,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 76,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      getWeatherIcon(_favWeather.icon, 40),
                                      Text(
                                        "${_favWeather.temp.toInt()}°",
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    } else {
                      return Shimmer.fromColors(
                        baseColor: Colors.green.shade300,
                        highlightColor: Colors.green.shade200,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 50,
                          child: null,
                        ),
                      );
                    }
                  },
                  future: getCurrentWeather(_favLocation),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(left: 15),
                child: const Text(
                  'Empty favorite location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
      ],
    );
  }

  Column _currentlyLocationsDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            SizedBox(width: 15),
            Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 5),
            Text(
              'Another locations',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        //
        const SizedBox(height: 10),
        //
        _currentlyLocationsList.isNotEmpty
            ? SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _currentlyLocationsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FutureBuilder(
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Weather _currentlyWeather = snapshot.data;
                            if (_currentlyWeather == null) {
                              return const Text("Error getting weather");
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  if (_currentlyLocationsList[index].city ==
                                      widget.selectedLocation.city) {
                                    Navigator.of(context).pop();
                                  } else {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (_) {
                                      return HomePage(
                                          _currentlyLocationsList[index]);
                                    }));
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 0,
                                    bottom: 0,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          (_currentlyLocationsList[index].city)
                                              .toLowerCase()
                                              .capitalizeFirstOfEach,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 76,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            getWeatherIcon(
                                                _currentlyWeather.icon, 40),
                                            Text(
                                              "${_currentlyWeather.temp.toInt()}°",
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          } else {
                            return Shimmer.fromColors(
                              baseColor: Colors.blue.shade300,
                              highlightColor: Colors.blue.shade200,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 0,
                                  bottom: 0,
                                ),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: null,
                              ),
                            );
                          }
                        },
                        future:
                            getCurrentWeather(_currentlyLocationsList[index]),
                      );
                    },
                  ),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(left: 15),
                child: const Text(
                  'Empty list of currently location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
      ],
    );
  }
  //================================================================================

  //================================================================================
  // view of current weather
  Widget currentWeatherView(LocationItem location) {
    Weather _weather;

    return FutureBuilder(
      future: getCurrentWeather(location),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _weather = snapshot.data;
          if (_weather == null) {
            return const Text("Error getting weather");
          } else {
            return Column(
              children: [
                currentWeatherBox(_weather),
              ],
            );
          }
        } else {
          return Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 228, 228, 228),
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.all(15),
              height: 180,
              decoration: const BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(10),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          );
        }
      },
    );
  }

  Widget currentWeatherBox(Weather _weather) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(15.0),
            margin: const EdgeInsets.all(15.0),
            height: 180,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ],
              // color: Color.fromARGB(255, 242, 182, 226),
              color: const Color.fromARGB(255, 241, 175, 223),
              // color: Color.fromARGB(255, 242, 162, 221),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
          ),
          ClipPath(
            clipper: Clipper(),
            child: Container(
              padding: const EdgeInsets.all(15.0),
              margin: const EdgeInsets.all(15.0),
              height: 180,
              decoration: const BoxDecoration(
                // color: Color.fromARGB(255, 242, 182, 226),
                color: Color.fromARGB(255, 173, 162, 242),
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
            margin:
                const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
            height: 190,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 5),
                // left
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          margin: const EdgeInsets.only(left: 0),
                          child: getWeatherIcon(_weather.icon, 90)),
                      Container(
                        margin: const EdgeInsets.all(5),
                        child: Text(
                          _weather.description.capitalizeFirstOfEach,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5.0),
                        child: Text(
                          "High: ${_weather.high.toInt()}°  Low: ${_weather.low.toInt()}°",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // right
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    const SizedBox(height: 6),
                    Text(
                      "${_weather.temp.toInt()}°",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 75,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Feels like ${_weather.feelsLike.toInt()}°",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  //================================================================================

  //================================================================================
  Widget topTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      // fontSize: 18 * chartWidth / 500,
      fontSize: 18,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: const Text('10', style: style),
    );
  }

  // box contain info about weather pass by hours a day
  Widget hourlyBoxes(ForecastHourly _forecast) {
    // var _counter = 0;

    // List<FlSpot> spots = _forecast.hourly
    //     .map((item) => FlSpot((_counter++).toDouble(), item.temp))
    //     .toList();

    // return Container(
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     // color: Colors.grey[400],
    //     borderRadius: const BorderRadius.all(Radius.circular(18)),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.grey.withOpacity(0.2),
    //         spreadRadius: 2,
    //         blurRadius: 4,
    //         offset: const Offset(0, 1), // changes position of shadow
    //       )
    //     ],
    //   ),
    //   height: 200,
    //   margin: const EdgeInsets.symmetric(horizontal: 15),
    //   padding: const EdgeInsets.only(left: 10, right: 10),
    //   child: SingleChildScrollView(
    //     child: Column(
    //       children: [
    //         Container(
    //           height: 150.0,
    //           child: ListView.builder(
    //             padding: const EdgeInsets.only(
    //                 left: 0, top: 10, bottom: 10, right: 0),
    //             scrollDirection: Axis.horizontal,
    //             itemCount: _forecast.hourly.length,
    //             itemBuilder: (BuildContext context, int index) {
    //               return Container(
    //                 // width: 50,
    //                 // padding: const EdgeInsets.only(
    //                 // left: 10, top: 15, bottom: 15, right: 10),
    //                 margin: const EdgeInsets.only(top: 10, bottom: 10),
    //                 decoration: BoxDecoration(
    //                   color: Colors.white,
    //                   borderRadius: const BorderRadius.all(Radius.circular(18)),
    //                   boxShadow: [
    //                     BoxShadow(
    //                       color: Colors.grey.withOpacity(0.1),
    //                       spreadRadius: 2,
    //                       blurRadius: 2,
    //                       offset:
    //                           const Offset(0, 1), // changes position of shadow
    //                     )
    //                   ],
    //                 ),
    //                 child: Column(
    //                   children: [
    //                     Text(
    //                       "${(_forecast.hourly[index].temp).round()}°",
    //                       style: const TextStyle(
    //                           fontWeight: FontWeight.w500,
    //                           fontSize: 17,
    //                           color: Colors.black),
    //                     ),
    //                     Image.network(
    //                       'http:' + _forecast.hourly[index].icon,
    //                     ),
    //                     Text(
    //                       "${_forecast.hourly[index].current_hour}:00",
    //                       style: TextStyle(
    //                         fontWeight: FontWeight.w700,
    //                         fontSize: 13,
    //                         color: Colors.grey[500],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               );
    //             },
    //           ),
    //         ),
    //         //
    //         //
    //         SingleChildScrollView(
    //           scrollDirection: Axis.horizontal,
    //           child: Container(
    //             margin: const EdgeInsets.symmetric(horizontal: 30),
    //             // padding: const EdgeInsets.only(left: 10, right: 10),
    //             height: 50,
    //             width: 600,
    //             child: LineChart(
    //               LineChartData(
    //                 titlesData: FlTitlesData(
    //                   show: true,
    //                   bottomTitles: const AxisTitles(
    //                     sideTitles: SideTitles(showTitles: false),
    //                   ),
    //                   leftTitles: const AxisTitles(
    //                     sideTitles: SideTitles(showTitles: false),
    //                   ),
    //                   topTitles: AxisTitles(
    //                     sideTitles: SideTitles(
    //                       showTitles: true,
    //                       interval: 1,
    //                       getTitlesWidget: (value, meta) {
    //                         return topTitleWidgets(
    //                           value,
    //                           meta,
    //                         );
    //                       },
    //                       reservedSize: 30,
    //                     ),
    //                   ),
    //                   rightTitles: const AxisTitles(
    //                     sideTitles: SideTitles(showTitles: false),
    //                   ),
    //                 ),
    //                 borderData: FlBorderData(show: false),
    //                 gridData: const FlGridData(show: false),
    //                 lineBarsData: [
    //                   LineChartBarData(
    //                     color: Colors.grey[600],
    //                     spots: spots,
    //                     isCurved: true,
    //                     dotData: const FlDotData(show: true),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    return Container(
      height: 160,
      padding: const EdgeInsets.only(left: 10, top: 0, bottom: 0, right: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _forecast.hourly.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 83,
            padding:
                const EdgeInsets.only(left: 10, top: 15, bottom: 15, right: 10),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "${_forecast.hourly[index].current_hour}:00",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Image.network(
                  // ignore: prefer_interpolation_to_compose_strings
                  'http:' + _forecast.hourly[index].icon,
                ),
                const SizedBox(height: 6),
                Text(
                  "${(_forecast.hourly[index].temp).round()}°",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // weather pass by hours a day
  Widget forcastViewsHourly(LocationItem location) {
    // Forecast _forecast;
    ForecastHourly _forecast;

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _forecast = snapshot.data;
          if (_forecast == null) {
            return const Text("Error getting weather");
          } else {
            return hourlyBoxes(_forecast);
          }
        } else {
          return Container(
            height: 160,
            padding:
                const EdgeInsets.only(left: 10, top: 0, bottom: 0, right: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return Shimmer.fromColors(
                    baseColor: const Color.fromARGB(255, 228, 228, 228),
                    // baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 83,
                      padding: const EdgeInsets.only(
                          left: 10, top: 15, bottom: 15, right: 10),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(18)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: null,
                    ));
              },
            ),
          );
        }
      },
      future: getForecastHourly(location, 2),
    );
  }
  //================================================================================

  //================================================================================
  // box contain info about weather pass by days
  Widget dailyBoxes(var _listForecastData) {
    // Widget dailyBoxes(ForecastDaily _forecast) {

    final random = Random();
    var minTemp, maxTemp;

    if (_listForecastData[1] != "null") {
      var maxMin = _listForecastData[1].split(' ');

      minTemp = double.parse(maxMin[0]).round();
      maxTemp = double.parse(maxMin[1]).round();

      if ((_listForecastData[0].arrDaily[0].nightTemp).round() - minTemp > 4) {
        minTemp = (_listForecastData[0].arrDaily[0].nightTemp).round() -
            random.nextInt(4);
      }
      if (minTemp - (_listForecastData[0].arrDaily[0].nightTemp).round() > 4) {
        minTemp = (_listForecastData[0].arrDaily[0].nightTemp).round() +
            random.nextInt(4);
      }

      if ((_listForecastData[0].arrDaily[0].dayTemp).round() - maxTemp > 4) {
        maxTemp = (_listForecastData[0].arrDaily[0].dayTemp).round() -
            random.nextInt(4);
      }
      if (maxTemp - (_listForecastData[0].arrDaily[0].dayTemp).round() > 4) {
        maxTemp = (_listForecastData[0].arrDaily[0].dayTemp).round() +
            random.nextInt(4);
      }
    } else {
      minTemp = (_listForecastData[0].arrDaily[0].nightTemp).round() +
          random.nextInt(2);
      maxTemp = (_listForecastData[0].arrDaily[0].dayTemp).round() +
          random.nextInt(2);
    }

    return Container(
      height: 190,
      padding: const EdgeInsets.only(top: 10, bottom: 0, right: 25, left: 25),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Yesterday',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$maxTemp° / $minTemp°",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: _listForecastData[0].arrDaily.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.only(top: 5),
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // =======================
                          Expanded(
                            flex: 2,
                            child: Text(
                              getDateFromTimestamp(
                                  _listForecastData[0].arrDaily[index].date),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          //
                          SizedBox(
                            width: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("💧"),
                                      Text(
                                        "${(_listForecastData[0].arrDaily[index].humidity).round()}%",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      "http:${_listForecastData[0].arrDaily[index].dayIcon}",
                                      width: 30,
                                      height: 30,
                                    ),
                                    const SizedBox(width: 2),
                                    Image.network(
                                      "http:${_listForecastData[0].arrDaily[index].nightIcon}",
                                      width: 30,
                                      height: 30,
                                    ),
                                  ],
                                ),
                                //
                                Text(
                                  "${(_listForecastData[0].arrDaily[index].dayTemp).round()}° / ${(_listForecastData[0].arrDaily[index].nightTemp).round()}°",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // =======================
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // weather pass by days
  Widget forcastViewsDaily(LocationItem location) {
    ForecastDaily _forecast;

    // print(widget.selectedLocation.city);

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var listForecastData = snapshot.data;
          // var _forecast = snapshot.data;
          if (listForecastData == null) {
            // if (_forecast == null) {
            return const Text("Error getting weather");
          } else {
            return dailyBoxes(listForecastData);
            // return dailyBoxes(_forecast);
          }
        } else {
          return Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 228, 228, 228),
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 170,
              padding: const EdgeInsets.only(
                  top: 10, bottom: 0, right: 10, left: 25),
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: null,
            ),
          );
        }
      },
      future:
          // getForecastDaily(location, 3),
          Future.wait(
              [getForecastDaily(location, 3), getYesterdayInfo(location)]),
    );
  }
  //================================================================================

  //================================================================================
  // info about sunrise & sunset
  Widget infoAboutSun(LocationItem location) {
    Sun sunInfo;

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          sunInfo = snapshot.data;
          if (sunInfo == null) {
            return const Text("Error getting weather");
          } else {
            return sunInfoBox(sunInfo);
          }
        } else {
          // return const Center(child: CircularProgressIndicator());
          return Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 228, 228, 228),
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 190,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(left: 15, right: 15, top: 0),
              decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: null,
            ),
          );
        }
      },
      future: getSunInfo(location),
    );
  }

  // sunrise & sunset box
  Widget sunInfoBox(Sun sunInfo) {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(left: 15, right: 15, top: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Sunrise',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sunInfo.sunrise,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //
                  const Image(
                    image: AssetImage('assets/icons/sunrise1.gif'),
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
              //
              const SizedBox(width: 50),
              //
              Column(
                children: [
                  Text(
                    'Sunset',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sunInfo.sunset,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //
                  const Image(
                    image: AssetImage('assets/icons/sunset12.gif'),
                    width: 100,
                    height: 100,
                  ),
                  //
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  //================================================================================

  //================================================================================
  // info about other indexes
  Widget infoAboutOtherIndexes(LocationItem location) {
    OtherIndexesWeather info;

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          info = snapshot.data;
          if (info == null) {
            return const Text("Error getting weather");
          } else {
            return otherIndexesBox(info);
          }
        } else {
          // return const Center(child: CircularProgressIndicator());
          return Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 228, 228, 228),
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 130,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: null,
            ),
          );
        }
      },
      future: getOtherIndexesWeather(location),
    );
  }

  // other indexes box
  Widget otherIndexesBox(OtherIndexesWeather info) {
    return Container(
      height: 120,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // index UV
          Column(
            children: [
              const SizedBox(height: 10),
              // icon
              Image.asset(
                'assets/icons/index_sun1.png',
                width: 41,
                height: 41,
              ),
              //
              const SizedBox(height: 10),
              // title - name
              const Text(
                'UV',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // description
              Text(
                info.uv,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          //
          VerticalDivider(
            width: 2,
            thickness: 1,
            indent: 5,
            endIndent: 5,
            color: Colors.grey[400],
          ),
          // index humidity
          Column(
            children: [
              const SizedBox(height: 10),
              // icon
              Image.asset(
                'assets/icons/index_humidity 2.png',
                width: 40,
                height: 40,
              ),
              //
              const SizedBox(height: 10),
              // title - name
              const Text(
                'Humidity',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // description
              Text(
                '${info.humidity}%',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          //
          VerticalDivider(
            width: 2,
            thickness: 1,
            indent: 5,
            endIndent: 5,
            color: Colors.grey[400],
          ),
          //
          // index wind
          Column(
            children: [
              const SizedBox(height: 10),
              // icon
              Image.asset(
                'assets/icons/index_wind 2.png',
                width: 40,
                height: 40,
              ),
              //
              const SizedBox(height: 10),
              // title - name
              const Text(
                'Wind',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // description
              Text(
                '${(info.wind).round()} km/h',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  //================================================================================

  //================================================================================
  // check time if real time pass 60 -> need to change hour (hour -= 1)
  String timeForFooter(DateTime now, int delay) {
    String result = '';
    int hour = now.hour;
    int minute = now.minute;
    int day = now.day;
    int month = now.month;

    if (minute < delay) {
      hour -= 1;
      minute = 60 + (minute - delay);
    } else {
      minute -= delay;
    }

    String hourString = '';
    String minuteString = '';
    String dayString = '';
    String monthString = '';

    if (minute < 10) {
      minuteString = '0$minute';
    } else {
      minuteString = minute.toString();
    }

    if (hour < 10) {
      hourString = '0$hour';
    } else {
      hourString = hour.toString();
    }

    if (day < 10) {
      dayString = '0$day';
    } else {
      dayString = day.toString();
    }

    if (month < 10) {
      monthString = '0$month';
    } else {
      monthString = month.toString();
    }

    result = '$hourString:$minuteString $dayString/$monthString';

    return result;
  }

  // the time when successfully updating data
  Widget pageFooter() {
    DateTime now = DateTime.now();
    Random random = Random();
    int delayRandom = random.nextInt(15) + 5;

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${timeForFooter(now, delayRandom)} Đã cập nhật',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
  //================================================================================
}
