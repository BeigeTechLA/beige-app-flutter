import 'package:flutter/material.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import 'select_shoot_type_edits.dart';

class SelectDateTime extends StatefulWidget {
  final int bookingId;

  const SelectDateTime({super.key, required this.bookingId});

  @override
  State<SelectDateTime> createState() => _SelectDateTimeState();
}

class _SelectDateTimeState extends State<SelectDateTime> {
  DateTime baseDate = DateTime.now();
  Set<DateTime> selectedDates = {};

  int selectedTimeIndex = -1;
  bool isCustomSelected = false;
  double selectedHour = 16;
bool isLoading =false;

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


  String formatTime24(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
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
      String startTime = "";
      String endTime = "";
      int durationHours = 0;

      if (!isCustomSelected) {
        final slot = parseTimeSlot(timeSlots[selectedTimeIndex]);
        startTime = slot['start']!.split(" ")[0]; // 10:00
        endTime = slot['end']!.split(" ")[0];     // 12:00
        durationHours = 2;
      } else {
        startTime = "10:00";
        endTime = "${10 + selectedHour.toInt()}:00";
        durationHours = selectedHour.toInt();
      }

      final DateTime apiDate = selectedDates.first;

      final body = {
        "event_date": formatDate(apiDate), // ✅ REQUIRED FIELD
        "start_time": startTime,
        "end_time": endTime,
        "duration_hours": durationHours,
      };

      debugPrint("TIME API BODY => $body");

      final response = await ApiService().putData(
        "${ApiEndpoints.booking}/${widget.bookingId}/time",
        body,
      );

      debugPrint("TIME API RESPONSE => $response");

      if (response != null && response['error'] == false) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SelectShootTypeEdits(bookingId: widget.bookingId,)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?['message'] ?? "Failed")),
        );
      }
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
              child: Text("2/5", style: TextStyle(color: Colors.white)),
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
                5,
                    (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    height: 5,
                    decoration: BoxDecoration(
                      color: index < 2
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
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2035),
                          );

                          if (picked != null) {
                            setState(() {
                              if (selectedDates.any((d) => isSameDate(d, picked))) {
                                selectedDates.removeWhere(
                                        (d) => isSameDate(d, picked));
                              } else {
                                if (selectedDates.length < 5) {
                                  selectedDates.add(picked);
                                }
                              }
                            });
                          }
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
                        final bool isSelected =
                        selectedDates.any((d) => isSameDate(d, date));

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedDates.removeWhere(
                                        (d) => isSameDate(d, date));
                              } else if (selectedDates.length < 5) {
                                selectedDates.add(date);
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
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                Text(
                                  ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                                  [date.weekday % 7],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
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

            const SizedBox(height: 20),

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
                      onChanged: (v) =>
                          setState(() => selectedHour = v),
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
