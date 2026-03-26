import 'dart:ui';

import 'package:beige/Home/HomeSekect/payment_method.dart';
import 'package:beige/MainScreen.dart';
import 'package:beige/utility/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import '../widgets/TopMessage.dart';
import 'Shoot_updated_screen.dart';
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

  Map<String, dynamic>? pricing;
  List<dynamic> pricingBreakdown = [];


  List<dynamic> savedCards = [];
  bool hasSavedCard = false;




  String creativeName = "";
  String creativeRole = "";
  String creativeImage = "";
  String creativeRate = "";
  String creativeRatingText = "";
  Map<String, dynamic>? crewSummary;

  final TextEditingController NotesController = TextEditingController();


  Map<String, dynamic>? summaryData;

  Map<String, dynamic>? creative;
  Map<String, dynamic>? booking;
  Map<String, dynamic>? totals;
  List<dynamic> addons = [];


  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    final d = DateTime.parse(date);
    return DateFormat('EEE, dd MMM yyyy').format(d);
  }

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
        pricing = data['pricing'];
        pricingBreakdown = pricing?['breakdown'] ?? [];
        creative = data['creative'];
        booking = data['booking'];
        totals = data['totals'];
        addons = data['addons'] ?? [];

        booking = data['booking'];
        pricing = data['pricing'];

        crewSummary = data['crew_summary'];

        /// ✅ CHECK SAVED CARD
        List savedCards = data['payment_methods']?['saved_cards'] ?? [];
        hasSavedCard = savedCards.isNotEmpty;

        if (!hasSavedCard) {
          selectedIndex = 0; // force default to card
        }
        creativeRole = getContentTypeTitle(
          int.tryParse(booking?['content_type'] ?? "0") ?? 0,
        );
        creativeName = booking?['shoot_type_name'] ?? "—";
        creativeImage = booking?['shoot_type_image_url'] ?? "";
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

      } else {
        // ❌ API ERROR
        TopMessage.show(context,response['message'] ?? "Something went wrong");
      }
    } catch (e) {
      print("🔥 EXCEPTION OCCURRED:");
      print(e);
      TopMessage.show(context,'Network error');

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Network error")),
      // );
    } finally {
      setState(() => loding = false);
    }
  }

  String getContentTypeTitle(int contentTypeId) {
    switch (contentTypeId) {
      case 1:
        return "Video Shoot Type";
      case 2:
        return "Photo Shoot Type";
      case 3:
        return "Photo & Video Shoot Type";
      default:
        return "Shoot Type";
    }
  }

  List<String> getContentTypeTitles(int contentTypeId) {
    switch (contentTypeId) {
      case 1:
        return ["Video Shoot Type"];
      case 2:
        return ["Photo Shoot Type"];
      case 3:
        return [
          "Video Shoot Type",
          "Photo Shoot Type",
        ];
      default:
        return ["Shoot Type"];
    }
  }

  int getSafeContentType() {
    final value = booking?['content_type'];

    if (value == null) return 0;

    if (value is int) return value;

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
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
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 16), // 🔥 control position
            child: Align(
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(
                images.back, // 🔥 updated path
                height: 22,
                width: 22,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
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
                      fontFamily: "Unbounded ",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorCode.white,
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

                                getContentTypeTitle(getSafeContentType()),

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

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                            "assets/svg/Group 2087328870.svg",
                            "${booking?['start_time']} to ${booking?['end_time']} "
                                "(${pricing?['duration_hours']}h duration)",
                          ),
                          const SizedBox(height: 8),
                          infoRowBlack(
                            "assets/svg/Frame.svg",
                            formatDate(booking?['event_date']),
                          ),
                          const SizedBox(height: 8),
                          infoRowBlack(
                            "assets/svg/location.svg",
                            booking?['event_location'] ?? "",
                          ),

                        ],
                      ),
                    )
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
                        "Editing Services",
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282828),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 🔹 Title
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            "$creativeRole:",
                            style: const TextStyle(
                              color: ColorCode.white,
                              fontSize: 12,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        /// 🔹 Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (booking?['edit_types'] ?? []).length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.3, // thoda slim card
                          ),
                          itemBuilder: (context, index) {

                            final edit = booking!['edit_types'][index];

                            final parts = edit.split('(');
                            final title = parts[0].trim();
                            final duration = parts.length > 1 ? "(${parts[1]}" : "";

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: ColorCode.kGoldLight20,   // ✅ background change
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  /// 🔹 Title
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: ColorCode.kButtonColor, // ✅ text color change
                                      fontFamily: "Outfit",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  /// 🔹 Duration
                                  if (duration.isNotEmpty)
                                    Text(
                                      duration,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: ColorCode.kButtonColor, // ✅ text color change
                                        fontFamily: "Outfit",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),


                  SizedBox(height: 14),
                  // _buildField("Full Name*", nameController),
                  //
                  // const SizedBox(height: 15),
                  //
                  // _buildField("Email ID", emailController),
                  //
                  // const SizedBox(height: 15),
                  //
                  // _buildField("Phone Number*", phoneController, isPhone: true),



                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pricing Summary",
                        style: TextStyle(
                            fontSize: 14,
                            color: ColorCode.white,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: ColorCode.kGoldGradientLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Package Offer",
                              style: TextStyle(
                                color: ColorCode.kHeadingColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Outfit",
                              ),
                            ),
                            const Divider(color: ColorCode.black),

                            _buildCheckRow(
                              index: 1,
                              text: "Unlimited Usage Rights",
                              iconPath: "assets/newbookflow/security-wifi (1).png",
                            ),
                            const SizedBox(height: 12),
                            _buildCheckRow(
                              index: 2,
                              text: "All Raw Content",
                              iconPath: images.all,
                            ),
                            const SizedBox(height: 12),
                            _buildCheckRow(
                              index: 3,
                              text: "Include Edited Deliverable",
                              iconPath:images.include,
                            ),
                            const SizedBox(height: 12),
                            _buildCheckRow(
                              index: 4,
                              text: "Up to 2 Sets of Revisions",
                              iconPath:images.up,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      Divider(color: ColorCode.kDividerWhite12),
                      // --- SHOOT COST CARD ---
                      builderPricingCard(
                        title: "Shoot Cost",
                        amount: calculateShootCost()['total'],
                        subtitles: [
                          if (calculateShootCost()['hasPreProd']) "",
                          if (calculateShootCost()['hasRush']) "• Rush Fee",

                        ],
                      ),

                      // --- EDITING SERVICES CARD ---
                      builderPricingCard(
                        title: "Editing Services",
                        amount: (pricing?['editing_amount'] ?? 0).toDouble(),
                        subtitles: (pricing?['editing_breakdown'] as List? ?? [])
                            .map((e) => "• ${e['label']}")
                            .toList(),
                      ),

                      // --- ADDITIONAL CREW CARD ---
                      if (calculateAdditionalCrew()['total'] > 0)
                        builderPricingCard(
                          title: "Additional Crew",
                          amount: calculateAdditionalCrew()['total'],
                          subtitles: (calculateAdditionalCrew()['counts'] as Map<int, int>)
                              .entries
                              .map((e) => "• ${e.value}x ${e.key == 1 ? 'Videographer' : 'Photographer'}")
                              .toList(),
                        ),

                      const SizedBox(height: 10),
                      const Divider(color: ColorCode.kDividerWhite12),

                      /// 🔹 TOTAL
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Amount",
                              style: TextStyle(
                                fontSize: 16,
                                color: ColorCode.white,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "\$${pricing?['total_amount']?.toStringAsFixed(2) ?? "0.00"}",
                              style: const TextStyle(
                                fontSize: 18,
                                color: ColorCode.kButtonColor, // Making total stand out
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )


                ],
              ),
              /* Column(
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentMethodScreen(bookingId:widget.bookingId),
                            ),
                          );
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
               *//*   Container(
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
                  ),*//*


                ],
              ),*/





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
            /* Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children:  [
                Text(
            "\$ ${pricing?['total_amount'] ?? 0}.00/-",

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
            ),*/

            const SizedBox(width: 16),

            /// 🔹 CONTINUE BUTTON
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShootUpdatedScreen(

                        ),
                      ),
                    );
                  },


                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Update Schedule",
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

  Widget infoRowBlack(String svgIcon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// SVG ICON
        SvgPicture.asset(
          svgIcon,
          height: 16,
          width: 16,
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
              fontWeight: FontWeight.w400,
            ),
          ),

        ),
        const SizedBox(height: 8),
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

  Widget _buildCheckRow({
    required int index,
    required String text,
    required String iconPath,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 28,
          width: 28,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: index==1
                ?
            Image.asset( iconPath, height: 14, width: 14, color: Colors.white, )

            :SvgPicture.asset(
              iconPath, // 👈 now this should be .svg path
              height: 14,
              width: 14,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: ColorCode.black,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: "Outfit",
            ),
          ),
        ),
      ],
    );
  }

  Widget builderPricingCard({
    required String title,
    required double amount,
    required List<String> subtitles,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Darker background for the cards
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Outfit",
                ),
              ),
              Text(
                "\$${NumberFormat('#,##0.00').format(amount)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Outfit",
                ),
              ),
            ],
          ),
          /*    if (subtitles.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: subtitles
                  .map((sub) => Text(
                sub,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontFamily: "Outfit",
                ),
              ))
                  .toList(),
            ),
          ]*/
        ],
      ),
    );
  }
  /// Calculates Shoot Cost: (Base Price of 1st Videographer + 1st Photographer) + Pre-prod + Rush
  Map<String, dynamic> calculateShootCost() {
    double preProd = pricing?['pre_production']?.toDouble() ?? 0.0;
    double rushFee = pricing?['rush_fee']?.toDouble() ?? 0.0;
    double shootCost = preProd + rushFee;

    // Use crewSummary instead of bookingSummaryData
    Map<String, dynamic> requiredByRole = crewSummary?['required_by_role'] ?? {};
    Map<int, int> processedCount = {};

    List<dynamic> creatives = pricing?['creative_price_breakdown'] ?? [];

    for (var c in creatives) {
      int roleId = c['role_id'];
      // API keys are strings "1", "2", so we convert to string for lookup
      int required = int.tryParse(requiredByRole[roleId.toString()]?.toString() ?? "0") ?? 0;
      int current = processedCount[roleId] ?? 0;

      if (current < required) {
        shootCost += (c['amount'] ?? 0).toDouble();
        processedCount[roleId] = current + 1;
      }
    }

    return {
      "total": shootCost,
      "hasPreProd": preProd > 0,
      "hasRush": rushFee > 0,
    };
  }

  Map<String, dynamic> calculateAdditionalCrew() {
    double additionalTotal = 0;
    Map<int, int> extraCount = {};

    Map<String, dynamic> requiredByRole = crewSummary?['required_by_role'] ?? {};
    Map<int, int> processedCount = {};

    List<dynamic> creatives = pricing?['creative_price_breakdown'] ?? [];

    for (var c in creatives) {
      int roleId = c['role_id'];
      int required = int.tryParse(requiredByRole[roleId.toString()]?.toString() ?? "0") ?? 0;
      int current = processedCount[roleId] ?? 0;

      if (current < required) {
        processedCount[roleId] = current + 1;
      } else {
        additionalTotal += (c['amount'] ?? 0).toDouble();
        extraCount[roleId] = (extraCount[roleId] ?? 0) + 1;
      }
    }

    return {
      "total": additionalTotal,
      "counts": extraCount,
    };
  }
}
