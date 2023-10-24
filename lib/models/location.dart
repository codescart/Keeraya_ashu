class Location {
  String name;
  String cityId;
  String cityName;
  String stateId;
  String stateName;
  String cityState;
  String latitude;
  String longitude;
  String countryCode;
  String countryName;

  Location({
    this.name = '',
    this.cityId = '',
    this.cityName = '',
    this.stateId = '',
    this.stateName = '',
    this.cityState = '',
    this.latitude = '',
    this.longitude = '',
    this.countryCode = '',
    this.countryName = '',
  });

  @override
  String toString() {
    return 'Location{name: $name, cityId: $cityId, cityName: $cityName, stateId: $stateId, stateName: $stateName, cityState: $cityState, latitude: $latitude, longitude: $longitude, countryCode: $countryCode, countryName: $countryName}';
  }
}
