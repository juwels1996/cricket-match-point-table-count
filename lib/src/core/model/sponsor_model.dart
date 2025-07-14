class SponsorModel {
  final String? title;
  final String image;

  SponsorModel({
    this.title,
    required this.image,
  });

  // Convert JSON to PDF object
  factory SponsorModel.fromJson(Map<String, dynamic> json) {
    return SponsorModel(
      title: json['title'] ?? "",
      image: json['image'],
    );
  }
}
