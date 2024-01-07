import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../models/location/location.dart';
import '../models/weather/weather.dart';
import '../utils/extensions.dart';
import '../utils/getAPI.dart';
import 'homepage.dart';

class ManageLocationsPage extends StatefulWidget {
  //================================================================================
  LocationItem recentlyLastLocation;

  ManageLocationsPage(this.recentlyLastLocation, {super.key});

  @override
  State<ManageLocationsPage> createState() => _ManageLocationsPageState();
}

class _ManageLocationsPageState extends State<ManageLocationsPage> {
  //================================================================================
  // LocationItem _favLocation = LocationItem();
  LocationItem _favLocation = LocationItem();

  List<LocationItem> _currentlyLocationsList = [];
  List<bool> _statusChoosingCurrentlyLocationsList = [];

  List<int> _listContainsIndexNeedToHandle = [];
  int indexNeedToHandle = -1;
  //================================================================================

  //================================================================================
  // appearance status
  bool _appearanceStatus = false;
  //
  // button choose all
  bool _choosingAll = false;
  //
  // button choose all
  bool _choosingFavLocation = false;
  //================================================================================

  //================================================================================
  // save that location to list of currently locations
  void addNewLocationToCurrentlyLocationsBox(LocationItem newLocation) {
    final Box currentlyLocationsBox = Hive.box('currently_locations');
    currentlyLocationsBox.add(newLocation);
  }
  //================================================================================

  //================================================================================
  // save that location to list of currently locations
  void deleteLocationToCurrentlyLocationsBox(int index) {
    final Box currentlyLocationsBox = Hive.box('currently_locations');
    currentlyLocationsBox.deleteAt(index);
  }
  //================================================================================

