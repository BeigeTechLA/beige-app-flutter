import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../Customtextfiled/CustomInputField.dart';
import '../utility/images.dart';
import 'bookin_review_confirm.dart';
import 'booking_summary_view_summary.dart';

class BookingSelectDateTimeSlots extends StatefulWidget {
  final int bookingId;


  const BookingSelectDateTimeSlots({super.key, required this.bookingId});

  @override
  State<BookingSelectDateTimeSlots> createState() => _BookingSelectDateTimeSlotsState();
}

class _BookingSelectDateTimeSlotsState extends State<BookingSelectDateTimeSlots> {



  List<dynamic> editTypes = [];              // API data
  List<int> selectedEditTypeIds = [];        // selected ids
  List<String> selectedEditTypeNames = [];


  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  DateTime? selectedDate;

  bool? isEditNeeded;
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
    if (selectedDate == null) return false;
    if (startTime == null || endTime == null) return false;

    // 🔥 TIME VALIDATION
    if (!isEndTimeAfterStart(startTime!, endTime!)) return false;

    if (isEditNeeded == true && selectedEditTypeIds.isEmpty) {
      return false;
    }

    return true;
  }


  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    dateController.dispose();
    super.dispose();
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

    if (selectedEditTypeNames.isEmpty) {
      return "Select skills";
    }

    if (selectedEditTypeNames.length == 1) {
      return selectedEditTypeNames.first;
    }

    return "${selectedEditTypeNames.first} +${selectedEditTypeNames.length - 1}";
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
  Future<void> _ShootDate_Time() async {
    if (!isFormValid) return;

    setState(() => isSubmitting = true);

    final payload = {
      "event_date": _apiDateFormat(selectedDate!),
      "start_time": startTimeController.text,
      "end_time": endTimeController.text,
      "edits_needed": isEditNeeded == true ? 1 : 0,
      "edit_types": isEditNeeded == true ? selectedEditTypeIds : [],
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
            builder: (_) => BookinReviewConfirm(

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


/*


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // 🔥 past date disable
      lastDate: DateTime(2100),

      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: const Color(0xFF121212),

            colorScheme: const ColorScheme.dark(
              primary: ColorCode.kButtonColor,      // selected date bg
              onPrimary: Colors.black,               // selected date text
              surface: Color(0xFF1E1E1E),             // calendar bg
              onSurface: Colors.white,                // normal date text
            ),

            datePickerTheme: const DatePickerThemeData(
              headerBackgroundColor: ColorCode.kButtonColor,
              headerForegroundColor: Colors.black,
              dayForegroundColor: MaterialStatePropertyAll(Colors.white),
              weekdayStyle: TextStyle(color: Colors.grey),
              todayForegroundColor: MaterialStatePropertyAll(Colors.white),
              todayBackgroundColor: MaterialStatePropertyAll(Colors.transparent),
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ColorCode.kButtonColor, // OK / CANCEL
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
        dateController.text =
        "${picked.day.toString().padLeft(2, '0')}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.year}";
      });
    }
  }
*/

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

  Future<void> _edittype() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking_shoot_types}${12}/edit-types",
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leadingWidth: 40, // 🔥 important
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: SvgPicture.asset(
                images.back,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          actions: const [ Padding( padding: EdgeInsets.only(right: 16), child: Center( child: Text("1/2", style: TextStyle(color: Colors.white)), ), ) ],
        ),




      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Stack(
            children: [
              Row(
                children: List.generate(
                  2,
                      (index) => Expanded(
                    child: Container(
                      margin:  EdgeInsets.only(right: 6),
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
              SingleChildScrollView(
                child: Column(
                  children: [

                    SizedBox(
                      height: 20,
                    ),
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

                 /*   TextField(
                      controller: dateController,
                      readOnly: true, // 🔥 keyboard band
                      cursorColor: ColorCode.white,

                      style: const TextStyle(
                        color: ColorCode.white,
                        fontFamily: "Outfit",
                        fontSize: 14,
                      ),

                      decoration: InputDecoration(
                        labelText: "Select Date",
                        floatingLabelBehavior: FloatingLabelBehavior.always,

                        labelStyle: TextStyle(
                          color: ColorCode.kWhiteOpacity70,
                          fontSize: 12,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w400,
                        ),

                        suffixIcon: InkWell(
                          onTap: () => _selectDate(context),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: ColorCode.kWhiteOpacity70,
                          ),
                        ),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: ColorCode.kWhiteOpacity70,
                            width: 0.5,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: ColorCode.kWhiteOpacity70,
                            width: 0.5,
                          ),
                        ),
                      ),

                      onTap: () => _selectDate(context), // 🔥 full field clickable
                    ),*/

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
               /*     timeField(
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
                    ),
*/

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
      /*              Column(
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
                              children: const [
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
                                    Text(
                                      "25 edited photos per hour",
                                      style: TextStyle(
                                        color: Color(0xFFBDBDBD),
                                        fontSize: 13,
                                        fontFamily: "Outfit",
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
                                  // labelText: getContentTypeTitle(widget.contentTypeId),
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

                          if (selectedEditTypeNames.isNotEmpty) ...[
                            const SizedBox(height: 14),

                            Wrap(
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
                          ),
                          ]

                        ],
                      ],
                    ),*/




                  ],
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
      ),

        bottomNavigationBar: Padding(
          padding:  EdgeInsets.all(16),
          child: Row(
            children: [

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
                    "Next",
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
        )



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

            suffixIcon: const Icon(
              Icons.watch_later,
              size: 20,
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
                height: 10,
                width: 10,
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
