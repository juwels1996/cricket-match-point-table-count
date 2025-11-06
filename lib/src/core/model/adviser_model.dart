class Adviser {
  final int id;
  final String name;
  final String imageUrl;
  final String designation;

  Adviser({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.designation,
  });

  factory Adviser.fromJson(Map<String, dynamic> json) {
    return Adviser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      designation: json['designation'] ?? '',
    );
  }
}
