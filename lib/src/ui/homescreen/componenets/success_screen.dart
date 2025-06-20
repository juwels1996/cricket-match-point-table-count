import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:screenshot/screenshot.dart';

import '../../widgets/button/iconbutton.dart';

class SuccessScreen extends StatefulWidget {
  final int userId;

  SuccessScreen({required this.userId});

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  Map<String, dynamic> userData = {};
  final ScreenshotController controller = ScreenshotController();

  Future<void> fetchUserData() async {
    final uri = Uri.parse(
        'http://192.168.68.102:8000/get_user_data/${widget.userId}/'); // Adjust with your endpoint

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
        });
      } else {
        print('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registration Success')),
      body: userData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Screenshot(
              controller: controller,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Image.asset(
                    'assets/sponsors/background.jpeg',
                    fit: BoxFit.cover,
                  ),
                  // Content over the background image
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/sponsors/dpl2.png',
                            height: 100,
                            width: 100,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "DPL - Deedar Premier League(Season-3)",
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Congratulations",
                            style: GoogleFonts.dancingScript(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                color:
                                    Colors.white, // Default color for the text
                              ),
                              children: [
                                TextSpan(
                                  text: "Your registration is ",
                                ),
                                TextSpan(
                                  text: "successfully completed",
                                  style: TextStyle(
                                    color: Colors
                                        .yellow, // Different color for this part of the text
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            15), // Adjust the radius as needed
                                        child: Image.network(
                                          // Check if player photo exists or use default image
                                          userData['player_photo'] != null
                                              ? 'http://192.168.68.102:8000${userData['player_photo']}'
                                              : 'https://via.placeholder.com/150',
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                      : null,
                                                ),
                                              );
                                            }
                                          },
                                          errorBuilder: (BuildContext context,
                                              Object error,
                                              StackTrace? stackTrace) {
                                            return Image.asset(
                                              'assets/sponsors/jjs.jpg',
                                              height: 150,
                                              width: 150,
                                            ); // Local fallback image
                                          },
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        userData['name'] ?? 'No name provided',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Address: ${userData['address'] ?? 'Not available'}",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Area: ${userData['area'] ?? 'Not available'}",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Category: ${userData['speciality'] ?? 'Not available'}",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      width:
                                          60), // Space between the two columns
                                  Image.asset(
                                    'assets/sponsors/Player_logo.png',
                                    height: 140,
                                    width: 80,
                                    fit: BoxFit
                                        .fill, // Ensures the image fills the container
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment
                                .center, // Align items to the center
                            spacing: 10, // Horizontal space between buttons
                            runSpacing:
                                10, // Vertical space between lines of buttons
                            children: [
                              CustomButton(
                                text:
                                    "FB Page: DPL - Deedar Premier League", // You can pass an icon here
                                onPressed: () {
                                  // Button pressed action
                                  print("Button pressed!");
                                },
                              ),
                              CustomButton(
                                text: "dplt10.org",
                                icon:
                                    "assets/sponsors/web_icon.png", // You can pass an icon here
                                onPressed: () {
                                  // Button pressed action
                                  print("Button pressed!");
                                },
                              ),
                              CustomButton(
                                text:
                                    "Fan Group - DPL fan Arena", // You can pass an icon here
                                onPressed: () {
                                  // Button pressed action
                                  print("Button pressed!");
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await controller.capture();
          if (image != null) {
            // Save or share the image here
          }
        },
        child: Icon(Icons.download),
      ),
    );
  }
}
