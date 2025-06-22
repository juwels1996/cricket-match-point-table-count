import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:screenshot/screenshot.dart';

// ───────── imports only needed on mobile / desktop
import 'dart:io'; // ignore: dart_io_import
import 'package:path_provider/path_provider.dart';

// ───────── web-only import (guarded with kIsWeb before use)
import 'dart:html' as html; // ignore: avoid_web_libraries_in_flutter

import '../../widgets/button/iconbutton.dart';

class SuccessScreen extends StatefulWidget {
  final int userId;
  const SuccessScreen({super.key, required this.userId});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final ScreenshotController controller = ScreenshotController();
  Map<String, dynamic> userData = {};

  // ───────────────────────────────── fetch data
  Future<void> fetchUserData() async {
    final uri =
        Uri.parse('https://backend.dplt10.org/get_user_data/${widget.userId}/');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        setState(() => userData = Map<String, dynamic>.from(
              jsonDecode(res.body) as Map,
            ));
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // ───────────────────────────────── capture + save / download
  Future<void> captureCard() async {
    Uint8List? bytes = await controller.capture();
    if (bytes == null) return;

    if (kIsWeb) {
      // ───────── browser download
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..download = 'dpl_card.png'
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // ───────── save to local documents dir
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/dpl_card_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card saved to: ${file.path}')),
      );
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
      appBar: AppBar(title: const Text('Registration Success')),
      body: userData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Screenshot(
                controller: controller,
                child: _buildRegistrationCard(context),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: captureCard,
        child: const Icon(Icons.download),
      ),
    );
  }

  // ──────────────────────────────── card widget (your Stack)
  Widget _buildRegistrationCard(BuildContext context) {
    return SizedBox(
      width: 450,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/sponsors/background.jpeg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.35)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/sponsors/dpl2.png',
                      height: 100, width: 100),
                  // const SizedBox(height: 20),
                  const Text(
                    "DPL - Deedar Premier League (Season-6)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text("Congratulations",
                      style: GoogleFonts.dancingScript(
                          fontSize: 28, color: Colors.white)),
                  const SizedBox(height: 6),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                      children: [
                        TextSpan(text: "Your registration is "),
                        TextSpan(
                            text: "successfully completed",
                            style: TextStyle(color: Colors.yellow)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  _buildPlayerInfo(),
                  const SizedBox(height: 8),
                  _buildLinks(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── player photo & info
  Widget _buildPlayerInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                userData['player_photo'] != null
                    ? 'https://backend.dplt10.org${userData['player_photo']}'
                    : 'https://via.placeholder.com/150',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/sponsors/default1.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _infoText(userData['name'] ?? 'No name'),
            _infoText('Address: ${userData['address'] ?? 'N/A'}'),
            _infoText('Area: ${userData['area'] ?? 'N/A'}'),
            _infoText('Category: ${userData['speciality'] ?? 'N/A'}'),
          ],
        ),
        const SizedBox(width: 60),
        Image.asset('assets/sponsors/Player_logo.png',
            height: 140, width: 80, fit: BoxFit.fill),
      ],
    );
  }

  // ───────────────────────── link buttons row
  Widget _buildLinks() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        CustomButton(
            text: "FB Page: DPL -Deeder Premier League", onPressed: () {}),
        CustomButton(
            text: "dplt10.org",
            icon: "assets/sponsors/web_icon.png",
            onPressed: () {}),
        CustomButton(text: "Fan Group -DPL Fan Arena", onPressed: () {}),
      ],
    );
  }

  Widget _infoText(String text) => Text(text,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white));
}
