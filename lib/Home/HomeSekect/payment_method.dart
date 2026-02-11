import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

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
      debugPrint("🚀 CREATE SETUP INTENT API START");

      final response = await ApiService().postData(
        ApiEndpoints.payment_setup,
        {},
      );

      debugPrint("📥 RAW SETUP INTENT RESPONSE:");
      debugPrint(response.toString());


      if (response == null || response['error'] == true) {
        throw response?['message'] ?? "SetupIntent failed";
      }

      final data = response['data'];

      /// 🔥 YAHAN CLIENT SECRET SAVE HO RAHA HAI
      setupIntentClientSecret = data['client_secret'];

      debugPrint("✅ CLIENT SECRET SAVED:");
      debugPrint(setupIntentClientSecret);

      return data;
    } catch (e) {
      debugPrint("❌ CREATE SETUP INTENT ERROR: $e");
      rethrow;
    } finally {
      debugPrint("🛑 CREATE SETUP INTENT API END");
    }
  }


  Future<void> _openStripeSheet() async {
    try {
      print("=== STRIPE START ===");
      setState(() => loading = true);

      // 1. Create SetupIntent
      print("1️⃣ Calling setup intent API");
      final setupData = await _createSetupIntent();

      final String? clientSecret = setupData['client_secret'];
      print("Client Secret: $clientSecret");

      if (clientSecret == null || clientSecret.isEmpty) {
        throw "Client secret missing";
      }

      // 2. Init Payment Sheet
      print("2️⃣ Initializing payment sheet");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: "BEIGE",
          allowsDelayedPaymentMethods: false,
        ),
      );

      // 3. Present Payment Sheet
      print("3️⃣ Presenting payment sheet");
      await Stripe.instance.presentPaymentSheet();
      print("Payment sheet completed");

      // 4. Retrieve SetupIntent
      print("4️⃣ Retrieving setup intent");
      final setupIntent =
      await Stripe.instance.retrieveSetupIntent(clientSecret);

      final String? paymentMethodId = setupIntent.paymentMethodId;
      print("Payment Method ID: $paymentMethodId");

      if (paymentMethodId == null || paymentMethodId.isEmpty) {
        throw "Payment method id not found";
      }

      // 5. Attach to backend
      print("5️⃣ Attaching payment method to backend");
      await _attachPaymentMethodToBackend(paymentMethodId);

      // 6. Refresh list
      print("6️⃣ Refreshing payment list");
      await _fetchBookSummary();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Card saved successfully")),
      );

      print("=== STRIPE SUCCESS ===");
    } catch (e) {
      print("❌ STRIPE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => loading = false);
      print("=== STRIPE END ===");
    }
  }




  Future<void> _attachPaymentMethodToBackend(String paymentMethodId) async {
    try {
      debugPrint("🔗 ATTACH PAYMENT METHOD API START");

      final payload = {
        // "payment_method_token": paymentMethodId,
        "payment_method_token": paymentMethodId,
      };

      debugPrint("📤 REQUEST PAYLOAD:");
      debugPrint(payload.toString());

      final response = await ApiService().postData(
        ApiEndpoints.payment_attach,
        payload,
      );

      debugPrint("📥 RAW API RESPONSE:");
      debugPrint(response.toString());

      if (response == null || response['error'] == true) {
        throw response?['message'] ?? "Failed to attach payment method";
      }

      debugPrint("✅ PAYMENT METHOD ATTACHED SUCCESSFULLY");
    } catch (e) {
      debugPrint("🔥 ATTACH PAYMENT METHOD ERROR: $e");
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
             /* _paymentTile(
                title: "Apple Pay",
                icon: "assets/Icons/apple.png",
              ),
              _paymentTile(
                title: "PayPal",
                icon: "assets/Icons/PayPal.png",
              ),*/
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
