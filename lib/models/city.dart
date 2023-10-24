class City {
  String id;
  String name;
  String stateId;
  String stateName;
  String cityState;

  City({
    this.id,
    this.name,
    this.stateId,
    this.stateName,
    this.cityState,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['cityid'],
      name: json['cityname'],
      stateId: json['stateid'],
      stateName: json['statename'],
      cityState: json['citystate'],
    );
  }
}
