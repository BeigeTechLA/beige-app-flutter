import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';
import '../../../utility/ColorCode.dart';
import '../../HomeSekect/payment_method.dart';
import 'PaymentSuccessScreen.dart';

class ReviewConfirmScreen extends StatefulWidget {
  // final int id;
  final int bookingId;
  const ReviewConfirmScreen({super.key,  required this.bookingId});

  @override
  State<ReviewConfirmScreen> createState() => _ReviewConfirmScreenState();
}

class _ReviewConfirmScreenState extends State<ReviewConfirmScreen> {


  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool hasSavedCard = false;

  String? nameError;
  String? emailError;
  String? phoneError;

  Map<String, dynamic>? booking;
  List<dynamic> heldCreatives = [];
  Map<String, dynamic>? pricing;
  Map<String, dynamic>? contact;
  String creativeName = "";
  String creativeRole = "";
  String creativeImage = "";
  String creativeRate = "";
  String creativeRatingText = "";
  Map<String, dynamic>? crewSummary;

  int currentStep = 2;
     bool payFullAdvance = true;
    int selectedIndex = 0;
     bool isLoading =true;

  @override
  void initState() {
    super.initState();
    _fetchHomeReview();
  }
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchHomeReview() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking}/${widget.bookingId}/summary-details",
      );

      if (response != null && response['error'] == false) {
        final data = response['data'];

        booking = data['booking'];
        pricing = data['pricing'];
        heldCreatives = data['held_creatives'] ?? [];
        crewSummary = data['crew_summary'];

        /// ✅ CHECK SAVED CARD
        List savedCards = data['payment_methods']?['saved_cards'] ?? [];
        hasSavedCard = savedCards.isNotEmpty;

        if (!hasSavedCard) {
          selectedIndex = 0; // force default to card
        }

        creativeName = booking?['shoot_type_name'] ?? "—";
        creativeImage = booking?['shoot_type_image_url'] ?? "";
        creativeRole = getContentTypeTitle(
          int.tryParse(booking?['content_type'] ?? "0") ?? 0,
        );
      }
    } catch (e) {
      debugPrint("Review API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }



  Future<void> _fetchReview() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService().putData(
        "${ApiEndpoints.booking}/${widget.bookingId}/payment",
        {
          "payment_method": getPaymentMethod(),
          "full_name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "phone": phoneController.text.trim(),
        },
      );

      if (response != null && response['error'] == false) {
        debugPrint("✅ Payment Details Submitted");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              bookingId: widget.bookingId,
              fullName: nameController.text.trim(),
              phone: phoneController.text.trim(),
              paymentMethod: getPaymentMethod(),
            ),
          ),
        );
      }
      else {
        debugPrint("❌ Payment API failed: $response");
      }
    } catch (e) {
      debugPrint("Review API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    final d = DateTime.parse(date);
    return DateFormat('EEE, dd MMM yyyy').format(d);
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

  String getPaymentMethod() {
    switch (selectedIndex) {
      case 0:
        return "1"; // Card
      case 1:
        return "2"; // Stripe
      default:
        return "1";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  "assets/Icons/Reply.png",
                  height: 24,
                  color: ColorCode.white,
                ),
              ),
            ),
            Text(
              "Book & Confirm",
              style: TextStyle(
                fontFamily: "Outfit",
                color: ColorCode.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "3/3",
                style: TextStyle(
                  color: ColorCode.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              Row(
                children: List.generate(3, (index) {
                  double fillWidth = 0;

                  if (index < currentStep) {
                    // ✅ Completed step (FULL)
                    fillWidth = double.infinity;
                  } else if (index == currentStep) {
                    // 🟡 Current step (HALF)
                    fillWidth = 140.44;
                  } else {
                    fillWidth = 0;
                  }

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      height: 5,
                      decoration: BoxDecoration(
                        color: ColorCode.kSubtextColor, // grey background
                        borderRadius: BorderRadius.circular(64),
                      ),
                      child: fillWidth > 0
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 5,
                          width: fillWidth == double.infinity
                              ? null
                              : fillWidth,
                          decoration: BoxDecoration(
                            color: ColorCode.kButtonColor,
                            borderRadius: BorderRadius.circular(64),
                          ),
                        ),
                      )
                          : const SizedBox(),
                    ),
                  );
                }),
              ),

              SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          child: Container(
                            height: 144,
                            width: 126,
                            color: Colors.black12, // optional bg
                            child: creativeImage.isNotEmpty
                                ? Image.network(
                              "${ApiService.imageURL}$creativeImage",
                              fit: BoxFit.cover, // 🔥 proper crop
                              alignment: Alignment.center, // 🔥 center focus
                              errorBuilder: (_, __, ___) {
                                return Image.asset(
                                  "assets/images/Rectangle 34661070.png",
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                );
                              },
                            )
                                : Image.asset(
                              "assets/images/Rectangle 34661070.png",
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),


                        SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// ⭐ Rating
                              /*     Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    creativeRatingText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: ColorCode.kWhiteOpacity70,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ],
                              ),
*/
                              const SizedBox(height: 6),
                              Text(
                                // Content Type:creativeRole,
                                "Content Type: $creativeRole",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ColorCode.kButtonColor,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                creativeName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: "Outfit",
                                ),
                              ),


                              /// 🎥 ROLE


                              const SizedBox(height: 10),

                              /*       /// 💰 RATE
                              creativeRate.isNotEmpty
                                  ? Text(
                                "From \$$creativeRate/Hr",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: ColorCode.kButtonColor,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                                  : const SizedBox(),
*/
                            ],
                          ),
                        ),

                      ],
                    ),

                    SizedBox(height: 14),

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
                            "${booking?['start_time']} to ${booking?['end_time']} "
                                "(${pricing?['duration_hours']}h duration)",
                          ),

                          infoRowBlack(
                            Icons.calendar_month,
                            formatDate(booking?['event_date']),

                          ),

                          infoRowBlack(
                            Icons.location_on,
                            booking?['event_location'] ?? "",
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
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF282828),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(

                                "$creativeRole:", style: TextStyle(
                                  color: ColorCode.white,
                                  fontSize: 12,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400),

                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (booking?['edit_types'] ?? []).length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.4, // 🔥 wrap ke liye better
                          ),
                          itemBuilder: (context, index) {
                            final edit = booking!['edit_types'][index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: ColorCode.kGoldGradientLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  edit,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  maxLines: 3,
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(
                                    color: ColorCode.black,
                                    fontFamily: "Outfit",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),


                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Divider(color: ColorCode.kDividerWhite12,),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Payment Method",
                            style: TextStyle(
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
                                  builder: (context) =>
                                      PaymentMethodScreen(
                                        bookingId: widget.bookingId,),
                                ),
                              );
                            },
                            child: Image.asset(
                              "assets/Icons/rightside.png",
                              height: 40, // bigger height
                              width: 40,
                              color: ColorCode.white,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 14),

                      /// 🔹 PAY AT VENUE
                      /*  paymentRadioTile(
                        title: "Pay By Credit or Debit Card",
                        value: 0,
                      ),

                      paymentRadioTile(
                        title: "Pay Via Stripe",
                        value: 1,
                      ),*/
                      paymentRadioTile(
                        title: hasSavedCard
                            ? "Pay Via Stripe"
                            : "Pay Via Stripe (Add Card First)",
                        value: 1,
                        isDisabled: !hasSavedCard,
                      ),


                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Divider(color: ColorCode.kDividerWhite12,),
                  ),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Contact Information",

                        style: TextStyle(
                            fontSize: 14,
                            color: ColorCode.white,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w500
                        ),),
                    ],
                  ),
                  SizedBox(height: 14),
                  _buildField("Full Name*", nameController),

                  const SizedBox(height: 15),

                  _buildField("Email ID", emailController),

                  const SizedBox(height: 15),

                  _buildField("Phone Number*", phoneController, isPhone: true),

                  const SizedBox(height: 15),

                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Divider(color: ColorCode.kDividerWhite12,),
                  ),

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
                              text: "Unlimited Usage Rights",
                              iconPath: "assets/newbookflow/security-wifi (1).png",
                            ),
                            const SizedBox(height: 12),
                            _buildCheckRow(
                              text: "All Raw Content",
                              iconPath: "assets/newbookflow/File Image.png",
                            ),
                            const SizedBox(height: 12),
                            _buildCheckRow(
                              text: "Include Edited Deliverable",
                              iconPath: "assets/newbookflow/Box.png",
                            ),
                            const SizedBox(height: 12),
                            _buildCheckRow(
                              text: "Up to 2 Sets of Revisions",
                              iconPath: "assets/newbookflow/Refresh.png",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      Divider(color: ColorCode.kDividerWhite12),
                      // --- SHOOT COST CARD ---
                      // --- SHOOT COST CARD ---
                      builderPricingCard(
                        title: "Shoot Cost",
                        amount: calculateShootCost(),
                        subtitles: [],
                      ),

// --- EDITING SERVICES CARD ---
                      builderPricingCard(
                        title: "Editing Services",
                        amount: calculateEditingCost(),
                        subtitles: [],
                      ),

// --- ADDITIONAL CREW CARD ---
                      if (calculateAdditionalCrew() > 0)
                        builderPricingCard(
                          title: "Additional Crew",
                          amount: calculateAdditionalCrew(),
                          subtitles: [],
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
                              "\$${NumberFormat('#,##0.00').format(pricing?['total_amount'] ?? 0)}",
                              style: const TextStyle(
                                fontSize: 18,
                                color: ColorCode.kButtonColor,
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


            ],
          ),

        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [

            // 🔸 Continue Button
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _fetchReview,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Pay \$${NumberFormat('#,##0.00').format(
                      (pricing?['total_amount'] ?? 0).toDouble(),
                    )}",

                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w600,
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


  Widget paymentRadioTile({
    required String title,
    required int value,
    bool isDisabled = false,
  }) {
    final bool isSelected = selectedIndex == value;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isDisabled
          ? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add a card first"),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PaymentMethodScreen(bookingId: widget.bookingId),
          ),
        );
      }
          : () {
        setState(() {
          selectedIndex = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade800 : const Color(0xFF282828),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : Colors.white,
                  fontSize: 14,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected && !isDisabled
                    ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8D1AB),
                    Color(0xFFD4A14D),
                  ],
                )
                    : null,
                border: Border.all(
                  color: ColorCode.kWhiteOpacity70,
                  width: 1,
                ),
              ),
              child: isSelected && !isDisabled
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


  /// Text Field (Email)
  Widget _buildField(
      String label,
      TextEditingController controller, {
        bool isPhone = false,
      }) {
    return TextField(
      controller: controller,
      cursorColor: ColorCode.white,
      style: const TextStyle(color: ColorCode.white),

      /// ✅ PHONE FIELD KE LIYE NUMBER KEYPAD
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,

      /// ✅ SIRF DIGITS (PHONE)
      inputFormatters: isPhone
          ? [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ]
          : null,

      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(color: ColorCode.kWhiteOpacity70),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.5,
          ),
        ),
      ),
    );
  }



  Widget _buildCheckRow({
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
            child: Image.asset(
              iconPath,
              height: 14,
              width: 14,
              color: Colors.white,
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
        color: const Color(0xFF1A1A1A),
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

          if (subtitles.isNotEmpty) ...[
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subtitles.map((sub) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    sub,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontFamily: "Outfit",
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ],
      ),
    );
  }


  double calculateShootCost() {
    double base = pricing?['base_amount']?.toDouble() ?? 0.0;
    double preProd = pricing?['pre_production']?.toDouble() ?? 0.0;
    return base + preProd;
  }

  double calculateEditingCost() {
    return pricing?['editing_amount']?.toDouble() ?? 0.0;
  }

  double calculateAdditionalCrew() {
    double total = pricing?['total_amount']?.toDouble() ?? 0.0;
    double shoot = calculateShootCost();
    double editing = calculateEditingCost();

    double extra = total - (shoot + editing);
    return extra > 0 ? extra : 0;
  }

/// Calculates Shoot Cost: (Base Price of 1st Videographer + 1st Photographer) + Pre-prod + Rush
  /*Map<String, dynamic> calculateShootCost() {
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
  }*/
}
