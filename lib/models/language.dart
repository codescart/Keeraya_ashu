class Language {
  String id;
  String code;
  String direction;
  String name;
  String fileName;
  bool isActive;
  bool isDefault;

  Language({
    this.id,
    this.code,
    this.direction,
    this.name,
    this.fileName,
    this.isActive,
    this.isDefault,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      code: json['code'],
      direction: json['direction'],
      name: json['name'],
      fileName: json['file_name'],
      isActive: json['active'] == '1' ? true : false,
      isDefault: json['default'] == '1' ? true : false,
    );
  }
}
