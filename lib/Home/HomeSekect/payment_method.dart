import 'package:biegeapp/app/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../NewBookingFlow/Book_Confirm/review_confirm_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final int bookingId;
  const PaymentMethodScreen({super.key, required this.bookingId});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  List<dynamic> savedCards = [];
  List<dynamic> recommended = [];

  @override
  void initState() {
    super.initState();
    _fetchBookSummary();
    _createSetupIntent();
  }


  bool loading = true;
  Map<String, dynamic>? paymentData;
  String? setupIntentClientSecret;


  bool isProcessing = false;
  Future<void> _fetchBookSummary() async {
    setState(() => loading = true);

    try {
      debugPrint("🚀 API CALL START");
      debugPrint("📡 API URL: ${ApiEndpoints.payment}");

      final response = await ApiService().fetchData(
        ApiEndpoints.payment,
      );

      debugPrint("📥 RAW RESPONSE:");
      debugPrint(response.toString());

      if (response != null) {
        debugPrint("ℹ️ error flag: ${response['error']}");
        debugPrint("ℹ️ message: ${response['message']}");
      }

      if (response != null && response['error'] == false) {
        debugPrint("✅ API SUCCESS");

        final data = response['data'];
        debugPrint("📦 DATA OBJECT:");
        debugPrint(data.toString());

        setState(() {
          savedCards = data['saved_cards'] ?? [];
          recommended = data['recommended'] ?? [];
          paymentData = data;
        });
      } else {
        debugPrint("❌ API ERROR MESSAGE: ${response?['message']}");
      }
    } catch (e) {
      debugPrint("❌ EXCEPTION OCCURRED:");
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => loading = false);
        debugPrint("🛑 API CALL END");
      }
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

      debugPrint("✅ PAYMENT SHEET DATA:");
      debugPrint(paymentSheet.toString());

      /// ✅ CORRECT CLIENT SECRET
      setupIntentClientSecret =
      paymentSheet['payment_intent_client_secret'];

      debugPrint("✅ CLIENT SECRET:");
      debugPrint(setupIntentClientSecret);

      return paymentSheet; // 🔥 important
    } catch (e) {
      debugPrint("❌ CREATE PAYMENT SHEET ERROR: $e");
      rethrow;
    } finally {
      debugPrint("🛑 CREATE PAYMENT SHEET API END");
    }
  }

  Future<void> _openStripeSheet() async {
    if (isProcessing) {
      debugPrint("⛔ Already Processing");
      return;
    }

    isProcessing = true;

    try {
      debugPrint("🚀 STRIPE FLOW START");

      setState(() => loading = true);

      /// 1️⃣ Get Payment Sheet Data
      final paymentSheet = await _createSetupIntent();

      final clientSecret =
      paymentSheet['payment_intent_client_secret'];

      debugPrint("🔑 CLIENT SECRET:");
      debugPrint(clientSecret);

      if (clientSecret == null || clientSecret.isEmpty) {
        throw "Client secret missing";
      }

      /// 2️⃣ Init Stripe Sheet
      debugPrint("💳 INIT PAYMENT SHEET");

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerId: paymentSheet['customer_id'],
          customerEphemeralKeySecret:
          paymentSheet['ephemeral_key_secret'],
          merchantDisplayName: "BEIGE",
        ),
      );

      debugPrint("✅ INIT DONE");

      /// 3️⃣ Open Stripe UI
      await Stripe.instance.presentPaymentSheet();

      debugPrint("✅ PAYMENT SUCCESS (Stripe side)");

      /// 4️⃣ Extract PaymentIntent ID
      final paymentIntentId = clientSecret.split('_secret').first;

      debugPrint("🆔 PAYMENT INTENT ID:");
      debugPrint(paymentIntentId);

      /// 5️⃣ Call Backend Confirm API
      await _attachPaymentMethodToBackend(paymentIntentId);

      /// 6️⃣ Final API (optional)
      // await _fetchReview();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Payment Completed")),
        );
      }

      debugPrint("🎉 FULL PAYMENT FLOW DONE");
    } on StripeException catch (e) {
      debugPrint("❌ STRIPE ERROR: ${e.error.localizedMessage}");

      if (e.error.code == FailureCode.Canceled) {
        debugPrint("⚠️ User Cancelled");
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.error.localizedMessage ?? "Payment failed"),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ GENERAL ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      isProcessing = false;
      if (mounted) setState(() => loading = false);

      debugPrint("🛑 STRIPE FLOW END");
    }
  }


  Future<void> _attachPaymentMethodToBackend(
      String paymentIntentId) async {
    try {
      debugPrint("🔗 BACKEND CONFIRM START");

      final payload = {
        "payment_intent_id": paymentIntentId,
      };

      debugPrint("📤 PAYLOAD:");
      debugPrint(payload.toString());

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




  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },

                child: SvgPicture.asset("assets/svg/back.svg", height: 24),
              ),

              const SizedBox(height: 14),
              Text(
                "Payment Method",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,

                  color: AppColors.white,
                ),
              ),


              const Text(
                "Manage your saved payment options for\nfaster and secure checkouts.",
                style: TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white70
                ),
              ),

              const SizedBox(height: 24),


              if (savedCards.isNotEmpty) ...[
                const Text(
                  "Saved Card",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (savedCards.isNotEmpty)
                ...savedCards.map((card) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewConfirmScreen(bookingId: widget.bookingId,),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/Icons/stripe.png",
                            height: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Stripe",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const Icon(
                            Icons.radio_button_checked,
                            color: Color(0xFFFFE6A5),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),



              /// ===== CARD SECTION =====
              Text(
                "Card",
                style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: isProcessing ? null : _openStripeSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Add Credit or Debit Card",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE6A5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// ===== RECOMMENDED =====
              const Text(
                "Recommended",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              _paymentTile(
                title: "Stripe",
                icon: "assets/Icons/stripe.png",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== PAYMENT TILE =====
  Widget _paymentTile({required String title, required String icon}) {
    return InkWell(
      onTap: isProcessing ? null : _openStripeSheet,

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              height: 26,
              width: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
