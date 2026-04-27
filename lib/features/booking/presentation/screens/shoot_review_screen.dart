import 'package:beige/shared/widgets/top_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/shared/widgets/custom_input_field.dart';
import 'package:beige/features/booking/presentation/providers/booking_review_notifier.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/core/utils/date_time_utils.dart';
import 'package:beige/shared/widgets/loading.dart' show AppLoader;

class ShootReviewScreen extends ConsumerStatefulWidget {
  final int bookingId;
  const ShootReviewScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ShootReviewScreen> createState() => _ShootReviewScreenState();
}

class _ShootReviewScreenState extends ConsumerState<ShootReviewScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? nameError;
  String? emailError;
  String? phoneError;

  int currentStep = 2;
  bool payFullAdvance = true;
  int selectedIndex = 0;
  bool isProcessing = false;

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

  List<String> getAdditionalCrewSubtitles(Map<String, dynamic>? crewSummary) {
    final extra = crewSummary?['extra_by_role'] ?? {};
    List<String> list = [];
    extra.forEach((key, value) {
      if (value > 0) {
        list.add("${getRoleName(key)}: $value");
      }
    });
    return list;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  double getShootAmount(Map<String, dynamic>? pricing) {
    return (pricing?['pricing_sections']?['shoot_cost']?['amount'] ?? 0).toDouble();
  }

  double getEditingAmount(Map<String, dynamic>? pricing) {
    return (pricing?['pricing_sections']?['editing_services']?['amount'] ?? 0).toDouble();
  }

  double getAdditionalCrewAmount(Map<String, dynamic>? pricing) {
    return (pricing?['pricing_sections']?['additional_crew']?['amount'] ?? 0).toDouble();
  }

  Future<void> _openStripeSheet() async {
    if (isProcessing) return;

    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    setState(() => isProcessing = true);

    final notifier = ref.read(
      bookingReviewNotifierProvider(widget.bookingId).notifier,
    );

    try {
      // 1. Save contact info
      final isSaved = await notifier.savePaymentInfo(
        bookingId: widget.bookingId,
        data: {
          "payment_method": getPaymentMethod(),
          "full_name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "phone": phoneController.text.trim(),
        },
      );

      if (!isSaved) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to save details")),
          );
        }
        return;
      }

      // 2. Create payment sheet
      final paymentSheet = await notifier.createPaymentSheet(
        bookingId: widget.bookingId,
      );

      if (paymentSheet == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to create payment sheet")),
          );
        }
        return;
      }

      final clientSecret = paymentSheet['payment_intent_client_secret'];

      if (clientSecret == null || (clientSecret as String).isEmpty) {
        throw "Client secret missing";
      }

      // 3. Init Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerId: paymentSheet['customer_id'],
          customerEphemeralKeySecret: paymentSheet['ephemeral_key_secret'],
          merchantDisplayName: "BEIGE",
        ),
      );

      // 4. Present Stripe
      await Stripe.instance.presentPaymentSheet();

      // 5. Confirm with backend
      final paymentIntentId = clientSecret.split('_secret').first;

      final confirmed = await notifier.confirmPayment(
        bookingId: widget.bookingId,
        paymentIntentId: paymentIntentId,
      );

      if (!confirmed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment confirmation failed")),
          );
        }
        return;
      }

      // 6. Navigate to success
      if (mounted) {
        context.goNamed(
          RouteNames.paymentSuccess,
          pathParameters: {'bookingId': widget.bookingId.toString()},
          extra: {
            'fullName': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'paymentMethod': getPaymentMethod(),
          },
        );
      }
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.error.localizedMessage ?? "Payment failed")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
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
    final reviewState = ref.watch(
      bookingReviewNotifierProvider(widget.bookingId),
    );
    final isLoading = reviewState.status == BookingReviewStatus.loading;
    final booking = reviewState.booking;
    final pricing = reviewState.pricing;
    final crewSummary = reviewState.crewSummary;
    final hasSavedCard = reviewState.hasSavedCard;

    final creativeName = booking?['shoot_type_name'] ?? "No Name";
    final creativeImage = booking?['shoot_type_image_url'] ?? "";
    final creativeRole = getContentTypeTitle(
      int.tryParse(booking?['content_type']?.toString() ?? "0") ?? 0,
    );

    if (!hasSavedCard && selectedIndex != 0) {
      selectedIndex = 0;
    }

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
                onTap: () => context.pop(),
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
                                        "${ApiEndpoints.imageUrl}$creativeImage",
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

                                        const SizedBox(height: 6),
                                        Text(
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


                                        const SizedBox(height: 10),
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

                                    /// 🔥 MULTI DAY
                                    if ((booking?['booking_days'] ?? []).isNotEmpty) ...[
                                      ...List.generate(booking!['booking_days'].length, (index) {
                                        var day = booking!['booking_days'][index];

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            infoRowBlack(
                                              "assets/svg/Group 2087328870.svg",
                                              "${DateTimeUtils.formatTime(day['start_time'])} to "
                                                  "${DateTimeUtils.formatTime(day['end_time'])} "
                                                  "(${DateTimeUtils.formatDuration((day['duration_hours'] ?? 0).toDouble())})",
                                            ),
                                            const SizedBox(height: 6),

                                            infoRowBlack(
                                              "assets/svg/Frame.svg",
                                              DateTimeUtils.formatDate(day['date']),
                                            ),

                                            const SizedBox(height: 10),
                                          ],
                                        );
                                      }),
                                    ]

                                    /// 🔥 SINGLE DAY
                                    else ...[
                                      infoRowBlack(
                                        "assets/svg/Group 2087328870.svg",
                                        "${DateTimeUtils.formatTime(booking?['start_time'])} to "
                                            "${DateTimeUtils.formatTime(booking?['end_time'])} "
                                            "(${DateTimeUtils.formatDuration((booking?['duration_hours'] ?? 0).toDouble())})",
                                      ),
                                      const SizedBox(height: 6),

                                      infoRowBlack(
                                        "assets/svg/Frame.svg",
                                        DateTimeUtils.formatDate(booking?['event_date']),
                                      ),
                                    ],

                                    /// 📍 LOCATION
                                    const SizedBox(height: 10),
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

                                      Column(
                                        children: List.generate(
                                          booking?['video_edit_types'].length ?? 0,
                                              (index) {
                                            final item = booking?['video_edit_types'][index];

                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.goldLight20,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  "${item['value']} x${item['count']}",
                                                  style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 12,
                                                    fontFamily: "Outfit",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
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

                                      Column(
                                        children: List.generate(
                                          booking?['photo_edit_types'].length ?? 0,
                                              (index) {
                                            final item = booking?['photo_edit_types'][index];

                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.goldLight20,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  "${item['value']} x${item['count']}"
                                                      "${item['note'] != null ? ' (${item['note']})' : ''}",
                                                  style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 12,
                                                    fontFamily: "Outfit",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ]
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
                                builderPricingCard(
                                  title: "Shoot Cost",
                                  amount: getShootAmount(pricing),
                                  subtitles: [],
                                ),

                                builderPricingCard(
                                  title: "Editing Services",
                                  amount: getEditingAmount(pricing),
                                  subtitles: [],
                                ),

                                // --- ADDITIONAL CREW CARD ---
                                if (getAdditionalCrewSubtitles(crewSummary).isNotEmpty)
                                  builderPricingCard(
                                    title: "Additional Crew",
                                    amount: getAdditionalCrewAmount(pricing),
                                    subtitles: getAdditionalCrewSubtitles(crewSummary), // 🔥 YE ADD KAR
                                  ),

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

        context.pushNamed(RouteNames.paymentMethod, extra: {
          'bookingId': widget.bookingId,
        });
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


}
