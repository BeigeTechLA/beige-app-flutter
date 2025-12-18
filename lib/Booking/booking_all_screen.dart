import 'package:flutter/material.dart';
import '../utility/ColorCode.dart';
import 'booking_select_date_time_slots.dart';
import 'upcoming_booking_event_summary.dart';

class BookingAllScreen extends StatefulWidget {
  const BookingAllScreen({super.key});

  @override
  State<BookingAllScreen> createState() => _BookingAllScreenState();
}

class _BookingAllScreenState extends State<BookingAllScreen> {
  bool isUpcomingSelected = true;
  String? selectedPayment;
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              /// 🔹 HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bookings",
                    style: TextStyle(
                      color: ColorCode.white,
                      fontFamily: 'Unbounded',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      openFilterBottomSheet(context);
                    },
                    child: Image.asset(
                      "assets/Icons/Filter.png",
                      height: 40,
                      width: 40,
                      color: ColorCode.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 TOGGLE
              Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorCode.k282828,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Row(
                  children: [

                    /// UPCOMING
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isUpcomingSelected = true);
                        },
                        child: toggleButton(
                          title: "Upcoming",
                          isSelected: isUpcomingSelected,
                        ),
                      ),
                    ),

                    /// COMPLETED
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isUpcomingSelected = false);
                        },
                        child: toggleButton(
                          title: "Completed",
                          isSelected: !isUpcomingSelected,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 BODY
              if (isUpcomingSelected) upcomingBookingCard(),
              if (!isUpcomingSelected) completedBookingCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOGGLE BUTTON =================

  Widget toggleButton({required String title, required bool isSelected}) {
    return Container(
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
          colors: [
            Color(0xFFE8D1AB),
            Color(0xFFD4A14D),
          ],
        )
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontFamily: "Outfit",
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ================= UPCOMING CARD =================

  Widget upcomingBookingCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  BookingSelectDateTimeSlots(),
          ),
        );
      },
      child: bookingCard(
        imagePath: "assets/images/home2.png",
        buttonText: "Manage Booking",
        filledButton: true,
        showActiveDot: true,
      ),
    );
  }


  // ================= COMPLETED CARD =================

  Widget completedBookingCard() {
    return bookingCard(
      imagePath: "assets/images/home1.png",
      buttonText: "Book Again",
      filledButton: false,
      showActiveDot: false,
    );
  }

  // ================= COMMON CARD =================

  Widget bookingCard({
    required String imagePath,
    required String buttonText,
    required bool filledButton,
    required bool showActiveDot,
  }) {
    return Container(
      width: double.infinity,
      height: 280,
      child: Stack(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(18)),
              child: Image.asset(
                "assets/images/Rectangle 19.png",
                height: 120,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),

          if (showActiveDot)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                height: 14,
                width: 14,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          if (showActiveDot)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                height: 36,
                width: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Image.asset(
                    "assets/Icons/Calendar Mark.png",
                    height: 18,
                  ),
                ),
              ),
            ),

          bookingBottomContent(
            buttonText: buttonText,
            filledButton: filledButton,
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM CONTENT =================

  Widget bookingBottomContent({
    required String buttonText,
    required bool filledButton,
  }) {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.star, color: Colors.yellow, size: 18),
              SizedBox(width: 4),
              Text(
                "4.5 (120)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Text(
            "Angela Kia",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Videography Specialist",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: filledButton ? ColorCode.kButtonColor : null,
                    borderRadius: BorderRadius.circular(28),
                    border: filledButton
                        ? null
                        : Border.all(color: ColorCode.kWhiteOpacity70),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      color: filledButton ? Colors.black : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                'assets/images/Group 2087328980.png',
                height: 44,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= FILTER BOTTOM SHEET =================

  void openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(

                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    Center(
                      child: Container(
                        width: 35,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: ColorCode.kWhiteOpacity70,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filter By",
                          style: TextStyle(
                            fontFamily: "Unbounded",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withOpacity(0.15)),
                    const SizedBox(height: 16),

                    filterDropdown("Booking Type"),
                    const SizedBox(height: 12),
                    filterDropdown("Select Date"),
                    const SizedBox(height: 12),
                    filterDropdown("Select Status"),

                    const SizedBox(height: 20),



                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔹 TITLE
                      const Text(
                        "Sort By Payment",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// 🔹 OPTIONS
                      _paymentTile("Paid", 0),
                      _paymentTile("Pending", 1),
                      _paymentTile("Refunded", 2),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: ColorCode.kWhiteOpacity60
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // setState(() {
                                //   selectedIndex = 0;
                                //   priceRange =
                                //   const RangeValues(100, 15000);
                                // });
                              },
                              child: const Text(
                                "Clear All",
                                style: TextStyle(
                                  fontFamily: "Unbounded",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: ColorCode.kButtonColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                  "Apply",
                                  style: TextStyle(
                                    fontFamily: "Unbounded",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ColorCode.black,
                                  )
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= FILTER HELPERS =================

  Widget filterDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }

  Widget paymentRadio(String title, StateSetter setModalState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: RadioListTile<String>(
        value: title,
        groupValue: selectedPayment,
        onChanged: (val) {
          setModalState(() {
            selectedPayment = val;
          });
        },
        activeColor: ColorCode.kButtonColor,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
  Widget _paymentTile(String title, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// TEXT
            Text(
              title,
              style: TextStyle(
                fontFamily: "Outfit",
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
              ),
            ),

            /// CUSTOM RADIO
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white38,
                  width: 1.2,
                ),
              ),
              child: selectedIndex == index
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
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
}
