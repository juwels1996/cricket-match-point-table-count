import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../core/model/pdf_model.dart';

class PDFListScreen extends StatefulWidget {
  @override
  _PDFListScreenState createState() => _PDFListScreenState();
}

class _PDFListScreenState extends State<PDFListScreen> {
  List<PDF> pdfs = [];
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Fetch PDF data from the API
  Future<void> fetchPDFs() async {
    final response =
        await http.get(Uri.parse("https://backend.dplt10.org/api/pdfs/"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        pdfs = data.map((pdfData) => PDF.fromJson(pdfData)).toList();
      });
    } else {
      throw Exception('Failed to load PDFs');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPDFs(); // Fetch PDFs when screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF List")),
      body: pdfs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pdfs.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image Section
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.asset(
                          "assets/sponsors/dpl2.png",
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 100.h,
                        ),
                      ),
                      // Title Section
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          pdfs[index].title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Description Section
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10),
                      //   child: Text(
                      //     "",
                      //     style: TextStyle(
                      //       fontSize: 14,
                      //       color: Colors.black54,
                      //     ),
                      //   ),
                      // ),
                      // Button Section
                      TextButton(
                          onPressed: () => _launchURL(pdfs[index].pdfLink),
                          child: RichText(
                              text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: 'Click ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'HERE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ' to Download the PDF',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ])))
                    ],
                  ),
                );
              },
            ),
    );
  }
}
