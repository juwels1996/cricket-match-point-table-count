import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/api-service/api_services.dart';
import '../../../core/model/sponsor_model.dart';

class SponsorScreen extends StatefulWidget {
  const SponsorScreen({super.key});

  @override
  State<SponsorScreen> createState() => _SponsorScreenState();
}

class _SponsorScreenState extends State<SponsorScreen> {
  late Future<List<Sponsor>> _futureSponsors;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureSponsors = apiService.fetchSponsors();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Sponsor>>(
      future: _futureSponsors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text("No sponsors found",
                  style: TextStyle(color: Colors.white70)));
        }

        final sponsors = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "All Sponsors",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Grid-style layout for all sponsors
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: sponsors.map((s) {
                  // Handle multiple images for each sponsor
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Create a row of images for each sponsor
                      Wrap(
                        spacing: 8, // Space between images
                        children: s.images.map((imageUrl) {
                          final imageSrc = imageUrl.startsWith('http')
                              ? imageUrl
                              : 'http://192.168.0.139:8000$imageUrl';

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageSrc,
                              // height: 80,
                              width: 100.w,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 80,
                                width: 120,
                                color: Colors.grey[800],
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image,
                                    color: Colors.white54),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.name,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
