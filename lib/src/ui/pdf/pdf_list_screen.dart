import 'dart:convert';
import 'package:flutter/material.dart';
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
        await http.get(Uri.parse("http://64.227.150.216:8454/api/pdfs/"));

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
                return Column(
                  children: [
                    Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(pdfs[index].title),
                        subtitle: Text(pdfs[index].description),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _launchURL(pdfs[index].pdfLink),
                      child: Text("Open PDF"),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
