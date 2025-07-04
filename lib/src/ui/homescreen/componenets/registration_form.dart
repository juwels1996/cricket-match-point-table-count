import 'dart:convert';
import 'dart:io';
import 'package:cricket_scorecard/src/ui/homescreen/componenets/success_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final categoryController = TextEditingController();
  final specialityController = TextEditingController();
  final areaController = TextEditingController();
  final districtController = TextEditingController();
  final nidController = TextEditingController();
  final birthDateController = TextEditingController();
  final bkashAccountController = TextEditingController();
  final bkashTransactionIdController = TextEditingController();

  // Variables to store image data for web and mobile
  XFile? _chosenImage; // For mobile
  String? _webImageDataUrl; // For web
  final List<String> areaOptions = ['Local', 'Semi-Local', 'Overseas'];
  String? selectedArea;

  final List<String> categoryOptions = ['A', 'B', 'C'];
  final List<String> specialityOptions = ['Bowler', 'Batsman', 'All-Rounder'];

// ───── currently chosen items ────────────────────────────────────────────────
  String? selectedCategory;
  String? selectedSpeciality;

  // Image picker instance
  final ImagePicker picker = ImagePicker();

  Future<void> selectImage() async {
    // Pick an image (this works for both mobile and web)
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        String base64Image =
            "data:image/jpeg;base64," + base64Encode(imageBytes);

        setState(() {
          _webImageDataUrl = base64Image;
        });
      } else {
        setState(() {
          _chosenImage = pickedFile; // Store the XFile for mobile
        });
      }
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCategory == null ||
          selectedSpeciality == null ||
          selectedArea == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please select Area, Category, and Speciality')),
        );
        return;
      }

      final uri = Uri.parse('https://backend.dplt10.org/register_user/');
      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = nameController.text;
      request.fields['bkash_number'] = bkashAccountController.text;
      request.fields['bkash_transaction_id'] =
          bkashTransactionIdController.text;
      request.fields['phone_number'] = phoneController.text;
      request.fields['address'] = addressController.text;
      request.fields['district'] = districtController.text;
      request.fields['nid_or_birth_certificate_no'] = nidController.text;
      request.fields['date_of_birth'] = birthDateController.text;
      request.fields['area'] =
          selectedArea!; // Still string, but backend should allow it
      request.fields['player_category'] = selectedCategory!;
      request.fields['speciality'] = selectedSpeciality!;

      // Add image file (only if it's available)
      if (_chosenImage != null) {
        var photo = await http.MultipartFile.fromPath(
            'player_photo', _chosenImage!.path);
        request.files.add(photo);
      } else if (_webImageDataUrl != null) {
        request.fields['player_photo'] = _webImageDataUrl!;
      }

      try {
        var response = await request.send();

        // Get the raw response body
        var responseBody = await response.stream.bytesToString();
        print('Raw response body: $responseBody');

        // Try to decode it as JSON
        try {
          var data = jsonDecode(responseBody);

          if (data is Map) {
            var id = data['id']; // assuming 'id' is a field in your response
            if (id != null && id is int) {
              print('Successfully registered with id: $id');
              // Navigate to the success screen with the user ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuccessScreen(userId: id),
                ),
              );
            } else {
              print('ID is missing or not an integer');
            }
          } else {
            print('Expected Map but received something else');
          }
        } catch (e) {
          print('Error decoding response: $e');
        }
      } catch (e) {
        print('Error submitting form: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(centerTitle: true, title: Text('Player Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Show selected image (either web or mobile)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text('Important Information'),
                            content: SingleChildScrollView(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black), // default style
                                  children: [
                                    TextSpan(
                                        text:
                                            "⚡ DPL Season-6 প্লেয়ার রেজিস্ট্রেশন ও নিলাম \n⚡🏏 প্রিয় ক্রিকেট প্লেয়ারবৃন্দ,\nআশা করি সকলে সুস্থ ও ভালো আছেন। আপনাদের বহুল প্রত্যাশিত DPL (Season-6) টুর্নামেন্টের প্লেয়ার রেজিস্ট্রেশন শুরু হয়েছে।\n⚠️ গুরুত্বপূর্ণ নোটিশ: নিমোক্ত তথ্যগুলো ভালোভাবে পড়ে রেজিস্ট্রেশন প্রক্রিয়া সম্পূ‍র্ণ করুন। কোন প্লেয়ার রেজিস্ট্রেশন ব্যতীত এই টুর্নামেন্টে অংশগ্রহণ করতে পারবেন না। এই রেজিস্ট্রেশন প্রক্রিয়া ওভারসীজ প্লেয়ারসহ সকল প্লেয়ারের জন্য প্রযোজ্য।\n🏆 মূল টুর্নামেন্ট: ০৭ নভেম্বর - ১২ ডিসেম্বর, ২০২৫ তাই এই সময়ের মধ্যে যারা অংশগ্রহণ করতে পারবেন শুধুমাত্র তাঁদেরকেই রেজিস্ট্রেশন করার জন্য বিশেষভাবে আহবান করা হলো।\n💥 এখনই রেজিস্ট্রেশন করুন এবং আপনার ক্রিকেট স্বপ্নকে বাস্তব করুন!\n📋 রেজিস্ট্রেশন ও ফি:🏠লোকাল প্লেয়ার রেজিস্ট্রেশন ফি: ২০০ টাকা (অফেরতযোগ্য)\n🌐 যোগ্যতার এলাকা: বলরামপুর, কাশিনাথপুর ও জয়পুরের স্থায়ী বাসিন্দা\n🌍 সেমি-লোকাল প্লেয়ার রেজিস্ট্রেশন ফি: ২০০ টাকা (অফেরতযোগ্য)╰┈➤ West Zone: ধনপুর, রংপুর, বাতাবাড়িয়া, চাঙ্গিনী, আলমপুর পূর্ব╰┈➤ East Zone: দৌলতপুর, ছায়াবিতান, গোবিন্দপুর, হাড়াতলী, বেলতলী (শুধুমাত্র স্থায়ী বাসিন্দারা)\n✈️ ওভারসীজ প্লেয়ার রেজিস্ট্রেশন ফি: ৩০০ টাকা(শর্তসাপেক্ষে ফেরতযোগ্য)\n🌐 যোগ্যতার এলাকা: সমগ্র বাংলাদেশ\n💰 রিফান্ড নীতি\n⚠️ ওভারসীজ প্লেয়ারদের জন্য গুরুত্বপূর্ণ বিজ্ঞপ্তি: যে সকল ওভারসীজ প্লেয়ার রেজিস্ট্রেশন সম্পন্ন করেও পুরো টুর্নামেন্টে কোনো টিমে স্থান পাবেন না, তাদের ৫০% রেজিস্ট্রেশন ফি ক্লোজিং অনুষ্ঠানে ফেরত প্রদান করা হবে।\n📅 গুরুত্বপূর্ণ তারিখসমূহ\n📝 রেজিস্ট্রেশনের শেষ তারিখ: ০৫ জুলাই, ২০২৫ (রাত ১১:৫৯ পর্যন্ত)\n🎪 নিলাম অনুষ্ঠান: ১৮ জুলাই, ২০২৫\n📌 স্থান: ব্যুরো বাংলাদেশ ডিভিশনাল অফিস, অডিটোরিয়াম রুম🌐 ... ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                        )),
                                    TextSpan(
                                      text:
                                          ' https://maps.app.goo.gl/Yu3gi3FiZinoXKNP9\n\n',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          final Uri url = Uri.parse(
                                              'https://maps.app.goo.gl/Yu3gi3FiZinoXKNP9');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          }
                                        },
                                    ),

                                    TextSpan(
                                        text:
                                            "⚡ 🏆 মূল টুর্নামেন্ট: ০৭ নভেম্বর - ১২ ডিসেম্বর, ২০২৫🎯 প্লেয়ার নির্বাচন প্রক্রিয়াপ্রতিটি দল নিলামের মাধ্যমে লোকাল ও সেমি-লোকাল প্লেয়ারদের মধ্য থেকে পছন্দের খেলোয়াড়দের দলে অন্তর্ভুক্ত করতে পারবে।📝 রেজিস্ট্রেশন করার নিয়মধাপ\n\n ১: এই 01327-641252 (Fahim Traders) নম্বরে নি‍র্ধারিত রেজিস্ট্রেশন ফি bKash থেকে পেমেন্ট করুন এবং ট্রানজেকশন আইডি সংরক্ষণ করুন।ধাপ\n ২: 🔗 রেজিস্ট্রেশন লিংকে গিয়ে সকল তথ্য সঠিকভাবে পূরণ করুন।ধাপ \n ৩: ✅ রেজিস্ট্রেশন সম্পূর্ণ হলে আপনার ডাটার একটি ইমেজ পাবেন ডাউনলোড করতে পারবেন। \n ৪: 📸 ডাউনলোডকৃত ইমেজটি দিয়ে আপনার অনুভূতি DPL Fan Arena  গ্রুপে পোস্ট করুন ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                        )),

                                    TextSpan(
                                      text:
                                          'https://www.facebook.com/groups/1860853024771742/',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          final Uri url = Uri.parse(
                                              'https://www.facebook.com/groups/1860853024771742/');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          }
                                        },
                                    ),
                                    TextSpan(
                                        text:
                                            "যোগাযোগআরও তথ্যের জন্য যোগাযোগ করুন:📧 DPL-Deedar Premier League পেইজের ইনবক্স করুন।অথবা,\n",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                        )),

                                    TextSpan(
                                      text: '☎️ ০১৭৪৬৭০৮৫৩৮ ☎️ ,',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          final Uri phoneUri = Uri(
                                              scheme: 'tel',
                                              path: '01746708538');
                                          if (await canLaunchUrl(phoneUri)) {
                                            await launchUrl(phoneUri);
                                          }
                                        },
                                    ),
                                    TextSpan(
                                      text: '☎️০১৮১২৫৫৭২৪৮☎️\n\n,',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          final Uri phoneUri = Uri(
                                              scheme: 'tel',
                                              path: '01812557248');
                                          if (await canLaunchUrl(phoneUri)) {
                                            await launchUrl(phoneUri);
                                          }
                                        },
                                    ),

                                    TextSpan(
                                        text:
                                            " প্রিয় ক্রিকেট প্রেমীরা, দেরি না করে আজই রেজিস্ট্রেশন করুন!মনে রাখবেন, রেজিস্ট্রেশন ছাড়া কেউ টুর্নামেন্টে খেলতে পারবেন না - তাই অবশ্যই রেজিস্ট্রেশন সম্পন্ন করুন!DPL Season-6 হবে এক অসাধারণ ক্রিকেট উৎসব। আপনার প্রতিভা দেখানোর এই সুযোগ হাতছাড়া করবেন না।রেজিস্ট্রেশনের সময় খুবই কম আগামী ০৫ জুলাইয়ের মধ্যে অবশ্যই রেজিস্ট্রেশন সম্পন্ন করুন!আপনার বন্ধুদেরও জানান এবং একসাথে DPL Season-6 এর অংশ হয়ে উঠুন!ডিপিএল সিজন-৬ এ সকল প্লেয়ারদের স্বাগতম! 🎉সকল নিয়মকানুন সাপেক্ষে পরিবর্তনযোগ্য। চূড়ান্ত নিয়মাবলী খুব শীঘ্রই ঘোষণা করা হবে।#DPLSeason6 #CricketRegistration #DeedarPremierLeague #JoinNow #CricketBangladesh=================================================",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                        )),

                                    // Add more spans as needed...
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              Center(
                                  child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blueAccent),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Ok",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ))
                            ]);
                      },
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text(
                    "জরুরি নির্দেশনা ও তথ্য(ক্লিক করুন)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[600],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       'Please read carefully before registration',
              //       style: TextStyle(
              //           fontSize: 15,
              //           fontFamily: 'Roboto',
              //           fontWeight: FontWeight.w500,
              //           color: Colors.grey),
              //     ),
              //     IconButton(
              //       icon: Icon(Icons.info_outline, color: Colors.blue),
              //       onPressed: () {
              //         showDialog(
              //           context: context,
              //           builder: (BuildContext context) {
              //             return AlertDialog(
              //                 title: Text('Important Information'),
              //                 content: SingleChildScrollView(
              //                   child: RichText(
              //                     text: TextSpan(
              //                       style: TextStyle(
              //                           fontSize: 16,
              //                           color: Colors.black), // default style
              //                       children: [
              //                         TextSpan(
              //                             text:
              //                                 "⚡ DPL Season-6 প্লেয়ার রেজিস্ট্রেশন ও নিলাম ⚡🏏 প্রিয় ক্রিকেট প্লেয়ারবৃন্দ,আশা করি সকলে সুস্থ ও ভালো আছেন। আপনাদের বহুল প্রত্যাশিত DPL (Season-6) টুর্নামেন্টের প্লেয়ার রেজিস্ট্রেশন শুরু হয়েছে।⚠️ গুরুত্বপূর্ণ নোটিশ: নিমোক্ত তথ্যগুলো ভালোভাবে পড়ে রেজিস্ট্রেশন প্রক্রিয়া সম্পূ‍র্ণ করুন। কোন প্লেয়ার রেজিস্ট্রেশন ব্যতীত এই টুর্নামেন্টে অংশগ্রহণ করতে পারবেন না। এই রেজিস্ট্রেশন প্রক্রিয়া ওভারসীজ প্লেয়ারসহ সকল প্লেয়ারের জন্য প্রযোজ্য।🏆 মূল টুর্নামেন্ট: ০৭ নভেম্বর - ১২ ডিসেম্বর, ২০২৫ তাই এই সময়ের মধ্যে যারা অংশগ্রহণ করতে পারবেন শুধুমাত্র তাঁদেরকেই রেজিস্ট্রেশন করার জন্য বিশেষভাবে আহবান করা হলো।💥 এখনই রেজিস্ট্রেশন করুন এবং আপনার ক্রিকেট স্বপ্নকে বাস্তব করুন!📋 রেজিস্ট্রেশন ও ফি:🏠লোকাল প্লেয়ার রেজিস্ট্রেশন ফি: ২০০ টাকা (অফেরতযোগ্য)🌐 যোগ্যতার এলাকা: বলরামপুর, কাশিনাথপুর ও জয়পুরের স্থায়ী বাসিন্দা🌍 সেমি-লোকাল প্লেয়ার রেজিস্ট্রেশন ফি: ২০০ টাকা (অফেরতযোগ্য)╰┈➤ West Zone: ধনপুর, রংপুর, বাতাবাড়িয়া, চাঙ্গিনী, আলমপুর পূর্ব╰┈➤ East Zone: দৌলতপুর, ছায়াবিতান, গোবিন্দপুর, হাড়াতলী, বেলতলী (শুধুমাত্র স্থায়ী বাসিন্দারা)✈️ ওভারসীজ প্লেয়ার রেজিস্ট্রেশন ফি: ৩০০ টাকা(শর্তসাপেক্ষে ফেরতযোগ্য)🌐 যোগ্যতার এলাকা: সমগ্র বাংলাদেশ💰 রিফান্ড নীতি⚠️ ওভারসীজ প্লেয়ারদের জন্য গুরুত্বপূর্ণ বিজ্ঞপ্তি: যে সকল ওভারসীজ প্লেয়ার রেজিস্ট্রেশন সম্পন্ন করেও পুরো টুর্নামেন্টে কোনো টিমে স্থান পাবেন না, তাদের ৫০% রেজিস্ট্রেশন ফি ক্লোজিং অনুষ্ঠানে ফেরত প্রদান করা হবে।📅 গুরুত্বপূর্ণ তারিখসমূহ📝 রেজিস্ট্রেশনের শেষ তারিখ: ০৫ জুলাই, ২০২৫ (রাত ১১:৫৯ পর্যন্ত)🎪 নিলাম অনুষ্ঠান: ১৮ জুলাই, ২০২৫📌 স্থান: ব্যুরো বাংলাদেশ ডিভিশনাল অফিস, অডিটোরিয়াম রুম🌐 ... ",
              //                             style: TextStyle(
              //                               fontSize: 16,
              //                               fontFamily: 'Roboto',
              //                             )),
              //                         TextSpan(
              //                           text:
              //                               ' https://maps.app.goo.gl/Yu3gi3FiZinoXKNP9\n\n',
              //                           style: TextStyle(
              //                             color: Colors.blue,
              //                             decoration: TextDecoration.underline,
              //                           ),
              //                           recognizer: TapGestureRecognizer()
              //                             ..onTap = () async {
              //                               final Uri url = Uri.parse(
              //                                   'https://maps.app.goo.gl/Yu3gi3FiZinoXKNP9');
              //                               if (await canLaunchUrl(url)) {
              //                                 await launchUrl(url,
              //                                     mode: LaunchMode
              //                                         .externalApplication);
              //                               }
              //                             },
              //                         ),
              //
              //                         TextSpan(
              //                             text:
              //                                 "⚡ 🏆 মূল টুর্নামেন্ট: ০৭ নভেম্বর - ১২ ডিসেম্বর, ২০২৫🎯 প্লেয়ার নির্বাচন প্রক্রিয়াপ্রতিটি দল নিলামের মাধ্যমে লোকাল ও সেমি-লোকাল প্লেয়ারদের মধ্য থেকে পছন্দের খেলোয়াড়দের দলে অন্তর্ভুক্ত করতে পারবে।📝 রেজিস্ট্রেশন করার নিয়মধাপ\n ১: এই 01327-641252 (Fahim Traders) নম্বরে নি‍র্ধারিত রেজিস্ট্রেশন ফি bKash থেকে পেমেন্ট করুন এবং ট্রানজেকশন আইডি সংরক্ষণ করুন।ধাপ\n ২: 🔗 রেজিস্ট্রেশন লিংকে গিয়ে সকল তথ্য সঠিকভাবে পূরণ করুন।ধাপ \n ৩: ✅ রেজিস্ট্রেশন সম্পূর্ণ হলে আপনার ডাটার একটি ইমেজ পাবেন ডাউনলোড করতে পারবেন। ধাপ\n ৪: 📸 ডাউনলোডকৃত ইমেজটি দিয়ে আপনার অনুভূতি DPL Fan Arena  গ্রুপে পোস্ট করুন ",
              //                             style: TextStyle(
              //                               fontSize: 16,
              //                               fontFamily: 'Roboto',
              //                             )),
              //
              //                         TextSpan(
              //                           text:
              //                               'https://www.facebook.com/groups/1860853024771742/',
              //                           style: TextStyle(
              //                             color: Colors.blue,
              //                             decoration: TextDecoration.underline,
              //                           ),
              //                           recognizer: TapGestureRecognizer()
              //                             ..onTap = () async {
              //                               final Uri url = Uri.parse(
              //                                   'https://www.facebook.com/groups/1860853024771742/');
              //                               if (await canLaunchUrl(url)) {
              //                                 await launchUrl(url,
              //                                     mode: LaunchMode
              //                                         .externalApplication);
              //                               }
              //                             },
              //                         ),
              //                         TextSpan(
              //                             text:
              //                                 "যোগাযোগআরও তথ্যের জন্য যোগাযোগ করুন:📧 DPL-Deedar Premier League পেইজের ইনবক্স করুন।অথবা,\n",
              //                             style: TextStyle(
              //                               fontSize: 16,
              //                               fontFamily: 'Roboto',
              //                             )),
              //
              //                         TextSpan(
              //                           text: '☎️ ০১৭৪৬৭০৮৫৩৮ ☎️ ,',
              //                           style: TextStyle(
              //                             color: Colors.blue,
              //                             decoration: TextDecoration.underline,
              //                           ),
              //                           recognizer: TapGestureRecognizer()
              //                             ..onTap = () async {
              //                               final Uri phoneUri = Uri(
              //                                   scheme: 'tel',
              //                                   path: '01746708538');
              //                               if (await canLaunchUrl(phoneUri)) {
              //                                 await launchUrl(phoneUri);
              //                               }
              //                             },
              //                         ),
              //                         TextSpan(
              //                           text: '☎️০১৮১২৫৫৭২৪৮☎️\n\n,',
              //                           style: TextStyle(
              //                             color: Colors.blue,
              //                             decoration: TextDecoration.underline,
              //                           ),
              //                           recognizer: TapGestureRecognizer()
              //                             ..onTap = () async {
              //                               final Uri phoneUri = Uri(
              //                                   scheme: 'tel',
              //                                   path: '01812557248');
              //                               if (await canLaunchUrl(phoneUri)) {
              //                                 await launchUrl(phoneUri);
              //                               }
              //                             },
              //                         ),
              //
              //                         TextSpan(
              //                             text:
              //                                 " প্রিয় ক্রিকেট প্রেমীরা, দেরি না করে আজই রেজিস্ট্রেশন করুন!মনে রাখবেন, রেজিস্ট্রেশন ছাড়া কেউ টুর্নামেন্টে খেলতে পারবেন না - তাই অবশ্যই রেজিস্ট্রেশন সম্পন্ন করুন!DPL Season-6 হবে এক অসাধারণ ক্রিকেট উৎসব। আপনার প্রতিভা দেখানোর এই সুযোগ হাতছাড়া করবেন না।রেজিস্ট্রেশনের সময় খুবই কম আগামী ০৫ জুলাইয়ের মধ্যে অবশ্যই রেজিস্ট্রেশন সম্পন্ন করুন!আপনার বন্ধুদেরও জানান এবং একসাথে DPL Season-6 এর অংশ হয়ে উঠুন!ডিপিএল সিজন-৬ এ সকল প্লেয়ারদের স্বাগতম! 🎉সকল নিয়মকানুন সাপেক্ষে পরিবর্তনযোগ্য। চূড়ান্ত নিয়মাবলী খুব শীঘ্রই ঘোষণা করা হবে।#DPLSeason6 #CricketRegistration #DeedarPremierLeague #JoinNow #CricketBangladesh=================================================",
              //                             style: TextStyle(
              //                               fontSize: 16,
              //                               fontFamily: 'Roboto',
              //                             )),
              //
              //                         // Add more spans as needed...
              //                       ],
              //                     ),
              //                   ),
              //                 ),
              //                 actions: [
              //                   Center(
              //                       child: ElevatedButton(
              //                     style: ButtonStyle(
              //                       backgroundColor:
              //                           MaterialStateProperty.all<Color>(
              //                               Colors.blueAccent),
              //                     ),
              //                     onPressed: () {
              //                       Navigator.pop(context);
              //                     },
              //                     child: Text("Ok",
              //                         style: TextStyle(
              //                           color: Colors.white,
              //                           fontFamily: 'Roboto',
              //                           fontSize: 16,
              //                           fontWeight: FontWeight.bold,
              //                         )),
              //                   ))
              //                 ]);
              //           },
              //         );
              //       },
              //     ),
              //   ],
              // ),
              SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildTextField(bkashAccountController, 'Bkash Account No'),
                    buildTextField(
                        bkashTransactionIdController, 'Bkash Transaction ID'),
                    buildTextField(nameController, 'Name'),
                    buildTextField(phoneController, 'Phone Number'),
                    buildTextField(addressController, 'Address'),
                    buildTextField(districtController, 'District'),
                    buildTextField(nidController, 'NID/Birth Certificate No'),
                    buildDatePickerField(birthDateController, 'Date of Birth'),

                    // buildTextField(
                    //     areaController, 'Area (Local/Semi-Local/Overseas)'),
                    buildDropdownField(
                      selectedValue: selectedArea,
                      items: areaOptions,
                      label: 'Area',
                      onChanged: (val) {
                        setState(() {
                          selectedArea = val;
                        });
                      },
                    ),

                    buildDropdownField<String>(
                      selectedValue: selectedCategory,
                      items: categoryOptions,
                      label: 'category',
                      onChanged: (val) =>
                          setState(() => selectedCategory = val),
                    ),

                    buildDropdownField<String>(
                      selectedValue: selectedSpeciality,
                      items: specialityOptions,
                      label: 'Speciality',
                      onChanged: (val) =>
                          setState(() => selectedSpeciality = val),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Center(child: buildProfileImagePicker()),
              SizedBox(height: 10),
              Text('Upload Profile Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),

              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                ),
                onPressed: submitForm,
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget buildDropdownField<T>({
    required T? selectedValue,
    required List<T> items,
    required String label,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(item is Map
                      ? item['label'] // Map → show label
                      : item.toString()), // String/int → show itself
                ))
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? 'Required' : null,
      ),
    );
  }

  Widget buildDatePickerField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(now.year - 18), // sensible default
            firstDate: DateTime(1900),
            lastDate: now,
          );
          if (picked != null) {
            controller.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
      ),
    );
  }

  Widget buildProfileImagePicker() {
    return Stack(
      children: [
        // Profile Image (or placeholder)
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: _webImageDataUrl != null
              ? NetworkImage(_webImageDataUrl!)
              : _chosenImage != null
                  ? FileImage(File(_chosenImage!.path)) as ImageProvider
                  : AssetImage('assets/sponsors/default1.png'), // placeholder
        ),

        // Camera icon button overlay
        Positioned(
          bottom: 0,
          right: 4,
          child: InkWell(
            onTap: selectImage,
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
