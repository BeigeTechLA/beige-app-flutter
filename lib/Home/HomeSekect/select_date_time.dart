import 'package:flutter/material.dart';
import '../../utility/ColorCode.dart';

class SelectDateTime extends StatefulWidget {
  const SelectDateTime({super.key});

  @override
  State<SelectDateTime> createState() => _SelectDateTimeState();
}

class _SelectDateTimeState extends State<SelectDateTime> {

  int selectedIndex = 0;

  DateTime baseDate = DateTime.now();   // starting point
  DateTime selectedDate = DateTime.now();

  double selectedHour = 16; // default


  String getMonthYear(DateTime date) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return "${months[date.month - 1]} ${date.year}";
  }
  List<String> timeSlots = [
    "12:45 PM",
    "01:30 PM",
    "04:30 PM",
    "05:30 PM",
    "06:30 PM",
    "07:30 PM",
  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ColorCode.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: ColorCode.kBackgroundColor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Image.asset("assets/Icons/Reply.png", height: 24),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text("2/5", style: TextStyle(color: Colors.black)),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [

              /// ✅ STEP INDICATOR
              Row(
                children: List.generate(
                  5,
                      (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      height: 5,
                      decoration: BoxDecoration(
                        color: index < 2 ? Colors.black : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ✅ TITLE
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Date & Time Slots",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              /// ✅ DATE CONTAINER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// ✅ MONTH ROW (DYNAMIC)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getMonthYear(selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );

                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.calendar_month_outlined, size: 20),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// ✅ DATE ROW (DYNAMIC)
                    SizedBox(
                      height: 75,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10000, // 👈 practically endless
                        itemBuilder: (context, index) {

                          final DateTime date =
                          baseDate.add(Duration(days: index));

                          final bool isSelected =
                              date.year == selectedDate.year &&
                                  date.month == selectedDate.month &&
                                  date.day == selectedDate.day;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xffEAD1A6)
                                      : Colors.grey.shade100,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.black : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                                      [date.weekday % 7],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected ? Colors.black : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  ],
                ),
              ),

              Container(
                height: 350, // 👈 image jaise fixed height
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color:  ColorCode.white, // light beige
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          timeSlots[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Custom Time Duration",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ],
                    ),


                    const SizedBox(height: 16),

                    /// ✅ SLIDER
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: const Color(0xffEAD1A6),
                        inactiveTrackColor: Colors.black,
                        thumbColor: ColorCode.kButtonColor,
                        overlayColor: const Color(0xffEAD1A6).withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      ),
                      child: Slider(
                        min: 5,
                        max: 50,
                        divisions: 11, // 02h to 24h
                        value: selectedHour,
                        onChanged: (value) {
                          setState(() {
                            selectedHour = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// ✅ HOURS LABELS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("02h"),
                        Text("04h"),
                        Text("08h"),
                        Text("12h"),
                        Text("16h"),
                        Text("20h"),
                        Text("24h"),
                      ],
                    ),
                  ],
                ),
              ),


              Row(
                children: [

                  // ✅ Next Button
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE7C89E),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(builder: (_) =>  SelectLocation()),
                          // );
                        },
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            color: ColorCode.kHeadingColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ),
                    ),
                  ),
                ],
              )


            ],
          ),
        ),
      ),
    );
  }
}
