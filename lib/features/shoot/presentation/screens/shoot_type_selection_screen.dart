import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/shared/widgets/app_text_field.dart';
import 'package:beige/features/booking/presentation/providers/shoot_type_selection_notifier.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/assets.dart';

class ShootTypeSelectionScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const ShootTypeSelectionScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ShootTypeSelectionScreen> createState() => _ShootTypeSelectionScreenState();
}

class _ShootTypeSelectionScreenState extends ConsumerState<ShootTypeSelectionScreen> {

  Map<DateTime, bool> expandedMap = {};
  Map<DateTime, TimeOfDay?> startTimes = {};
  Map<DateTime, TimeOfDay?> endTimes = {};

  Map<int, int> videoCounts = {};
  Map<int, int> photoCounts = {};

  TimeOfDay? shootStartTime;
  TimeOfDay? shootEndTime;
  bool isSingleLocked = true;
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
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.background,
              onSurface: AppColors.white,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: AppColors.surfaceGradientDark,
              dialBackgroundColor: AppColors.surfaceGradientDark,
              dialHandColor: AppColors.white,
              dialTextColor: AppColors.neutralGrey,
              hourMinuteColor: AppColors.primary,
              hourMinuteTextColor: AppColors.black,
              dayPeriodColor: AppColors.primary,
              dayPeriodTextColor: AppColors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: AppColors.surfaceGradientDark),
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

  bool isLoading = true;
  bool _hasSynced = false;

  String _apiDateFormat(DateTime date) {

    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  }

  String formatDatesAlt(List<DateTime> dates) {
    if (dates.isEmpty) return "";

    dates.sort();

    final days = dates.map((e) => DateFormat('d').format(e)).toList();
    final lastDate = dates.last;

    String daysText = "";

    if (days.length == 1) {
      daysText = days.first;
    } else if (days.length == 2) {
      daysText = "${days[0]} & ${days[1]}";
    } else {
      daysText =
      "${days.sublist(0, days.length - 1).join(', ')} & ${days.last}";
    }

    final month = DateFormat('MMM').format(lastDate);
    final year = DateFormat('yyyy').format(lastDate);

    return "$month $daysText, $year";
  }
  String formatSelectedDates(List<DateTime> dates) {
    if (dates.isEmpty) return "";

    dates.sort(); // important for correct order

    final days = dates.map((e) => DateFormat('d').format(e)).toList();
    final lastDate = dates.last;

    String daysText = "";

    if (days.length == 1) {
      daysText = days.first;
    } else if (days.length == 2) {
      daysText = "${days[0]} & ${days[1]}";
    } else {
      daysText =
      "${days.sublist(0, days.length - 1).join(', ')} & ${days.last}";
    }

    final monthYear = DateFormat('MMM yyyy').format(lastDate);

    return "Selected Days: $daysText $monthYear";
  }
  bool isEndTimeAfterStart(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
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
            return false; // ❌ any date missing time
          }
        }
      }
    }

    /// 🔥 EDIT VALIDATION
    if (isEditNeeded && selectedEditTypeIds.isEmpty) return false;

    return true;
  }
  /*String getEditingDescription() {

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
  }*/


  bool isMultiLocked = false;

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


