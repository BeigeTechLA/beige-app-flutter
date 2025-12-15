import 'package:beige/Home/HomeSekect/review_confirm.dart';
import 'package:flutter/material.dart';

import '../../utility/ColorCode.dart';

class AddInformationBudget extends StatefulWidget {
  const AddInformationBudget({super.key});

  @override
  State<AddInformationBudget> createState() => _AddInformationBudgetState();
}

class _AddInformationBudgetState extends State<AddInformationBudget> {
  RangeValues budgetRange = const RangeValues(100, 15000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,

      appBar: AppBar(
        backgroundColor:  ColorCode.bcakgroundcolor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset("assets/Icons/Reply.png", height: 24),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "4/5",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ---- PROGRESS BAR ----
              Row(
                children: List.generate(
                  4,
                      (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      height: 5,
                      decoration: BoxDecoration(
                        color: index < 3
                            ? ColorCode.kButtonColor
                            : ColorCode.kSubtextColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Add Information & Budget",
                style: TextStyle(
                  fontFamily: "Unbounded",  // ← autocomplete yaha show hoga
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 20),

              /// ---- SHOOT NAME ----
              _buildInputField("Shoot Name",),

              const SizedBox(height: 16),


              _buildInputField( "Add Crew Size",),

              const SizedBox(height: 16),

              /// ---- REFERENCE LINK ----
              _buildInputField( "Reference Link",),

              const SizedBox(height: 16),

              /// ---- SPECIAL NOTE ----
              _buildInputField(
               "Special Note",
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              /// ---- BUDGET RANGE ----
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorCode.k282828, // dark card background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 Title
                    const Text(
                      "Budget Range",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 🔹 Range Slider
                    RangeSlider(
                      values: budgetRange,
                      min: 100,
                      max: 15000,
                      divisions: 149,
                      activeColor: ColorCode.kButtonColor,
                      inactiveColor: ColorCode.kCreamSoft,
                      onChanged: (values) {
                        setState(() {
                          budgetRange = values;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    /// 🔹 Min / Max Values
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Minimum",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "outfit",
                                color: ColorCode.kWhiteOpacity70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${budgetRange.start.toInt()}",
                              style: const TextStyle(
                                fontFamily: "outfit",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Maximum",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${budgetRange.end.toInt()}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),


               SizedBox(height: 30),

              /// ✅ Next Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                 backgroundColor: ColorCode.kButtonColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewConfirm(),
                      ),
                    );
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  /// ---- REUSABLE INPUT FIELD ----
  Widget _buildInputField(String label, {TextEditingController? controller, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: ColorCode.white,

      style: const TextStyle(
        color: ColorCode.white, // typed text color
      ),

      decoration: InputDecoration(
        labelText: "$label*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        /// ⭐ 0.5px BORDER + OPACITY COLOR
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
            width: 0.5,                       // 🔥 exact 0.5px
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
            width: 0.5,                          // focus border thicker
          ),
        ),

        floatingLabelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
        ),
      ),
    );
  }



}
