import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import 'booking_summary_detils.dart';

class AddOnServices extends StatefulWidget {
  final int bookingId;
  const AddOnServices({super.key, required this.bookingId});

  @override
  State<AddOnServices> createState() => _AddOnServicesState();
}

class _AddOnServicesState extends State<AddOnServices> {
  bool isLoading = false;
  List<Map<String, dynamic>> addOns = [];

  @override
  void initState() {
    super.initState();
    _fetchAddOns();
  }

  Future<void> _fetchAddOns() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking_select}/${widget.bookingId}/add-ons",
      );

      if (response != null && response['error'] == false) {
        setState(() {
          addOns = List<Map<String, dynamic>>.from(
            response['data']['items'] ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint("Add-ons API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _AddOns() async {
    setState(() => isLoading = true);

    try {
      List<Map<String, dynamic>> items = [];

      for (var addon in addOns) {
        if (addon['selected'] == true) {
          final int priceType = addon['price_type'];

          if (priceType == 2) {
            items.add({
              "addon_id": addon['addon_id'],
              "hours": addon['hours'] ?? 1, // ✅ default
            });
          } else {
            items.add({
              "addon_id": addon['addon_id'],
              "qty": addon['quantity'] ?? 1, // ✅ default
            });
          }
        }
      }

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one add-on")),
        );
        return;
      }

      final response = await ApiService().putData(
        "${ApiEndpoints.booking_select}/${widget.bookingId}/add-ons",
        { "items": items },
      );

      if (response != null && response['error'] == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSummaryDetils(bookingId: widget.bookingId,),
          ),
        );
      }
    } catch (e) {
      debugPrint("Add-ons API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BACK
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  "assets/Icons/Vector.png",
                  height: 24,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              /// TITLE
              const Text(
                "Add - Ons",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColorCode.white,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Would you like to add anything to your shoot?",
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  color: ColorCode.kWhiteOpacity70,
                ),
              ),

              const SizedBox(height: 20),

              /// ADDONS LIST
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: addOns.length,
                itemBuilder: (context, index) {
                  return _addOnItem(addOns[index]);
                },
              ),

              const SizedBox(height: 20),

              /// BUTTON
            ],
          ),
        ),

      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorCode.kButtonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isLoading ? null : _AddOns,

            child: const Text(
              "Proceed to Payment",
              style: TextStyle(
                color: ColorCode.kHeadingColor,
                fontFamily: "Unbounded",
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ADDON CARD
  Widget _addOnItem(Map<String, dynamic> addon) {
    final int priceType = addon['price_type'] ?? 1;
    final bool showInput = priceType == 2 || priceType == 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addon['title'] ?? '',
                  style: const TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Outfit",
                    fontSize: 14,
                  ),
                ),

                if (addon['estimated_duration_text'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    addon['estimated_duration_text'],
                    style: const TextStyle(
                      color: ColorCode.kWhiteOpacity60,
                      fontSize: 10,
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                Text(
                  "\$ ${addon['unit_price']}.00/-",
                  style: const TextStyle(
                    color: ColorCode.white,
                    fontSize: 14,
                  ),
                ),

                if (showInput) ...[
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                      priceType == 2 ? "How many hours" : "Quantity",
                      hintStyle: const TextStyle(
                        fontSize: 10,
                        color: ColorCode.kWhiteOpacity70,
                      ),
                      filled: true,
                      fillColor: ColorCode.kHeadingColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      final value = int.tryParse(val) ?? 1;

                      if (priceType == 2) {
                        addon['hours'] = value;
                      } else {
                        addon['quantity'] = value;
                      }
                    },
                  ),
                ],
              ],
            ),
          ),

          /// ➕ / ✔ BUTTON
          GestureDetector(
            onTap: () {
              setState(() {
                addon['selected'] = !(addon['selected'] ?? false);

                /// 🔥 DEFAULT VALUE SET HERE
                if (addon['selected'] == true) {
                  if (priceType == 2) {
                    addon['hours'] ??= 1; // default 1 hour
                  } else if (priceType == 3) {
                    addon['quantity'] ??= 1; // default qty 1
                  }
                }
              });
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8D1AB),
                    Color(0xFFD4A14D),
                  ],
                ),
              ),
              child: Icon(
                addon['selected'] == true ? Icons.check : Icons.add,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