/*  String getEditTypeDisplayText() {

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
  }*/


  void _syncFromNotifier(Map<String, dynamic> data) {
    if (_hasSynced) return;
    _hasSynced = true;

    setState(() {
      editTypes = data['video_edit_types'] ?? [];
      photoEditTypes = data['photo_edit_types'] ?? [];

      selectedDates.clear();
      startTimes.clear();
      endTimes.clear();

      if (data['booking_type'] == "single_day") {
        selectedIndex = 1;
        isSingleLocked = false;
        isMultiLocked = true;

        if (data['event_date'] != null) {
          selectedDate = DateTime.parse(data['event_date']);
          dateController.text =
              "${selectedDate!.day.toString().padLeft(2, '0')}-"
              "${selectedDate!.month.toString().padLeft(2, '0')}-"
              "${selectedDate!.year}";
        }

        if (data['start_time'] != null) {
          final s = data['start_time'].split(":");
          startTime = TimeOfDay(
            hour: int.parse(s[0]),
            minute: int.parse(s[1]),
          );
          _updateTimeText(startTimeController, startTime!);
        }

        if (data['end_time'] != null) {
          final e = data['end_time'].split(":");
          endTime = TimeOfDay(
            hour: int.parse(e[0]),
            minute: int.parse(e[1]),
          );
          _updateTimeText(endTimeController, endTime!);
        }

        selectedDates.clear();
        startTimes.clear();
        endTimes.clear();
      } else if (data['booking_type'] == "multi_day") {
        selectedIndex = 2;
        isSingleLocked = true;
        isMultiLocked = false;

        final multiDay = data['multi_day'];

        selectedDate = null;
        dateController.clear();

        if (multiDay != null && multiDay['selected_dates'] != null) {
          selectedDates = (multiDay['selected_dates'] as List)
              .map((d) => DateTime.parse(d))
              .toList();
        }

        istimingsame =
            multiDay?['same_timings_for_all_selected_dates'] ?? true;

        if (istimingsame == true && multiDay?['shared_time'] != null) {
          final shared = multiDay['shared_time'];

          if (shared['start_time'] != null) {
            final s = shared['start_time'].split(":");
            startTime = TimeOfDay(
              hour: int.parse(s[0]),
              minute: int.parse(s[1]),
            );
            _updateTimeText(startTimeController, startTime!);
          }

          if (shared['end_time'] != null) {
            final e = shared['end_time'].split(":");
            endTime = TimeOfDay(
              hour: int.parse(e[0]),
              minute: int.parse(e[1]),
            );
            _updateTimeText(endTimeController, endTime!);
          }
        }

        if (multiDay?['days'] != null) {
          for (var day in multiDay['days']) {
            final date = DateTime.parse(day['date']);

            if (day['start_time'] != null) {
              final s = day['start_time'].split(":");
              startTimes[date] = TimeOfDay(
                hour: int.parse(s[0]),
                minute: int.parse(s[1]),
              );
            }

            if (day['end_time'] != null) {
              final e = day['end_time'].split(":");
              endTimes[date] = TimeOfDay(
                hour: int.parse(e[0]),
                minute: int.parse(e[1]),
              );
            }
          }
        }
      }

      isLoading = false;
    });
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




  Future<void> _selectDateMultiple(BuildContext context) async {
    List<DateTime> tempSelected = List.from(selectedDates);

    final result = await showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.black,
              surface: AppColors.surfaceGradientDark,
              onSurface: AppColors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: AppColors.surfaceGradientDark),
          ),
          child: Dialog(
            insetPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxl),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.lgAll,
            ),
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// HEADER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.base),
                      color: AppColors.surfaceDark,
                      child: Text(
                        "Select Date",
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 20,
                          color: AppColors.white,
                        ),
                      ),
                    ),

                    /// CALENDAR
                    SizedBox(
                      height: 350,
                      child: CalendarDatePicker2(
                        config: CalendarDatePicker2Config(
                          calendarType: CalendarDatePicker2Type.multi,
                          selectedDayHighlightColor: AppColors.primary,
                          selectedDayTextStyle: const TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: tempSelected,
                        onValueChanged: (dates) {
                          setStateDialog(() {
                            tempSelected = dates;
                          });
                        },
                      ),
                    ),

                    /// ACTIONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            context.pop(tempSelected);
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

    /// 🔥 IMPORTANT FIX (THIS WAS MISSING)
    if (result != null && result is List<DateTime>) {
      setState(() {
        selectedDates = result;

        /// reset times
        startTimes.clear();
        endTimes.clear();
      });
    }
  }



  void _updateTimeText(TextEditingController controller, TimeOfDay picked) {
    final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod.toString().padLeft(2, '0');
    final minute = picked.minute.toString().padLeft(2, '0');
    final period = picked.period == DayPeriod.am ? "AM" : "PM";
    controller.text = "$hour:$minute $period";
  }




  @override
  Widget build(BuildContext context) {
    final selectionState = ref.watch(
      shootTypeSelectionNotifierProvider(widget.bookingId),
    );

    if (selectionState.status == ShootTypeSelectionStatus.loaded &&
        !_hasSynced) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncFromNotifier(selectionState.bookingTimeData);
      });
    }

    if (selectionState.status == ShootTypeSelectionStatus.loading) {
      isLoading = true;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 40, // 🔥 important
        leading: InkWell(
          onTap: () => context.pop(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: SvgPicture.asset(
              AppAssets.back,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        actions: const [ Padding( padding: EdgeInsets.only(right: AppSpacing.base), child: Center( child: Text("1/2", style: TextStyle(color: AppColors.white)), ), ) ],
      ),

      body: SafeArea(

        child: Stack(
          children: [
            Padding(
              padding:  EdgeInsets.all(AppSpacing.base),
              child: Column(
                children: [

                  Row(
                    children: List.generate(
                      2,
                          (index) => Expanded(
                        child: Container(
                          margin:  EdgeInsets.only(right: AppSpacing.xs),
                          height: 5,
                          decoration: BoxDecoration(
                            color: index < 1
                                ? AppColors.primary
                                : AppColors.textSubtle,
                            borderRadius: BorderRadius.circular(AppRadii.mld),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      Text(

                        textAlign: TextAlign.start,
                        "Select Booking Type",
                        style: AppTextStyles.titleSmall,
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
                              /// ================= SINGLE =================
                              Expanded(
                                child: GestureDetector(
                                  /* onTap: () {
                                    if (isSingleLocked) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Single Day not allowed")),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      selectedIndex = 1;

                                      /// reset multi
                                      selectedDates.clear();
                                      startTimes.clear();
                                      endTimes.clear();

                                      /// reset time
                                      startTime = null;
                                      endTime = null;
                                      startTimeController.clear();
                                      endTimeController.clear();
                                    });
                                  },*/
                                  onTap: null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.lg),
                                    decoration: BoxDecoration(
                                      /// 🔥 COLOR FIX
                                      color: isSingleLocked
                                          ? AppColors.neutralGrey.withValues(alpha: 0.3)
                                          : (selectedIndex == 1
                                          ? AppColors.primary
                                          : AppColors.transparent),

                                      borderRadius: AppRadii.lgAll,

                                      border: selectedIndex == 1
                                          ? null
                                          : Border.all(color: AppColors.white.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Single Day",
                                          style: AppTextStyles.labelLarge.copyWith(
                                            color: isSingleLocked
                                                ? AppColors.neutralGrey
                                                : (selectedIndex == 1
                                                ? AppColors.black
                                                : AppColors.neutralGrey),
                                          ),
                                        ),

                                        /// RADIO
                                        selectedIndex == 1
                                            ? Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppColors.black,
                                                AppColors.surfaceWarmLight,
                                              ],
                                            ),
                                            border: Border.all(color: AppColors.neutralGrey),
                                          ),
                                          child: const Center(
                                            child: CircleAvatar(
                                              radius: 3,
                                              backgroundColor: AppColors.primary,
                                            ),
                                          ),
                                        )
                                            : Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.white.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// ================= MULTI =================
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (isMultiLocked) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Multiple Day not allowed")),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      selectedIndex = 2;

                                      /// reset single
                                      selectedDate = null;
                                      dateController.clear();

                                      /// reset time
                                      startTime = null;
                                      endTime = null;
                                      startTimeController.clear();
                                      endTimeController.clear();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.lg),
                                    decoration: BoxDecoration(
                                      /// 🔥 COLOR FIX
                                      color: isMultiLocked
                                          ? AppColors.neutralGrey.withValues(alpha: 0.3)
                                          : (selectedIndex == 2
                                          ? AppColors.primary
                                          : AppColors.transparent),

                                      borderRadius: AppRadii.lgAll,

                                      border: selectedIndex == 2
                                          ? null
                                          : Border.all(color: AppColors.white.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Multiple Days",
                                          style: AppTextStyles.labelLarge.copyWith(
                                            color: isMultiLocked
                                                ? AppColors.neutralGrey
                                                : (selectedIndex == 2
                                                ? AppColors.black
                                                : AppColors.neutralGrey),
                                          ),
                                        ),

                                        /// RADIO
                                        selectedIndex == 2
                                            ? Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppColors.black,
                                                AppColors.surfaceWarmLight,
                                              ],
                                            ),
                                            border: Border.all(color: AppColors.neutralGrey),
                                          ),
                                          child: const Center(
                                            child: CircleAvatar(
                                              radius: 3,
                                              backgroundColor: AppColors.primary,
                                            ),
                                          ),
                                        )
                                            : Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.white.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ),
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
                                        fontFamily: AppAssets.fontUnbounded,
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
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceWarm,
                                        borderRadius: AppRadii.lgAll,
                                      ),
                                      child: Text(
                                        "Total Days: ${selectedDates.length}",
                                        style: const TextStyle(color: AppColors.primary, fontSize: 13,fontFamily: AppAssets.fontHelveticaNeue,fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(AppSpacing.md),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceWarm,
                                          borderRadius: AppRadii.lgAll,
                                        ),
                                        child: selectedDates.isEmpty
                                            ? const Text(
                                          "No dates selected",
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                        )
                                            : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal, // 👈 scroll enable
                                          child: Text(
                                              formatSelectedDates(selectedDates),
                                              style: const TextStyle(color: AppColors.primary, fontSize: 13,fontFamily: AppAssets.fontHelveticaNeue,fontWeight: FontWeight.w500)
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12,),
                                Text('Are Timings Same For All\nSelected Dates?',style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.white,
                                  fontFamily:AppAssets.fontUnbounded,
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
                                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                        decoration: BoxDecoration(

                                          border: isOpen?
                                          Border.all(color: AppColors.white.withValues(alpha: 0.2)):

                                          Border.all(color:  AppColors.transparent),
                                          borderRadius: AppRadii.lgAll,
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
                                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.base),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceVariant,
                                                  borderRadius: AppRadii.lgAll,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      DateFormat('MMMM dd, yyyy').format(date),
                                                      style: const TextStyle(color: AppColors.white),
                                                    ),
                                                    Icon(
                                                      isOpen
                                                          ? Icons.keyboard_arrow_up
                                                          : Icons.keyboard_arrow_down,
                                                      color: AppColors.white,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),

                                            /// 🔥 BODY
                                            if (isOpen) ...[
                                              Padding(
                                                padding: const EdgeInsets.all(AppSpacing.base),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,

                                                  children: [

                                                    /// Start Time

                                                    AppTextField(
                                                      label: "Start Time",
                                                      controller: TextEditingController(
                                                        text: startTimes[date]?.format(context) ?? "",
                                                      ),
                                                      readOnly: true,
                                                      /*   onTap: () {
                                                        _selectTime(context, null, true, date); // ✅ FIX
                                                      },*/
                                                      onTap: null,
                                                      suffix: Padding(
                                                        padding: const EdgeInsets.all(AppSpacing.md),
                                                        child: SvgPicture.asset(
                                                          AppAssets.clock,
                                                          color: AppColors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 30,),
                                                    AppTextField(
                                                      label: "End Time",
                                                      controller: TextEditingController(
                                                        text: endTimes[date]?.format(context) ?? "",
                                                      ),
                                                      readOnly: true,
                                                      /*  onTap: () {
                                                        _selectTime(context, null, false, date); // ✅ FIX
                                                      },*/
                                                      onTap: null,
                                                      suffix: Padding(
                                                        padding: const EdgeInsets.all(AppSpacing.md),
                                                        child: SvgPicture.asset(
                                                          AppAssets.clock,
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
                                                        color: AppColors.primary,
                                                        borderRadius: AppRadii.mdAll,
                                                      ),
                                                      child: Text(
                                                        getDurationText(date),
                                                        style: const TextStyle(
                                                          color: AppColors.black,
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
                                  AppTextField(
                                    label: "Start Time",
                                    controller: startTimeController,
                                    readOnly: true,
                                    /* onTap: () {
                                      if (selectedDates.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please select date first")),
                                        );
                                        return;
                                      }

                                      _selectTime(context, startTimeController, true, null); // ✅ FIX
                                    },*/
                                    onTap: null,
                                    suffix: Padding(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: SvgPicture.asset(
                                        AppAssets.clock,
                                        color: AppColors.white,
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 30),

                                  /// ✅ END TIME
                                  AppTextField(
                                    label: "End Time",
                                    controller: endTimeController,
                                    readOnly: true,
                                    /* onTap: () {
                                      if (selectedDates.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please select date first")),
                                        );
                                        return;
                                      }

                                      _selectTime(context, endTimeController, false, null); // ✅ FIX
                                    },*/
                                    onTap: null,
                                    suffix: Padding(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: SvgPicture.asset(
                                        AppAssets.clock,
                                        color: AppColors.white,
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 12),

                                  Row(
                                    children: [
                                      SvgPicture.asset(AppAssets.checkmark, width: 24, height: 24),
                                      SizedBox(width: 6),
                                      Text(
                                        'Applied to ${selectedDates.length} selected dates',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                          height: 1.36,
                                        ),
                                      ),
                                    ],
                                  ),
                                ]



                              ],
                            ),
                          ],


                          if (selectedIndex==1) ...[
                            Row(
                              children: [
                                Text(
                                  "Shoot Date & Time",
                                  style: TextStyle(
                                    fontFamily: AppAssets.fontUnbounded,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 30,),



                            AppTextField(
                              label: "Select Date",
                              controller: dateController,
                              readOnly: true,
                              onTap: null,
                              suffix: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: SvgPicture.asset(
                                  AppAssets.calendar,
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
                            AppTextField(
                              label: "Start Time",
                              controller: startTimeController,
                              readOnly: true,
                              /*   onTap: () {
                                if (!isDateSelected()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please select date first")),
                                  );
                                  return;
                                }

                                // _selectTime(context, startTimeController, true, null); // ✅ FIX
                              },*/
                              onTap: null,
                              suffix: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: SvgPicture.asset(
                                  AppAssets.clock,
                                  width: 20,
                                  height: 20,
                                  color: AppColors.white,
                                ),
                              ),
                            ),

                            SizedBox(height: 30),

                            AppTextField(
                              label: "End Time",
                              controller: endTimeController,
                              readOnly: true,
                              /* onTap: () {
                                if (!isDateSelected()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please select date first")),
                                  );
                                  return;
                                }

                                _selectTime(context, endTimeController, false, null); // ✅ FIX
                              },*/
                              onTap: null,
                              suffix: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: SvgPicture.asset(
                                  AppAssets.clock,
                                  width: 20,
                                  height: 20,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],



                          SizedBox(height: 30,),




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
                  color: AppColors.black.withValues(alpha: 0.15), // optional dim
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),*/
          ],

        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.smd, AppSpacing.base, AppSpacing.base),
        child: Row(
          children: [
            /*   Expanded(
              child:  OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.neutralGrey),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.mld),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.lgAll,
                  ),
                ),
                child:  Text("Back",style: TextStyle(fontFamily: AppAssets.fontUnbounded,fontWeight: FontWeight.w500,fontSize: 14),),
              ),
            ),*/
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                /* onPressed: isFormValid && !isSubmitting
                    ? () {
                  debugPrint("✅ Continue clicked");
                  _ShootDate_Time(); // 🔥 API CALL
                }
                    : null, // ❌ disabled when false
*/
                onPressed: () {
                  context.pushNamed(
                    RouteNames.bookingReviewConfirm,
                    pathParameters: {'bookingId': widget.bookingId.toString()},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid
                      ? AppColors.primary   // ✅ active
                      : AppColors.surfaceVariant,       // ❌ disabled
                  foregroundColor: isFormValid
                      ? AppColors.black
                      : AppColors.neutralGrey,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.mld),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.lgAll,
                  ),
                  elevation: isFormValid ? 2 : 0,
                ),

                child: Text(
                  "Next",
                  style: AppTextStyles.labelLarge.copyWith(
                    fontFamily: AppAssets.fontUnbounded,
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
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 Header
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, top: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getHeaderMonth(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppAssets.fontOutfit,
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectDateMultiple(context),
                  child: SvgPicture.asset(
                    AppAssets.calndermark,
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


                return GestureDetector(
                /*  onTap: isPast
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
                  },*/
                  onTap: () {

                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.smd),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 19, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadii.roundLg),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${date.day}",
                          style: TextStyle(
                            fontFamily: AppAssets.fontOutfit,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.background
                                : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: AppAssets.fontOutfit,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.background
                                : AppColors.white.withValues(alpha: 0.6),
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
      margin: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white.withValues(alpha: 0.3), width: 0.5),
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        children: [
          /// HEADER
          GestureDetector(
            onTap: () {
              setState(() {
                isVideoOpen = !isVideoOpen;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadii.xlAll,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),

                  AnimatedRotation(
                    turns: isVideoOpen ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: AppColors.white),
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
                int id = entry.key; // ✅ FIX
                var item = entry.value;

                String name = item['value'] ?? ""; // ✅ FIX

                int count = videoCounts[id] ?? 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 11),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: TextStyle(color: AppColors.white)),
                      ),

                      /// COUNTER
                      Container(
                        width: 75,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadii.smAll,
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (count > 0) {
                                    videoCounts[id] = count - 1;

                                    if (videoCounts[id] == 0) {
                                      selectedEditTypeIds.remove(id);
                                    }
                                  }
                                });
                              },
                              child: Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                child: Icon(Icons.remove, size: 10,color: AppColors.black,),
                              ),
                            ),

                            Text(count.toString().padLeft(2, '0'),style: TextStyle(
                              color: AppColors.textHeading,
                              fontSize: 11.17,
                              fontFamily: AppAssets.fontHelveticaNeue,
                              fontWeight: FontWeight.w500,
                            ),),

                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  videoCounts[id] = count + 1;

                                  if (!selectedEditTypeIds
                                      .contains(id)) {
                                    selectedEditTypeIds.add(id);
                                  }
                                });
                              },
                              child: Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                child: Icon(Icons.add, size: 10,color: AppColors.black,),
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
      margin: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white.withValues(alpha: 0.3), width: 0.5),
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        children: [
          /// HEADER
          GestureDetector(
            onTap: () {
              setState(() {
                isPhotoOpen = !isPhotoOpen;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadii.lgAll,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: AppTextStyles.buttonLarge.copyWith(color: AppColors.white)),

                  Icon(
                    isPhotoOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.white,
                  )
                ],
              ),
            ),
          ),

          /// BODY
          if (isPhotoOpen)
            ...data.asMap().entries.map((entry) {
              int id = entry.key; // ✅ FIX
              var item = entry.value;

              String name = item['value'] ?? ""; // ✅ FIX

              int count = photoCounts[id] ?? 0;

              return Padding(
                padding:
                EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: TextStyle(color: AppColors.white)),
                    ),

                    Container(
                      width: 80,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadii.smAll,
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (count > 0) {
                                  photoCounts[id] = count - 1;
                                }
                              });
                            },
                            child: Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              child: Icon(Icons.remove, size: 10,color: AppColors.black,),
                            ),
                          ),

                          Text(count.toString().padLeft(2, '0'),style: TextStyle(  color: AppColors.textHeading,
                            fontSize: 11.17,
                            fontFamily: AppAssets.fontHelveticaNeue,
                            fontWeight: FontWeight.w500,
                          ),),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                photoCounts[id] = count + 1;
                              });
                            },
                            child: Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                child: Icon(Icons.add, size: 10,color: AppColors.black,)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
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
          cursorColor: AppColors.white,

          style: const TextStyle(color: AppColors.white),

          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,

            labelStyle: AppTextStyles.labelMedium.copyWith(
              color: AppColors.white70,
            ),

            suffixIcon:  Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SvgPicture.asset(
                AppAssets.clock,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),

            contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),

            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.lgAll,
              borderSide:
              const BorderSide(color: AppColors.white70, width: 0.5),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.lgAll,
              borderSide:
              const BorderSide(color: AppColors.white70, width: 0.5),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: null,
      borderRadius: AppRadii.roundAll,
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
                  AppColors.primary, // light gold
                  AppColors.primaryDark, // dark gold
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
                  color: AppColors.black,
                ),
              ),
            )
                : const SizedBox(),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

}
