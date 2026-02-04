import 'dart:ui';

import 'package:flutter/material.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import 'booking_summary_view_summary.dart';

class BookinReviewConfirm extends StatefulWidget {
  final int bookingId;

  const BookinReviewConfirm({super.key, required this.bookingId});

  @override
  State<BookinReviewConfirm> createState() => _BookinReviewConfirmState();
}

class _BookinReviewConfirmState extends State<BookinReviewConfirm> {
  bool payFullAdvance = true;
  int selectedPayment = 0;
  int selectedIndex = 0;
bool loding =true;



  List<dynamic> savedCards = [];
  bool hasSavedCard = false;






  final TextEditingController NotesController = TextEditingController();


  Map<String, dynamic>? summaryData;

  Map<String, dynamic>? creative;
  Map<String, dynamic>? booking;
  Map<String, dynamic>? totals;
  List<dynamic> addons = [];


  @override
  void initState() {
    super.initState();
    _fetch_book_summary();
  }

  Future<void> _fetch_book_summary() async {
    setState(() => loding = true);
    print("🟢 FETCH BOOK SUMMARY START");

    try {
      final url =
          "${ApiEndpoints.booking_select}/${widget.bookingId}/summary-details";
      print("➡️ API URL: $url");

      final response = await ApiService().fetchData(url);

      print("📥 FULL API RESPONSE:");
      print(response);

      if (response == null) {
        print("❌ RESPONSE IS NULL");
        return;
      }

      print("ℹ️ ERROR FLAG: ${response['error']}");
      print("ℹ️ MESSAGE: ${response['message']}");

      if (response['error'] == false) {
        final data = response['data'] ?? {};
        print("📦 DATA OBJECT:");
        print(data);

        creative = data['creative'];
        booking = data['booking'];
        totals = data['totals'];
        addons = data['addons'] ?? [];
        savedCards = data['saved_cards'] ?? [];
        hasSavedCard = savedCards.isNotEmpty;

        /// 🔥 FIND DEFAULT CARD
        if (hasSavedCard) {
          final defaultCard = savedCards.firstWhere(
                (card) => card['is_default'] == true,
            orElse: () => savedCards.first,
          );

        }

        debugPrint("💳 HAS SAVED CARD: $hasSavedCard");
        print("✅ CREATIVE:");
        print(creative);

        print("✅ BOOKING:");
        print(booking);

        print("✅ TOTALS:");
        print(totals);

        print("✅ ADDONS:");
        print(addons);
      } else {
        print("❌ API RETURNED ERROR");
      }
    } catch (e) {
      print("🔥 EXCEPTION OCCURRED:");
      print(e);
    } finally {
      setState(() => loding = false);
      print("🛑 FETCH BOOK SUMMARY END");
    }
  }

