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

  Map<int, int> requiredCountByRole = {};

  Set<int> favouriteUsers = {};

  int requiredCount = 0;

  Set<int> allowedRoleIds = {};
  Set<int> addedCrewIds = {};
  List<dynamic> crewMatches = [];
  bool isLoading = true;


  Set<int> addedCrewUserIds = {};
  final List<String> options = [
    "Top Rated",
    "Nearest",
    "Newest Profiles",
    // "A to Z",
  ];

  String _getSortKey(int index) {
    switch (index) {
      case 0:
        return "top_rated";
      case 1:
        return "nearest";
      case 2:
        return "newest";
      case 3:
        return "a_z";
      default:
        return "nearest";
    }
  }

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
        "${ApiEndpoints.booking}/${widget.bookingId}/matches?sort=nearest&page=1&limit=50",
      );
      print("📥 FULL RESPONSE => $response");
      
      if (response != null && response['error'] == false) {
        setState(() {
          crewMatches = response['data']['items'];

          final requirements = response['data']['crew_requirements'] as List;

          allowedRoleIds =
              requirements.map<int>((e) => e['role_id']).toSet();

          // requiredCount = requirements[0]['required_count']; // ✅ 4
          requiredCountByRole = {
            for (var r in requirements)
              r['role_id']: r['required_count']
          };

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

  int get totalRequiredCount {
    return requiredCountByRole.values.fold(0, (a, b) => a + b);
  }

  bool get isRoleWiseSelectionComplete {

    if (requiredCountByRole.isEmpty) {
      return true;
    }

    for (final entry in requiredCountByRole.entries) {
      final roleId = entry.key;
      final required = entry.value;

      int selected = 0;

      for (final match in crewMatches) {
        final int uid = match['user']['id'];
        final int rId = int.tryParse(match['role_id'].toString()) ?? 0;

        if (rId == roleId && addedCrewUserIds.contains(uid)) {
          selected++;
        }
      }

      if (selected < required) {
        return false;
      }
    }

    return true;
  }


  Future<void> _filterCrew({required String sort}) async {
    setState(() => isLoading = true);

    final String url =
        "${ApiEndpoints.booking}/${widget.bookingId}/matches"
        "?sort=$sort&page=1&limit=30";

    // 🔍 PRINT API URL
    debugPrint("🟡 FILTER API URL => $url");

    try {
      final response = await ApiService().fetchData(url);

      // 🔍 PRINT FULL RESPONSE
      debugPrint("🟢 FILTER API RESPONSE => $response");

      if (response != null && response['error'] == false) {
        final List items = response['data']['items'] ?? [];

        setState(() {
          crewMatches = items;
        });

        debugPrint(
          "✅ FILTER APPLIED: $sort | ITEMS COUNT: ${items.length}",
        );
      } else {
        debugPrint("❌ FILTER API FAILED => $response");
      }
    } catch (e, stack) {
      // 🔥 ERROR + STACK TRACE
      debugPrint("❌ FILTER API ERROR => $e");
      debugPrint("📌 STACK TRACE => $stack");
    } finally {
      setState(() => isLoading = false);
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
                onTap: () {
                  Navigator.pop(context);
                },
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
                    _openFilterDialog(
                      context,
                          (sortKey) {
                        _filterCrew(sort: sortKey);
                      },
                    );
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
                                      /*           onTap: () {

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
                                      },*/
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

                                        /// 🔴 REMOVE
                                        if (isAdded) {
                                          setState(() {
                                            addedCrewUserIds.remove(creativeUserId);
                                          });
                                          return;
                                        }

                                        /// 🟢 ADD
                                        int selectedForThisRole = 0;

                                        for (final match in crewMatches) {
                                          final int uid = match['user']['id'];
                                          final int rId = int.parse(match['role_id']);

                                          if (addedCrewUserIds.contains(uid) && rId == roleId) {
                                            selectedForThisRole++;
                                          }
                                        }

                                        /// ✅ ROLE-WISE LIMIT
                                        final int maxAllowed =
                                            requiredCountByRole[roleId] ?? 0;

                                        if (selectedForThisRole >= maxAllowed) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "You can add only $maxAllowed ${item['role_name']}",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() {
                                          addedCrewUserIds.add(creativeUserId);
                                        });
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
                  // ✅ FINAL ENABLE / DISABLE LOGIC
                  onPressed: () async {

                    // 🔴 IF NO CREW SELECTED → SHOW POPUP
                    if (addedCrewUserIds.isEmpty) {
                      _showNoCrewPopup();
                      return;
                    }

                    // 🟢 IF CREW SELECTED → CALL HOLD API
                    for (final userId in addedCrewUserIds) {

                      final matches = crewMatches
                          .where((e) => e['user']['id'] == userId)
                          .toList();

                      if (matches.isEmpty) continue;

                      final roleId =
                          int.tryParse(matches.first['role_id'].toString()) ?? 0;

                      await _addHolds(
                        creativeUserId: userId,
                        roleId: roleId,
                      );
                    }

                    // 🚀 GO NEXT SCREEN
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewConfirmScreen(
                          bookingId: widget.bookingId,
                        ),
                      ),
                    );
                  },



                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRoleWiseSelectionComplete
                        ? ColorCode.kButtonColor
                        : ColorCode.kButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Continue with "
                        "${addedCrewUserIds.length.toString().padLeft(2, '0')} "
                        "${addedCrewUserIds.length == 1 ? "Member" : "Members"}",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w600,
                      color: isRoleWiseSelectionComplete
                          ? ColorCode.kHeadingColor
                          : ColorCode.kHeadingColor,
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

  void _openFilterDialog(
      BuildContext context,
      Function(String sortKey) onApply,
      ) {
    int selectedIndex = 1;
    RangeValues priceRange = const RangeValues(100, 15000);


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
                    /*    Container(
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
                        ),*/

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
                                    final sortKey = _getSortKey(selectedIndex);

                                    Navigator.pop(context);

                                    onApply(sortKey); // 🔥 YAHI MAIN LINE HAI
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
  void _showNoCrewPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return Center(
          child: Container(
            width: 380,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// 🔹 ICON
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2A2A2A),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: ColorCode.kButtonColor,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 TITLE
                  const Text(
                    "No Crew Selected?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Unbounded",
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 DESCRIPTION
                  const Text(
                    "You are choosing to continue without adding any team members.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: "Outfit",
                      height: 1.4,
                    ),
                  ),
                   Text(
                    "Beige's team will create the best talent for you based on your needs.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorCode.kButtonColor,
                      fontSize: 14,
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),

                  /// 🔹 BUTTONS
                  Row(
                    children: [

                      /// Go Back Button
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Go Back & Select",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// Yes Continue Button
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: ColorCode.kButtonColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReviewConfirmScreen(
                                    bookingId: widget.bookingId,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Yes, Continue",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w600,
                              ),
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
        );
      },
    );
  }


}
