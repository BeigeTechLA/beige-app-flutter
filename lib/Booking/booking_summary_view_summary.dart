import 'package:beige/MainScreen.dart';
import 'package:flutter/material.dart';
import '../utility/ColorCode.dart';

class BookingSummaryDetails extends StatefulWidget {
  const BookingSummaryDetails({super.key});

  @override
  State<BookingSummaryDetails> createState() => _BookingSummaryDetailsState();
}

class _BookingSummaryDetailsState extends State<BookingSummaryDetails> {
  bool payFullAdvance = true;
  int selectedPayment = 0;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              Text(
                "Booking Summary Details",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorCode.k282828,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔹 TOP PROFILE ROW
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            "assets/images/Rectangle 34661070.png",
                            height: 144,
                            width: 126,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14,
                                      color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text(
                                    "4.5 (120)",
                                    style: TextStyle(fontSize: 14,
                                      color: ColorCode.kWhiteOpacity70,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Angela Kia",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: "Outfit",
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Videography Specialist",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorCode.kWhiteOpacity70,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "From \$450/Hr",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorCode.kButtonColor,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              (constraints.maxWidth / 14).floor(),
                                  (index) =>
                                  Container(
                                    width: 6,
                                    height: 1,
                                    color: Colors.white30,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),


                    const SizedBox(height: 12),

                    /// ⬜ WHITE INFO BOX
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      child: Column(
                        children: [
                          infoRowBlack(
                            Icons.access_time,
                            "01:30 AM to 03:30 AM (1h duration)",
                          ),
                          const SizedBox(height: 10),
                          infoRowBlack(
                            Icons.calendar_month,
                            "Apr 01, 2025 - Apr 04, 2025",
                          ),
                          const SizedBox(height: 10),
                          infoRowBlack(
                            Icons.location_on,
                            "2458 Sunset Boulevard, Los Angeles, CA 90026",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: ColorCode.kDividerWhite12,),
              SizedBox(height: 28),


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment Details",
                        style: TextStyle(
                            fontSize: 14,
                            color: ColorCode.white,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w500
                        ),),
                    ],
                  ),
                  SizedBox(height: 14),


                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF282828),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [

                            /// 🔹 TITLE
                            Text(
                              "Confirmation Number",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                            Text(
                              "Transaction ID",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [

                            /// 🔹 TITLE
                            Text(
                              "#BG-20250125-001",
                              style: TextStyle(
                                  color: ColorCode.kWhiteOpacity70,
                                  fontSize: 12,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                            Text(
                              "txn_1234567890",
                              style: TextStyle(
                                  color: ColorCode.kWhiteOpacity70,
                                  fontSize: 12,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                        Divider(color: ColorCode.kDividerWhite12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [

                            /// 🔹 TITLE
                            Text(
                              "Payment Method",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            /// 🔹 TITLE
                            Text(
                              "Visa Card - 4556 **** **** **** ",
                              style: TextStyle(
                                  color: ColorCode.kWhiteOpacity70,
                                  fontSize: 12,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400
                              ),
                            ),

                          ],
                        ),
                        Divider(color: ColorCode.kDividerWhite12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [

                            /// 🔹 TITLE
                            Text(
                              "Payment Date & Time",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [

                            /// 🔹 TITLE
                            Text(
                              "August 26, 2025 at 06:50 PM",
                              style: TextStyle(
                                  color: ColorCode.kWhiteOpacity70,
                                  fontSize: 12,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400
                              ),
                            ),

                          ],
                        ),
                        Divider(color: ColorCode.kDividerWhite12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [

                            /// 🔹 TITLE
                            Text(
                              "Amount Paid",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [

                            /// 🔹 TITLE
                            Text(
                              "\$405.00",
                              style: TextStyle(
                                  color: ColorCode.green,
                                  fontSize: 12,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400
                              ),
                            ),

                          ],
                        ),

                      ],
                    ),
                  ),



                ],
              ),

            ],
          ),

        ),

      ),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.all(22),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Mainscreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorCode.kButtonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
            Text(
              "Book Another Session",
              style: TextStyle(
                fontFamily: "Unbounded",
                fontWeight: FontWeight.w500,
                color: ColorCode.kHeadingColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 WIDGETS
  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget infoRowBlack(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.black87,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 12,
                color: ColorCode.black,
                fontFamily: "Outfit",
                fontWeight: FontWeight.w400

            ),
          ),
        ),
      ],
    );
  }


}

