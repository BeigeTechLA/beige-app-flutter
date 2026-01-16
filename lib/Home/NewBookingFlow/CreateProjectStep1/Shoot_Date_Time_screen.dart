import 'package:flutter/material.dart';

import '../../../utility/ColorCode.dart';
import '../More_Details/more_details_screen.dart';

class ShootDateTimeScreen extends StatefulWidget {
  const ShootDateTimeScreen({super.key});

  @override
  State<ShootDateTimeScreen> createState() => _ShootDateTimeScreenState();
}

class _ShootDateTimeScreenState extends State<ShootDateTimeScreen> {


  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  DateTime? selectedDate;

  bool? isEditNeeded;


  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    dateController.dispose();
    super.dispose();
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

              const SizedBox(height: 30),


              TextField(
                cursorColor: ColorCode.white,
                style:  TextStyle(
                  color: ColorCode.white,
                  fontFamily: "Outfit",
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: "Video Edit Types",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(
                    color: ColorCode.kWhiteOpacity70,
                    fontSize: 12,
                    fontFamily: "Outfit",
                  ),
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
            ],
          ],
        ),




        ],
      ),

    ),
      ),
     /* bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("Continue clicked");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShootDateTimeScreen(
                        *//*  specialtyId: widget.specialtyId,
                              contentType: selectedContentType!,*//*
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorCode.kGoldGradientLight,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),*/
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
                onPressed: () {
                  debugPrint("Continue clicked");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreDetailsScreen(

                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                 /* backgroundColor: selectedIndex == -1
                      ? ColorCode.kGoldGradientLight // disabled
                      : ColorCode.kButtonColor, // enabled
                  foregroundColor: selectedIndex == -1
                      ? Colors.grey.shade400
                      : Colors.black,*/
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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



