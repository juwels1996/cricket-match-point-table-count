import 'package:cricket_scorecard/src/utils/responsives_classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class HighlightCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String date;
  double? height;
  double? width;
  final String views;
  final String duration;

  HighlightCard({
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
  _HighlightCardState createState() => _HighlightCardState();
}

class _HighlightCardState extends State<HighlightCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.isSmallScreen(context)
          ? 150
          : Responsive.isMediumScreen(context)
              ? 200
              : MediaQuery.of(context).size.width * 0.25,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
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
