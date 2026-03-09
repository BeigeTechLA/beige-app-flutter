import 'package:beige/Home/Specialities/BookShoot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart';

class Specialities extends StatefulWidget {
  final bool? showBackButton;

  const Specialities({super.key, this.showBackButton  = false});

  @override
  State<Specialities> createState() => _SpecialitiesState();
}

class _SpecialitiesState extends State<Specialities> {
  bool isLoadingSpecialties = true;

  List specialties = [];

  final List<String> bookShootIcons = [
    "assets/Book_shoot_svg/Events.svg",
    "assets/Book_shoot_svg/Commercial.svg",
    "assets/Book_shoot_svg/Music-Video.svg",
    "assets/Book_shoot_svg/Corporate.svg",
    "assets/Book_shoot_svg/Short.svg",
    "assets/Book_shoot_svg/Social Media.svg",
    "assets/Book_shoot_svg/Personal.svg",
    "assets/Book_shoot_svg/droneee.svg",
    "assets/Book_shoot_svg/Sports.svg",
    "assets/Book_shoot_svg/Education.svg",
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
              if (widget.showBackButton == true)

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
      child: Column(
        children: [

          /// 🔵 Icon area
          Expanded(
            flex: 3,
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// 📝 Text area
          Flexible(
            flex: 2,
            child: Text(
              (item["name"] ?? "")
                  .toString()
                  .replaceAll(" & ", " &\n"),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ColorCode.kWhiteOpacity60,
                fontSize: 11,
                fontFamily: "Outfit",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
