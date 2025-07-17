import 'package:cricket_scorecard/src/utils/responsives_classes.dart';
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
  late Future<Map<String, List<Sponsor>>> _futureSponsors;
  final ApiService apiService = ApiService();
  String selectedCategory = '';

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
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final sponsorsByCategory = snapshot.data!;
        final categoryNames = sponsorsByCategory.keys.toList();

        // Set initial category
        if (selectedCategory.isEmpty && categoryNames.isNotEmpty) {
          selectedCategory = categoryNames.first;
        }

        final selectedSponsors = sponsorsByCategory[selectedCategory] ?? [];
        final sortedCategories = [
          if (categoryNames.contains("Main Sponsor")) "Main Sponsor",
          ...categoryNames.where((c) => c != "Main Sponsor"),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 8,
            ),
            Center(
              child: Text(
                "Sponsor",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
              ),
            ),

            // CATEGORY ROW with IMAGE and NAME
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: sortedCategories.map((category) {
                  final sponsors = sponsorsByCategory[category];
                  final imageUrl = sponsors != null && sponsors.isNotEmpty
                      ? sponsors.first.image
                      : null;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                height: Responsive.isSmallScreen(context)
                                    ? 90
                                    : 120,
                                width: Responsive.isSmallScreen(context)
                                    ? 120
                                    : 160,
                                fit: BoxFit.fill,
                              ),
                            ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // SPONSORS OF SELECTED CATEGORY
            // Expanded(
            //   child: ListView.builder(
            //     padding: const EdgeInsets.all(16),
            //     itemCount: selectedSponsors.length,
            //     itemBuilder: (context, index) {
            //       final sponsor = selectedSponsors[index];
            //       return Padding(
            //         padding: const EdgeInsets.only(bottom: 16),
            //         child: Row(
            //           children: [
            //             ClipRRect(
            //               borderRadius: BorderRadius.circular(8),
            //               child: Image.network(
            //                 sponsor.image,
            //                 height: 60,
            //                 width: 100,
            //                 fit: BoxFit.cover,
            //               ),
            //             ),
            //             const SizedBox(width: 12),
            //             Expanded(
            //               child: Text(
            //                 sponsor.name,
            //                 style: const TextStyle(
            //                     fontSize: 16, color: Colors.white),
            //               ),
            //             )
            //           ],
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
