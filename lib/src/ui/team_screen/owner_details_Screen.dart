import 'package:flutter/material.dart';

class OwnerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> owner;

  // Constructor to receive selected owner data
  OwnerDetailsScreen({required this.owner});

  @override
  _OwnerDetailsScreenState createState() => _OwnerDetailsScreenState();
}

class _OwnerDetailsScreenState extends State<OwnerDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _textController;
  late Animation<double> _imageFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Image animation controller
    _imageController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _imageFadeAnimation = CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeIn,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _textSlideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // Start animations after widget build
    _imageController.forward();
    _textController.forward();
  }

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract owner details from the passed data
    String name = widget.owner['name'] ?? 'No Name';
    String imageUrl =
        widget.owner['image_url'] ?? 'assets/images/default_avatar.png';
    String description =
        widget.owner['description'] ?? 'No description available';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Introduce with Our Team Owner",
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
        ),
        backgroundColor:
            Colors.blueAccent, // You can change the background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fade-in animation for the owner's image
              FadeTransition(
                opacity: _imageFadeAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.height * 0.3,
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) =>
                        Image.asset('assets/images/default_avatar.png'),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Slide-in animation for the owner's name
              SlideTransition(
                position: _textSlideAnimation,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent, // Customize text color
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Slide-in animation for the owner's description
              SlideTransition(
                position: _textSlideAnimation,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54), // Customize text style
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
