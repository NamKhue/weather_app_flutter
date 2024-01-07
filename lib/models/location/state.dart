class State {
  final List statesList;

  State({
    required this.statesList,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    if (json['status'] == 'fail') {
      return State(statesList: []);
    }

    List statesData = json['data'];

    List states = [];

    for (var item in statesData) {
      states.add(item['state']);
    }

    return State(
      statesList: states,
    );
  }
}
