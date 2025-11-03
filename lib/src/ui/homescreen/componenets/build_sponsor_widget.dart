import 'package:flutter/material.dart';

import '../../../core/api-service/api_services.dart';
import '../../../core/model/sponsor_model.dart';

class SponsorScreen extends StatefulWidget {
  const SponsorScreen({super.key});

  @override
  State<SponsorScreen> createState() => _SponsorScreenState();
}

class _SponsorScreenState extends State<SponsorScreen> {
  late Future<Map<String, List<Sponsor>>> _futureSponsors;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureSponsors = apiService.fetchSponsors();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Sponsor>>>(
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

        final sponsorsByCategory = snapshot.data!;
        // Combine all sponsors from every category
        final allSponsors =
            sponsorsByCategory.values.expand((list) => list).toList();

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
                children: allSponsors.map((s) {
                  final imageUrl = s.image.startsWith('http')
                      ? s.image
                      : 'http://192.168.68.101:8000${s.image}';

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          height: 80,
                          width: 120,
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
