import 'dart:convert';
import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app_test/screens/map_page.dart';

import 'consts/theme_data.dart';
import 'models/location/location.dart';
import 'provider/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/homepage.dart';
import 'screens/manage_locations_page.dart';
import 'screens/search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes Hive with a valid directory in your app files
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  // Register Hive Adapter
  Hive.registerAdapter(LocationAdapter());

  // open box
  await Hive.openBox("currently_locations");
  await Hive.openBox("fav_location");

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //================================================================================
  LocationItem _selectedLocation = LocationItem();

  // detect user's current location
  Position? position;
  //================================================================================

  //================================================================================
  // Dark Theme
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePreferences.getTheme();
  }
  //================================================================================

  //================================================================================
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // Future<LocationItem> _getAddressBasedOnCoordinates(
  //     double lat, double lon) async {
  //   //
  //   // print('run here');
  //   List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
  //   // print('here 1');
  //   Placemark place = placemarks[0];
  //   // print('here 2');
  //   print(place.locality.toString());
  //   print(place.subLocality.toString());
  //   print(place.country.toString());
  //   return LocationItem(
  //     city: '',
  //     state: place.locality.toString(),
  //     country: place.country.toString(),
  //     lat: lat.toString(),
  //     lon: lon.toString(),
  //   );
  // }

  void getAddressOfUserByLatLon(double latitude, double longitude) async {
    print('getting address via api based on latitude and longitude');
    //
    // LocationItem newLocation =
    //     await _getAddressBasedOnCoordinates(latitude, longitude);
    //
    String urlAPI =
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${latitude}&longitude=${longitude}&localityLanguage=en';

    final response = await http.get(Uri.parse(urlAPI));

    // LocationItem newLocation;

    if (response.statusCode == 200) {
      LocationItem newLocation =
          LocationItem.fromJson(jsonDecode(response.body));

      _changeLocation(newLocation);
      addNewLocationToCurrentlyLocationsBox(newLocation);
    } else if (response.statusCode == 401) {
      print(response.body);
    } else {
      print(response.body);
    }

    print('done address');
  }

  // automatically change the location when user choose new location
  void _changeLocation(LocationItem newLocation) {
    setState(() {
      _selectedLocation = newLocation;
    });
  }

  void getLocationOfUser() async {
    // print('get coordinates');

    position = await _determinePosition();
    getAddressOfUserByLatLon(position!.latitude, position!.longitude);

    // final _worldtimePlugin = Worldtime();
    // const String myFormatter = '\\h';
    // final DateTime current_time_of_user_location =
    //     await _worldtimePlugin.timeByLocation(
    //         latitude: position!.latitude, longitude: position!.longitude);
    // final String result_current_time = _worldtimePlugin.format(
    //   dateTime: current_time_of_user_location,
    //   formatter: myFormatter,
    // );
    // print(result_current_time);
    // if (int.parse(result_current_time) >= 18) {
    //   setState(() {
    //     // themeState.setDarkTheme = themState.getDarkTheme;
    //   });
    // }

    // print('done coordinates');
  }

  // save that location to list of currently locations
  void addNewLocationToCurrentlyLocationsBox(LocationItem location) {
    //
    final Box currentlyLocationsBox = Hive.box('currently_locations');

    // print(currentlyLocationsBox.length);

    // if (currentlyLocationsBox.isNotEmpty) {
    //   var total = currentlyLocationsBox.length;

    //   for (var index = 0; index < total; index++) {
    //     currentlyLocationsBox.deleteAt(0);
    //   }
    // }

    // print(currentlyLocationsBox.length);

    // check if hive is empty
    if (currentlyLocationsBox.isEmpty) {
      currentlyLocationsBox.add(location);
    }

    // check if not exist before then add to hive
    if (!checkExistedInCurrentlyLocationsBox(location)) {
      currentlyLocationsBox.add(location);
    }

    // print(currentlyLocationsBox.length);
  }
  //================================================================================

  //================================================================================
  // check Existed before In Currently Locations Box
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
  @override
  void initState() {
    super.initState();

    // getCurrentAppTheme();

    // // get value according to user's current location
    // getLocationOfUser();

    // get value from HIVE BOX
    // or
    // get value according to user's current location
    // ADVANCED
    print('getting data from HiveBox');
    final Box currentlyLocationsBox = Hive.box('currently_locations');

    // if current location box has data
    if (currentlyLocationsBox.isNotEmpty) {
      setState(() {
        // pick random in current location box to display
        Random random = Random();
        int randomNumber = random.nextInt(currentlyLocationsBox.length);
        _selectedLocation = currentlyLocationsBox.getAt(randomNumber);
      });
    } else {
      // if current location box is empty
      //
      print('currently box empty');
      //
      // fetching value of user's current location
      getLocationOfUser();
    }

    // MORE
    // // ask user for fetching value of user's current location
    // // if user accept, then fetch
    // getLocationOfUser();
    // // if not accept, then
    // // check hive
    // // check if exist list of currently locations, pick random one of them
    // // if not exist any, ask user for fetching again
  }
  //================================================================================

  //================================================================================
  @override
  Widget build(BuildContext context) {
    return
        // MultiProvider(
        //   providers: [
        //     ChangeNotifierProvider(create: (_) {
        //       return themeChangeProvider;
        //     })
        //   ],
        //   child:
        //   Consumer<DarkThemeProvider>(
        // builder: (context, themeData, child) {
        //   return
        MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(245, 255, 255, 255),
      ),
      // theme: Styles.themeData(themeChangeProvider.getDarkTheme, context),
      home: HomePage(_selectedLocation),
      routes: {
        '/homepage': (context) => HomePage(_selectedLocation),
        '/manage_locations': (context) =>
            ManageLocationsPage(_selectedLocation),
        '/search': (context) => const SearchPage(),
        '/map': (context) => const MapPage(),
      },
    );
    // },
    // ),
    // );
  }
}
