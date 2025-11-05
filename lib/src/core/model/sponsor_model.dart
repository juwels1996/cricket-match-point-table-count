import 'dart:convert';

List<Sponsor> sponsorFromJson(String str) =>
    List<Sponsor>.from(json.decode(str).map((x) => Sponsor.fromJson(x)));

String sponsorToJson(List<Sponsor> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Sponsor {
  int id;
  String name;
  List<String> images;
  String category;
  String categoryLabel;
  int position;

  Sponsor({
    required this.id,
    required this.name,
    required this.images,
    required this.category,
    required this.categoryLabel,
    required this.position,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) => Sponsor(
        id: json["id"],
        name: json["name"],
        images: List<String>.from(json["images"].map((x) => x)),
        category: json["category"],
        categoryLabel: json["category_label"],
        position: json["position"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "images": List<dynamic>.from(images.map((x) => x)),
        "category": category,
        "category_label": categoryLabel,
        "position": position,
      };
}
