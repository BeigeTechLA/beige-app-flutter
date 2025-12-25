import 'package:flutter/material.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import 'add_information_budget.dart';

class SelectShootTypeEdits extends StatefulWidget {
  final int bookingId;

  const SelectShootTypeEdits({super.key, required this.bookingId});

  @override
  State<SelectShootTypeEdits> createState() => _SelectShootTypeEditsState();
}

class _SelectShootTypeEditsState extends State<SelectShootTypeEdits> {
  // Selected values
  String selectedShoot = "Wedding";
  String selectedEdit = "";
  int? selectedSpecialtyId;
  List<String> selectedEdits = [];

  // Expand/Collapse states
  bool shootOpen = true;
  bool editOpen = true;
bool isLoading =false;


  List specialties = [];

  final Map<String, int> shootTypeMap = {
    "Wedding": 1,
    "Engagement / Pre-wedding": 2,
    "Birthday Parties": 3,
    "Baby Shower": 4,
    "Cultural Events": 5,
    "Others": 6,
  };

  static const List<String> list = [
    "None/Raw Files",
    "Basic Color Correction",
    "Advanced Color Grading",
    "Motion Graphics",
    "Visual Effects",
    "Standard Edit",
  ];


  @override
  void initState() {
    super.initState();
    _fetchbooking_data();
  }
  Future<void> _fetchbooking_data() async {
    setState(() => isLoading = true);

    try {
      final response =
      await ApiService().fetchData(ApiEndpoints.booking_specialties);

      if (response != null && response['error'] == false) {
        final List data = response['data']['deliverables'] ?? [];

        if (data.isNotEmpty) {
          setState(() {
            specialties = data;
            selectedSpecialtyId = data[0]['specialty_id']; // ✅ NOT NULL
          });

          debugPrint("Selected Specialty ID → $selectedSpecialtyId");
        }
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> select_shoottype() async {


    setState(() => isLoading = true);

    try {
      final payload = {
        "specialty_id": selectedSpecialtyId,
        "shoot_type_id": shootTypeMap[selectedShoot], // ✅ dynamic
        "edit_types": selectedEdits, // ✅ list
      };

      debugPrint("API Payload → $payload");

      final response = await ApiService().putData(
        "${ApiEndpoints.booking}/${widget.bookingId}/options",
        payload,
      );

      if (response != null && response['error'] == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddInformationBudget(
              bookingId: widget.bookingId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Something went wrong")),
        );
      }
    } catch (e) {
      debugPrint("Shoot API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
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
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset("assets/Icons/Reply.png", height: 24),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "3/5",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// -------------- Progress Bar ----------------
              Row(
                children: List.generate(
                  5,
                      (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      height: 5,
                      decoration: BoxDecoration(
                        color: index < 3
                            ? ColorCode.kButtonColor
                        : ColorCode.kSubtextColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// -------------- Page Title ----------------
               Text(
                "Select Shoot Type And Edits",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              /// -------------------------------------------------------------
              /// SHOOT TYPES SECTION
              /// -------------------------------------------------------------
              buildExpandableSection(
                title: "Shoot Types",
                isOpen: shootOpen,
                onToggle: () => setState(() => shootOpen = !shootOpen),
                items: [
                  "Wedding",
                  "Engagement / Pre-wedding",
                  "Birthday Parties",
                  "Baby Shower",
                  "Cultural Events",
                  "Others",
                ],
                selectedValue: selectedShoot,
                onSelect: (val) => setState(() => selectedShoot = val),
              ),


              const SizedBox(height: 20),

              /// -------------------------------------------------------------
              /// EDIT TYPES SECTION
              /// -------------------------------------------------------------
              buildExpandableSection(
                title: "Edit Types",
                isOpen: editOpen,
                onToggle: () => setState(() => editOpen = !editOpen),
                items: [
                  "None/Raw Files",
                  "Basic Color Correction",
                  "Advanced Color Grading",
                  "Motion Graphics",
                  "Visual Effects",
                  "Standard Edit",
                ],
                selectedValue: selectedEdit,
                onSelect: (val) => setState(() => selectedEdit = val),
              ),

              const SizedBox(height: 40),


              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE7C89E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isLoading ? null : select_shoottype,
            child: isLoading
                ? const CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            )
                : const Text(
              "Next",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

    );
  }

  /// **************************
  /// Reusable Expandable Card
  /// **************************
  Widget buildExpandableSection({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required List<String> items,
    required String selectedValue,
    required Function(String) onSelect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorCode.k282828,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// Header
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 16,
                      color: ColorCode.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 24,
                    weight: 24,

                  )
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.white10, // light transparent divider
            thickness: 1,
          ),
          /// Body
          if (isOpen)
            Column(
              children: items.map((item) {
                return ListTile(
                  title: Text(
                    item,
                    style:  TextStyle(
                      color: ColorCode.kWhiteOpacity70,
                      fontSize: 16,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  trailing:Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: selectedValue == item
                          ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFE8D1AB), // light shade
                          Color(0xFFD4A14D), // dark shade
                        ],
                      )
                          : null,
                      color: selectedValue == item ? null : Colors.transparent,
                      border: Border.all(
                        color: selectedValue == item
                            ? Colors.transparent
                            : ColorCode.kWhiteOpacity60,
                        width: 1,
                      ),
                    ),

                    // WHITE INNER DOT (ONLY WHEN SELECTED)
                    child: selectedValue == item
                        ? Center(
                      child: Container(
                        width: 10,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    )
                        : null,
                  )
                  ,

                    onTap: () => onSelect(item),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
