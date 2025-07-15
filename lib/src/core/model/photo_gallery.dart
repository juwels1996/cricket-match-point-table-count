import 'package:flutter/material.dart';

class MatchGallery {
  final int id;
  final int match;
  final String photo;
  final String description;
  final String date;
  final String uploadedAt;

  MatchGallery({
    required this.id,
    required this.match,
    required this.photo,
    required this.description,
    required this.date,
    required this.uploadedAt,
  });

  // Factory method to create a MatchGallery instance from JSON
  factory MatchGallery.fromJson(Map<String, dynamic> json) {
    return MatchGallery(
      id: json['id'],
      match: json['match'],
      photo: json['photo'],
      description: json['description'],
      date: json['date'],
      uploadedAt: json['uploaded_at'],
    );
  }

  // Method to convert MatchGallery instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match': match,
      'photo': photo,
      'description': description,
      'date': date,
      'uploaded_at': uploadedAt,
    };
  }
}
