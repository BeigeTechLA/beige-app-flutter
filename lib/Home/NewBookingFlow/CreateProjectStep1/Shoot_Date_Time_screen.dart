import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../Customtextfiled/CustomInputField.dart';
import '../../../main.dart';
import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';
import '../../../utility/ColorCode.dart';
import '../More_Details/more_details_screen.dart';

class ShootDateTimeScreen extends StatefulWidget {
  // final int specialtyId;
  final int ShootTypeId;
  final int bookingId;
  final int contentTypeId;

  const ShootDateTimeScreen({super.key,
    required this.ShootTypeId, required this.bookingId, required this.contentTypeId});

  @override
  State<ShootDateTimeScreen> createState() => _ShootDateTimeScreenState();
}

class _ShootDateTimeScreenState extends State<ShootDateTimeScreen> {
  late final screenHeight = MediaQuery.of(context).size.height;


  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    DateTime.now().day,
  );

  void generateDates() {
    DateTime current = startDate;

    while (current.isBefore(endDate) || current == endDate) {
      allDates.add(current);
      current = current.add(Duration(days: 1));
    }
  }

  List<DateTime> allDates = [];
  List<DateTime> selectedDates = [];

  List<int>counts=[0,0,0];
  int get totalReels => counts.reduce((a, b) => a + b);
  List<String> titles = [
    "Social Media Reel (15 sec-30 sec)",
    "Social Media Reel (30 sec-90 sec)",
    "Social Media Reel (2 min-4 min)",
  ];

  int selectedIndex=1;

  List<dynamic> editTypes = [];              // API data
  List<int> selectedEditTypeIds = [];        // selected ids
  List<String> selectedEditTypeNames = [];


  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  DateTime? selectedDate;

  bool isEditNeeded = false;  // ✅ Default = No selected

  bool isSubmitting = false;
  bool isDateSelected() {
    return selectedDate != null;
  }

 bool isLoading =true;
  @override
  void initState() {
    super.initState();

    _edittype();
  }
  String _apiDateFormat(DateTime date) {

    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  bool isEndTimeAfterStart(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }
  bool get isFormValid {
    debugPrint("DATE: $selectedDate");
    debugPrint("START: $startTime");
    debugPrint("END: $endTime");

    if (selectedDate == null) return false;
    if (startTime == null || endTime == null) return false;

    // ❌ REMOVE strict time check (allow overnight)

    if (isEditNeeded && selectedEditTypeIds.isEmpty) return false;

    return true;
  }
  String getEditingDescription() {

    // 🎬 Video Content
    if (widget.contentTypeId == 1) {
      return "Professional editing includes color grading,sound mixing, and basic revisions.";
    }

    // 📸 Photo Content (Special Case 16 & 9)
    if ((widget.ShootTypeId == 16 || widget.ShootTypeId == 9) &&
        (widget.contentTypeId == 2 || widget.contentTypeId == 3)) {
      return "50 edited photos per hour for weddings";
    }

    // 📷 Default Photo
    return "25 edited photos per hour";
  }


  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    dateController.dispose();
    super.dispose();
  }
  void resetEditTypes() {
    selectedEditTypeIds.clear();
    selectedEditTypeNames.clear();
  }


  String getContentTypeTitle(int contentTypeId) {
    switch (contentTypeId) {
      case 1:
        return "Video Shoot Type";
      case 2:
        return "Photo Shoot Type";
      case 3:
        return "Photo & Video Shoot Type";
      default:
        return "Shoot Type";
    }
  }


  String getEditTypeDisplayText() {

    /// 🔥 When nothing selected
    if (selectedEditTypeNames.isEmpty) {

      switch (widget.contentTypeId) {
        case 1:
          return "Select Video Edit Type";

        case 2:
          return "Select Photo Edit Type";

        case 3:
          return "Select Photo & Video Edit Type";

        default:
          return "Select Edit Type";
      }
    }

    /// 🔥 Single selection
    if (selectedEditTypeNames.length == 1) {
      return selectedEditTypeNames.first;
    }

    /// 🔥 Multiple selection
    return "${selectedEditTypeNames.first} +${selectedEditTypeNames.length - 1}";
  }

  Future<void> _edittype() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking_shoot_types}${widget.ShootTypeId}/edit-types",
      );

      debugPrint("API Response → $response");

      if (response != null && response['error'] == false) {
        setState(() {
          editTypes = response['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("API Error → $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> _ShootDate_Time() async {
    if (!isFormValid) return;

    setState(() => isSubmitting = true);

    if (!isEditNeeded) {
      selectedEditTypeIds.clear();
      selectedEditTypeNames.clear();
    }

    final payload = {
      "event_date": _apiDateFormat(selectedDate!),
      "start_time": startTimeController.text,
      "end_time": endTimeController.text,
      "edits_needed": isEditNeeded ? 1 : 0,
      "edit_types": isEditNeeded ? selectedEditTypeIds : null,
    };

    debugPrint("📤 REQUEST BODY → $payload");

    try {
      final response = await ApiService().putData(
        "${ApiEndpoints.booking}/${widget.bookingId}/time",
        payload,
      );

      if (response != null && response['error'] == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MoreDetailsScreen(
              contentTypeId: widget.contentTypeId,
              specialtyId: 22,
              ShootTypeId: widget.ShootTypeId,
              bookingId: widget.bookingId,

            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ API Error → $e");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  TimeOfDay getMinAllowedTime() {
    final now = DateTime.now().add(const Duration(hours: 4));
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  bool isTodaySelected() {
    if (selectedDate == null) return false;
    final now = DateTime.now();
    return selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;
  }


  DateTime minDateTimeForToday() {
    return DateTime.now().add(const Duration(hours: 4));
  }

  bool isMinTimeNextDay() {
    final min = minDateTimeForToday();
    final now = DateTime.now();
    return min.day != now.day;
  }



  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly, // Hide pencil icon
      helpText: '', // Remove "Select Date" text
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            useMaterial3: true,
            dialogBackgroundColor: const Color(0xFF121212),

            colorScheme: const ColorScheme.dark(
              primary: ColorCode.kButtonColor,
              onPrimary: Colors.black,
              surface: Color(0xFF121212),
              onSurface: Colors.white,
            ),

            datePickerTheme: DatePickerThemeData(
              backgroundColor: const Color(0xFF121212),
              dividerColor: Colors.white12,

              // 🔥 HEADER
              headerHeadlineStyle: const TextStyle(
                fontFamily: "Unbounded",
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              headerHelpStyle: const TextStyle(fontSize: 0, height: 0),
              headerBackgroundColor: Color(0xFF0E0E0E),

              // 🔥 GRID FEEL
              dayShape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),

              weekdayStyle: const TextStyle(
                fontFamily: "Outfit",
                fontSize: 13,
                color: Colors.white70,
              ),

              dayStyle: const TextStyle(
                fontFamily: "Outfit",
                fontSize: 14,
                color: Colors.white,
              ),
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ColorCode.kButtonColor,
                textStyle: const TextStyle(
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },

    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";

        // --- AUTO-FILL LOGIC ---
        if (isTodaySelected()) {
          DateTime nowPlus4 = DateTime.now().add(const Duration(hours: 4));
          startTime = TimeOfDay.fromDateTime(nowPlus4);
          DateTime endDefault = nowPlus4.add(const Duration(hours: 2));
          endTime = TimeOfDay.fromDateTime(endDefault);
        } else {
          startTime = const TimeOfDay(hour: 9, minute: 0);
          endTime = const TimeOfDay(hour: 17, minute: 0);
        }

        _updateTimeText(startTimeController, startTime!);
        _updateTimeText(endTimeController, endTime!);
      });
    }
  }

  // Helper method to format time (Make sure this is inside your _ShootDateTimeScreenState class)
  void _updateTimeText(TextEditingController controller, TimeOfDay picked) {
    final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod.toString().padLeft(2, '0');
    final minute = picked.minute.toString().padLeft(2, '0');
    final period = picked.period == DayPeriod.am ? "AM" : "PM";
    controller.text = "$hour:$minute $period";
  }

  // Updated timeField usage in build method:
  // For Start Time:
  // timeField(
  //   controller: startTimeController,
  //   label: "Start Time*",
  //   onTap: () => _selectTime(context, true),
  // ),

  // For End Time:
  // timeField(
  //   controller: endTimeController,
  //   label: "End Time*",
  //   onTap: () => _selectTime(context, false),
  // ),

// ... (Rest of your build method and existing helpers like isEndTimeAfterStart)
  //
  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate ?? DateTime.now(),
  //     firstDate: DateTime.now(), // 🔥 past date disable
  //     lastDate: DateTime(2100),
  //
  //     builder: (context, child) {
  //       return Theme(
  //         data: ThemeData.dark().copyWith(
  //           dialogBackgroundColor: const Color(0xFF121212),
  //
  //           colorScheme: const ColorScheme.dark(
  //             primary: ColorCode.kButtonColor,      // selected date bg
  //             onPrimary: Colors.black,               // selected date text
  //             surface: Color(0xFF1E1E1E),             // calendar bg
  //             onSurface: Colors.white,                // normal date text
  //           ),
  //
  //           datePickerTheme: const DatePickerThemeData(
  //             headerBackgroundColor: ColorCode.kButtonColor,
  //             headerForegroundColor: Colors.black,
  //             dayForegroundColor: MaterialStatePropertyAll(Colors.white),
  //             weekdayStyle: TextStyle(color: Colors.grey),
  //             todayForegroundColor: MaterialStatePropertyAll(Colors.white),
  //             todayBackgroundColor: MaterialStatePropertyAll(Colors.transparent),
  //           ),
  //
  //           textButtonTheme: TextButtonThemeData(
  //             style: TextButton.styleFrom(
  //               foregroundColor: ColorCode.kButtonColor, // OK / CANCEL
  //             ),
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //
  //   );
  //
  //   if (picked != null && mounted) {
  //     setState(() {
  //       selectedDate = picked;
  //       dateController.text =
  //       "${picked.day.toString().padLeft(2, '0')}-"
  //           "${picked.month.toString().padLeft(2, '0')}-"
  //           "${picked.year}";
  //     });
  //   }
  // }
  Future<void> _selectTime(
      BuildContext context,
      TextEditingController controller,
      bool isStartTime,
      ) async {

    // Use current values as initial picker time
    TimeOfDay initial = isStartTime ? (startTime ?? TimeOfDay.now()) : (endTime ?? TimeOfDay.now());

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: const Color(0xFF121212),

            colorScheme: const ColorScheme.dark(
              primary: ColorCode.kButtonColor, // Selected circle/hand color
              onPrimary: Colors.white,         // Text on primary
              surface: Color(0xFF1E1E1E),      // Picker background
              onSurface: Colors.white,         // Normal text color
            ),

            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF121212),
              dialBackgroundColor: Color(0xFF121212),
              dialHandColor: Colors.white,
              dialTextColor: Colors.grey,

              // 🔥 Hour / Minute box colors
              hourMinuteColor: ColorCode.kButtonColor,
              hourMinuteTextColor: Colors.black, // ✅ BLACK text inside selected time box

              // 🔥 AM / PM section
              dayPeriodColor: ColorCode.kButtonColor,
              dayPeriodTextColor: Colors.white, // ✅ WHITE text in AM / PM

              // 🔥 Action Buttons (OK / CANCEL)
              confirmButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(ColorCode.kButtonColor),
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(ColorCode.kButtonColor),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    // 🔒 HARD BLOCK: 4-HOUR RULE FOR TODAY
    if (isTodaySelected()) {
      final now = DateTime.now();
      final minAllowed = now.add(const Duration(hours: 4));

      // Create a DateTime from the picked time to compare easily
      final pickedDT = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, picked.hour, picked.minute);

      if (pickedDT.isBefore(minAllowed)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("For today, please select a time at least 4 hours from now.")),
        );
        return;
      }
    }

    setState(() {
      if (isStartTime) {
        startTime = picked;
        _updateTimeText(startTimeController, picked);

        // Validation: If Start is now after End, reset End to Start + 1 hour
        if (endTime != null && !isEndTimeAfterStart(startTime!, endTime!)) {
          endTime = TimeOfDay(hour: (startTime!.hour + 1) % 24, minute: startTime!.minute);
          _updateTimeText(endTimeController, endTime!);
        }
      } else {
        // Validation: Check if End is after Start
        if (startTime != null && !isEndTimeAfterStart(startTime!, picked)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("End time must be after Start time")),
          );
          return;
        }
        endTime = picked;
        _updateTimeText(endTimeController, picked);
      }
    });
  }
 /* Future<void> _selectTime(
      BuildContext context,
      TextEditingController controller,
      TimeOfDay? initialTime,
      Function(TimeOfDay) onTimeSelected,
      ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),

      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: const Color(0xFF121212),

            colorScheme: const ColorScheme.dark(
              primary: ColorCode.kButtonColor, // selected bg
              onPrimary: Colors.white,         // selected text
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),

            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF121212),
              dialBackgroundColor: Color(0xFF121212),
              dialHandColor: Colors.white,
              dialTextColor: Colors.grey, // normal numbers thode soft
              // 🔥 Hour / Minute box
              hourMinuteColor: ColorCode.kButtonColor,
              hourMinuteTextColor: Colors.black, // ✅ BLACK text inside time

              // 🔥 AM / PM
              dayPeriodColor: ColorCode.kButtonColor,
              dayPeriodTextColor: Colors.white, // ✅ WHITE text in AM / PM



              // 🔥 Buttons
              confirmButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(ColorCode.kButtonColor),
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(ColorCode.kButtonColor),
              ),
            ),

          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        onTimeSelected(picked);

        final hour = picked.hourOfPeriod.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.period == DayPeriod.am ? "AM" : "PM";

        controller.text = "$hour:$minute $period";
      });
    }
  }
*/

  // Future<void> _selectTime(
  //     BuildContext context,
  //     TextEditingController controller,
  //     TimeOfDay? initialTime,
  //     Function(TimeOfDay) onTimeSelected,
  //     ) async {
  //
  //   // 🔥 Aaj ke liye initial time = NOW
  //   TimeOfDay initial = TimeOfDay.now();
  //
  //   final picked = await showTimePicker(
  //     context: context,
  //     initialTime: initial,
  //     builder: (context, child) {
  //       return Theme(
  //         data: ThemeData.dark(),
  //         child: child!,
  //       );
  //     },
  //   );
  //
  //   if (picked == null || !mounted) return;
  //
  //   // 🔒 HARD BLOCK PAST TIME (ONLY FOR TODAY)
  //   if (isTodaySelected()) {
  //     final now = TimeOfDay.now();
  //
  //     final pickedMinutes = picked.hour * 60 + picked.minute;
  //     final nowMinutes = now.hour * 60 + now.minute;
  //
  //     if (pickedMinutes <= nowMinutes) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text(
  //             "Please select a future time",
  //           ),
  //         ),
  //       );
  //       return; // ❌ past time blocked
  //     }
  //   }
  //
  //   // ✅ SAFE TO SET
  //   setState(() {
  //     onTimeSelected(picked);
  //
  //     final hour = picked.hourOfPeriod.toString().padLeft(2, '0');
  //     final minute = picked.minute.toString().padLeft(2, '0');
  //     final period = picked.period == DayPeriod.am ? "AM" : "PM";
  //
  //     controller.text = "$hour:$minute $period";
  //   });
  // }
  //



  @override
  Widget build(BuildContext context) {
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
                onTap: () => Navigator.pop(context,true),
                child: SvgPicture.asset(
                  "assets/svg/back.svg",
                  height: 24,
                ),
              ),
            ),
            Text(
              "Create Project",
              style: TextStyle(
                color: ColorCode.white,
                fontSize: 14,
                fontFamily: "Outfit",
                fontWeight: FontWeight.w400,
              ),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "1/3",
                style: TextStyle(
                  color: ColorCode.white,
                  fontSize: 14,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(

      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.all(20.0),
              child: Column(
                children: [

                  Row(
                    children: List.generate(3, (index) {
                      bool isActive = index == 0; // current step (1/3)

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          height: 5,
                          decoration: BoxDecoration(
                            color: ColorCode.kSubtextColor, // grey background
                            borderRadius: BorderRadius.circular(64),
                          ),
                          child: isActive
                              ? Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 5,
                              width: 120, // 🔥 colored portion only
                              decoration: BoxDecoration(
                                color: ColorCode.kButtonColor,
                                borderRadius: BorderRadius.circular(64),
                              ),
                            ),
                          )
                              : const SizedBox(),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      Text(

                           textAlign: TextAlign.start,
                        "Select Booking Type",
                        style: TextStyle(
                          fontFamily: "Unbounded",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12,),
                  //////////////////////////////////////////////////////////////////////////

      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 19),
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? Color(0xFFE6D5B8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: selectedIndex == 1
                      ? null
                      :Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Single Day",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: selectedIndex == 1
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                selectedIndex==1?
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: selectedIndex == 1
                            ? LinearGradient(
                          colors: [
                            Color(0xFF000000),
                            Color(0xFF363131),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        border: selectedIndex == 1
                            ? Border.all(color: Colors.grey)
                            : null,
                      ),
                      child: selectedIndex == 1
                          ? Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE6D5B8),
                          ),
                        ),
                      )
                          : null,
                    ):Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),

                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 19),
                decoration: BoxDecoration(
                  color: selectedIndex == 2
                      ? Color(0xFFE6D5B8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: selectedIndex == 2
                      ? null
                      :Border.all(color: Colors.white.withOpacity(0.3)),

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Multiple Days",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: selectedIndex == 2
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),

                    selectedIndex==2?
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // color: selectedIndex == 1
                        //     ? Colors.black
                        //     : Colors.transparent,
                        gradient: selectedIndex == 2
                            ? LinearGradient(
                          colors: [
                            Color(0xFF000000),
                            Color(0xFF363131),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,

                        border: selectedIndex == 2
                            ? Border.all(color: Colors.grey)
                            : null,
                      ),
                      child: selectedIndex == 2
                          ? Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE6D5B8),
                          ),
                        ),
                      )
                          : null,
                    ):Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        )
                      )
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),




                  SizedBox(
                    height: 50,
                  ),

        if (selectedIndex==2) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Select Date",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              buildDateSelector(
                context: context,
                selectedDates: selectedDates,
                onChanged: (dates) {
                  setState(() {
                    selectedDates = dates;
                  });
                },
              ),

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xff322F2A),

                ),

              ),
              Text(
                "Total Days: ${selectedDates.length}",
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          ],


                  if (selectedIndex==1) ...[
                    Row(
                      children: [
                        Text(
                          "Shoot Date & Time",
                          style: TextStyle(
                            fontFamily: "Unbounded",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30,),



                    CustomInputField(
                      title: "Select Date",
                      controller: dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/svg/calendar-03.svg",
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            ColorCode.kWhiteOpacity70,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                    /*   timeField(
                    controller: startTimeController,
                    label: "Start Time*",
                    onTap: () {
                      if (!isDateSelected()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select date first")),
                        );
                        return;
                      }
                      // Updated call: 3 arguments (context, controller, isStartTime)
                      _selectTime(context, startTimeController, true);
                    },
                  ),*/

                    CustomInputField(
                      title: "Start Time",
                      controller: startTimeController,
                      readOnly: true,
                      onTap: () {
                        if (!isDateSelected()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select date first")),
                          );
                          return;
                        }
                        _selectTime(context, startTimeController, true);
                      },
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/svg/Group 2087328870.svg",
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            ColorCode.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                    /*  timeField(
                    controller: endTimeController,
                    label: "End Time*",
                    onTap: () {
                      if (!isDateSelected()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select date first")),
                        );
                        return;
                      }
                      // Updated call: 3 arguments (context, controller, isStartTime)
                      _selectTime(context, endTimeController, false);
                    },
                  ),*/
                    CustomInputField(
                      title: "End Time",
                      controller: endTimeController,
                      readOnly: true,
                      onTap: () {
                        if (!isDateSelected()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select date first")),
                          );
                          return;
                        }
                        _selectTime(context, endTimeController, false);
                      },
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/svg/Group 2087328870.svg",
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            ColorCode.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],



                  SizedBox(height: 30,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔹 TITLE
                      Text(
                        "Edits Needed?",
                        style: TextStyle(
                          fontFamily: "Unbounded",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// 🔹 YES / NO
                      Row(
                        children: [
                          _buildOption(
                            title: "Yes",
                            isSelected: isEditNeeded == true,
                            onTap: () {
                              setState(() {
                                isEditNeeded = true;
                              });
                            },
                          ),
                          const SizedBox(width: 24),
                          _buildOption(

                            title: "No",
                            isSelected: isEditNeeded == false,
                            onTap: () {
                              setState(() {
                                isEditNeeded = false;

                                // 🔥 CLEAR OLD DATA
                                resetEditTypes();

                              });
                            },

                          ),
                        ],
                      ),

                      /// 🔥 ONLY SHOW WHEN YES SELECTED
                      if (isEditNeeded == true) ...[
                        const SizedBox(height: 30),

                        /// 🔹 INFO CONTAINER
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: ColorCode.k282828,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:  [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Editing includes",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Color(0xFFBDBDBD),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      getEditingDescription(),
                                      style: const TextStyle(
                                        color: ColorCode.kWhiteOpacity70,
                                        fontSize: 13,
                                        fontFamily: "Outfit",
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30),


                        GestureDetector(
                          onTap: _showEditTypeBottomSheet,
                          child: AbsorbPointer(
                            child: TextField(
                              controller: TextEditingController(
                                text: getEditTypeDisplayText(),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: "Outfit",
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                labelText: getContentTypeTitle(widget.contentTypeId),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down,

                                  color: ColorCode.kWhiteOpacity70,
                                ),
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  const BorderSide(color: ColorCode.kWhiteOpacity70, width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  const BorderSide(color: ColorCode.kWhiteOpacity70, width: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        VideoEdits('Video Edits'),
                        VideoEdits2('Photo Edits'),

                        SizedBox(height: 12,),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xffE8D1AB), // Beige/Cream color
                            borderRadius: BorderRadius.circular(8), // Fully rounded like the image
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Sparkle Icon Container
                              Container(
                                width: 34,
                                height: 34,
                                padding: EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child:  Center(
                                  child: Image.asset('assets/images/star.png'),
                                ),
                              ),

                              const SizedBox(width: 5),

                              // Text
                              const Expanded(
                                child: Text(
                                  "You’ll Receive 125 Photos + 2 Videos",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff101010),

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),


                        if (selectedEditTypeNames.isNotEmpty) ...[
                          const SizedBox(height: 14),

                         /* Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(selectedEditTypeNames.length, (index) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: ColorCode.k282828,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ColorCode.kWhiteOpacity70,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      selectedEditTypeNames[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFamily: "Outfit",
                                      ),
                                    ),
                                    const SizedBox(width: 6),

                                    /// ❌ REMOVE ICON
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedEditTypeIds.removeAt(index);
                                          selectedEditTypeNames.removeAt(index);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),*/
                        ]

                      ],
                    ],
                  ),




                ],
              ),

            ),
          ),
        /*  if (isSubmitting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.15), // optional dim
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ),
            ),*/
        ],

      ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child:  OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:  Text("Back",style: TextStyle(fontFamily: "Unbounded",fontWeight: FontWeight.w500,fontSize: 14),),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isFormValid && !isSubmitting
                    ? () {
                  debugPrint("✅ Continue clicked");
                  _ShootDate_Time(); // 🔥 API CALL
                }
                    : null, // ❌ disabled when false

                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid
                      ? ColorCode.kButtonColor   // ✅ active
                      : ColorCode.k282828,       // ❌ disabled
                  foregroundColor: isFormValid
                      ? Colors.black
                      : Colors.grey.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isFormValid ? 2 : 0,
                ),

                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),

            ),


          ],
        ),
      ),
    );
  }
  /////////////////////////////////////////////////////////////////////////////////////
  Widget buildDateSelector({
    required BuildContext context,
    required List<DateTime> selectedDates,
    required Function(List<DateTime>) onChanged,
  }) {
    DateTime today = DateTime.now();
    List<DateTime> allDates = List.generate(60, (index) => today.add(Duration(days: index)));

    bool isSameDate(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    String getHeaderMonth() {
      return selectedDates.isNotEmpty
          ? DateFormat('MMM yyyy').format(selectedDates.first)
          : DateFormat('MMM yyyy').format(today);
    }

    // Show multi‑date picker with local state
    Future<void> showMultiDatePicker() async {
      // Temporary local list to hold selections inside the dialog
      List<DateTime> tempSelected = List.from(selectedDates);

      await showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: const Color(0xFF1C1C1C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              // Get valid screen height inside the dialog
              final double dialogScreenHeight = MediaQuery.of(dialogContext).size.height;

              return Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 7,),
                    const Text(
                      "Select Multiple Dates",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // ✅ Fixed height calendar – no pixel error
                    SizedBox(
                      height: dialogScreenHeight * 0.6,
                      child: CalendarDatePicker2(
                        config: CalendarDatePicker2Config(
                          calendarType: CalendarDatePicker2Type.multi,
                          selectedDayHighlightColor: const Color(0xFFE8D1AB),
                          selectedDayTextStyle: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(dialogContext).size.width * 0.04,
                          ),
                          dayTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(dialogContext).size.width * 0.035,
                          ),
                          weekdayLabelTextStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: MediaQuery.of(dialogContext).size.width * 0.035,
                          ),
                        ),
                        value: tempSelected,
                        onValueChanged: (dates) {
                          setDialogState(() {
                            tempSelected = dates;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8D1AB)),
                          onPressed: () {
                            Navigator.pop(dialogContext, tempSelected);
                          },
                          child: const Text("Done", style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ).then((result) {
        if (result != null && result is List<DateTime>) {
          onChanged(result);
        }
      });
    }

    return Container(
      // padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff282828),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getHeaderMonth(),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: showMultiDatePicker,
                  child: const Icon(Icons.calendar_today, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
          //  color: Colors.red,
            child: SizedBox(
              height:58 ,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allDates.length,
                itemBuilder: (context, index) {
                  final date = allDates[index];
                  final isSelected = selectedDates.any((d) => isSameDate(d, date));

                  return GestureDetector(
                    onTap: () {
                      List<DateTime> updated = List.from(selectedDates);
                      if (isSelected) {
                        updated.removeWhere((d) => isSameDate(d, date));
                      } else {
                        updated.add(date);
                      }
                      onChanged(updated);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical:4),//
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE8D1AB) : Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.black87 : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Total Days: ${selectedDates.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2723),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    selectedDates.isEmpty
                        ? "No dates selected"
                        : selectedDates.map((e) => DateFormat('d MMM').format(e)).join(', '),
                    style: const TextStyle(color: Color(0xFFE8D1AB), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
  ////////////////////////////////////////////////////////////////////////////////////


  Widget VideoEdits(String title) {
    bool _isOpen = true;
    int _count1 = 0;
    int _count2 = 0;
    int _count3 = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: EdgeInsets.only(top: 17, bottom: 17),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header - alag color
              GestureDetector(
                onTap: () => setState(() => _isOpen = !_isOpen),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff282828),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomLeft: _isOpen ? Radius.circular(23) : Radius.circular(14),
                      bottomRight: _isOpen ? Radius.circular(23) : Radius.circular(14),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isOpen ? 0 : 0.5,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isOpen) ...[
                // Row 1
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  child: Row(
                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Social Media Reel (15 sec–30 sec)',
                            style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12,fontFamily:'Outfit',
                            fontWeight:FontWeight.w500,
                            )),
                      ),
                      Container(
                        width: 80,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xffE8D1AB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() {
                                if (_count1 > 0) _count1--;


                              }),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.remove, size: 10, color: Color(0xFF1A1A1A)),
                              ),
                            ),
                            Text(
                              _count1.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _count1++),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.add, size: 10, color: Color(0xFF1A1A1A)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

               // const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20, color: Color(0xFF333333)),

                // Row 2
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Social Media Reel (30 sec–90 sec)',
                            style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12,fontFamily:'Outfit',
                              fontWeight:FontWeight.w500,
                            )),
                      ),
                      Container(
                        width: 80,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xffE8D1AB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() { if (_count2 > 0) _count2--; }),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.remove, size: 10, color: Color(0xFF1A1A1A)),
                              ),
                            ),
                            Text(
                              _count2.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _count2++),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.add, size: 10, color: Color(0xFF1A1A1A)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              //  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20, color: Color(0xFF333333)),

                // Row 3
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Social Media Reel (2 min–4 min)',
                            style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12,fontFamily:'Outfit',
                              fontWeight:FontWeight.w500,
                            )),
                      ),
                      Container(
                        width: 80,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xffE8D1AB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() { if (_count3 > 0) _count3--; }),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.remove, size: 10, color: Color(0xFF1A1A1A)),
                              ),
                            ),
                            Text(
                              _count3.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _count3++),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.add, size: 10, color: Color(0xFF1A1A1A)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  //////////////////////////////////////////
  Widget VideoEdits2(String title) {
    bool _isOpen = true;
    int _count1 = 0;


    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: EdgeInsets.only(top: 17, bottom: 17),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header - alag color
              GestureDetector(
                onTap: () => setState(() => _isOpen = !_isOpen),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff282828),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomLeft: _isOpen ? Radius.circular(23) : Radius.circular(14),
                      bottomRight: _isOpen ? Radius.circular(23) : Radius.circular(14),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isOpen ? 0 : 0.5,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isOpen) ...[
                // Row 1
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  child: Column(
                    children: [
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Edited Photos',style: TextStyle(fontFamily: 'Outfit',fontWeight: FontWeight.w500,fontSize: 12),),

                              Text('+25 photos Per Set',style: TextStyle(fontFamily: 'Outfit',fontWeight: FontWeight.w300,fontSize: 10),),
                            ],
                          ),
                          Spacer(),
                          Container(
                            width: 80,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xffE8D1AB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() { if (_count1 > 0) _count1--; }),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.remove, size: 10, color: Color(0xFF1A1A1A)),
                                  ),
                                ),
                                Text(
                                  _count1.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _count1++),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.add, size: 10, color: Color(0xFF1A1A1A)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7,),
                      Divider(
                      thickness: 2,
                        color: Colors.white.withOpacity(0.20),
                      ),

                      SizedBox(height: 7,),

                      Container(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xff322F2A),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('📸 Includes 100 free photo edits',style: TextStyle(
                              fontSize: 10,
                              color: Color(0xffE8D1AB),
                              fontWeight: FontWeight.w500,
                            ),),

                            Container(

                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "4 Hour Duration",
                                style: TextStyle(
                                  fontSize: 10,

                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],

                        ),
                      ),
                      SizedBox(height: 18,),

                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff322F2A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('➕ 25 Added Extra',style: TextStyle(
                              fontSize: 12,
                              color: Color(0xffE8D1AB),
                            ),),
                          ),
                        ],
                      ),
                      SizedBox(height: 7,),

                      
                    ],
                  ),
                ),





              ],
            ],
          ),
        );
      },
    );
  }

  Widget timeField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer( // 🔥 TextField touch disable
        child: TextField(
          controller: controller,
          readOnly: true,
          cursorColor: ColorCode.white,

          style: const TextStyle(color: ColorCode.white),

          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,

            labelStyle: TextStyle(
              color: ColorCode.kWhiteOpacity70,
              fontSize: 12,
              fontFamily: "Outfit",
            ),

            suffixIcon:  Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                "assets/svg/Group 2087328870.svg",
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  ColorCode.white,
                  BlendMode.srcIn,
                ),
              ),
            ),

            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: ColorCode.kWhiteOpacity70, width: 0.5),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: ColorCode.kWhiteOpacity70, width: 0.5),
            ),
          ),
        ),
      ),
    );
  }
  void _showEditTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.65, // 🔥 fixed height
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Edit Types",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// ✅ SCROLLABLE LIST (PIXEL ISSUE SOLVED)
                    Expanded(
                      child: ListView.builder(
                        itemCount: editTypes.length,
                        itemBuilder: (context, index) {
                          final item = editTypes[index];
                          final int id = item['edit_type_id'];
                          final String name = item['name'];
                          final bool isSelected =
                          selectedEditTypeIds.contains(id);

                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: ColorCode.kButtonColor,
                            checkColor: Colors.black,
                            title: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: "Outfit",
                              ),
                            ),
                            onChanged: (value) {
                              setSheetState(() {
                                if (value == true) {
                                  if (!selectedEditTypeIds.contains(id)) {
                                    selectedEditTypeIds.add(id);
                                    selectedEditTypeNames.add(name);
                                  }
                                } else {
                                  final index =
                                  selectedEditTypeIds.indexOf(id);
                                  if (index != -1) {
                                    selectedEditTypeIds.removeAt(index);
                                    selectedEditTypeNames.removeAt(index);
                                  }
                                }
                              });

                              setState(() {}); // 🔥 update chips
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// DONE BUTTON (FIXED AT BOTTOM)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorCode.kButtonColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Done",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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


  Widget _buildOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8D1AB), // light gold
                  Color(0xFFD4A14D), // dark gold
                ],
              )
                  : null,
              border: Border.all(
                color: ColorCode.kWhiteOpacity70,
                width: 1,
              ),
            ),
            child: isSelected
                ? Center(
              child: Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              ),
            )
                : const SizedBox(),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: ColorCode.white,
              fontSize: 14,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  }



