import 'package:flutter/material.dart';

class BookingSummaryDetils extends StatefulWidget {
  const BookingSummaryDetils({super.key});

  @override
  State<BookingSummaryDetils> createState() => _BookingSummaryDetilsState();
}

class _BookingSummaryDetilsState extends State<BookingSummaryDetils> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/Icons/Vector.png",
                    height: 24,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
                 SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
