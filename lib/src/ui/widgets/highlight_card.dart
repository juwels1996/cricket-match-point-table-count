import 'package:cricket_scorecard/src/utils/responsives_classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class HighlightCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String date;
  final double? height;
  final double? width;
  final String views;
  final String duration;

  const HighlightCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.date,
    this.height,
    this.width,
    required this.views,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.isSmallScreen(context)
          ? 180
          : Responsive.isMediumScreen(context)
              ? 200
              : MediaQuery.of(context).size.width * 0.22,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// 🔵 Image with top-rounded corners
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          /// 🔵 Bottom blue section
          Container(
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM, yyyy').format(DateTime.parse(date)),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HighlightCard1 extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String date;
  double? height;
  double? width;
  final String views;
  final String duration;

  HighlightCard1({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.date,
    this.height,
    this.width,
    required this.views,
    required this.duration,
  }) : super(key: key);

  @override
  _HighlightCard1State createState() => _HighlightCard1State();
}

class _HighlightCard1State extends State<HighlightCard1> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.isSmallScreen(context)
          ? 200.w
          : Responsive.isMediumScreen(context)
              ? 250.w
              : MediaQuery.of(context).size.width * 0.25,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),

          /// ✅ **Image with Rounded Corners**
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.network(
              widget.imageUrl,
              height: MediaQuery.of(context).size.height * 0.15,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ✅ **Title**
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  DateFormat('dd MMM yyyy').format(DateTime.parse(widget.date)),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                )

                /// ✅ **Date, Views & Duration Row**
              ],
            ),
          ),
        ],
      ),
    );
  }
}
