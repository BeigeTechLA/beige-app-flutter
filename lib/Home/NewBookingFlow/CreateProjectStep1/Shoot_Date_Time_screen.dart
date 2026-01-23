import 'package:flutter/material.dart';

import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';
import '../../../utility/ColorCode.dart';
import '../More_Details/more_details_screen.dart';

class ShootDateTimeScreen extends StatefulWidget {
  final int specialtyId;
  final int ShootTypeId;
  final int bookingId;
  final int contentTypeId;
  
  const ShootDateTimeScreen({super.key,
    required this.specialtyId, required this.ShootTypeId, required this.bookingId, required this.contentTypeId});

  @override
  State<ShootDateTimeScreen> createState() => _ShootDateTimeScreenState();
}

class _ShootDateTimeScreenState extends State<ShootDateTimeScreen> {

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
            builder: (_) => MoreDetailsScreen(
              contentTypeId: widget.contentTypeId,
              specialtyId: widget.specialtyId,
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

            colorScheme: ColorScheme.dark(
              primary: ColorCode.kButtonColor, // selected date bg
              onPrimary: Colors.white,
              surface: const Color(0xFF1E1E1E),
              onSurface: Colors.white,
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

  Future<void> _selectTime(
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
            colorScheme: ColorScheme.dark(
              primary: ColorCode.kButtonColor, // selected time
              onPrimary: Colors.white,
              surface: const Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            timePickerTheme: const TimePickerThemeData(
              hourMinuteTextColor: Colors.white,
              dialHandColor: Colors.white,
              dialBackgroundColor: Color(0xFF1E1E1E),
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
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  "assets/Icons/Reply.png",
                  height: 24,
                  color: ColorCode.white,
                ),
              ),
            ),
            Text(
              "Create Project",
              style: TextStyle(
                color: ColorCode.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
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

                  TextField(
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
                  ),


                  SizedBox(height: 30,),
                  timeField(
                    controller: startTimeController,
                    label: "Start Time*",
                    onTap: () {
                      _selectTime(
                        context,
                        startTimeController,
                        startTime,
                            (time) => startTime = time,
                      );
                    },
                  ),


                  SizedBox(height: 30,),
                  timeField(
                    controller: endTimeController,
                    label: "End Time*",
                    onTap: () {
                      _selectTime(
                        context,
                        endTimeController,
                        endTime,
                            (time) => endTime = time,
                      );
                    },
                  ),

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
                              decoration: InputDecoration(
                                labelText: "Video Edit Types",
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
                  ),




                ],
              ),

            ),
          ),
          if (isSubmitting)
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
            ),
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
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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

                  ...editTypes.map((item) {
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
                            selectedEditTypeIds.remove(id);
                            selectedEditTypeNames.removeAt(index);
                          }
                        });

                        setState(() {}); // 🔥 chips update
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.kButtonColor,
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
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



