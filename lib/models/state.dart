class CountryState {
  String id;
  String code;
  String name;

  CountryState({
    this.id,
    this.code,
    this.name,
  });

  factory CountryState.fromJson(Map<String, dynamic> json) {
    return CountryState(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }
}
