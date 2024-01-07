import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_app_test/screens/homepage.dart';

import '../models/location/location.dart';
import '../utils/extensions.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  //================================================================================
  List<LocationItem> _list = [];
  //================================================================================

  //================================================================================
  TextEditingController searchController = TextEditingController();
  List<LocationItem> _searchResult = [];
  bool _isClickForSearching = false;
  //================================================================================

  //================================================================================
  // load data of locations via local json file
  void loadData(List<LocationItem> list) async {
    // load list contains all cities, states, countries
    await readJsonFile('assets/database/cities.json', list);
  }
  //================================================================================

  //================================================================================
  // open hive
  // hive box
  final Box currentlyLocationsBox = Hive.box('currently_locations');
  //================================================================================

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // load list city json
    // if (_list == null) {
    loadData(_list);
    // }
  }

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
        title: Container(
          padding: const EdgeInsets.only(left: 20),
          height: 55,
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 135, 99, 198),
          ),
          child: Row(
            children: [
              //
              Flexible(
                child: TextField(
                  onTap: () {
                    setState(() {
                      _isClickForSearching = true;
                    });
                  },
                  controller: searchController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    decoration: TextDecoration.none,
                  ),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Search city or country',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onChanged: searchingText,
                ),
              ),
              //
              searchController.text.isNotEmpty
                  ? _isClickForSearching
                      ? Container(
                          margin: const EdgeInsets.only(right: 5),
                          // decoration: BoxDecoration(
                          //     border: Border.all(color: Colors.black)),
                          // width: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, size: 30),
                                onPressed: () {
                                  setState(() {
                                    _isClickForSearching = false;
                                  });
                                  searchController.clear();
                                  searchingText('');
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ],
                          ),
                        )
                      : const Text('')
                  : const Text(''),
            ],
          ),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ListView(children: [
          searchController.text.isNotEmpty
              ? searchResultView()
              : const Text(''),
        ]),
      ),
    );
  }

  //================================================================================
  // results of searching view
  searchingText(String text) async {
    _searchResult.clear();
    //
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    //
    text = text.toLowerCase();
    //
    _searchResult = _list
        .where((LocationItem item) =>
            ("${item.city}, ${item.state}, ${item.country}")
                .toLowerCase()
                .startsWith(text.toLowerCase()))
        .toList();

    if (_searchResult.isEmpty) {
      _searchResult = _list
          .where((LocationItem item) =>
              ("${item.city}, ${item.state}, ${item.country}")
                  .toLowerCase()
                  .contains(text.toLowerCase()))
          .toList();
    }
    //
    setState(() {});
  }

  Widget searchBar() {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50),
      margin: const EdgeInsets.only(top: 20),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: const Icon(Icons.search),
          title: TextField(
            onTap: () {
              setState(() {
                _isClickForSearching = true;
              });
            },
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search city or country',
              border: InputBorder.none,
            ),
            onChanged: searchingText,
          ),
          trailing: searchController.text.isNotEmpty
              ? _isClickForSearching
                  ? IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        setState(() {
                          _isClickForSearching = false;
                        });
                        searchController.clear();
                        searchingText('');
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : const Text('')
              : const Text(''),
        ),
      ),
    );
  }

  Widget searchResultView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      // ? (_searchResult.length * 55).toDouble()
      // ? (_searchResult.length * 105).toDouble()
      height: _searchResult.length < 6
          ? _searchResult.length < 4
              ? (_searchResult.length * 70).toDouble()
              : (_searchResult.length * 50).toDouble()
          : 300,
      margin: const EdgeInsets.only(left: 25, right: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 20,
          ),
        ],
      ),
      child: searchController.text.isNotEmpty
          ? _isClickForSearching
              ? ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _searchResult.length,
                  itemBuilder: (BuildContext context, int index) {
                    final LocationItem item = _searchResult.elementAt(index);
                    return InkWell(
                      hoverColor: Colors.grey[400],
                      child: GestureDetector(
                        onTap: () {
                          // return to homepage after choosing location
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(builder: (_) {
                            return HomePage(item);
                          }));

                          // then add that location to list of currently locations via Hive box
                          currentlyLocationsBox.add(item);
                        },
                        child: ListTile(
                          minLeadingWidth: 20,
                          leading: Transform.translate(
                              offset: const Offset(-7, 0),
                              child: const Icon(Icons.search,
                                  color: Colors.black)),
                          title: Transform.translate(
                              offset: const Offset(-5, 0),
                              child: Text(
                                "${item.city}, ${item.state}, ${item.country}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              )),
                        ),
                      ),
                    );
                  },
                )
              : const Text('')
          : const Text(''),
    );
  }
  //================================================================================
}
