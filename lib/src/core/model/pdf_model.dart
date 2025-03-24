class PDF {
  final String title;
  final String description;
  final String pdfLink;
  final String date;

  PDF({
    required this.title,
    required this.description,
    required this.pdfLink,
    required this.date,
  });

  // Convert JSON to PDF object
  factory PDF.fromJson(Map<String, dynamic> json) {
    return PDF(
      title: json['title'],
      description: json['description'],
      pdfLink: json['pdf_link'],
      date: json['date'],
    );
  }
}