  Future<void> confirm_reschedule() async {
    setState(() => loding = true);

    try {
      print(
        "➡️ API URL: ${ApiEndpoints.booking}/${widget.bookingId}/confirm-reschedule",
      );

      final response = await ApiService().postData(
        "${ApiEndpoints.booking}/${widget.bookingId}/confirm-reschedule",
        {}, // empty body
      );

      print("📥 FULL API RESPONSE:");
      print(response);

      if (response == null) {
        print("❌ RESPONSE IS NULL");
        return;
      }

      if (response['error'] == false) {
        // ✅ SUCCESS
        showScheduleUpdatedDialog(context);
      } else {
        // ❌ API ERROR
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Something went wrong")),
        );
      }
    } catch (e) {
      print("🔥 EXCEPTION OCCURRED:");
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error")),
      );
    } finally {
      setState(() => loding = false);
    }
  }

  String getContentTypeTitle(String? type) {
    switch (type) {
      case "1":
        return "Video Shoot";
      case "2":
        return "Photo Shoot";
      case "3":
        return "Photo & Video Shoot";
      default:
        return "Shoot Type";
    }
  }

  String getShootTypeImage() {
    final img = booking?['shoot_type_image_url'];
    if (img == null || img.isEmpty) return "";

    if (img.startsWith("http")) return img;

    return ApiService().getImageURL(img);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,


      appBar: AppBar(
        backgroundColor: ColorCode.bcakgroundcolor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Image.asset(
            "assets/Icons/Reply.png",
            height: 22,
            color: Colors.white,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text("2/2", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.all(16),
          child: Column(
            children: [

              /// STEP INDICATOR
              Row(
                children: List.generate(
                  2,
                      (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      height: 5,
                      decoration: BoxDecoration(
                        color: index < 2
                            ? ColorCode.kButtonColor
                            : ColorCode.kSubtextColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    "Review & Confirm",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
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
                child: getShootTypeImage().isNotEmpty
                    ? Image.network(
                  getShootTypeImage(),
                  height: 144,
                  width: 126,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      "assets/images/Rectangle 34661070.png",
                      height: 144,
                      width: 126,
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
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
                            children:  [

                              SizedBox(height: 6),
                              Text(
                                booking?['project_name'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: "Outfit",
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                booking?['shoot_type_name'] ?? '',
                                style: TextStyle(
                                  fontSize: 12, color: ColorCode.kWhiteOpacity70,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(

                                getContentTypeTitle(booking?['content_type']),
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
                            "${booking?['start_time']} - ${booking?['end_time']} "
                                "(${booking?['duration_hours']}h)",
                          ),
                          const SizedBox(height: 10),
                          infoRowBlack(
                            Icons.calendar_month,
                            booking?['event_date'] ?? '--',
                          ),
                          const SizedBox(height: 10),
                          infoRowBlack(
                            Icons.location_on,
                            booking?['event_location'] ?? '--',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white24,),
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
                    title: "Pay Via Stripe",
                    value: 0,
                  ),

                  paymentRadioTile(
                    title: "Pay By Credit or Debit Card",
                    value: 1,
                  ),
               /*   Container(
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
                  ),*/


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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorCode.k282828,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [

                    priceRow(
                      "Base Package",
                      "\$ ${totals?['base_amount'] ?? 0}.00/-",
                    ),

                    if ((totals?['addons_amount'] ?? 0) > 0)
                      priceRow(
                        "Add-ons",
                        "\$ ${totals?['addons_amount']}.00/-",
                      ),

                    if ((totals?['discount_amount'] ?? 0) > 0)
                      priceRow(
                        "Discount",
                        "- \$ ${totals?['discount_amount']}.00/-",
                        isDiscount: true,
                      ),

                    const Divider(color: Colors.white30),

                    priceRow(
                      "Total",
                      "\$ ${totals?['total_amount'] ?? 0}.00/-",
                      isTotal: true,
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

            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [

            /// 🔹 PRICE + DETAILS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children:  [
                Text(
                  "\$ ${totals?['total_amount'] ?? 0}.00/-",
                  // "\$ ${totals?['total_amount'] ?? 0}.00/-",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${booking?['service_count'] ?? 0} Services | ${booking?['duration_hours'] ?? 0} Hours",
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            /// 🔹 CONTINUE BUTTON
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await confirm_reschedule();
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorCode.kHeadingColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
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

  void showScheduleUpdatedDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Schedule Updated",
      barrierColor: Colors.black.withOpacity(0.35), // dark overlay
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // 🔥 BLUR STRENGTH
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// 🔹 ICON STACK

                    Image.asset(
                      "assets/images/Group 1171276698 (1).png",
                      height: 64,
                      width: 64,
                      fit: BoxFit.contain,
                    ),


                    const SizedBox(height: 16),

                    /// 🔹 TITLE
                    const Text(
                      "Schedule Updated",
                      style: TextStyle(
                        fontFamily: "Unbounded",
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: ColorCode.kButtonColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 🔹 SUBTITLE
                    const Text(
                      "Your booking has been rescheduled with updated date and time.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ColorCode.kWhiteOpacity70,
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [

                        // ✅ Next Button
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE7C89E),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) =>BookingSummaryDetails()),
                                );
                              },
                              child: const Text(
                                "View Summary",
                                style: TextStyle(
                                  color: ColorCode.kHeadingColor,
                                  fontFamily: 'Unbounded',   // ← Add this
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    /*  transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(anim),
            child: child,
          ),
        );
      },*/
    );
  }
}
