import 'package:cricket_scorecard/src/ui/homescreen/componenets/registration_form.dart';
import 'package:flutter/material.dart';

class EventRegistrationCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) =>
          //         RegistrationForm(), // Navigate to RegistrationForm
          //   ),
          // );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20), // Rounded corners for the card
          ),
          elevation: 10, // Add some shadow for better depth
          shadowColor: Colors.blueAccent, // Customize shadow color
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.purple
                ], // Gradient color background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Banner at the top of the card (you can replace this with an image if needed)
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      "Event Registration",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Icon(
                  Icons.event,
                  size: 60,
                  color: Colors.white, // Icon color
                ),
                SizedBox(height: 20),
                // Text(
                //   "Register for the Upcoming DPL Season 06",
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white, // Text color
                //   ),
                //   textAlign: TextAlign.center,
                // ),
                Text(
                  "Event registraion is closed for DPL Season 06",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.8), // Lighter text color
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Fill out the form below to secure your spot at the event.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8), // Lighter text color
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: null,
                  // onPressed: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => RegistrationForm(),
                  //     ),
                  //   );
                  // },
                  child: Text(
                    "Register Now",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
