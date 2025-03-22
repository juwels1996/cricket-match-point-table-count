import 'package:flutter/material.dart';

class HighlightCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String date;
  final String views;
  final String duration;

  const HighlightCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.date,
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
      width: 180,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅ **Image with Rounded Corners**
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.network(
              widget.imageUrl,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),

                /// ✅ **Date, Views & Duration Row**
                Row(
                  children: [
                    Spacer(),
                    Icon(Icons.visibility, color: Colors.white54, size: 12),
                    SizedBox(width: 5),
                    Text(widget.duration,
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
