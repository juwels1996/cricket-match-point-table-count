class Sponsor {
  final String name;
  final String image; // full or relative
  final String category; // "media" | "co" | "main"
  Sponsor({required this.name, required this.image, required this.category});

  factory Sponsor.fromJson(Map<String, dynamic> j) => Sponsor(
        name: j['name'] ?? '',
        image: j['image'] ?? '',
        category: j['category'] ?? '',
      );
}

// Call this after fetching the JSON from your /sponsors endpoint
Map<String, List<Sponsor>> parseSponsorsByCategory(Map<String, dynamic> json) {
  final Map<String, List<Sponsor>> out = {};
  json.forEach((categoryLabel, list) {
    final items = (list as List)
        .map((e) => Sponsor.fromJson(e as Map<String, dynamic>))
        .toList();
    out[categoryLabel] = items; // <-- keep ALL items, not just first
  });
  return out;
}