  //================================================================================
  // open hive
  // hive box
  final Box currentlyLocationsBox = Hive.box('currently_locations');
  final Box favLocationBox = Hive.box('fav_location');
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
  // snackbar for notifying that deleted successfully
  final snackBarForDeleting = SnackBar(
    content: const SizedBox(
        height: 25,
        child: Text('Successfully deleted!', style: TextStyle(fontSize: 18))),
    action: SnackBarAction(
      label: '',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  // snackbar for notifying that deleted successfully
  final snackBarForSettingFavLocation = SnackBar(
    content: const SizedBox(
        height: 25,
        child: Text('Successfully setting favorite location!',
            style: TextStyle(fontSize: 16))),
    action: SnackBarAction(
      label: '',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );
  //================================================================================

  //================================================================================
  void loadDataFromHivebox() {
    // setup fav location
    if (favLocationBox.isNotEmpty) {
      setState(() {
        _favLocation = favLocationBox.getAt(0);
      });
    } else {
      print('fav is empty');
      //
      _choosingFavLocation = true;
    }

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

    setState(() {
      //
      _statusChoosingCurrentlyLocationsList = List<bool>.filled(
          _currentlyLocationsList.length, false,
          growable: true);
      //
      _listContainsIndexNeedToHandle =
          List<int>.filled(_currentlyLocationsList.length, 0, growable: true);

      // print(currentlyLocationsBox.length);
      // print(_currentlyLocationsList.length);
      // print(_statusChoosingCurrentlyLocationsList.length);
      // print(_listContainsIndexNeedToHandle.length);
    });
  }
  //================================================================================

  //================================================================================
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadDataFromHivebox();
  }
  //================================================================================

  //================================================================================
  @override
  Widget build(BuildContext context) {
    //
    //================================================================================
    // check all items in _statusChoosingCurrentlyLocationsList are true
    isBelowThreshold(currentValue) => currentValue == true;

    // check there are more than ONE item in _listContainsIndexNeedToHandle  are -1
    isEqualTrue(currentValue) => currentValue == 1;
    //================================================================================
    //
    return Scaffold(
      appBar: _appBar(isBelowThreshold, context),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(children: [
          // main content
          favLocationAndCurrentlyLocationsList(context),
          // animate bottom bar
          setFavAndDeleteBar(context, isEqualTrue),
        ]),
      ),
      floatingActionButton: !_appearanceStatus
          ? FloatingActionButton(
              elevation: 6,
              backgroundColor: const Color.fromARGB(255, 115, 221, 120),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18))),
              // When the user taps the button
              onPressed: () {
                // return to homepage after choosing location
              },
              tooltip: 'Search more',
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
                icon: const Icon(
                  Icons.search,
                  size: 30,
                ),
              ),
            )
          : null,

      // bottomNavigationBar: _bottomAppBar(isEqualTrue),
    );
  }

  Container favLocationAndCurrentlyLocationsList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      // width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          //
          SizedBox(
            // height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                //
                const SizedBox(height: 10),
                //
                // fav location
                favLocation(),
                //
                const SizedBox(height: 10),
                //
                // list of currently locations
                currentlyLocations(),
                //
              ],
            ),
          ),
          //
        ],
      ),
    );
  }

  AnimatedPositioned setFavAndDeleteBar(
      BuildContext context, bool Function(dynamic currentValue) isEqualTrue) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      top: _appearanceStatus
          ? MediaQuery.of(context).size.height - 180
          : MediaQuery.of(context).size.height,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade500,
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          color: Colors.blueAccent,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        ),
        height: 80,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // add button
            _listContainsIndexNeedToHandle.where((item) => item == 1).length ==
                    1
                ? Expanded(
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(40)),
                      onTap: () {
                        setState(() {
                          // update all status
                          _appearanceStatus = false;
                          _choosingAll = false;
                          _choosingFavLocation = false;
                          for (int index = 0;
                              index <
                                  _statusChoosingCurrentlyLocationsList.length;
                              index++) {
                            _statusChoosingCurrentlyLocationsList[index] =
                                false;
                          }
                          indexNeedToHandle =
                              _listContainsIndexNeedToHandle.indexOf(1);
                          print(indexNeedToHandle);
                          // assign for new fav location
                          _favLocation =
                              _currentlyLocationsList[indexNeedToHandle];
                          // update hive
                          if (favLocationBox.isNotEmpty) {
                            // add to Hive box
                            favLocationBox.deleteAt(0);
                            favLocationBox.add(
                                _currentlyLocationsList[indexNeedToHandle]);
                            // print(favLocationBox.getAt(0).city);
                            // print(favLocationBox.length);
                          } else {
                            favLocationBox.add(
                                _currentlyLocationsList[indexNeedToHandle]);
                            print(favLocationBox.getAt(0).city);
                          }
                          for (var index = 0;
                              index < _listContainsIndexNeedToHandle.length;
                              index++) {
                            _listContainsIndexNeedToHandle[index] = 0;
                            // print(
                            //     "${index}, ${_listContainsIndexNeedToHandle[index]}");
                          }

                          // snackbar for noti delete successfully
                          ScaffoldMessenger.of(context)
                              .showSnackBar(snackBarForSettingFavLocation);
                          //
                        });
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_location_alt,
                            size: 32,
                            color: Colors.white,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Set favorite',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Text(''),
            //
            // delete button
            Expanded(
              child: InkWell(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(40)),
                onTap: () {
                  setState(() {
                    // if not choosing all items even fav and list currently
                    if (!_choosingAll) {
                      //
                      // check fav choosing
                      if (_choosingFavLocation && _favLocation.country != '') {
                        favLocationBox.deleteAt(0);
                        _favLocation = LocationItem();
                        _choosingFavLocation = false;
                      }
                      if (_listContainsIndexNeedToHandle
                          .where(isEqualTrue)
                          .isNotEmpty) {
                        List _sublistContainsIndexNeedToHandle = [];
                        // get position of index need to delete
                        for (int index = 0;
                            index < _listContainsIndexNeedToHandle.length;
                            index++) {
                          if (_listContainsIndexNeedToHandle[index] == 1) {
                            _sublistContainsIndexNeedToHandle.add(index);
                          }
                        }
                        for (int index =
                                _sublistContainsIndexNeedToHandle.length - 1;
                            index >= 0;
                            index--) {
                          // delete in lists relevant to that index
                          _currentlyLocationsList.removeAt(
                              _sublistContainsIndexNeedToHandle[index]);
                          _statusChoosingCurrentlyLocationsList.removeAt(
                              _sublistContainsIndexNeedToHandle[index]);
                          _listContainsIndexNeedToHandle.removeAt(
                              _sublistContainsIndexNeedToHandle[index]);
                          // delete in hive box}
                          currentlyLocationsBox.deleteAt(
                              _sublistContainsIndexNeedToHandle[index]);
                        }
                      }
                    } else {
                      // if choosing all items even fav and list currently
                      //
                      // print('run here');
                      // check fav choosing
                      if (_choosingFavLocation && _favLocation.country != '') {
                        favLocationBox.deleteAt(0);
                        _favLocation = LocationItem();
                        _choosingFavLocation = false;
                      }
                      var total = _listContainsIndexNeedToHandle.length;
                      // print(total);
                      for (int index = 0; index < total; index++) {
                        // delete in lists relevant to that index
                        _currentlyLocationsList.removeAt(0);
                        _statusChoosingCurrentlyLocationsList.removeAt(0);
                        _listContainsIndexNeedToHandle.removeAt(0);
                        // delete in hive box}
                        currentlyLocationsBox.deleteAt(0);
                      }
                    }
                    for (var index = 0;
                        index < _listContainsIndexNeedToHandle.length;
                        index++) {
                      _listContainsIndexNeedToHandle[index] = 0;
                      // print(
                      //     "${index}, ${_listContainsIndexNeedToHandle[index]}");
                    }
                    //
                    // update all status
                    _appearanceStatus = false;
                    _choosingAll = false;
                    for (int index = 0;
                        index < _statusChoosingCurrentlyLocationsList.length;
                        index++) {
                      _statusChoosingCurrentlyLocationsList[index] = false;
                    }

                    // snackbar for noti delete successfully
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackBarForDeleting);
                    //
                  });
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      size: 32,
                      color: Colors.white,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(bool Function(dynamic currentValue) isBelowThreshold,
      BuildContext context) {
    return AppBar(
      backgroundColor: Colors.deepPurple[300],
      elevation: 0,
      toolbarHeight: 78,
      title: _appearanceStatus == true
          ? const Text('Edit locations', style: TextStyle(fontSize: 20))
          : const Text('Manage locations', style: TextStyle(fontSize: 20)),
      leading: _appearanceStatus == true
          ? Row(
              children: [
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!_choosingAll) {
                            if (!_choosingFavLocation) {
                              _choosingFavLocation = !_choosingFavLocation;
                            }
                            for (int i = 0;
                                i <
                                    _statusChoosingCurrentlyLocationsList
                                        .length;
                                i++) {
                              if (!_statusChoosingCurrentlyLocationsList[i]) {
                                _statusChoosingCurrentlyLocationsList[i] = true;
                              }
                            }

                            for (var index = 0;
                                index < _listContainsIndexNeedToHandle.length;
                                index++) {
                              _listContainsIndexNeedToHandle[index] = 1;
                            }
                          } else {
                            if (_choosingFavLocation) {
                              _choosingFavLocation = !_choosingFavLocation;
                            }
                            for (int i = 0;
                                i <
                                    _statusChoosingCurrentlyLocationsList
                                        .length;
                                i++) {
                              if (_statusChoosingCurrentlyLocationsList[i]) {
                                _statusChoosingCurrentlyLocationsList[i] =
                                    false;
                              }
                            }

                            for (var index = 0;
                                index < _listContainsIndexNeedToHandle.length;
                                index++) {
                              _listContainsIndexNeedToHandle[index] = 0;

                              // print("${index}, ${_listContainsIndexNeedToHandle[index]}");
                            }
                          }
                          _choosingAll = !_choosingAll;

                          for (var index = 0;
                              index < _listContainsIndexNeedToHandle.length;
                              index++) {
                            // print(
                            //     "${index}, ${_listContainsIndexNeedToHandle[index]}");
                          }
                        });
                      },
                      child: _choosingAll == true ||
                              (_choosingFavLocation &&
                                  (_statusChoosingCurrentlyLocationsList.isEmpty
                                      ? true
                                      : _statusChoosingCurrentlyLocationsList
                                          .every(isBelowThreshold)))
                          ? const Icon(Icons.check_circle_rounded, size: 33)
                          : const Icon(Icons.circle_outlined, size: 33),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'All',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).pop();
                    // Future.delayed(const Duration(milliseconds: 300), () {
                    //   Navigator.of(context).pop();
                    // });
                    // Navigator.pushNamed(context, '/homepage');

                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (_) {
                      return HomePage(widget.recentlyLastLocation);
                    }));
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ],
            ),
      actions: [
        _appearanceStatus
            ? _appearanceStatus
                ? Container(
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10)),
                    width: 90,
                    padding: const EdgeInsets.only(left: 3, right: 3),
                    margin: const EdgeInsets.only(
                        left: 17, right: 15, top: 14, bottom: 14),
                    child: (IconButton(
                      icon:
                          const Text('Close', style: TextStyle(fontSize: 18.5)),
                      onPressed: () {
                        setState(() {
                          _appearanceStatus = false;
                          if (_choosingFavLocation) {
                            _choosingFavLocation = false;
                          }
                          for (int i = 0;
                              i < _statusChoosingCurrentlyLocationsList.length;
                              i++) {
                            if (_statusChoosingCurrentlyLocationsList[i]) {
                              _statusChoosingCurrentlyLocationsList[i] = false;
                            }
                          }

                          for (var index = 0;
                              index < _listContainsIndexNeedToHandle.length;
                              index++) {
                            _listContainsIndexNeedToHandle[index] = 0;

                            // print(
                            //     "${index}, ${_listContainsIndexNeedToHandle[index]}");
                          }

                          _choosingAll = false;
                        });
                      },
                    )),
                  )
                : const Text('')
            : Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    // turn on status appear
                    setState(() {
                      if (!_appearanceStatus) {
                        _appearanceStatus = !_appearanceStatus;
                        _choosingAll = false;

                        for (var index = 0;
                            index < _listContainsIndexNeedToHandle.length;
                            index++) {
                          _listContainsIndexNeedToHandle[index] = 0;

                          // print(
                          //     "${index}, ${_listContainsIndexNeedToHandle[index]}");
                        }
                      }
                    });
                  },
                  icon: const Icon(Icons.edit_outlined, size: 29),
                ),
              ),
      ],
    );
  }

  Column currentlyLocations() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_outlined),
            const SizedBox(width: 5),
            Text(
              'Another locations',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
          ],
        ),
        //
        const SizedBox(height: 10),
        //
        _currentlyLocationsList.isNotEmpty
            ? SizedBox(
                height: _appearanceStatus ? 420 : 480,
                child: SingleChildScrollView(
                  child: ListView.builder(
                    reverse: true,
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
                              return Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.blue[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    //
                                    const SizedBox(width: 10),
                                    // checkbox
                                    Visibility(
                                      visible: _appearanceStatus,
                                      child: Transform.scale(
                                        scale: 1.5,
                                        child: Checkbox(
                                          side: const BorderSide(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          shape: const CircleBorder(),
                                          value:
                                              _statusChoosingCurrentlyLocationsList[
                                                  index],
                                          // activeColor: Colors.orangeAccent,
                                          activeColor: Colors.white,
                                          checkColor: Colors.blue[300],
                                          // tristate: true,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              //
                                              // indexNeedToHandle = index;
                                              // print(_choosingFavLocation);

                                              if (_listContainsIndexNeedToHandle[
                                                      index] ==
                                                  0) {
                                                _listContainsIndexNeedToHandle[
                                                    index] = 1;

                                                // for (var index = 0;
                                                //     index <
                                                //         _listContainsIndexNeedToHandle
                                                //             .length;
                                                //     index++) {
                                                //   print(
                                                //       "${index}, ${_listContainsIndexNeedToHandle[index]}");
                                                // }
                                              }

                                              // for (var item
                                              //     in _listContainsIndexNeedToHandle) {
                                              //   print(item);
                                              // }

                                              // if this button is on
                                              else if (_listContainsIndexNeedToHandle[
                                                      index] ==
                                                  1) {
                                                _listContainsIndexNeedToHandle[
                                                    index] = 0;

                                                // for (var index = 0;
                                                //     index <
                                                //         _listContainsIndexNeedToHandle
                                                //             .length;
                                                //     index++) {
                                                //   print(
                                                //       "${index}, ${_listContainsIndexNeedToHandle[index]}");
                                                // }
                                              }

                                              //
                                              _statusChoosingCurrentlyLocationsList[
                                                  index] = newValue!;
                                              if (!_statusChoosingCurrentlyLocationsList[
                                                      index] &&
                                                  _choosingAll) {
                                                _choosingAll = !_choosingAll;

                                                // _listContainsIndexNeedToHandle[
                                                //     index] = 0;

                                                // for (var item
                                                //     in _listContainsIndexNeedToHandle) {
                                                //   print(item);
                                                // }
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    // info
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          if (!_appearanceStatus) {
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (_) {
                                              return HomePage(
                                                  _currentlyLocationsList[
                                                      index]);
                                            }));
                                          }
                                        },
                                        onLongPress: () {
                                          setState(() {
                                            //
                                            // indexNeedToHandle = index;
                                            // print(_choosingFavLocation);

                                            if (_listContainsIndexNeedToHandle[
                                                    index] ==
                                                0) {
                                              _listContainsIndexNeedToHandle[
                                                  index] = 1;

                                              for (var index = 0;
                                                  index <
                                                      _listContainsIndexNeedToHandle
                                                          .length;
                                                  index++) {
                                                // print(
                                                //     "${index}, ${_listContainsIndexNeedToHandle[index]}");
                                              }
                                            }

                                            // for (var item
                                            //     in _listContainsIndexNeedToHandle) {
                                            //   print(item);
                                            // }

                                            // if this button is on
                                            else if (_listContainsIndexNeedToHandle[
                                                    index] ==
                                                1) {
                                              _listContainsIndexNeedToHandle[
                                                  index] = 0;

                                              for (var index = 0;
                                                  index <
                                                      _listContainsIndexNeedToHandle
                                                          .length;
                                                  index++) {
                                                // print(
                                                //     "${index}, ${_listContainsIndexNeedToHandle[index]}");
                                              }
                                            }

                                            //
                                            if (_choosingFavLocation &&
                                                _currentlyLocationsList
                                                        .length ==
                                                    1) {
                                              _choosingAll = true;
                                            }
                                            //
                                            if (!_appearanceStatus) {
                                              _appearanceStatus =
                                                  !_appearanceStatus;
                                              _statusChoosingCurrentlyLocationsList[
                                                      index] =
                                                  !_statusChoosingCurrentlyLocationsList[
                                                      index];

                                              // _listContainsIndexNeedToHandle[
                                              //     index] = 0;

                                              // for (var item
                                              //     in _listContainsIndexNeedToHandle) {
                                              //   print(item);
                                              // }
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding:
                                              const EdgeInsets.only(right: 0),
                                          margin: const EdgeInsets.only(
                                              left: 0, right: 20),
                                          child: Row(
                                            children: [
                                              //
                                              _appearanceStatus == true
                                                  ? const SizedBox(width: 10)
                                                  : const SizedBox(width: 20),
                                              //
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      (_currentlyLocationsList[
                                                                  index]
                                                              .city)
                                                          .toLowerCase()
                                                          .capitalizeFirstOfEach,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 22,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 1),
                                                    Text(
                                                      (_currentlyLocationsList[
                                                                  index]
                                                              .country)
                                                          .toLowerCase()
                                                          .capitalizeFirstOfEach,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              //
                                              Row(
                                                children: [
                                                  getWeatherIcon(
                                                      _currentlyWeather.icon,
                                                      80),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${_currentlyWeather.temp.toInt()}°",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${_currentlyWeather.high.toInt()}° / ${_currentlyWeather.low.toInt()}°",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else {
                            return Shimmer.fromColors(
                              baseColor: Colors.blue.shade300,
                              highlightColor: Colors.blue.shade100,
                              child: Container(
                                height: 100,
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.blue[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                    fontSize: 18,
                  ),
                ),
              ),
      ],
    );
  }

  Widget favLocation() {
    return SizedBox(
      height: _favLocation.country != '' ? 140 : 70,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.star),
              const SizedBox(width: 5),
              Text(
                'Favorite location',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 18,
                ),
              ),
            ],
          ),
          //
          const SizedBox(height: 10),
          //
          SizedBox(
            child: _favLocation.country != ''
                ? Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FutureBuilder(
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Weather _favWeather = snapshot.data;
                          if (_favWeather == null) {
                            return const Text("Error getting weather");
                          } else {
                            return Row(
                              children: [
                                //
                                const SizedBox(width: 10),
                                // checkbox
                                Visibility(
                                  visible: _appearanceStatus,
                                  child: Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(
                                      side: const BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      // tristate: true,
                                      shape: const CircleBorder(),
                                      value: _choosingFavLocation,
                                      activeColor: Colors.white,
                                      checkColor: Colors.green[400],
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          _choosingFavLocation = newValue!;

                                          if (!_choosingFavLocation &&
                                              _choosingAll) {
                                            _choosingAll = !_choosingAll;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                // info
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      if (!_appearanceStatus) {
                                        if (!checkExistedInCurrentlyLocationsBox(
                                            _favLocation)) {
                                          currentlyLocationsBox
                                              .add(_favLocation);
                                        }

                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (_) {
                                          return HomePage(_favLocation);
                                        }));
                                      }
                                    },
                                    //
                                    onLongPress: () {
                                      setState(() {
                                        for (var index = 0;
                                            index <
                                                _listContainsIndexNeedToHandle
                                                    .length;
                                            index++) {
                                          _listContainsIndexNeedToHandle[
                                              index] = 0;

                                          // print(
                                          //     "${index}, ${_listContainsIndexNeedToHandle[index]}");
                                        }

                                        if (!_appearanceStatus) {
                                          _appearanceStatus =
                                              !_appearanceStatus;
                                          _choosingFavLocation =
                                              !_choosingFavLocation;
                                        }

                                        print(_choosingFavLocation);
                                      });
                                    },
                                    //
                                    child: Container(
                                      padding: const EdgeInsets.only(right: 0),
                                      margin: const EdgeInsets.only(
                                          left: 0, right: 20),
                                      child: Row(
                                        children: [
                                          //
                                          _appearanceStatus == true
                                              ? const SizedBox(width: 10)
                                              : const SizedBox(width: 20),
                                          // info
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (_favLocation.city)
                                                      .toLowerCase()
                                                      .capitalizeFirstOfEach,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  (_favLocation.country)
                                                      .toLowerCase()
                                                      .capitalizeFirstOfEach,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              getWeatherIcon(
                                                  _favWeather.icon, 80),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${_favWeather.temp.toInt()}°",
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${_favWeather.high.toInt()}° / ${_favWeather.low.toInt()}°",
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        } else {
                          return Shimmer.fromColors(
                            baseColor: Colors.green.shade300,
                            highlightColor: Colors.green.shade100,
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.green[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      future: getCurrentWeather(_favLocation),
                    ),
                  )
                : Container(
                    height: 30,
                    margin: const EdgeInsets.only(left: 15),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Empty favorite location',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
