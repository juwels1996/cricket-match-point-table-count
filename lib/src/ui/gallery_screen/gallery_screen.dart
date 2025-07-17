import 'package:cricket_scorecard/src/utils/responsives_classes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/api-service/api_services.dart';
import '../../core/model/photo_gallery.dart';
// Import your model

class MatchGalleryScreen extends StatefulWidget {
  @override
  _MatchGalleryScreenState createState() => _MatchGalleryScreenState();
}

class _MatchGalleryScreenState extends State<MatchGalleryScreen> {
  final ApiService apiService = ApiService();
  late Future<List<MatchGallery>> matchGalleryList;

  @override
  void initState() {
    super.initState();
    matchGalleryList = apiService.fetchMatchGallery(); // Fetch data on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Match Photo Gallery',
          style: TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
        ),
      ),
      body: FutureBuilder<List<MatchGallery>>(
        future: matchGalleryList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found.'));
          } else {
            List<MatchGallery> galleries = snapshot.data!;
            Map<String, List<MatchGallery>> groupedByDate = {};

            // Group galleries by date
            for (var gallery in galleries) {
              if (groupedByDate[gallery.date] == null) {
                groupedByDate[gallery.date] = [];
              }
              groupedByDate[gallery.date]!.add(gallery);
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.isLargeScreen(context)
                    ? 6
                    : 4, // Dynamically set column count
                crossAxisSpacing: 0.3, // Space between items horizontally
                mainAxisSpacing: 0.3, // Space between items vertically
                childAspectRatio: 0.9, // Aspect ratio for images (1:1)
              ),
              itemCount: groupedByDate.keys.length,
              itemBuilder: (context, index) {
                String date = groupedByDate.keys.elementAt(index);
                List<MatchGallery> galleryList = groupedByDate[date]!;

                // Show a card for each date
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 6.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MatchPhotoDetailScreen(galleryList: galleryList),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            galleryList[0].photo,
                            fit: BoxFit.cover,
                            height: 160,
                            width: 180,
                          ),
                        ),
                        // Container(
                        //   height: 180,
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     gradient: LinearGradient(
                        //       begin: Alignment.topCenter,
                        //       end: Alignment.bottomCenter,
                        //       colors: [
                        //         Colors.black.withOpacity(0.3),
                        //         Colors.black.withOpacity(0.7),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(30)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Row(
                                children: [
                                  Icon(Icons.photo_camera_outlined,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    "${galleryList.length}",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          bottom: 20,
                          child: Text(
                            galleryList[0].description,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Text(
                            galleryList[0].date,
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class MatchPhotoDetailScreen extends StatelessWidget {
  final List<MatchGallery> galleryList;

  MatchPhotoDetailScreen({required this.galleryList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photos for ${galleryList[0].date}')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.isLargeScreen(context) ? 4 : 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: galleryList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            child: Image.network(
              galleryList[index].photo,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
