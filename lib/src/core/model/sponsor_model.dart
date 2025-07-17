class Sponsor {
  final String name;
  final String image;
  final String category;

  Sponsor({
    required this.name,
    required this.image,
    required this.category,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      name: json['name'],
      image: json['image'],
      category: json['category'],
    );
  }
}
