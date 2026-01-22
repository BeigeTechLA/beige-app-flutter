import 'package:flutter/material.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import 'bookin_review_confirm.dart';
import 'booking_summary_view_summary.dart';

class BookingSelectDateTimeSlots extends StatefulWidget {
  final int bookingId;

  const BookingSelectDateTimeSlots({super.key, required this.bookingId});

  @override
  State<BookingSelectDateTimeSlots> createState() => _BookingSelectDateTimeSlotsState();
}

class _BookingSelectDateTimeSlotsState extends State<BookingSelectDateTimeSlots> {
  DateTime baseDate = DateTime.now();
  Set<DateTime> selectedDates = {};

  int selectedTimeIndex = -1;
  bool isCustomSelected = false;
  double selectedHour = 16;
  bool isLoading =false;

  Map<String, dynamic>? booking;
  Map<String, dynamic>? timeSlot;

  DateTime? selectedDate;


  final List<String> timeSlots = [
    "10:00 AM - 12:00 PM",
    "12:00 PM - 02:00 PM",
    "02:00 PM - 04:00 PM",
    "04:00 PM - 06:00 PM",
    "06:00 PM - 08:00 PM",
    "08:00 PM - 10:00 PM",
  ];

  String getMonthYear() {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    DateTime date =
    selectedDates.isNotEmpty ? selectedDates.first : DateTime.now();
    return "${months[date.month - 1]} ${date.year}";
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }


  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
  }

  Map<String, String> parseTimeSlot(String slot) {
    final parts = slot.split(" - ");
    return {
      "start": parts[0],
      "end": parts[1],
    };
  }

  TimeOfDay roundToNextHour(TimeOfDay time) {
    return TimeOfDay(hour: (time.hour + 1) % 24, minute: 0);
  }

  TimeOfDay addHours(TimeOfDay time, int hours) {
    final totalHours = time.hour + hours;
    return TimeOfDay(hour: totalHours % 24, minute: 0);
  }

  String formatTime24(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }



  @override
  void initState() {
    super.initState();
    _fetchReview();

  }
  Future<void> _fetchReview() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking}/${widget.bookingId}/review",
      );

      if (response != null && response['error'] == false) {
        booking = response['data']['booking'];
        timeSlot = response['data']['time_slot'];

        /// 📅 DATE
        final apiDate = DateTime.parse(timeSlot!['event_date']);

        /// ⏰ TIME (24 hour)
        final startParts = timeSlot!['start_time'].split(":");
        final endParts = timeSlot!['end_time'].split(":");

        final startHour = int.parse(startParts[0]);
        final endHour = int.parse(endParts[0]);

        final duration =
        endHour >= startHour ? endHour - startHour : (24 - startHour) + endHour;

        setState(() {
          selectedDates.clear();
          selectedDates.add(
            DateTime(apiDate.year, apiDate.month, apiDate.day),
          );

          selectedHour = duration.toDouble();
          selectedTimeIndex = -1;
          isCustomSelected = true;
        });

        /// 🔥 IMPORTANT LINE (THIS WAS MISSING)
        matchFixedSlot(startHour, endHour);

        debugPrint("✅ Review Data Applied");
        debugPrint("Date: $apiDate");
        debugPrint("Start Hour: $startHour");
        debugPrint("End Hour: $endHour");
        debugPrint("Duration: $duration h");
      }
    } catch (e) {
      debugPrint("❌ Review API Exception: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  void matchFixedSlot(int startHour, int endHour) {
    for (int i = 0; i < timeSlots.length; i++) {
      final slot = timeSlots[i];
      final parts = slot.split(" - ");

      final slotStart = to24Hour(parts[0]); // ✅ FIXED
      final slotEnd   = to24Hour(parts[1]); // ✅ FIXED

      if (slotStart == startHour && slotEnd == endHour) {
        setState(() {
          selectedTimeIndex = i;
          isCustomSelected = false;
        });
        return;
      }
    }

    /// ❗ no fixed slot matched → custom
    setState(() {
      isCustomSelected = true;
      selectedTimeIndex = -1;
    });
  }

  int to24Hour(String time) {
    final parts = time.split(" ");
    final hm = parts[0].split(":");
    int hour = int.parse(hm[0]);
    final period = parts[1];

    if (period == "PM" && hour != 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    return hour;
  }


  Future<void> selectTimeApi() async {
    if (selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date")),
      );
      return;
    }

    if (selectedTimeIndex == -1 && !isCustomSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select time")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      for (final apiDate in selectedDates) {
        String startTime = "";
        String endTime = "";
        int durationHours = 0;

        DateTime startDateTime;
        DateTime endDateTime;

        /// FIXED SLOT
        if (!isCustomSelected) {
          final slot = parseTimeSlot(timeSlots[selectedTimeIndex]);
          startTime = slot['start']!.split(" ")[0];
          durationHours = 2;

          startDateTime = DateTime(
            apiDate.year,
            apiDate.month,
            apiDate.day,
            int.parse(startTime.split(":")[0]),
          );

          endDateTime = startDateTime.add(const Duration(hours: 2));
          endTime =
          "${endDateTime.hour.toString().padLeft(2, '0')}:00";
        }

        /// CUSTOM DURATION
        else {
          final now = TimeOfDay.now();
          final startTOD = roundToNextHour(now);

          startDateTime = DateTime(
            apiDate.year,
            apiDate.month,
            apiDate.day,
            startTOD.hour,
            0,
          );

          endDateTime =
              startDateTime.add(Duration(hours: selectedHour.toInt()));

          startTime =
          "${startDateTime.hour.toString().padLeft(2, '0')}:00";
          endTime =
          "${endDateTime.hour.toString().padLeft(2, '0')}:00";

          durationHours = selectedHour.toInt();
        }

        final body = {
          "event_date": formatDate(startDateTime), // ✅ one date per call
          "start_time": startTime,
          "end_time": endTime,
          "duration_hours": durationHours,
        };

        debugPrint("API BODY => $body");

        await ApiService().putData(
          "${ApiEndpoints.booking}/${widget.bookingId}/time",
          body,
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookinReviewConfirm(bookingId: widget.bookingId,)),
      );
    } catch (e) {
      debugPrint("TIME API ERROR => $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.black,
      appBar: AppBar(
        backgroundColor: ColorCode.black,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Image.asset(
            "assets/Icons/Reply.png",
            height: 22,
            color: Colors.white,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text("1/2", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: index < 1
                          ? ColorCode.kButtonColor
                          : ColorCode.kSubtextColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// TITLE
            const Text(
              "Select Date & Time Slots",
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            /// DATE CARD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorCode.k282828,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// MONTH + CALENDAR ICON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getMonthYear(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final DateTime now = DateTime.now();

                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDates.isNotEmpty
                            ? selectedDates.first
                            : now,
                        firstDate: DateTime(now.year, now.month, now.day),
                        lastDate: DateTime(2035),
                      );

                      if (picked == null) return;

                      final normalized =
                      DateTime(picked.year, picked.month, picked.day);

                      setState(() {
                        if (selectedDates.any((d) => isSameDate(d, normalized))) {
                          selectedDates.removeWhere(
                                  (d) => isSameDate(d, normalized));
                        } else {
                          if (selectedDates.length < 5) {
                            selectedDates.add(normalized);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("You can select up to 5 dates only"),
                              ),
                            );
                          }
                        }
                      });
                    },
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        "assets/Icons/Calendar_Mark.png",
                        width: 22,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// DATE LIST
              SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final date = baseDate.add(Duration(days: index));
                    final normalized =
                    DateTime(date.year, date.month, date.day);

                    final bool isSelected =
                    selectedDates.any((d) => isSameDate(d, normalized));

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedDates.removeWhere(
                                    (d) => isSameDate(d, normalized));
                          } else {
                            if (selectedDates.length < 5) {
                              selectedDates.add(normalized);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text("You can select up to 5 dates only"),
                                ),
                              );
                            }
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? ColorCode.kButtonColor
                              : ColorCode.black,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                            Text(
                              ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                              [date.weekday % 7],
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),


         SizedBox(height: 20),

            /// TIME SLOTS
            ...List.generate(timeSlots.length, (index) {

              final bool isSelected =
                  selectedTimeIndex == index && !isCustomSelected;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTimeIndex = index;
                    isCustomSelected = false;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorCode.kButtonColor
                        : ColorCode.k282828,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeSlots[index],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:
                          isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check,
                            color: Colors.black, size: 22),
                    ],
                  ),
                ),
              );
            }),

            /// CUSTOM TIME
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isCustomSelected = true;
                        selectedTimeIndex = -1;
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Custom Time Duration",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.white70),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: ColorCode.kCreamSoft,
                      inactiveTrackColor: ColorCode.white,
                      thumbColor: ColorCode.kCreamSoft,
                    ),
                    child: Slider(
                      min: 2,
                      max: 24,
                      divisions: 11,
                      value: selectedHour,
                      onChanged: (v) {
                        setState(() {
                          selectedHour = v;
                          isCustomSelected = true;   // 🔥 VERY IMPORTANT
                          selectedTimeIndex = -1;   // slot deselect
                        });
                      },

                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("02h"), Text("04h"), Text("08h"),
                      Text("12h"), Text("16h"), Text("20h"), Text("24h"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// NEXT BUTTON
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorCode.kButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : selectTimeApi,

                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
