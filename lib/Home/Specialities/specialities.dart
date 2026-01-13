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

  final List<Map<String, String>> staticAssets = [
    {
      "bg": "assets/images/Frame 2087328875@3x.png",
      "icon": "assets/images/party.png",
    },
    {
      "bg": "assets/images/Frame 2087328875@3x.png",
      "icon": "assets/images/Creative.png",
    },
    {
      "bg": "assets/images/Frame 2087328875@3x.png",
      "icon": "assets/images/Travel.png",
    },
    {
      "bg": "assets/images/Frame 2087328875@3x.png",
      "icon": "assets/images/drone.png",
    },
    {
      "bg": "assets/images/Frame 2087328875@3x.png",
      "icon": "assets/images/sports_action.png",
    },
    {
      "bg": "assets/images/Frame 2087328875@3x.png",
      "icon": "assets/images/personal_photo.png",
    },
    {
      "bg": "assets/images/Frame 2087328875@3x.png",
      "icon": "assets/images/hotel.png",
    },
    /*{
      "bg": "assets/images/Frame 2087328875@3x.png",
      "icon": "assets/images/eduction.png",
    },*/
    {
      "bg": "assets/images/Frame 2087328875@3x.png",
      "icon": "assets/images/5522882 1 (2).png",
    },
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
                    : GridView.builder(
                  itemCount: specialties.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    return _buildGridItem(
                      specialties[index],
                      index,
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
    final assetIndex = index % staticAssets.length;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentTypeScreen(   //BookShootScreen
              specialtyId: item["specialty_id"],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            /// 🔹 STATIC BACKGROUND
            Positioned.fill(
              child: Image.asset(
                staticAssets[assetIndex]["bg"]!,
                fit: BoxFit.cover,
              ),
            ),

            /// 🔹 DYNAMIC NAME
            Positioned(
              top: 10,
              left: 8,
              child: Text(
                (item["name"] ?? "").toString().replaceAll(" & ", " &\n"),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(
                  color: ColorCode.white,
                  fontFamily: 'Outfit',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.2, // optional: line spacing clean
                ),
              ),
            ),

            /// 🔹 STATIC ICON
            Positioned(
              bottom: 0,
              right: 2,
              child: Image.asset(
                staticAssets[assetIndex]["icon"]!,
                height: 70,
                width: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
