import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../../core/model/adviser_model.dart';
import '../../utils/responsives_classes.dart';

class AdviserScreen extends StatefulWidget {
  const AdviserScreen({Key? key}) : super(key: key);

  @override
  State<AdviserScreen> createState() => _AdviserScreenState();
}

class _AdviserScreenState extends State<AdviserScreen> {
  Map<String, List<Adviser>> advisersByCategory = {};

  @override
  void initState() {
    super.initState();
    fetchAdvisers();
  }

  Future<void> fetchAdvisers() async {
    try {
      final response =
          await http.get(Uri.parse("https://backend.dplt10.org/api/advisers/"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Group advisers by designation
        final Map<String, List<Adviser>> grouped = {};
        for (var item in data) {
          final adviser = Adviser.fromJson(item);
          grouped.putIfAbsent(adviser.designation, () => []).add(adviser);
        }

        setState(() {
          advisersByCategory = grouped;
        });
      } else {
        throw Exception("Failed to load advisers");
      }
    } catch (e) {
      debugPrint("Error fetching advisers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (advisersByCategory.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = advisersByCategory.keys.toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Advisers", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 🌈 Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✨ Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.map((category) {
                final advisers = advisersByCategory[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    // 🏷️ Category Title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 5),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: Colors.grey),

                    // 👇 Adviser Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getColumns(context),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: advisers.length,
                      itemBuilder: (context, index) {
                        final adviser = advisers[index];
                        return _buildGlassCard(adviser);
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 🪞 Glass card for each adviser
  Widget _buildGlassCard(Adviser adviser) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  adviser.imageUrl,
                  fit: BoxFit.cover,
                  height: 130.h,
                  width: 120.w,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                adviser.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                adviser.designation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📱 Responsive grid layout
  int _getColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 800) return 3;
    return 2;
  }
}
