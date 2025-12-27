import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';

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
  }


  bool loading = true;
  Map<String, dynamic>? paymentData;



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
    final response = await ApiService().postData(
      ApiEndpoints.payment_setup,
      {},
    );

    if (response == null || response['error'] == true) {
      throw response?['message'] ?? "SetupIntent failed";
    }

    return response['data'];
  }

  Future<void> _openStripeSheet() async {
    try {
      setState(() => loading = true);

      /// 1️⃣ Create SetupIntent
      final setupData = await _createSetupIntent();
      final clientSecret = setupData['client_secret'];

      /// 2️⃣ Init Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: "BEIGE",

          // 🔥 THIS IS THE FIX
          paymentMethodOrder: ['card'],

          allowsDelayedPaymentMethods: false,
        ),
      );


      /// 3️⃣ Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      /// 4️⃣ 🔥 GET PAYMENT METHOD ID (CORRECT WAY)
      final setupIntent =
      await Stripe.instance.retrieveSetupIntent(clientSecret);

      final paymentMethodId = setupIntent.paymentMethodId;

      if (paymentMethodId == null || paymentMethodId.isEmpty) {
        throw "PaymentMethod ID not received from Stripe";
      }

      debugPrint("💳 PAYMENT METHOD ID: $paymentMethodId");


      await _attachPaymentMethodToBackend(paymentMethodId);

      await _fetchBookSummary();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Card saved successfully")),
      );
    } catch (e) {
      debugPrint("❌ STRIPE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _attachPaymentMethodToBackend(String paymentMethodId) async {
    try {
      debugPrint("🔗 ATTACH PAYMENT METHOD API START");

      final payload = {
        "payment_method_token": paymentMethodId,
      };

      debugPrint("📤 REQUEST PAYLOAD:");
      debugPrint(payload.toString());

      debugPrint("📡 API URL: ${ApiEndpoints.payment_attach}");

      /// 🔹 API Call
      final response = await ApiService().postData(
        ApiEndpoints.payment_attach,
        payload,
      );

      debugPrint("📥 RAW API RESPONSE:");
      debugPrint(response.toString());


      if (response == null) {
        debugPrint("❌ RESPONSE IS NULL");
        throw "Attach payment API returned null response";
      }

      debugPrint("ℹ️ error flag: ${response['error']}");
      debugPrint("ℹ️ message: ${response['message']}");

      if (response['error'] == true) {
        debugPrint("❌ API ERROR");
        throw response['message'] ?? "Failed to attach payment method";
      }

      debugPrint("✅ PAYMENT METHOD ATTACHED SUCCESSFULLY");

    } catch (e) {
      debugPrint("🔥 ATTACH PAYMENT METHOD EXCEPTION:");
      debugPrint(e.toString());
      rethrow;
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ColorCode.bcakgroundcolor,
     
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

                  child: Image.asset("assets/Icons/Reply.png", height: 24),
              ),

              const SizedBox(height: 14),
               Text(
                "Payment Method",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,

                  color: ColorCode.white,
                ),
              ),


              const Text(
                "Manage your saved payment options for\nfaster and secure checkouts.",
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorCode.kWhiteOpacity70
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
                    color: ColorCode.white,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (savedCards.isNotEmpty)
                ...savedCards.map((card) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/Icons/visa.png",
                          height: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "**** **** **** ${card['last4'] ?? 'XXXX'}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const Icon(
                          Icons.radio_button_checked,
                          color: Color(0xFFFFE6A5),
                        )
                      ],
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
                    color: ColorCode.white
                ),
              ),
              const SizedBox(height: 12),
        
              Container(
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
              _paymentTile(
                title: "Apple Pay",
                icon: "assets/Icons/apple.png",
              ),
              _paymentTile(
                title: "PayPal",
                icon: "assets/Icons/PayPal.png",
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
      onTap: _openStripeSheet,

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
