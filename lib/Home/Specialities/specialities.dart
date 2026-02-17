import 'package:beige/Home/Specialities/BookShoot.dart';
import 'package:flutter/material.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart';

class Specialities extends StatefulWidget {
  const Specialities({super.key});

  @override
  State<Specialities> createState() => _SpecialitiesState();
}

class _SpecialitiesState extends State<Specialities> {
  bool isLoadingSpecialties = true;

  List specialties = [];
  final List<String> bookShootIcons = [
    "assets/Book_shoot/Events.png",
    "assets/Book_shoot/Commercial.png",
    "assets/Book_shoot/music.png",
    "assets/Book_shoot/Corporate.png",
    "assets/Book_shoot/Short.png",
    "assets/Book_shoot/Social_Media.png",
    "assets/Book_shoot/user 1.png",
    "assets/Book_shoot/drone 1.png",
    "assets/Book_shoot/sports 1.png",
    "assets/Book_shoot/graduation 1.png",
  ];



  @override
  void initState() {
    super.initState();
    _fetchhome_data();
  }

  Future<void> _fetchhome_data() async {
    try {
      final response = await ApiService().fetchData(ApiEndpoints.home_data);

      if (response != null && response['error'] == false) {
        setState(() {
          specialties = response['data']['specialties'] ?? [];
          isLoadingSpecialties = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoadingSpecialties = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔙 BACK
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  "assets/Icons/Reply.png",
                  height: 24,
                  width: 24,
                  color: ColorCode.white,
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Book A Shoot",
                style: TextStyle(
                  color: ColorCode.white,
                  fontFamily: 'Unbounded',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              /// 🔥 GRID
              Expanded(
                child: isLoadingSpecialties
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    return GridView.builder(
                      itemCount: specialties.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,   // 🔥 4 in one row
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.65,
                      ),
                      itemBuilder: (context, index) {
                        return _buildGridItem(
                          specialties[index],
                          index,
                        );
                      },
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
  Widget _buildGridItem(Map item, int index) {
    final iconPath = bookShootIcons[index % bookShootIcons.length];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentTypeScreen(
              specialtyId: item["specialty_id"],
            ),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double circleSize = constraints.maxWidth * 0.75; // 🔥 bigger circle

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              /// 🔵 Bigger Circle
              Container(
                height: circleSize,
                width: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2E2E2E),
                      Color(0xFF1F1F1F),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(circleSize * 0.22),
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// 📝 Name
              Text(
                (item["name"] ?? "")
                    .toString()
                    .replaceAll(" & ", " &\n"),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ColorCode.kWhiteOpacity60,
                  fontSize: 11, // 🔥 little bigger text
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }






}
