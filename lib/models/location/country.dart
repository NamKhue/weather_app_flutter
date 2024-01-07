class Country {
  final List countryList;

  Country({
    required this.countryList,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    if (json['status'] == 'fail') {
      return Country(countryList: []);
    }

    // if status == success
    List countriesData = json['data'];

    List countries = [];

    for (var item in countriesData) {
      countries.add(item['country']);
    }

    return Country(
      countryList: countries,
    );

    //
    //
    // List data = json['data'];
    // List countries = [];

    // for (var item in data) {
    //   countries.add(item);
    // }

    // return Country(
    //   countryList: countries,
    // );
  }
}
