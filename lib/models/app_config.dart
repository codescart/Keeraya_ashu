class AppConfig {
  String featuredFee;
  String highlightFee;
  String urgentFee;

  AppConfig({this.featuredFee, this.highlightFee, this.urgentFee});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      featuredFee: json['featured-fee'],
      highlightFee: json['highlight_fee'],
      urgentFee: json['urgent_fee'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['featured-fee'] = this.featuredFee;
    data['highlight_fee'] = this.highlightFee;
    data['urgent_fee'] = this.featuredFee;
    return data;
  }
}
