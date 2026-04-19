import 'package:beige/widgets/TopMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../Customtextfiled/CustomInputField.dart';
import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';
import '../../../app/colors.dart';
import '../../../widgets/loding.dart' show AppLoader;
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

  bool loading = true;
  Map<String, dynamic>? paymentData;
  String? setupIntentClientSecret;


  Map<String, dynamic>? booking;
  List<dynamic> heldCreatives = [];
  Map<String, dynamic>? pricing;
  Map<String, dynamic>? contact;
  String creativeName = "";
  String creativeRole = "";
  String creativeImage = "";
  String creativeRate = "";
  String creativeRatingText = "";
  String videoedittypesdata = "";
  String photedittypesdata = "";
  Map<String, dynamic>? crewSummary;

  int currentStep = 2;
     bool payFullAdvance = true;
    int selectedIndex = 0;
     bool isLoading =true;

  String getRoleName(String roleId) {
    switch (roleId) {
      case "1":
        return "Videographer";
      case "2":
        return "Photographer";
      default:
        return "Crew";
    }
  }
  List<String> getAdditionalCrewSubtitles() {
    final extra = crewSummary?['extra_by_role'] ?? {};

    List<String> list = [];

    extra.forEach((key, value) {
      if (value > 0) {
        list.add("${getRoleName(key)}: $value");
      }
    });

    return list;
  }

  void initState() {
    super.initState();
    _fetchHomeReview();
    _createSetupIntent();
  }
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  List<String> getShootSubtitles() {
    final breakdown = pricing?['pricing_sections']?['shoot_cost']?['breakdown'] ?? [];

    return breakdown
        .map<String>((item) => "${item['label']} : \$${item['amount']}")
        .toList();
  }

  List<String> getEditingSubtitlesNew() {
    final breakdown = pricing?['pricing_sections']?['editing_services']?['breakdown'] ?? [];

    return breakdown
        .map<String>((item) => "${item['label']} : \$${item['amount']}")
        .toList();
  }

  List<String> getAdditionalCrewSubtitlesNew() {
    final breakdown = pricing?['pricing_sections']?['additional_crew']?['breakdown'] ?? [];

    return breakdown
        .map<String>((item) => "${item['label']} : \$${item['amount']}")
        .toList();
  }


  double getShootAmount() {
    return (pricing?['pricing_sections']?['shoot_cost']?['amount'] ?? 0).toDouble();
  }

  double getEditingAmount() {
    return (pricing?['pricing_sections']?['editing_services']?['amount'] ?? 0).toDouble();
  }

  double getAdditionalCrewAmount() {
    return (pricing?['pricing_sections']?['additional_crew']?['amount'] ?? 0).toDouble();
  }
  Future<void> _fetchHomeReview() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking}/${widget.bookingId}/summary-details",
      );

      if (response != null && response['error'] == false) {
        final data = response['data'];
        final bookingData = data['booking'];

        setState(() {
          /// 🔹 MAIN DATA
          booking = bookingData;
          pricing = data['pricing'];
          heldCreatives = data['held_creatives'] ?? [];
          crewSummary = data['crew_summary'];

          /// 🔹 EDIT TYPES
          videoedittypesdata =
              (bookingData['video_edit_types'] ?? []).toString();
          photedittypesdata =
              (bookingData['photo_edit_types'] ?? []).toString();

          /// 🔹 PAYMENT
          List savedCards = data['payment_methods']?['saved_cards'] ?? [];
          hasSavedCard = savedCards.isNotEmpty;

          if (!hasSavedCard) {
            selectedIndex = 0;
          }

          /// 🔥 IMPORTANT (NAME + IMAGE)
          creativeName = bookingData['shoot_type_name'] ?? "No Name";
          creativeImage = bookingData['shoot_type_image_url'] ?? "";

          creativeRole = getContentTypeTitle(
            int.tryParse(bookingData['content_type'] ?? "0") ?? 0,
          );
        });

        /// 🔍 DEBUG (check in console)
        debugPrint("✅ NAME: $creativeName");
        debugPrint("✅ IMAGE: $creativeImage");
        debugPrint("✅ FULL BOOKING: $bookingData");
      }
    } catch (e) {
      debugPrint("❌ Review API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  bool isProcessing = false;
/*void _snakbar(String message){
    TopMessage.show(context, message);

}*/
  Map<String, int> groupEditTypes(List list) {
    Map<String, int> grouped = {};

    for (var item in list) {
      grouped[item] = (grouped[item] ?? 0) + 1;
    }

    return grouped;
  }
  Future<bool> _fetchReview() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return false;
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
        debugPrint("✅ Details Saved");
        return true; // 🔥 only return
      } else {
        debugPrint("❌ API Failed: $response");
        return false;
      }
    } catch (e) {
      debugPrint("❌ ERROR: $e");
      return false;
    } finally {
      setState(() => isLoading = false);
    }
  }
  Future<Map<String, dynamic>> _createSetupIntent() async {
    try {
      debugPrint("🚀 CREATE PAYMENT SHEET API START");

      final response = await ApiService().postData(
        "${ApiEndpoints.booking}/${widget.bookingId}/paymentsheet",
        {},
      );

      debugPrint("📥 FULL RESPONSE:");
      debugPrint(response.toString());

      if (response == null || response['error'] == true) {
        throw response?['message'] ?? "PaymentSheet failed";
      }

      final data = response['data'];
      final paymentSheet = data['payment_sheet'];

      /// ✅ Correct client secret
      setupIntentClientSecret =
      paymentSheet['payment_intent_client_secret'];

      debugPrint("✅ CLIENT SECRET:");
      debugPrint(setupIntentClientSecret);

      return paymentSheet; // 🔥 VERY IMPORTANT
    } catch (e) {
      debugPrint("❌ CREATE PAYMENT SHEET ERROR: $e");
      rethrow;
    } finally {
      debugPrint("🛑 CREATE PAYMENT SHEET API END");
    }
  }
  Future<void> _openStripeSheet() async {
    if (isProcessing) return;

    isProcessing = true;

    try {
      setState(() => loading = true);

      /// 🔥 1️⃣ FIRST SAVE DETAILS
      final isSaved = await _fetchReview();

      if (!isSaved) return;

      debugPrint("✅ Details saved, starting payment...");

      /// 🔥 2️⃣ CREATE PAYMENT SHEET
      final paymentSheet = await _createSetupIntent();

      final clientSecret =
      paymentSheet['payment_intent_client_secret'];

      if (clientSecret == null || clientSecret.isEmpty) {
        throw "Client secret missing";
      }

      /// 🔥 3️⃣ INIT STRIPE
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerId: paymentSheet['customer_id'],
          customerEphemeralKeySecret:
          paymentSheet['ephemeral_key_secret'],
          merchantDisplayName: "BEIGE",
        ),
      );

      /// 🔥 4️⃣ OPEN STRIPE
      await Stripe.instance.presentPaymentSheet();

      debugPrint("✅ Payment Success");

      /// 🔥 5️⃣ GET PAYMENT INTENT ID
      final paymentIntentId = clientSecret.split('_secret').first;

      /// 🔥 6️⃣ BACKEND CONFIRM
      await _attachPaymentMethodToBackend(paymentIntentId);

      /// 🔥 7️⃣ NAVIGATE SUCCESS SCREEN
      if (mounted) {
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

    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error.localizedMessage ?? "Payment failed")),
      );
    } catch (e) {
      debugPrint("❌ ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isProcessing = false;
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _attachPaymentMethodToBackend(
      String paymentIntentId) async {
    try {
      debugPrint("🔗 BACKEND CONFIRM START");

      final payload = {
        "payment_intent_id": paymentIntentId,
      };

      debugPrint("📤 PAYLOAD: $payload");

      final response = await ApiService().postData(
        "${ApiEndpoints.payment}/${widget.bookingId}/stripe/confirm",
        payload,
      );

      debugPrint("📥 BACKEND RESPONSE:");
      debugPrint(response.toString());

      if (response == null || response['error'] == true) {
        throw response?['message'] ?? "Backend confirm failed";
      }

      debugPrint("✅ BACKEND CONFIRM SUCCESS");
    } catch (e) {
      debugPrint("❌ BACKEND ERROR: $e");
      rethrow;
    }
  }


  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";

    final d = DateTime.parse(date);
    return DateFormat('MM-dd-yyyy').format(d); // 👉 04 08, 2026
  }
  String formatTime(String? time) {
    if (time == null || time.isEmpty) return "";

    final parsedTime = DateFormat("HH:mm:ss").parse(time);
    return DateFormat("hh:mm a").format(parsedTime); // 👉 03:27 PM
  }
  String getContentTypeTitle(int contentTypeId) {
    switch (contentTypeId) {
      case 1:
        return "Videography";
      case 2:
        return "Photography";
      case 3:
        return "Photography & Videography";
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
                child: SvgPicture.asset(
                  "assets/svg/back.svg",
                  height: 24,
                ),
                ),

            ),
            Text(
              "Book & Confirm",
              style: TextStyle(
                fontFamily: "Outfit",
                color: AppColors.white,
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
                  fontFamily: "Outfit",
                  color: AppColors.white,
                  fontSize: 14,

                ),
              ),
            ),
          ],
        ),
      ),

      body:  Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                          color: AppColors.textSecondary, // grey background
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
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(64),
                            ),
                          ),
                        )
                            : const SizedBox(),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Review & Confirm",
                      style: TextStyle(
                        fontFamily: "Unbounded",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),


                  ],
                ),

                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
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
                                          return SvgPicture.asset(
                                            "assets/svg/imag_placeholder.svg",

                                            alignment: Alignment.center,
                                          );
                                        },
                                      )
                                          : SvgPicture.asset(
                                        "assets/svg/imag_placeholder.svg",
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
                                              color: AppColors.white70,
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
                                            color: AppColors.primary,
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
                                          color: AppColors.primary,
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withOpacity(0.9)),
                                ),
                                child: Column(
                                  children: [

                                    /// 🔥 CHECK MULTI OR SINGLE
                                    if ((booking?['booking_days'] ?? []).isNotEmpty) ...[

                                      /// ✅ MULTI DAY
                                      ...List.generate(booking!['booking_days'].length, (index) {
                                        var day = booking!['booking_days'][index];

                                        return Column(
                                          children: [
                                            infoRowBlack(
                                              "assets/svg/Group 2087328870.svg",
                                              "${formatTime(day['start_time'])} to ${formatTime(day['end_time'])}"
                                                  " (${day['duration_hours']}h)",
                                            ),
                                            const SizedBox(height: 8),
                                            infoRowBlack(
                                              "assets/svg/Frame.svg",
                                              formatDate(day['date']),
                                            ),
                                            const SizedBox(height: 8)
                                          ],
                                        );
                                      }),

                                    ] else ...[

                                      /// ✅ SINGLE DAY (🔥 IMPORTANT FIX)
                                      infoRowBlack(
                                        "assets/svg/Group 2087328870.svg",
                                        "${formatTime(booking?['start_time'])} to ${formatTime(booking?['end_time'])}"
                                            " (${booking?['duration_hours']}h)",
                                      ),
                                      const SizedBox(height: 8),
                                      infoRowBlack(
                                        "assets/svg/Frame.svg",
                                        formatDate(booking?['event_date']),
                                      ),
                                    ],

                                    /// 📍 LOCATION (COMMON)
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
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Container(
                            height: 1,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.09), // left
                                  Colors.white.withOpacity(0.09), // center
                                  Colors.white.withOpacity(0.09), // right
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),


                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            if ((booking?['video_edit_types'] ?? []).isNotEmpty ||
                                (booking?['photo_edit_types'] ?? []).isNotEmpty) ...[

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Editing Services",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.white,
                                      fontFamily: "Unbounded",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF282828),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    /// ================= VIDEO EDITS =================
                                    if ((booking?['video_edit_types'] ?? []).isNotEmpty) ...[

                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          "Video Edits:",
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 12,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),

                                      Builder(
                                        builder: (context) {
                                          final rawList =
                                          List<String>.from(booking?['video_edit_types'] ?? []);

                                          final Map<String, int> countMap = {};

                                          for (var item in rawList) {
                                            countMap[item] = (countMap[item] ?? 0) + 1;
                                          }

                                          final uniqueList = countMap.keys.toList();

                                          return Column(
                                            children: uniqueList.map((edit) {
                                              final count = countMap[edit];

                                              return Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                   // width: double.infinity,
                                                  margin: const EdgeInsets.only(bottom: 8),
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.goldLight20,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    "${(edit)} x$count",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontSize: 12,
                                                      fontFamily: "Outfit",
                                                      fontWeight: FontWeight.w500, // 🔥 better look
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        },
                                      ),

                                      SizedBox(height: 12),
                                    ],

                                    /// ================= PHOTO EDITS =================
                                    if ((booking?['photo_edit_types'] ?? []).isNotEmpty) ...[

                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          "Photo Edits:",
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 12,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),

                                      Builder(
                                        builder: (context) {
                                          final rawList =
                                          List<String>.from(booking?['photo_edit_types'] ?? []);

                                          final Map<String, int> countMap = {};

                                          for (var item in rawList) {
                                            countMap[item] = (countMap[item] ?? 0) + 1;
                                          }

                                          final uniqueList = countMap.keys.toList();

                                          return Column(
                                            children: uniqueList.map((edit) {
                                              final count = countMap[edit];

                                              return Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                   // width: double.infinity,
                                                  margin: const EdgeInsets.only(bottom: 8),
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.goldLight20,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    "${(edit)} x$count",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontSize: 12,
                                                      fontFamily: "Outfit",
                                                      fontWeight: FontWeight.w500, // 🔥 better look
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Container(
                                  height: 1,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.09), // left
                                        Colors.white.withOpacity(0.09), // center
                                        Colors.white.withOpacity(0.09), // right
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ),
                            ],



                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Contact Information",

                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.white,
                                      fontFamily: "Unbounded",
                                      fontWeight: FontWeight.w500
                                  ),),
                              ],
                            ),
                            SizedBox(height: 14),
                            // _buildField("Full Name*", nameController),
                            CustomInputField(
                              title: "Full Name",
                              controller: nameController,
                            ),
                            const SizedBox(height: 15),

                            CustomInputField(
                              title: "Email ID",
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 15),
                            CustomInputField(
                              title: "Phone Number",
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,

                              onFieldSubmitted: (_) {
                                FocusScope.of(context).unfocus(); // ✅ Done button
                              },

                              onChanged: (value) {
                                if (value.length == 10) {
                                  FocusScope.of(context).unfocus(); // ✅ Auto close after 10 digit
                                }
                              },

                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),            const SizedBox(height: 15),

                            Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Divider(color: AppColors.dividerDark,),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pricing Summary",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.white,
                                      fontFamily: "Unbounded",
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  // padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10,bottom: 10,top: 10),
                                        child: const Text(
                                          "Package Offer",
                                          style: TextStyle(
                                            color: AppColors.textHeading,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Outfit",
                                          ),
                                        ),
                                      ),
                                      const Divider(color: AppColors.black),

                                      _buildCheckRow(
                                        text: "Unlimited Usage Rights",
                                        iconPath: "assets/svg/Unlimited_Usage_Rights.svg",
                                      ),
                                      const SizedBox(height: 12),
                                      _buildCheckRow(
                                        text: "All Raw Content",
                                        iconPath: "assets/svg/All_Raw_Content.svg",
                                      ),
                                      const SizedBox(height: 12),
                                      _buildCheckRow(
                                        text: "Include Edited Deliverable",
                                        iconPath: "assets/svg/Include_Edited_Deliverable .svg",
                                      ),
                                      const SizedBox(height: 12),
                                      _buildCheckRow(
                                        text: "Up to 2 Sets of Revisions",
                                        iconPath: "assets/svg/Up_to _Sets _Revisions.svg",
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 14),
                                Divider(color: AppColors.dividerDark),
                                // --- SHOOT COST CARD ---
                                // --- SHOOT COST CARD ---
                                builderPricingCard(
                                  title: "Shoot Cost",
                                  amount: getShootAmount(),
                                  subtitles: [],
                                ),

                                // --- EDITING SERVICES CARD ---
                                /* builderPricingCard(
                          title: "Editing Services",
                          amount: calculateEditingCost(),
                          subtitles: [],
                        ),*/
                                builderPricingCard(
                                  title: "Editing Services",
                                  amount: getEditingAmount(),
                                  subtitles: [],
                                  // subtitles: getEditingSubtitles(),
                                ),

                                // --- ADDITIONAL CREW CARD ---
                                if (getAdditionalCrewSubtitles().isNotEmpty)
                                  builderPricingCard(
                                    title: "Additional Crew",
                                    amount: getAdditionalCrewAmount(),
                                    subtitles: getAdditionalCrewSubtitles(), // 🔥 YE ADD KAR
                                  ),

                                /*
                        if (calculateAdditionalCrew() > 0)
                          builderPricingCard(
                            title: "Additional Crew",
                            amount: calculateAdditionalCrew(),
                            subtitles: [],
                          ),*/

                                const SizedBox(height: 10),
                                const Divider(color: AppColors.dividerDark),

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
                                          color: AppColors.primary,
                                          fontFamily: "Outfit",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "\$${NumberFormat('#,##0.00').format(pricing?['total_amount'] ?? 0)}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: AppColors.white,
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



              ],
            ),
          ),
          if (isLoading)
            const AppLoader()
        ],

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
                  onPressed: isLoading ? null : _openStripeSheet,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: isProcessing
                        ? AppColors.surfaceVariant // 👈 disabled look
                        : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Pay \$${NumberFormat('#,##0.00').format(
                      (pricing?['total_amount'] ?? 0).toDouble(),
                    )}",

                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeading,
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
 /* String _cleanText(String text) {
    return text
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'(\d+)'), (match) => match.group(0)!) // numbers safe
        .split(' ')
        .map((word) =>
    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }*/

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
              color: AppColors.black,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w400,
            ),
          ),

        ),
        const SizedBox(height: 8),
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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Please add a card first"),
        //   ),
        // );
        TopMessage.show(context,'Please add a card first');

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
                  color: AppColors.white70,
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
      cursorColor: AppColors.white,
      style: const TextStyle(color: AppColors.white),

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
        labelStyle: const TextStyle(color: AppColors.white70),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.white70,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.white70,
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
    return Padding(
      padding: const EdgeInsets.only(left: 10,bottom: 4,),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              iconPath,
              height:32,
              width: 32,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.start,
              style:
              const TextStyle(

                color: AppColors.black,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontFamily: "Outfit",
              ),
            ),
          ),
        ],
      ),
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
    double base = (pricing?['base_amount'] ?? 0).toDouble();
    double preProd = (pricing?['pre_production'] ?? 0).toDouble();
    double rushFee = (pricing?['rush_fee'] ?? 0).toDouble();

    return base + preProd + rushFee;   // ✅ Rush added
  }

  double calculateEditingCost() {
    return (pricing?['editing_amount'] ?? 0).toDouble();
  }

  double calculateAdditionalCrew() {
    return (pricing?['extra_creatives_amount'] ?? 0).toDouble();
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
