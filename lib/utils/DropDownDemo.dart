// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:weather_app_test/models/location/location.dart';

// class DropDownDemo extends StatefulWidget {
//   @override
//   _DropDownDemoState createState() => _DropDownDemoState();
// }

// class _DropDownDemoState extends State<DropDownDemo> {
//   List<Location> _list = [];
//   Location _selectedMenuItem = Location();

//   // String selected = "hello";

//   Future<List<Location>> loadJsonFromAsset() async {
//     String data = await DefaultAssetBundle.of(context)
//         .loadString("assets/database/cities.json");
//     final decoded = json.decode(data);
//     try {
//       return (decoded != null)
//           ? decoded["data"]
//               .map<Location>((item) => Location(
//                     city: item['name'],
//                     state: item['state_name'],
//                     country: item['country_name'],
//                     lat: item['latitude'],
//                     lon: item['longitude'],
//                   ))
//               .toList()
//           : [];
//     } catch (e) {
//       debugPrint(e.toString());
//       return [];
//     }
//   }

//   Future initJson() async {
//     _list = await loadJsonFromAsset();

//     if (_list.length > 0) {
//       _selectedMenuItem = _list[0];
//     }
//   }

//   DropdownMenuItem<Location> buildDropdownMenuItem(Location item) {
//     return DropdownMenuItem(
//       value: item, // you must provide a value
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Text(item.city ?? ""),
//       ),
//     );
//   }

//   Widget buildDropdownButton() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: DropdownButton<Location>(
//           elevation: 1,
//           hint: const Text("Select one"),
//           isExpanded: true,
//           underline: Container(
//             height: 2,
//             color: Colors.black12,
//           ),
//           items: _list.map((item) => buildDropdownMenuItem(item)).toList(),
//           value: _selectedMenuItem, // values should match
//           onChanged: (Location? item) {
//             setState(() => _selectedMenuItem = item!);
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   void initState() {
//     initJson();

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return buildDropdownButton();
//     // Scaffold(
//     //   appBar: AppBar(),
//     //   body: buildDropdownButton(),
//     // );
//   }
// }
