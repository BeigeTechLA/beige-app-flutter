  import 'package:calendar_date_picker2/calendar_date_picker2.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_svg/svg.dart';
  import 'package:intl/intl.dart';

  import '../../../../Customtextfiled/CustomInputField.dart';
  import '../../../../main.dart';
  import '../../../../service/api_endpoints.dart';
  import '../../../../service/api_service.dart';
  import '../../../../app/colors.dart';
  import '../../More_Details/more_details_screen.dart';

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
    bool isToday = false;

    Map<DateTime, bool> expandedMap = {};
    Map<DateTime, TimeOfDay?> startTimes = {};
    Map<DateTime, TimeOfDay?> endTimes = {};

    Map<int, int> videoCounts = {};
    Map<int, int> photoCounts = {};

    TimeOfDay? shootStartTime;
    TimeOfDay? shootEndTime;
    bool isShootDateSelected() {
      return selectedDates.isNotEmpty;
    }

    String getDurationText(DateTime date) {
      final start = startTimes[date];
      final end = endTimes[date];

      if (start == null || end == null) return "Duration:00";

      final startMin = start.hour * 60 + start.minute;
      final endMin = end.hour * 60 + end.minute;

      int diff;

      if (endMin >= startMin) {
        diff = endMin - startMin;
      } else {
        /// 🔥 NEXT DAY SUPPORT
        diff = (24 * 60 - startMin) + endMin;
      }

      final hours = diff ~/ 60;
      final minutes = diff % 60;

      /// 🔥 FORMAT LOGIC
      if (hours > 0 && minutes > 0) {
        return "Duration: ${hours}h ${minutes}m";
      } else if (hours > 0) {
        return "Duration: ${hours}h";
      } else {
        return "Duration: ${minutes}m";
      }
    }
    Future<void> pickTime(DateTime date, bool isStart) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (picked != null) {
        setState(() {
          if (isStart) {
            startTimes[date] = picked;
          } else {
            endTimes[date] = picked;
          }
        });
      }
    }

    Future<void> selectShootTime(
        BuildContext context,
        TextEditingController controller,
        bool isStartTime,
        ) async {

      TimeOfDay initial = isStartTime
          ? (shootStartTime ?? TimeOfDay.now())
          : (shootEndTime ?? TimeOfDay.now());

      final picked = await showTimePicker(
        context: context,
        initialTime: initial,
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              dialogBackgroundColor: const Color(0xFF121212),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Color(0xFF1E1E1E),
                onSurface: Colors.white,
              ),
              timePickerTheme: const TimePickerThemeData(
                backgroundColor: Color(0xFF121212),
                dialBackgroundColor: Color(0xFF121212),
                dialHandColor: Colors.white,
                dialTextColor: Colors.grey,
                hourMinuteColor: AppColors.primary,
                hourMinuteTextColor: Colors.black,
                dayPeriodColor: AppColors.primary,
                dayPeriodTextColor: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          if (isStartTime) {
            shootStartTime = picked;
          } else {
            shootEndTime = picked;
          }

          controller.text = picked.format(context);
        });
      }
    }

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
    List<dynamic> photoEditTypes = [];
    List<dynamic> editTypes = [];




    int selectedIndex=1;
    bool istimingsame=true;
    bool isPhotoOpen = true; //      // API data
    bool isVideoOpen = true; //      // API data

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

    String formatDatesAlt(List<DateTime> dates) {
      if (dates.isEmpty) return "";

      dates.sort();

      Map<String, List<int>> monthMap = {};

      for (var date in dates) {
        String key = DateFormat('MMM yyyy').format(date);

        if (!monthMap.containsKey(key)) {
          monthMap[key] = [];
        }

        monthMap[key]!.add(date.day);
      }

      List<String> result = [];

      monthMap.forEach((month, days) {
        days.sort();

        String daysText = "";

        if (days.length == 1) {
          daysText = "${days.first}";
        } else if (days.length == 2) {
          daysText = "${days[0]} & ${days[1]}";
        } else {
          daysText =
          "${days.sublist(0, days.length - 1).join(', ')} & ${days.last}";
        }

        result.add("$month $daysText");
      });

      return result.join(", ");
    }
    String formatSelectedDates(List<DateTime> dates) {
      if (dates.isEmpty) return "";

      dates.sort();

      Map<String, List<int>> monthMap = {};

      for (var date in dates) {
        String key = DateFormat('MMM yyyy').format(date);

        if (!monthMap.containsKey(key)) {
          monthMap[key] = [];
        }

        monthMap[key]!.add(date.day);
      }

      List<String> result = [];

      monthMap.forEach((month, days) {
        days.sort();

        String daysText = "";

        if (days.length == 1) {
          daysText = "${days.first}";
        } else if (days.length == 2) {
          daysText = "${days[0]} & ${days[1]}";
        } else {
          daysText =
          "${days.sublist(0, days.length - 1).join(', ')} & ${days.last}";
        }

        result.add("$daysText $month");
      });

      return "Selected Days: ${result.join(', ')}";
    }

    bool isEndTimeAfterStart(TimeOfDay start, TimeOfDay end) {
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;

      /// ✅ SAME DAY
      if (endMinutes > startMinutes) return true;

      /// ✅ NEXT DAY ALLOW
      return true;
    }
    bool get isFormValid {

      /// 🔥 SINGLE DAY
      if (selectedIndex == 1) {
        if (selectedDate == null) return false;
        if (startTime == null || endTime == null) return false;
      }

      /// 🔥 MULTIPLE DAY
      if (selectedIndex == 2) {
        if (selectedDates.isEmpty) return false;

        /// 👉 SAME TIME FOR ALL
        if (istimingsame == true) {
          if (startTime == null || endTime == null) return false;
        }

        /// 👉 DIFFERENT TIME FOR EACH DATE
        if (istimingsame == false) {
          for (var date in selectedDates) {
            if (startTimes[date] == null || endTimes[date] == null) {
              return false;
            }
          }
        }
      }

      /// 🔥 EDIT VALIDATION (FIXED)
      if (isEditNeeded) {
        bool hasEdits = false;

        // check video edits
        videoCounts.forEach((key, value) {
          if (value > 0) hasEdits = true;
        });

        // check photo edits
        photoCounts.forEach((key, value) {
          if (value > 0) hasEdits = true;
        });

        if (!hasEdits) return false;
      }

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
        // return "50 edited photos per hour for weddings";
        return "Professional editing includes color grading,sound mixing, and basic revisions.";
      }

      // 📷 Default Photo
      return "Professional editing includes color grading,sound mixing, and basic revisions.";
      // return "25 edited photos per hour";
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
          final data = response['data'];

          setState(() {
            editTypes = data['video_edit_types'] ?? [];
            photoEditTypes = data['photo_edit_types'] ?? [];
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

      /// 🔥 RESET
      if (!isEditNeeded) {
        selectedEditTypeIds.clear();
        selectedEditTypeNames.clear();
        videoCounts.clear();
        photoCounts.clear();
      }

      /// 🔥 BUILD EDIT ARRAYS
      List<String> videoEditKeys = [];
      List<String> photoEditKeys = [];

      videoCounts.forEach((key, count) {
        if (count > 0) {
          String apiKey = editTypes[key]['key'];
          for (int i = 0; i < count; i++) {
            videoEditKeys.add(apiKey);
          }
        }
      });

      photoCounts.forEach((key, count) {
        if (count > 0) {
          String apiKey = photoEditTypes[key]['key'];
          for (int i = 0; i < count; i++) {
            photoEditKeys.add(apiKey);
          }
        }
      });

      Map<String, dynamic> payload = {};

      /// ================= SINGLE DAY =================
      if (selectedIndex == 1) {

        /// ✅ SAFETY CHECK
        if (selectedDate == null || startTime == null || endTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select date and time")),
          );
          setState(() => isSubmitting = false);
          return;
        }

        /// ✅ END > START CHECK
        if (!isEndTimeAfterStart(startTime!, endTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("End time must be after Start time")),
          );
          setState(() => isSubmitting = false);
          return;
        }

        payload = {
          "booking_type": "single_day",
          "time_zone": "Asia/Calcutta",
          "event_date": _apiDateFormat(selectedDate!),
          "start_time": _formatTime(startTime!),
          "end_time": _formatTime(endTime!),
          "edits_needed": isEditNeeded ? 1 : 0,
          "video_edit_types": videoEditKeys,
          "photo_edit_types": photoEditKeys,
        };
      }

      /// ================= MULTIPLE DAY =================
      if (selectedIndex == 2) {
        List<Map<String, dynamic>> bookingDays = [];

        if (selectedDates.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select dates")),
          );
          setState(() => isSubmitting = false);
          return;
        }

        /// 🔹 SAME TIME FOR ALL
        if (istimingsame) {

          if (startTime == null || endTime == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select time")),
            );
            setState(() => isSubmitting = false);
            return;
          }

          if (!isEndTimeAfterStart(startTime!, endTime!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("End time must be after Start time")),
            );
            setState(() => isSubmitting = false);
            return;
          }

          for (var date in selectedDates) {
            bookingDays.add({
              "date": _apiDateFormat(date),
              "start_time": _formatTime(startTime!),
              "end_time": _formatTime(endTime!),
            });
          }

        }

        /// 🔹 DIFFERENT TIME FOR EACH DATE
        else {

          for (var date in selectedDates) {

            final start = startTimes[date];
            final end = endTimes[date];

            /// ❌ NULL CHECK
            if (start == null || end == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Select time for all dates")),
              );
              setState(() => isSubmitting = false);
              return;
            }

            /// ❌ VALIDATION
            if (!isEndTimeAfterStart(start, end)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("End time must be after Start time")),
              );
              setState(() => isSubmitting = false);
              return;
            }

            bookingDays.add({
              "date": _apiDateFormat(date),
              "start_time": _formatTime(start), // ✅ FIXED
              "end_time": _formatTime(end),     // ✅ FIXED
            });
          }
        }

        payload = {
          "booking_type": "multi_day",
          "time_zone": "Asia/Calcutta",
          "booking_days": bookingDays,
          "edits_needed": isEditNeeded ? 1 : 0,
          "video_edit_types": videoEditKeys,
          "photo_edit_types": photoEditKeys,
        };
      }

      debugPrint("📤 FINAL PAYLOAD → $payload");

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
    String _formatTime(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return "$hour:$minute:00";
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
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        helpText: '',
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              useMaterial3: true,
              dialogBackgroundColor: const Color(0xFF121212),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.black,
                surface: Color(0xFF121212),
                onSurface: Colors.white,
              ),
              datePickerTheme: DatePickerThemeData(
                backgroundColor: const Color(0xFF121212),
                dividerColor: Colors.white12,
                headerHeadlineStyle: const TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                headerHelpStyle: const TextStyle(fontSize: 0, height: 0),
                headerBackgroundColor: Color(0xFF0E0E0E),
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
                  foregroundColor: AppColors.primary,
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
          /// 🔥 SINGLE DAY MODE
          if (selectedIndex == 1) {
            selectedDate = picked;
            dateController.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
          }

          /// 🔥 MULTIPLE DAY MODE
          else {
            bool exists = selectedDates.any((d) =>
            d.year == picked.year &&
                d.month == picked.month &&
                d.day == picked.day);

            if (exists) {
              selectedDates.removeWhere((d) =>
              d.year == picked.year &&
                  d.month == picked.month &&
                  d.day == picked.day);
            } else {
              selectedDates.add(picked);
            }
          }

          /// 🔥 AUTO TIME LOGIC (ONLY SINGLE)
          if (selectedIndex == 1) {
            if (isTodaySelected()) {
              DateTime nowPlus4 =
              DateTime.now().add(const Duration(hours: 4));
              startTime = TimeOfDay.fromDateTime(nowPlus4);
              DateTime endDefault =
              nowPlus4.add(const Duration(hours: 2));
              endTime = TimeOfDay.fromDateTime(endDefault);
            } else {
              startTime = const TimeOfDay(hour: 9, minute: 0);
              endTime = const TimeOfDay(hour: 17, minute: 0);
            }

            _updateTimeText(startTimeController, startTime!);
            _updateTimeText(endTimeController, endTime!);
          }
        });
      }
    }

    Future<void> _selectDateMultiple(BuildContext context) async {
      List<DateTime> tempSelected = List.from(selectedDates);

      final result = await showDialog(
        context: context,
        builder: (context) {
          return Theme(
            data: ThemeData.dark().copyWith(
              useMaterial3: true,
              dialogBackgroundColor: const Color(0xFF121212),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.black,
                surface: Color(0xFF121212),
                onSurface: Colors.white,
              ),
            ),
            child: Dialog(
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// HEADER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFF0E0E0E),
                        child: const Text(
                          "Select Date",
                          style: TextStyle(
                            fontFamily: "Unbounded",
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      /// CALENDAR
                      SizedBox(
                        height: 350,
                        child: CalendarDatePicker2(
                          config: CalendarDatePicker2Config(
                            calendarType: CalendarDatePicker2Type.multi,

                            /// ❌ REMOVE DEFAULT CIRCLE
                            selectedDayHighlightColor: Colors.transparent,

                            /// ❌ PAST DATES DISABLE
                            firstDate: DateTime.now(),

                            /// TEXT STYLE
                            selectedDayTextStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),

                            /// 🔥 CUSTOM UI (MAIN PART)
                            dayBuilder: ({
                              required DateTime date,
                              TextStyle? textStyle,
                              BoxDecoration? decoration,
                              bool? isSelected,
                              bool? isDisabled,
                              bool? isToday,
                            }) {
                              final today = DateTime.now();

                              bool isPast = date.isBefore(
                                DateTime(today.year, today.month, today.day),
                              );

                              /// ❌ PAST DATE (VISIBLE BUT DISABLED)
                              if (isPast) {
                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  child: Center(
                                    child: Text(
                                      "${date.day}",
                                      style: const TextStyle(
                                        color: Colors.grey, // 👈 grey = disabled look
                                      ),
                                    ),
                                  ),
                                );
                              }

                              /// ✅ SELECTED (BOX STYLE)
                              if (isSelected == true) {
                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8D1AB),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${date.day}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              /// ✅ NORMAL DATE
                              return Container(
                                margin: const EdgeInsets.all(4),
                                child: Center(
                                  child: Text(
                                    "${date.day}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),

                          value: tempSelected,

                          onValueChanged: (dates) {
                            setStateDialog(() {
                              /// 🔥 SAFETY FILTER
                              tempSelected = dates.where((date) {
                                return !date.isBefore(
                                  DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                  ),
                                );
                              }).toList();
                            });
                          },
                        ),
                      ),

                      /// ACTIONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, tempSelected);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          );
        },
      );

      if (result != null && result is List<DateTime>) {
        setState(() {
          selectedDates = result;
          startTimes.clear();
          endTimes.clear();
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


    Future<void> _selectTime(
        BuildContext context,
        TextEditingController? controller,
        bool isStartTime,
        DateTime? date,
        ) async {
      final now = DateTime.now();

      /// 🔥 BASE DATE (ALL CASE COVER)
      DateTime? baseDate;

      if (date != null) {
        baseDate = date; // Multiple NO
      } else if (selectedDate != null) {
        baseDate = selectedDate; // Single Day
      }else if (selectedDates.isNotEmpty && date == null) {
        baseDate = selectedDates.first; // or remove this block completely
      }

      if (baseDate == null) return;

      /// 🔥 CHECK TODAY
      bool isSameDay =
          baseDate.year == now.year &&
              baseDate.month == now.month &&
              baseDate.day == now.day;

      /// 🔥 INITIAL TIME
      TimeOfDay initial;

      if (date != null) {
        initial = isStartTime
            ? (startTimes[date] ?? TimeOfDay.now())
            : (endTimes[date] ?? TimeOfDay.now());
      } else {
        initial = isStartTime
            ? (startTime ?? TimeOfDay.now())
            : (endTime ?? TimeOfDay.now());
      }

      /// 🔥 TODAY START TIME → AUTO +4 HOURS
      /*if (isSameDay && isStartTime) {
        final min = now.add(const Duration(hours: 4));
        initial = TimeOfDay(hour: min.hour, minute: min.minute);
      }*/

      /// 🔥 TIME PICKER WITH THEME
      final picked = await showTimePicker(
        context: context,
        initialTime: initial,
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              useMaterial3: true,
              dialogBackgroundColor: const Color(0xFF121212),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.black,
                surface: Color(0xFF121212),
                onSurface: Colors.white,
              ),
              timePickerTheme: const TimePickerThemeData(
                backgroundColor: Color(0xFF121212),
                dialBackgroundColor: Color(0xFF121212),
                dialHandColor: Colors.white,
                dialTextColor: Colors.grey,
                hourMinuteColor: AppColors.primary,
                hourMinuteTextColor: Colors.black,
                dayPeriodColor: AppColors.primary,
                dayPeriodTextColor: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked == null || !mounted) return;

      /// 🔥 VALIDATION (4 HOUR RULE)
      if (isStartTime) {
        final minAllowed = now.add(const Duration(hours: 4));
/*
        final pickedDT = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          picked.hour,
          picked.minute,
        );*/

        final pickedDT = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          picked.hour,
          picked.minute,
        );

        /// 🔥 APPLY ONLY IF TODAY
        bool isToday =
            baseDate.year == now.year &&
                baseDate.month == now.month &&
                baseDate.day == now.day;

        /// 🔥 ONLY APPLY FOR TODAY
        if (isToday && pickedDT.isBefore(minAllowed)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Select time after 4 hours from now"),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        /// 🔥 FINAL CORRECT CHECK (DATE + TIME)
        if (pickedDT.isBefore(minAllowed)) {
          final min = TimeOfDay.fromDateTime(minAllowed);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Select time after 4 hours from now"),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
      }

      /// 🔥 SAVE DATA
      setState(() {
        if (date != null) {
          /// MULTIPLE (NO)
          if (isStartTime) {
            startTimes[date] = picked;
          } else {
            endTimes[date] = picked;
          }
        } else {
          /// SINGLE / MULTIPLE YES
          if (isStartTime) {
            startTime = picked;
            if (controller != null) {
              _updateTimeText(controller, picked);
            }

          } else {
            endTime = picked;
            if (controller != null) {
              _updateTimeText(controller, picked);
            }
          }

        }
      });
    }
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
                  color: AppColors.white,
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
                    color: AppColors.white,
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
              Padding(
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
                              color: AppColors.textSecondary, // grey background
                              borderRadius: BorderRadius.circular(64),
                            ),
                            child: isActive
                                ? Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 5,
                                width: 120, // 🔥 colored portion only
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
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

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = 1;

                                        selectedDates.clear();   // 🔥 ADD THIS
                                        startTimes.clear();
                                        endTimes.clear();
                                        startTimeController.clear();
                                        endTimeController.clear();
                                        startTime = null;
                                        endTime = null;
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
                                        selectedDates.clear();   // 🔥 ADD THIS
                                        startTimes.clear();      // 🔥 ADD THIS
                                        endTimes.clear();

                                        startTimeController.clear();
                                        endTimeController.clear();
                                        startTime = null;
                                        endTime = null;
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
                              SizedBox(height: 12,),
                              buildDateSelector(
                                context: context,
                                selectedDates: selectedDates,
                                onChanged: (dates) {
                                  setState(() {
                                    selectedDates = dates;
                                  });
                                },
                              ),


                              SizedBox(height: 12,),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Color(0xff322F2A),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "Total Days: ${selectedDates.length}",
                                      style: const TextStyle(color: Color(0xffE8D1AB), fontSize: 13,fontFamily: "Helvetica Neue",fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Color(0xff322F2A),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: selectedDates.isEmpty
                                          ? const Text(
                                        "No dates selected",
                                        style: TextStyle(
                                          color: Color(0xFFE8D1AB),
                                          fontSize: 12,
                                        ),
                                      )
                                          : SingleChildScrollView(
                                        scrollDirection: Axis.horizontal, // 👈 scroll enable
                                        child: Text(
                                            formatSelectedDates(selectedDates),
                                            style: const TextStyle(color: Color(0xffE8D1AB), fontSize: 13,fontFamily: "Helvetica Neue",fontWeight: FontWeight.w500)
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 18,),
                              Text('Are Timings Same For All\nSelected Dates?',style: TextStyle(
                                color: Colors.white,
                                fontFamily:'Unbounded',
                                fontSize: 14,
                              ),),

                              const SizedBox(height: 12),

                              /// 🔹 YES / NO
                              Row(
                                children: [
                                  _buildOption(
                                    title: "Yes",
                                    isSelected: istimingsame == true,
                                    onTap: () {
                                      setState(() {
                                        istimingsame = true;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 24),
                                  _buildOption(

                                    title: "No",
                                    isSelected: istimingsame == false,
                                    onTap: () {
                                      setState(() {
                                        istimingsame = false;

                                        // 🔥 CLEAR OLD DATA
                                        resetEditTypes();

                                      });
                                    },

                                  ),
                                ],
                              ),
                              if (istimingsame == false) ...[
                                const SizedBox(height: 20),

                                Column(
                                  children: selectedDates.map((date) {
                                    final isOpen = expandedMap[date] ?? false;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(

                                        border: isOpen?
                                        Border.all(color: Colors.white.withOpacity(0.2)):

                                        Border.all(color:  Colors.transparent),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [

                                          /// 🔥 HEADER (Dropdown)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                expandedMap[date] = !isOpen;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xff282828),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    DateFormat('MMMM dd, yyyy').format(date),
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                  Icon(
                                                    isOpen
                                                        ? Icons.keyboard_arrow_up
                                                        : Icons.keyboard_arrow_down,
                                                    color: Colors.white,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),

                                          /// 🔥 BODY
                                          if (isOpen) ...[
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,

                                                children: [

                                                  /// Start Time

                                                      CustomInputField(
                                    title: "Start Time",
                                    controller: TextEditingController(
                                    text: startTimes[date]?.format(context) ?? "",
                                    ),
                                    readOnly: true,
                                    onTap: () {
                                    _selectTime(context, null, true, date); // ✅ FIX
                                    },
                                    suffixIcon: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                    "assets/svg/Group 2087328870.svg",
                                      color: AppColors.white,
                                    ),
                                    ),
                                    ),
                                                  SizedBox(height: 30,),
                                                  CustomInputField(
                                                    title: "End Time",
                                                    controller: TextEditingController(
                                                      text: endTimes[date]?.format(context) ?? "",
                                                    ),
                                                    readOnly: true,
                                                    onTap: () {
                                                      _selectTime(context, null, false, date); // ✅ FIX
                                                    },
                                                    suffixIcon: Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: SvgPicture.asset(
                                                        "assets/svg/Group 2087328870.svg",
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 16),

                                                  /// Duration
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 14, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xffE8D1AB),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      getDurationText(date),
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ]
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                )
                              ],



                              if (istimingsame == true) ...[
                                SizedBox(height: 22),

                                /// ✅ START TIME
                                CustomInputField(
                                  title: "Start Time",
                                  controller: startTimeController,
                                  readOnly: true,
                                  onTap: () {
                                    if (selectedDates.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please select date first")),
                                      );
                                      return;
                                    }

                                    _selectTime(context, startTimeController, true, null); // ✅ FIX
                                  },
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      "assets/svg/Group 2087328870.svg",
                                      color: AppColors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 30),

                                /// ✅ END TIME
                                CustomInputField(
                                  title: "End Time",
                                  controller: endTimeController,
                                  readOnly: true,
                                  onTap: () {
                                    if (selectedDates.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please select date first")),
                                      );
                                      return;
                                    }

                                    _selectTime(context, endTimeController, false, null); // ✅ FIX
                                  },
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      "assets/svg/Group 2087328870.svg",
                                      color: AppColors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 12),

                                Row(
                                  children: [
                                    SvgPicture.asset('assets/svg/true.svg', width: 24, height: 24),
                                    SizedBox(width: 6),
                                    Text(
                                      'Applied to ${selectedDates.length} selected dates',
                                      style: TextStyle(
                                        color: const Color(0xFFA9A9A9),
                                        fontSize: 14,
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w400,
                                        height: 1.36,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      /// 📅 ICON
                                      SvgPicture.asset("assets/svg/calendar-03.svg"),

                                      const SizedBox(width: 13),

                                      /// 📅 DATE + TIME (DYNAMIC)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            /// 🔥 DYNAMIC DATE
                                            Text(
                                              formatDatesAlt(selectedDates), // ✅ already in your code
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Helvetica Neue"
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            /// 🔥 DYNAMIC TIME
                                            Text(
                                              startTime != null && endTime != null
                                                  ? "${startTime!.format(context)} – ${endTime!.format(context)}"
                                                  : "Select Time",
                                              style: TextStyle(
                                                fontFamily: "Helvetica Neue",


                                                color: AppColors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// ⏱ DYNAMIC HOURS
                                      Text(
                                        getTotalDuration(), // 👇 function below
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 14,
                                          fontFamily: "Helvetica Neue",


                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),)
,                              ],

                              SizedBox(height: 12),





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
                                  AppColors.white70,
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

                              _selectTime(context, startTimeController, true, null); // ✅ FIX
                            },
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SvgPicture.asset(
                                "assets/svg/Group 2087328870.svg",
                                width: 20,
                                height: 20,
                                color: AppColors.white,
                              ),
                            ),
                          ),

                          SizedBox(height: 30),

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

                              _selectTime(context, endTimeController, false, null); // ✅ FIX
                            },
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SvgPicture.asset(
                                "assets/svg/Group 2087328870.svg",
                                width: 20,
                                height: 20,
                                color: AppColors.white,
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
                                  color: AppColors.surfaceVariant,
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
                                              color: AppColors.white70,
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


                          /*    GestureDetector(
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

                                        color: AppColors.white70,
                                      ),
                                      contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide:
                                        const BorderSide(color: AppColors.white70, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide:
                                        const BorderSide(color: AppColors.white70, width: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),*/
                              Column(
                                children: [

                                  /// ✅ VIDEO ONLY IF DATA AVAILABLE
                                  if (editTypes.isNotEmpty)
                                    VideoEdits('Video Edits', editTypes),

                                  /// ✅ PHOTO ONLY IF DATA AVAILABLE
                                  if (photoEditTypes.isNotEmpty)
                                    PhotoEdits('Photo Edits', photoEditTypes),

                                ],
                              ),

                              SizedBox(height: 12,),
                          /*    Container(
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
                              ),*/

                              if (selectedEditTypeNames.isNotEmpty) ...[
                                const SizedBox(height: 14),

                                /* Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(selectedEditTypeNames.length, (index) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.white70,
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
                        ? AppColors.primary   // ✅ active
                        : AppColors.surfaceVariant,       // ❌ disabled
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
    })
    {
      DateTime today = DateTime.now();

      /// ✅ Current month calculation (IMPORTANT FIX)
      DateTime firstDay = DateTime(today.year, today.month, 1);
      DateTime lastDay = DateTime(today.year, today.month + 1, 0);
      int totalDays = lastDay.day;

      /// ✅ Only current month dates
      List<DateTime> allDates = List.generate(
        totalDays - today.day + 1,
            (index) => DateTime(
          today.year,
          today.month,
          today.day + index,
        ),
      );

      bool isSameDate(DateTime a, DateTime b) {
        return a.year == b.year &&
            a.month == b.month &&
            a.day == b.day;
      }

      String getHeaderMonth() {
        return DateFormat('MMM yyyy').format(today);
      }

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xff282828),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 Header
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getHeaderMonth(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDateMultiple(context),
                    child: SvgPicture.asset(
                      'assets/svg/Calendar_Mark-2.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🔥 Horizontal Month Dates
            SizedBox(
              height: 58,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allDates.length,
                itemBuilder: (context, index) {
                  final date = allDates[index];

                  final isSelected =
                  selectedDates.any((d) => isSameDate(d, date));

                  /// ✅ Disable past dates (optional but good)
                  final isPast = date.isBefore(
                    DateTime(today.year, today.month, today.day),
                  );

                  return GestureDetector(
                    onTap: isPast
                        ? null
                        : () {
                      List<DateTime> updated =
                      List.from(selectedDates);

                      if (isSelected) {
                        updated.removeWhere(
                                (d) => isSameDate(d, date));
                      } else {
                        updated.add(date);
                      }

                      onChanged(updated);

                      /// 🔥 UI refresh
                      (context as Element).markNeedsBuild();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 9),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 19, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE8D1AB)
                            : Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xff222222)
                                  : const Color(0xff939393),
                            ),
                          ),
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              fontSize: 9,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xff1D1D1B)
                                  : Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      );
    }

    Widget VideoEdits(String title, List<dynamic> data) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            /// HEADER
            GestureDetector(
              onTap: () {
                setState(() {
                  isVideoOpen = !isVideoOpen;

                  /// ✅ CLOSE → CLEAR DATA
                 /* if (!isVideoOpen) {
                    videoCounts.clear();
                    selectedEditTypeIds.clear();
                  }*/
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Color(0xff282828),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        )),

                    AnimatedRotation(
                      turns: isVideoOpen ? 0.5 : 0,
                      duration: Duration(milliseconds: 300),
                      child: Icon(Icons.keyboard_arrow_down,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            /// BODY
            AnimatedCrossFade(
              duration: Duration(milliseconds: 300),
              crossFadeState: isVideoOpen
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,

              firstChild: Column(
                children: data.asMap().entries.map((entry) {
                  int id = entry.key;
                  var item = entry.value;

                  String name = item['value'] ?? "";

                  int count = videoCounts[id] ?? 0;

                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(name,
                              style: TextStyle(color: Colors.white)),
                        ),

                        /// COUNTER
                        Container(
                          width: 90,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color(0xffE8D1AB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [

                              /// ➖ MINUS
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      int current = videoCounts[id] ?? 0;

                                      if (current > 0) {
                                        current--;

                                        if (current == 0) {
                                          videoCounts.remove(id);
                                          selectedEditTypeIds.remove(id);
                                        } else {
                                          videoCounts[id] = current;
                                        }
                                      }
                                    });
                                  },
                                  child: Center(
                                    child: const Icon(Icons.remove, size: 16, color: Colors.black),
                                  ),
                                ),
                              ),

                              /// COUNT
                              Text(
                                (videoCounts[id] ?? 0)
                                    .toString()
                                    .padLeft(2, '0'),
                                style: TextStyle(
                                  color: AppColors.textHeading,
                                  fontSize: 13,
                                  fontFamily: "Helvetica Neue",
                                  fontWeight: FontWeight.w600

                                ),
                              ),

                              /// ➕ PLUS
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      int current = videoCounts[id] ?? 0;
                                      current++;

                                      videoCounts[id] = current;

                                      if (!selectedEditTypeIds.contains(id)) {
                                        selectedEditTypeIds.add(id);
                                      }
                                    });
                                  },
                                  child: Center(
                                    child: Icon(Icons.add,
                                        size: 16, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              secondChild: SizedBox(),
            ),
          ],
        ),
      );
    }
    Widget PhotoEdits(String title, List<dynamic> data) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            /// 🔥 HEADER
            GestureDetector(
              onTap: () {
                setState(() {
                  isPhotoOpen = !isPhotoOpen;

                  /*if (!isPhotoOpen) {
                    photoCounts.clear();
                  }*/
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xff2B2B2B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      isPhotoOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),

            /// 🔥 BODY
            if (isPhotoOpen)
              ...data.asMap().entries.map((entry) {
                int id = entry.key;
                var item = entry.value;

                String name = item['value'] ?? "";
                String note = item['note'] ?? "";
                int count = photoCounts[id] ?? 0;

                return Column(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        children: [
                          /// TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 1),
                                    Expanded(
                                      child: Text(
                                        note,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          /// COUNTER
                          Container(
                            width: 95,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8D1AB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                /// MINUS
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        int current = photoCounts[id] ?? 0;

                                        if (current > 0) {
                                          current--;

                                          if (current == 0) {
                                            photoCounts.remove(id);
                                          } else {
                                            photoCounts[id] = current;
                                          }
                                        }
                                      });
                                    },
                                    child: const Icon(Icons.remove,
                                        size: 16, color: Colors.black),
                                  ),
                                ),

                                /// COUNT
                                Text(
                                  count.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontFamily: "Helvetica Neue",


                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                /// PLUS
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        int current = photoCounts[id] ?? 0;
                                        current++;
                                        photoCounts[id] = current;
                                      });
                                    },
                                    child: const Icon(Icons.add,
                                        size: 16, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// DIVIDER
                    Container(
                      height: 0.5,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ],
                );
              }).toList(),

            /// 🔥 EXTRA SECTION (ONLY ONCE, NOT INSIDE LOOP)
            /*  if (isPhotoOpen)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xff322F2A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            /// LEFT TEXT
                            Expanded(
                              child: Row(
                                children: const [
                                  Text(
                                    "📸 ",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Includes 100 free photo edits",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// RIGHT BOX (INSIDE SAME CONTAINER)
                       *//*     Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                "4 Hour Duration",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),*//*
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                        Container(

                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xff322F2A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "+ 25 Added Extra",
                              style:
                              TextStyle(
                                color: const Color(0xFFE8D1AB),
                                fontSize: 12,
                                fontFamily: 'Helvetica Neue',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),*/
          ],
        ),
      );
    }


    String getTotalDuration() {
      if (startTime == null || endTime == null || selectedDates.isEmpty) {
        return "0 Hour";
      }

      final startMin = startTime!.hour * 60 + startTime!.minute;
      final endMin = endTime!.hour * 60 + endTime!.minute;

      int diff;

      if (endMin >= startMin) {
        diff = endMin - startMin;
      } else {
        diff = (24 * 60 - startMin) + endMin;
      }

      final hoursPerDay = diff ~/ 60;

      final totalDays = selectedDates.length;
      final totalHours = hoursPerDay * totalDays;
      return "$totalDays Hours / $totalHours Days";

    }

    Widget _buildOption({
      required String title,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,

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
                  color: AppColors.white70,
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
                color: AppColors.white,
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