import 'package:flutter/material.dart';

import '../utility/ColorCode.dart';
import 'bookin_review_confirm.dart';

class BookingSelectDateTimeSlots extends StatefulWidget {
  const BookingSelectDateTimeSlots({super.key});

  @override
  State<BookingSelectDateTimeSlots> createState() => _BookingSelectDateTimeSlotsState();
}

class _BookingSelectDateTimeSlotsState extends State<BookingSelectDateTimeSlots> {

  DateTime baseDate = DateTime.now();
  Set<DateTime> selectedDates = {};

  int selectedTimeIndex = -1;
  bool isCustomSelected = false;
  double selectedHour = 16;

  final List<String> timeSlots = [
    "09:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM",
    "12:00 PM - 01:00 PM",
    "01:00 PM - 02:00 PM",
    "02:00 PM - 03:00 PM",
    "03:00 PM - 04:00 PM",
    "04:00 PM - 05:00 PM",
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

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: ColorCode.bcakgroundcolor,
    appBar: AppBar(
      backgroundColor: ColorCode.bcakgroundcolor,
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
  padding:  EdgeInsets.all(16),
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

   SizedBox(height: 24),

  /// TITLE
   Text(
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

   SizedBox(height: 20),


    Column(
      children: List.generate(timeSlots.length, (index) {
        final bool isSelected =
            selectedTimeIndex == index && !isCustomSelected;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              selectedTimeIndex = index;
              isCustomSelected = false;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? ColorCode.kButtonColor
                  : ColorCode.k282828,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? ColorCode.kButtonColor
                    : Colors.white12,
              ),
            ),
            child: Row(
              children: [
                /// 🕒 TIME TEXT
                Expanded(
                  child: Text(
                    timeSlots[index],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color:
                      isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                if (isSelected)
                 Icon(Icons.check,
                    color: Colors.black, size: 22),
                /// ✅ CHECK ICON

              ],
            ),
          ),
        );
      }),
    ),

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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: "Outfit"
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.white70),
              ],
            ),
          ),
           SizedBox(height: 18),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ColorCode.kButtonColor,
              inactiveTrackColor: ColorCode.kCreamSoft,
              thumbColor: ColorCode.kButtonColor,
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
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("02h"), Text("04h"), Text("08h"),
              Text("12h"), Text("16h"), Text("20h"), Text("24h"),
            ],
          ),
        ],
      ),
    ),
   SizedBox(height: 24),



  ],
  ),
  ),

    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(20),
      child:    SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>  BookinReviewConfirm(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:  ColorCode.kButtonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
          Text(
            "Next",
            style: TextStyle(
              fontFamily: "Unbounded",
              fontWeight: FontWeight.w500,
              color: ColorCode.kHeadingColor,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ),
  );
  }
  }

