import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookingSummaryDetils extends StatefulWidget {
  const BookingSummaryDetils({super.key});

  @override
  State<BookingSummaryDetils> createState() => _BookingSummaryDetilsState();
}

class _BookingSummaryDetilsState extends State<BookingSummaryDetils> {
  bool payFullAdvance = true;
  int selectedPayment = 0;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:  EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔙 BACK + TITLE
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      "assets/Icons/Vector.png",
                      height: 22,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
               SizedBox(height: 12),
               Text(
                "Booking Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
               SizedBox(height: 24),

              /// 📸 CREATOR CARD
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
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text(
                                    "4.5 (120)",
                                    style: TextStyle(fontSize: 14, color: ColorCode.kWhiteOpacity70,  fontWeight: FontWeight.w500,
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
                                  fontSize: 12, color: ColorCode.kWhiteOpacity70,
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
                                  (index) => Container(
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
                      padding:  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

              SizedBox(height: 10),

              Divider(color: ColorCode.kDividerWhite12,),
               SizedBox(height: 28),


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment Method",
                        style:    TextStyle(
                            fontSize: 14,
                            color: ColorCode.white,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w500
                        ),),
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => Specialities(),
                          //   ),
                          // );
                        },
                        child: Image.asset(
                          "assets/Icons/rightside.png",
                          height: 40,   // bigger height
                          width: 40,
                          color: ColorCode.white,
                        ),
                      )
                    ],
                  ),
                   SizedBox(height: 14),

                  /// 🔹 PAY AT VENUE
                  paymentRadioTile(
                    title: "Pay at Venue",
                    value: 0,
                  ),

                  paymentRadioTile(
                    title: "Pay By Credit or Debit Card",
                    value: 1,
                  ),
                  Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
    color: const Color(0xFF282828),
    borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text(
    "Pay Full Payment in Advance",
    style: TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: "Outfit",
    fontWeight: FontWeight.w400,
    ),
    ),

    /// 🔥 IMAGE-LIKE SWITCH
    gradientSwitch(
    value: payFullAdvance,
    onChanged: (val) {
    setState(() {
    payFullAdvance = val;
    });
    },
    ),
    ],
    ),
    ),


    ],
              ),

              Divider(color: Colors.white30),
               SizedBox(height: 28),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Payment Details",
                    style:    TextStyle(
                        fontSize: 14,
                        color: ColorCode.white,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500
                    ),),

                ],
              ),
              SizedBox(height: 8),
              Container(
                padding:  EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:  ColorCode.k282828,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔹 BASE PACKAGE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Base Package (1 Hour)",
                          style:    TextStyle(
                              fontSize: 12,
                              color: ColorCode.white,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400
                          ),),
                        Text(
                          "\$ 450.00/-",
                          style:    TextStyle(
                              fontSize: 12,
                              color: ColorCode.white,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// 🔹 DISCOUNT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Early Bird Discount (10%)",
                          style:    TextStyle(
                              fontSize: 12,
                              color: ColorCode.green,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400
                          ),
                        ),
                        Text(
                          "- \$45.00/-",
                          style:    TextStyle(
                              fontSize: 12,
                              color: ColorCode.green,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),


                    const SizedBox(height: 10),

                    /// 🔹 TOTAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Total",
                          style:    TextStyle(
                              fontSize: 16,
                              color: ColorCode.white,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w600
                          ),),
                        Text(
                          "\$ 450.00/-",
                          style:    TextStyle(
                              fontSize: 16,
                              color: ColorCode.white,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// 🔹 GREEN PROTECTION BOX
                    Container(
                      padding:  EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:  Color(0xFFD9F8C4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.verified_user,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Beige Project Protection",
                                  style:    TextStyle(
                                      fontSize: 16,
                                      color: ColorCode.black,
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Your payment is protected with Stripe’s secure encryption. Funds are only released when you’re satisfied.",
                                  style:    TextStyle(
                                      fontSize: 10,
                                      color: ColorCode.black,
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
               SizedBox(height: 28),
       Divider(color: Colors.white30,),
              /// 📝 NOTES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Notes",
                    style:    TextStyle(
                        fontSize: 14,
                        color: ColorCode.white,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500
                    ),),

                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorCode.k282828,
                  borderRadius: BorderRadius.circular(12), // ✅ Radius 12px
                  border: Border.all(
                    color: const Color(0x80DDDDDD), // ✅ #DDDDDD at 50%
                    width: 0.5, // ✅ Border 0.5px
                  ),
                ),
                child: TextField(
                  minLines: 4, // ✅ 4 lines height
                  maxLines: 6,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: "Outfit",
                  ),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: "Comments or request",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: ColorCode.kWhiteOpacity70,
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),


              const SizedBox(height: 32),

              /// 🔘 BUTTON

            ],
          ),

        ),

      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child:    SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
             /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOnServices(),
                ),
              );*/
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:  ColorCode.kButtonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
            Text(
              "Add Payment Method",
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




  Widget priceRow(String title, String price,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: Colors.white70,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isDiscount
                  ? const Color(0xFF7ED957)
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  Widget paymentRadioTile({
    required String title,
    required int value,
  }) {
    final bool isSelected = selectedIndex == value;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          selectedIndex = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:  Color(0xFF282828),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            /// 🔹 TITLE
            Expanded(
              child: Text(
                title,
                style:  TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w400
                ),
              ),
            ),

            /// 🔹 CUSTOM RADIO (RIGHT SIDE)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                /// Gradient when selected
                gradient: isSelected
                    ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8D1AB), // light shade
                    Color(0xFFD4A14D),
                  ],
                )
                    : null,

                /// Border
                border: Border.all(
                  color: ColorCode.kWhiteOpacity70,
                  width: 1,
                ),
              ),

              /// 🔹 INNER DOT
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget gradientSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          /// 🔥 GRADIENT WHEN ON
          gradient: value
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8D1AB),
              Color(0xFFD4A14D),
            ],
          )
              : null,

          /// OFF COLOR
          color: value ? null : Colors.white.withOpacity(0.25),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment:
          value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

}
