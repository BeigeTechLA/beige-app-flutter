import 'package:flutter/material.dart';

import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';
import '../../../utility/ColorCode.dart';
import '../../HomeSekect/recommended_detils_screen.dart';
import '../Book_Confirm/review_confirm_screen.dart';

class SelectYourDreamTeam extends StatefulWidget {
  final int specialtyId;
  final int ShootTypeId;
  final int bookingId;
  final int contentTypeId;
  const SelectYourDreamTeam({super.key, required this.specialtyId, required this.ShootTypeId, required this.bookingId, required this.contentTypeId});

  @override
  State<SelectYourDreamTeam> createState() => _SelectYourDreamTeamState();
}

class _SelectYourDreamTeamState extends State<SelectYourDreamTeam> {

  int currentStep = 1;
  bool isAdded = false;


  Set<int> favouriteUsers = {};

  int requiredCount = 0;   // ✅ 🔥 YE LINE ADD KARO

  Set<int> allowedRoleIds = {};      // ✅ backend allowed roles
  Set<int> addedCrewIds = {};        // crew_member_ids
  List<dynamic> crewMatches = [];
  bool isLoading = true;


  Set<int> addedCrewUserIds = {};   // ✅ store USER IDs


  @override
  void initState() {
    super.initState();
    // _holds();
    _CrewSizeMatching();
  }
  Future<void> _CrewSizeMatching() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking}/${widget.bookingId}/matches?sort=nearest&page=1&limit=30",
      );

      if (response != null && response['error'] == false) {
        setState(() {
          crewMatches = response['data']['items'];

          final requirements = response['data']['crew_requirements'] as List;

          allowedRoleIds =
              requirements.map<int>((e) => e['role_id']).toSet();

          requiredCount = requirements[0]['required_count']; // ✅ 4
        });

        debugPrint("✅ REQUIRED COUNT = $requiredCount");
      }
    } catch (e) {
      debugPrint("❌ Crew API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }



  Future<void> _addFavourite(int userId) async {
    try {
      final response = await ApiService().postData(
        "${ApiEndpoints.addfavourites}/$userId",
        {},
      );

      if (response != null && response['error'] == false) {
        debugPrint("Favourite added");
      }
    } catch (e) {
      debugPrint("Add Favourite Error: $e");
    }
  }


  Future<void> _removeFavourite(int userId) async {
    try {
      final response = await ApiService().deleteData(
        "${ApiEndpoints.addfavourites}/$userId",

      );

      if (response != null && response['error'] == false) {
        debugPrint("Favourite removed");
      }
    } catch (e) {
      debugPrint("Remove Favourite Error: $e");
    }
  }

  Future<bool> _addHolds({
    required int creativeUserId,
    required int roleId,
  }) async {
    try {
      final response = await ApiService().postData(
        "${ApiEndpoints.booking}/${widget.bookingId}/hold",
        {
          "creative_user_id": creativeUserId,
          "role_id": roleId,
        },
      );

      if (response != null && response['error'] == false) {
        debugPrint("✅ Crew added successfully");
        return true;
      } else {
        debugPrint("❌ Add crew failed: $response");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Add Holds Error: $e");
      return false;
    }
  }

  Future<bool> _removeHolds({
    required int creativeUserId,
  }) async {
    try {
      final response = await ApiService().postData(
        "${ApiEndpoints.booking}/${widget.bookingId}/hold/remove",
        {
          "creative_user_id": creativeUserId,
        }
      );

      if (response != null && response['error'] == false) {
        debugPrint("✅ Crew removed successfully");
        return true;
      } else {
        debugPrint("❌ Remove crew failed: $response");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Remove Holds Error: $e");
      return false;
    }
  }

  Future<void> _holds() async {
    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking}/${widget.bookingId}/holds",
      );

      if (response != null && response['error'] == false) {
        final creatives = response['data']['creatives'] as List;

        setState(() {
          addedCrewUserIds =
              creatives.map<int>((e) => e['creative_user_id']).toSet();
        });

        debugPrint("🟢 HOLDS FROM BACKEND: $addedCrewUserIds");
      }
    } catch (e) {
      debugPrint("❌ Holds API Error: $e");
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

            // 🔹 Back Button (Left)
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
              "More Details",
              style: TextStyle(
                color: ColorCode.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "2/3",
                style: TextStyle(
                  color: ColorCode.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [



            Row(
              children: List.generate(3, (index) {
                double fillWidth = 0;

                if (index < currentStep) {
                  // ✅ Completed step (FULL)
                  fillWidth = double.infinity;
                } else if (index == currentStep) {
                  // 🟡 Current step (HALF)
                  fillWidth = 140.44;
                } else {

                  fillWidth = 0;
                }

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 5,
                    decoration: BoxDecoration(
                      color: ColorCode.kSubtextColor, // grey background
                      borderRadius: BorderRadius.circular(64),
                    ),
                    child: fillWidth > 0
                        ? Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 5,
                        width: fillWidth == double.infinity ? null : fillWidth,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Your Dream Team",
                  style: TextStyle(
                    fontFamily: "Unbounded ",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorCode.white,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _openFilterDialog(context);
                  },
                  child: Image.asset(
                    "assets/Icons/Filter.png",
                    height: 24,
                    width: 24,
                    color: ColorCode.white,
                  ),
                ),


              ],
            ),

            const SizedBox(height: 16),
            Expanded(
              child:ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: crewMatches.length,
                itemBuilder: (context, index) {
                  final item = crewMatches[index];

                  final int userId = item['user']['id'];
                  // final bool isFavourite = favouriteUsers.contains(userId);


                  final int creativeUserId = item['user']['id'];     // ✅ FIX
                  final int roleId = int.parse(item['role_id']);
                  final bool isAdded = addedCrewUserIds.contains(creativeUserId);
                  final bool isFavourite = favouriteUsers.contains(creativeUserId);


                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      height: 237,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [

                          /// 🔹 IMAGE (API)
                          Positioned.fill(
                            child: item['profile_image_url'] != null
                                ? Image.network(
                              ApiService().getImageURL(
                                item['profile_image_url'],
                              ),
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              "assets/images/Rectangle 34661070.png",
                              fit: BoxFit.cover,
                            ),
                          ),

                          /// 🔹 GRADIENT
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// 🔹 TOP ROW
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    CircleAvatar(
                                      radius: 4,
                                      backgroundColor: Colors.green,
                                    ),
                                    SizedBox(width: 6),
                                    Text("Active",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (isFavourite) {
                                      // ❌ REMOVE
                                      setState(() {
                                        favouriteUsers.remove(userId);
                                      });

                                      await _removeFavourite(userId);

                                      _showFavouriteToast("Removed from Favourite");
                                    } else {
                                      // ✅ ADD
                                      setState(() {
                                        favouriteUsers.add(userId);
                                      });

                                      await _addFavourite(userId);

                                      _showFavouriteToast("Added to Favourite");
                                    }
                                  },
                                  child: Image.asset(
                                    isFavourite
                                        ? "assets/Icons/Heart_Angl_COLOR.png"
                                        : "assets/images/Heart Angle.png",
                                    height: 22,
                                    width: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 🔹 BOTTOM CONTENT
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [

                                /// LEFT INFO
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${item['average_rating'] ?? '0'} (${item['total_reviews'] ?? 0})",
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      item['role_name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),

                                /// RIGHT BUTTONS
                                Row(
                                  children: [

                                    /// ADD / REMOVE CREW
                                    InkWell(
                                      onTap: () {

                                        // ❌ Role not allowed
                                        if (!allowedRoleIds.contains(roleId)) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("This role is not allowed for this booking"),
                                            ),
                                          );
                                          return;
                                        }

                                        /// 🔴 REMOVE (LOCAL ONLY)
                                        if (isAdded) {
                                          setState(() {
                                            addedCrewUserIds.remove(creativeUserId);
                                          });
                                        }

                                        /// 🟢 ADD (LOCAL ONLY)
                                        else {
                                          // count only local selected
                                          int selectedForThisRole = 0;

                                          for (final match in crewMatches) {
                                            final int uid = match['user']['id'];
                                            final int rId = int.parse(match['role_id']);

                                            if (addedCrewUserIds.contains(uid) && rId == roleId) {
                                              selectedForThisRole++;
                                            }
                                          }

                                          if (selectedForThisRole >= requiredCount) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "You can add only $requiredCount ${item['role_name']}",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          setState(() {
                                            addedCrewUserIds.add(creativeUserId);
                                          });
                                        }
                                      },


                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isAdded ? ColorCode.kLightRed : ColorCode.kButtonColor,
                                          borderRadius: BorderRadius.circular(30),
                                          border: isAdded ? Border.all(color: Colors.red) : null,
                                        ),
                                        child: Text(
                                          isAdded ? "Remove" : "Add to Crew",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w600,
                                            color: isAdded ? Colors.red : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),


                                    const SizedBox(width: 8),

                                    /// DETAILS BUTTON
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => RecommendedDetilsScreen(
                                              id: item['id'],
                                              bookingId: widget.bookingId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.asset(
                                        "assets/images/Group 2087328980.png",
                                        height: 32,
                                      ),
                                    ),
                                  ],
                                ),



                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),
          ],
        ),

      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  // ✅ ENABLE / DISABLE LOGIC
                  onPressed: addedCrewUserIds.length == requiredCount
                      ? () async {
                    for (final userId in addedCrewUserIds) {
                      final match = crewMatches.firstWhere(
                            (e) => e['user']['id'] == userId,
                      );

                      await _addHolds(
                        creativeUserId: userId,
                        roleId: int.parse(match['role_id']),
                      );
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewConfirmScreen(
                          bookingId: widget.bookingId,
                        ),
                      ),
                    );
                  }
                      : null, // ❌ disable when count mismatch

                  style: ElevatedButton.styleFrom(
                    backgroundColor: addedCrewUserIds.length == requiredCount
                        ? ColorCode.kButtonColor
                        : ColorCode.kWhiteOpacity60, // 🔥 disabled look
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),

                  child: Text(
                    "Continue with ${addedCrewUserIds.length} Member",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w600,
                      color: addedCrewUserIds.length == requiredCount
                          ? ColorCode.kHeadingColor
                          : Colors.black45,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  void _openFilterDialog(BuildContext context) {
    int selectedIndex = 1;
    RangeValues priceRange = const RangeValues(100, 15000);

    final List<String> options = [
      "Top Rated",
      "Alphabetical A - Z",
      "Nearest",
      "Newest Profiles",
      "Low to High Price",
      "High to Low Price",
    ];

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorCode.k282828,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// TOP INDICATOR
                        Center(
                          child: Container(
                            width: 35,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: ColorCode.kWhiteOpacity70,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Filter By",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Divider(color: Colors.white.withOpacity(0.15)),
                        const SizedBox(height: 16),

                        /// 🔹 SORT CARD (FIXED)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sort By",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),

                              ...List.generate(options.length, (index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() => selectedIndex = index);
                                  },
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          options[index],
                                          style: TextStyle(
                                            fontFamily: "Outfit",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: ColorCode.kWhiteOpacity70,
                                          ),
                                        ),

                                        /// ✅ GRADIENT RADIO (index valid here)
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: selectedIndex == index
                                                ? const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFE8D1AB), // light shade
                                                Color(0xFFD4A14D), // dark shade
                                              ],
                                            )
                                                : null,
                                            border: Border.all(
                                              color: Colors.white38,
                                            ),
                                          ),
                                          child: selectedIndex == index
                                              ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration:
                                              const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black,
                                              ),
                                            ),
                                          )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// PRICE RANGE
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            // color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Price Range",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.white,
                                ),
                              ),
                              RangeSlider(
                                values: priceRange,
                                min: 100,
                                max: 15000,
                                activeColor: ColorCode.kButtonColor,
                                inactiveColor: Colors.white24,
                                onChanged: (values) {
                                  setState(() => priceRange = values);
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Minimum\n\$${priceRange.start.toInt()}",
                                    style: const TextStyle(
                                      color: ColorCode.kWhiteOpacity70,
                                      fontSize: 11,
                                      fontFamily: "Unbounded",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Maximum\n\$${priceRange.end.toInt()}",
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color: ColorCode.kWhiteOpacity70,
                                      fontSize: 11,
                                      fontFamily: "Unbounded",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                  Border.all(color: ColorCode.kWhiteOpacity60
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = 0;
                                      priceRange =
                                      const RangeValues(100, 15000);
                                    });
                                  },
                                  child: const Text(
                                    "Clear All",
                                    style: TextStyle(
                                      fontFamily: "Unbounded",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: ColorCode.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  color: ColorCode.kButtonColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                      "Apply",
                                      style: TextStyle(
                                        fontFamily: "Unbounded",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: ColorCode.black,
                                      )
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  void _showFavouriteToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: ColorCode.kButtonColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Outfit",
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

}
