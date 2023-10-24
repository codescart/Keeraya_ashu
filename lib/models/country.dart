class Country {
  String id;
  String code;
  String lowerCaseCode;
  String name;
  String language;

  Country({
    this.id,
    this.code,
    this.lowerCaseCode,
    this.name,
    this.language,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      code: json['code'],
      lowerCaseCode: json['lowercase_code'],
      name: json['name'],
      language: json['lang'],
    );
  }
}
