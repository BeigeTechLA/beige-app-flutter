import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../app/route_names.dart';
import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';
import '../../../app/colors.dart';
import '../../../widgets/loding.dart' show AppLoader;

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

  int getRequired(int roleId) {
    return requiredByRole[roleId.toString()] ??
        requiredByRole[roleId] ??
        0;
  }

  int getHeld(int roleId) {
    return heldByRole[roleId.toString()] ??
        heldByRole[roleId] ??
        0;
  }
  Map<String, dynamic> heldByRole = {};
  Map<String,dynamic>requiredByRole={};

  int currentStep = 1;
  bool isAdded = false;

  Map<int, int> requiredCountByRole = {};

  Set<int> favouriteUsers = {};

  int requiredCount = 0;

  Set<int> allowedRoleIds = {};
  Set<int> addedCrewIds = {};
  List<dynamic> crewMatches = [];
  bool isLoading = true;

  List<dynamic> nearbyCreators = [];
  List<dynamic> otherCreators = [];
  bool showLocationCard = false;

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
  int getRoleIdByContentType(int contentTypeId, String roleName) {
    final name = roleName.toLowerCase();

    /// VIDEO ONLY
    if (contentTypeId == 1) return 1;

    /// PHOTO ONLY
    if (contentTypeId == 2) return 2;

    /// BOTH
    if (contentTypeId == 3) {
      if (name.contains("photographer")) return 2;
      if (name.contains("video")) return 1;
    }

    return 1;
  }

  /// 🔥 ROLE NAME → ROLE ID mapping
  int _mapRoleName(String roleName) {
    final name = roleName.toLowerCase();

    if (name.contains("video")) return 1;
    if (name.contains("photo")) return 2;

    return 1; // default (kabhi 0 nahi)
  }
  @override
  void initState() {
    super.initState();
    _holds();
    _CrewSizeMatching();
  }

  Future<void> _CrewSizeMatching() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking}/${widget.bookingId}/matches?sort=nearest&page=1&limit=400",
      );
      print("📥 FULL RESPONSE of the API => $response");

      if (response != null && response['error'] == false) {
        /*  setState(() {
          crewMatches = response['data']['items'];

          final requirements = response['data']['crew_requirements'] as List;

          allowedRoleIds =
              requirements.map<int>((e) => e['role_id']).toSet();

          // requiredCount = requirements[0]['required_count']; // ✅ 4
          requiredCountByRole = {
            for (var r in requirements)
              r['role_id']: r['required_count']
          };

        });*/

        setState(() {
          crewMatches = response['data']['items'];

          nearbyCreators.clear();
          otherCreators.clear();

          for (var item in crewMatches) {

            double distance = 0;

            if (item['distance_km'] != null) {
              distance = (item['distance_km'] as num).toDouble();
            }

            /// 🔥 CONDITION FIX
            if (distance > 0 && distance <= 100) {
              nearbyCreators.add(item);
            } else {
              otherCreators.add(item);
            }
          }

          /// agar nearby empty ho to special card dikhao
          showLocationCard = nearbyCreators.isEmpty;

          final requirements = response['data']['crew_requirements'] as List;

          allowedRoleIds = requirements.map<int>((e) => e['role_id']).toSet();

          requiredCountByRole = {
            for (var r in requirements) r['role_id']: r['required_count']
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
      print("📥 FULL RESPONSE => $response");

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
      final url = "${ApiEndpoints.booking}/${widget.bookingId}/hold";

      /// 🔥 PRINT START
      debugPrint("═══════════════════════════════");
      debugPrint("📤 ADD HOLD API CALL");
      debugPrint("👉 URL: $url");


      final body = {
        "crew_member_id": creativeUserId,
        "role_id": roleId,
      };

      debugPrint("👉 PAYLOAD:");

      body.forEach((key, value) {
        debugPrint("   $key : $value");
      });

      debugPrint("═══════════════════════════════");

      final response = await ApiService().postData(url, body);

      /// 🔥 RESPONSE PRINT
      debugPrint("📥 RESPONSE:");
      debugPrint(response.toString());
      debugPrint("═══════════════════════════════");
      print("📥 FULL RESPONSE OK => $response");


      if (response != null && response['error'] == false) {
        debugPrint("✅ SUCCESS");
        return true;
      }

      else {
        final msg = response?['message'] ?? "Something went wrong";

        debugPrint("❌ FAILED: $msg");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );

        return false;
      }
    } catch (e) {
      debugPrint("❌ EXCEPTION: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

      return false;
    }
  }

  Future<bool> _removeHolds({
    required int creativeUserId,
  }) async {
    try {
      final url = "${ApiEndpoints.booking}/${widget.bookingId}/hold/remove";

      debugPrint("👉 REMOVE HOLD URL: $url");
      debugPrint("👉 BODY: creative_user_id=$creativeUserId");

      final response = await ApiService().postData(
        url,
        {
          "crew_member_id": creativeUserId,
        },
      );

      debugPrint("✅ REMOVE RESPONSE: $response");


      if (response != null && response['error'] == false) {
        return true;
      } else {
        final msg = response?['message'] ?? "Remove failed";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );

        return false;
      }
    } catch (e) {
      debugPrint("❌ Remove Holds Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

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

        final summary=response['data']['summary'];

        setState(() {
          addedCrewUserIds =
              creatives.map<int>((e) => e['creative_user_id']).toSet();

          requiredByRole = Map<String, dynamic>.from(summary['required_by_role']);
          heldByRole = Map<String, dynamic>.from(summary['held_by_role']);

        });

        debugPrint("🟢 HOLDS FROM BACKEND: $addedCrewUserIds");
        print("📥 FULL RESPONSE2 => $response");

      }
    } catch (e) {
      debugPrint("❌ Holds API Error: $e");
    }
  }

  /* int get totalRequiredCount {
    return requiredCountByRole.values.fold(0, (a, b) => a + b);
  }*/

/*  bool get isRoleWiseSelectionComplete {

    if (requiredCountByRole.isEmpty) {
      return true;
    }

    for (final entry in requiredCountByRole.entries) {
      final roleId = entry.key;
      final required = entry.value;

      int selected = 0;

      for (final match in crewMatches) {
        final int uid =
            match['crew_member_id'] ?? match['user']?['id'] ?? 0;
        final int rId = int.tryParse(match['role_id'][0].toString()) ?? 0;

        if (rId == roleId && addedCrewUserIds.contains(uid)) {
          selected++;
        }
      }

      if (selected < required) {
        return false;
      }
    }

    return true;
  }*/


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

  int getRoleId(dynamic roleData) {
    if (roleData is List && roleData.isNotEmpty) {
      return int.tryParse(roleData.first.toString()) ?? 0;
    }
    return int.tryParse(roleData.toString()) ?? 0;
  }

  int getSelectedCountByRole(int roleId) {
    int count = 0;

    for (final match in crewMatches) {
      final int uid =
          match['crew_member_id'] ?? match['user']?['id'] ?? 0;

      final roleData = match['role_id'];

      final List roles = roleData is List ? roleData : [roleData];

      /// 🔥 MULTI ROLE SUPPORT
      bool hasRole = roles.any((r) => int.tryParse(r.toString()) == roleId);

      if (hasRole && addedCrewUserIds.contains(uid)) {
        count++;
      }
    }

    return count;
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
                    context.pop();
                  },
                  child:SvgPicture.asset(
                    "assets/svg/back.svg",
                    height: 24,
                  ),
                ),
              ),
              Text(
                "More Details",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w400,
                ),
              ),
              // 🔹 Step Text (Right)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "2/3",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15,right: 15,bottom: 15),
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
                            color: AppColors.textSecondary, // grey background
                            borderRadius: BorderRadius.circular(64),
                          ),
                          child: fillWidth > 0
                              ? Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 5,
                              width: fillWidth == double.infinity ? null : fillWidth,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
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
                          fontFamily: "Unbounded",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
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
                        child: SvgPicture.asset(
                          "assets/svg/Filter.svg",
                          height: 24,
                        ),
                      ),



                    ],
                  ),

                  const SizedBox(height: 16),
                  /*        Expanded(
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
                                        *//*           onTap: () {

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
                                        },*//*
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
                                            color: isAdded ? AppColors.errorLight : AppColors.primary,
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
                                          context.pushNamed(RouteNames.recommendedDetails, extra: {
                                            'id': item['id'],
                                            'bookingId': widget.bookingId,
                                          });
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

              SizedBox(height: 20),*/
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [

                        /// 🔥 LOCATION NOT FOUND CARD
                        /// 🔥 LOCATION NOT FOUND CARD
                        if (showLocationCard)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [

                                ClipOval(
                                  child: Image.asset(
                                    "assets/Icons/sale.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                const Text(
                                  "Our creators around \nyour location are booked ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "Unbounded",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                const Text(
                                  "Looks like no creators are available right now, but our sales expert can help you find a great match.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white60,
                                  ),
                                ),

                                SizedBox(height: 10),

                                Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.85,
                                    child: Divider(
                                      color: AppColors.dividerDark,
                                      thickness: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        /// TITLE
                        if (crewMatches.isNotEmpty &&
                            (crewMatches.first['distance_km'] ?? 0) > 100)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              "  Browse Other Creative Partners",//
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.white,
                              ),
                            ),
                          ),

                        /// CREW LIST
                        ...crewMatches.map((item) {

                          /// ✅ SAFE ID (NO CRASH)
                          final int creativeUserId =
                              item['crew_member_id'] ?? item['user']?['id'] ?? 0;

                          final int userId = creativeUserId;

                          /// ✅ SAFE ROLE ID
                          final roleData = item['role_id'];
                          final int roleId = (roleData is List)
                              ? int.tryParse(roleData.first.toString()) ?? 0
                              : int.tryParse(roleData.toString()) ?? 0;

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
                                children: [//

                                  /// 🔹 IMAGE
                                  Positioned.fill(
                                    child: item['profile_image_url'] != null
                                        ? Image.network(
                                      ApiService().getImageURL(item['profile_image_url']),
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter, // 🔥 important
                                      errorBuilder: (context, error, stackTrace) {
                                        return SvgPicture.asset('assets/svg/imag_placeholder.svg',fit: BoxFit.contain, height: 25,);
                                      },
                                    )
                                        : Image.asset(
                                      "assets/images/Rectangle 34661070.png",
                                      fit: BoxFit.contain,
                                      height: 25,
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
                                      Container(
                                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.5, 0.75, 1],
                          colors: [
                          Colors.transparent,
                          const Color(0xFF090909).withOpacity(0.6),
                          const Color(0xFF090909),
                          ],
                          ),
                          ),),
                                  /// 🔹 FAV ICON
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () async {
                                        if (isFavourite) {
                                          setState(() {
                                            favouriteUsers.remove(userId);
                                          });

                                          await _removeFavourite(userId);
                                          _showFavouriteToast("Removed from Favourite");
                                        } else {
                                          setState(() {
                                            favouriteUsers.add(userId);
                                          });

                                          await _addFavourite(userId);
                                          _showFavouriteToast("Added to Favourite");
                                        }
                                      },
                                      child: SvgPicture.asset(
                                        isFavourite
                                            ? "assets/svg/Heart_COLOR.svg"
                                            : "assets/svg/Heart.svg",
                                        height: 22,
                                        width: 22,
                                      ),
                                    ),
                                  ),

                                  /// 🔹 BOTTOM INFO
                                  Positioned(
                                    left: 14,
                                    right: 14,
                                    bottom: 14,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [

                                        /// LEFT INFO
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                         /*   Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    color: Colors.amber, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${item['average_rating'] ?? '0'} (${item['total_reviews'] ?? 0})",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),*/
                                            const SizedBox(height: 6),
                                            Text(
                                              item['name'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Outfit",
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              item['role_name'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontFamily: "Outfit",
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),

                                        /// RIGHT BUTTONS
                                        Row(
                                          children: [

                                            /// 🔥 ADD / REMOVE BUTTON
                                            if (!showLocationCard)
                                              InkWell(
                                                onTap: () async {
                                                  try {
                                                    final int creativeUserId =
                                                        item['crew_member_id'] ?? item['user']?['id'] ?? 0;

                                                    final roleData = item['role_id'];

                                                    /// 🔥 SAFE ROLE ID
                                                    final int roleId = (roleData is List)
                                                        ? int.tryParse(roleData.first.toString()) ?? 0
                                                        : int.tryParse(roleData.toString()) ?? 0;

                                                    if (creativeUserId == 0) return;

                                                    /// 🔴 REMOVE
                                                    if (addedCrewUserIds.contains(creativeUserId)) {
                                                      setState(() {
                                                        addedCrewUserIds.remove(creativeUserId);
                                                      });

                                                      final success = await _removeHolds(
                                                        creativeUserId: creativeUserId,
                                                      );

                                                      if (success) {
                                                        await _holds();
                                                      } else {
                                                        setState(() {
                                                          addedCrewUserIds.add(creativeUserId);
                                                        });
                                                      }

                                                      return;
                                                    }

                                                    /// 🟢 ADD FLOW

                                                    int selectedCount = getSelectedCountByRole(roleId);

                                                    /// 🔥 MAIN FIX (IMPORTANT)
                                                    final int maxAllowed =
                                                    (requiredCountByRole[roleId] ?? 0) == 0
                                                        ? 10 // 👉 fallback allow selection
                                                        : requiredCountByRole[roleId]!;

                                                    if (selectedCount >= maxAllowed) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "You can add only $maxAllowed ${item['role_name']}",
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    /// ✅ UI FIRST
                                                    setState(() {
                                                      addedCrewUserIds.add(creativeUserId);
                                                    });

                                                    final success = await _addHolds(
                                                      creativeUserId: creativeUserId,
                                                      roleId: roleId,
                                                    );

                                                    if (success) {
                                                      await _holds();
                                                    } else {
                                                      setState(() {
                                                        addedCrewUserIds.remove(creativeUserId);
                                                      });
                                                    }

                                                  } catch (e) {
                                                    print("❌ ERROR: $e");
                                                  }
                                                },

                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 14, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: isAdded
                                                        ? AppColors.errorLight
                                                        : AppColors.primary,
                                                    borderRadius: BorderRadius.circular(30),
                                                    border: isAdded
                                                        ? Border.all(color: Colors.red)
                                                        : null,
                                                  ),
                                                  child: Text(
                                                    isAdded ? "Remove" : "Add to Crew",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: 'Outfit',

                                                      fontWeight: FontWeight.w600,
                                                      color: isAdded
                                                          ? Colors.red
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            if (!showLocationCard) const SizedBox(width: 8),

                                            /// 🔹 DETAILS BUTTON
                                            InkWell(
                                              onTap: () {
                                                context.pushNamed(RouteNames.recommendedDetails, extra: {
                                                  'id': item['crew_member_id'],
                                                  'bookingId': widget.bookingId,
                                                });
                                              },
                                              child: SvgPicture.asset(
                                                "assets/svg/home_view_profile.svg",
                                                color: Colors.white,
                                                height: 36,
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
                        }).toList(),
                      ],
                    ),
                  )

                ],
              ),

            ),
            if (isLoading)
              const AppLoader(),
          ],
        ),

        /*    bottomNavigationBar: Padding(
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
                    context.goNamed(RouteNames.reviewConfirm, extra: {
                      'bookingId': widget.bookingId,
                    });
                  },



                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRoleWiseSelectionComplete
                        ? AppColors.primary
                        : AppColors.primary,
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
                          ? AppColors.textHeading
                          : AppColors.textHeading,
                    ),
                  ),

                ),
              ),
            ),
          ],
        ),
      ),*/
        // bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.all(10),
        //   child: Container(
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         /*     if (!showLocationCard)   /// 🔥 ONLY SHOW WHEN CONTINUE BUTTON
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //
        //               /// VIDEOGRAPHER CHIP
        //               if (getSelectedCountByRole(2) > 0)
        //                 Container(
        //                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(10),
        //                     border: Border.all(color: Colors.white24),
        //                   ),
        //                   child: Row(
        //                     children: [
        //
        //                       SvgPicture.asset(
        //                         "assets/svg/Icon_.svg",
        //                         height: 16,
        //                         color: Colors.white,
        //                       ),
        //
        //                       const SizedBox(width: 6),
        //
        //                       Text(
        //                         "Videographer(s): "
        //                             "${getSelectedCountByRole(2).toString().padLeft(2,'0')}/"
        //                             "${requiredCountByRole[2]?.toString().padLeft(2,'0') ?? '00'}",
        //                         style: const TextStyle(
        //                           fontSize: 12,
        //                           color: Colors.white,
        //                           fontFamily: "Outfit",
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //
        //               if (getSelectedCountByRole(2) > 0 &&
        //                   getSelectedCountByRole(1) > 0)
        //                 const SizedBox(width: 10),
        //
        //               /// PHOTOGRAPHER CHIP
        //               if (getSelectedCountByRole(1) > 0)
        //                 Container(
        //                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(10),
        //                     border: Border.all(color: Colors.white24),
        //                   ),
        //                   child: Row(
        //                     children: [
        //
        //                       SvgPicture.asset(
        //                         "assets/svg/CameraMinimalistic.svg",
        //                         height: 16,
        //                         color: Colors.white,
        //                       ),
        //
        //                       const SizedBox(width: 6),
        //
        //                       Text(
        //                         "Photographer(s): "
        //                             "${getSelectedCountByRole(1).toString().padLeft(2,'0')}/"
        //                             "${requiredCountByRole[1]?.toString().padLeft(2,'0') ?? '00'}",
        //                         style: const TextStyle(
        //                           fontSize: 12,
        //                           color: Colors.white,
        //                           fontFamily: "Outfit",
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //             ],
        //           ),*/
        //
        //
        //         //       if(showLocationCard==false){
        //         //
        //         // Text('Hey whats Up',style: TextStyle(
        //         // color: Colors.red
        //         // ),);
        //         // },
        //
        //
        //         if (showLocationCard == false)
        //      /*     Row(
        //             children: [
        //               Expanded(
        //                 child: Container(
        //
        //              padding: EdgeInsets.all(10),
        //                   // margin: EdgeInsets.symmetric(vertical: 12,),
        //
        //                   //margin: EdgeInsets.symmetric(vertical: 12, horizontal: 7),
        //                   decoration: BoxDecoration(
        //
        //                     borderRadius: BorderRadius.circular(12),
        //                     border: Border.all(
        //                       color: Colors.white.withOpacity(0.5),
        //                       width: 0.5,
        //                     ),
        //                   ),
        //                   child: Row(
        //                     children: [
        //                       SvgPicture.asset(
        //                         'assets/svg/video6.svg',
        //                         width: 17,
        //                         height: 17,
        //                       ),
        //                       SizedBox(width: 6),
        //                       Expanded(
        //                           child:  Text(
        //                             'Videographer(s): ${getSelectedCountByRole(1).toString().padLeft(2,'0')}/${getRequired(1).toString().padLeft(2,'0')}',
        //
        //                             style: TextStyle(
        //                               fontFamily: 'InstrumentSans',
        //                               fontSize: 10,
        //                               fontWeight: FontWeight.w500,
        //                             ),
        //                           )
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //               SizedBox(width: 16,),
        //               Expanded(
        //                 child: Container(
        //                   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        //                   margin: EdgeInsets.symmetric(vertical: 12,),
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(12),
        //                     border: Border.all(
        //                       color: Colors.white.withOpacity(0.5),
        //                       width: 0.5,
        //                     ),
        //                   ),
        //                   child: Row(
        //                     children: [
        //                     SvgPicture.asset(
        //                         'assets/svg/Photo6.SVG',
        //                         width: 17,
        //                         height: 17,
        //                       ),
        //                       SizedBox(width: 6),
        //                       Expanded(
        //                           child: Text(
        //                             'Photographer(s) : ${getSelectedCountByRole(2).toString().padLeft(2,'0')}/${getRequired(2).toString().padLeft(2,'0')}',
        //                             style: TextStyle(
        //                               fontFamily: 'InstrumentSans',
        //                               fontSize: 10,
        //                               fontWeight: FontWeight.w500,
        //                             ),
        //                           )
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),*/
        //
        //         /// 🔹 TEXT ABOVE BUTTON
        //         if (showLocationCard)
        //           Padding(
        //             padding: EdgeInsets.only(bottom: 10),
        //             child: InkWell(
        //               onTap: () {
        //                 Navigator.push(
        //                   context,
        //                   MaterialPageRoute(
        //                     builder: (_) => ReviewConfirmScreen(
        //                       bookingId: widget.bookingId,
        //                     ),
        //                   ),
        //                 );
        //               },
        //               child: Text(
        //                 "Complete your Shoot",
        //                 style: TextStyle(
        //                   fontSize: 14,
        //                   fontFamily: "Outfit",
        //                   fontWeight: FontWeight.w400,
        //                   color: AppColors.white70,
        //                   decoration: TextDecoration.underline,
        //                 ),
        //               ),
        //             ),
        //           ),
        //
        //         /// 🔹 BUTTON
        //         SizedBox(
        //           height: 55,
        //           width: double.infinity,
        //           child: ElevatedButton(
        //
        //             onPressed: () async {
        //
        //
        //
        //               /// CONTACT SALES FLOW
        //               if (showLocationCard) {
        //                 showSalesDialog(context);   // 🔥 Dialog open hoga
        //                 return;
        //               }
        //
        //               /// NORMAL FLOW
        //               /*      if (addedCrewUserIds.isEmpty) {
        //                 _showNoCrewPopup();
        //                 return;
        //               }*/
        //
        //               for (final userId in addedCrewUserIds) {
        //
        //                 final matches = crewMatches
        //                     .where((e) => (e['crew_member_id'] ?? e['user']?['id']) == userId)
        //                     .toList();
        //
        //                 if (matches.isEmpty) continue;
        //
        //                 /*  final roleId =
        //                     int.tryParse(matches.first['role_id'].toString()) ?? 0;*/
        //                 final roleId =
        //                     int.tryParse(matches.first['role_id'].toString()) ?? 0;
        //                 await _addHolds(
        //                   creativeUserId: userId,
        //                   roleId: roleId,
        //                 );
        //               }
        //
        //               Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                   builder: (_) => ReviewConfirmScreen(
        //                     bookingId: widget.bookingId,
        //                   ),
        //                 ),
        //               );
        //             },
        //
        //             style: ElevatedButton.styleFrom(
        //               backgroundColor: AppColors.primary,
        //               elevation: 0,
        //               shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(12),
        //               ),
        //             ),
        //
        //             child: Text(
        //               showLocationCard
        //                   ? "Contact With Sales"
        //                   : "Continue with ${addedCrewUserIds.length.toString().padLeft(2, '0')} ${addedCrewUserIds.length == 1 ? "Member" : "Members"}",
        //               style: const TextStyle(
        //                 fontSize: 14,
        //                 fontFamily: "Unbounded",
        //                 fontWeight: FontWeight.w600,
        //                 color: Colors.black,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // )
        bottomNavigationBar: ClipRect(
          
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
            
                  /// 🔥 SHOW ONLY WHEN NO LOCATION DATA
                  if (showLocationCard)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          context.pushNamed(RouteNames.reviewConfirm, extra: {
                            'bookingId': widget.bookingId,
                          });
                        },
                        child: const Text(
                          "Complete your Shoot",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
            
                  /// 🔥 MAIN BUTTON
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
            
                        /// 🔴 IF NO DATA → SALES FLOW
                        if (showLocationCard) {
                          showSalesDialog(context);
                          return;
                        }
            
                        /// 🟢 NORMAL FLOW
                        for (final userId in addedCrewUserIds) {
            
                          final matches = crewMatches
                              .where((e) => (e['crew_member_id'] ?? e['user']?['id']) == userId)
                              .toList();
            
                          if (matches.isEmpty) continue;
            
                          final roleId =
                              int.tryParse(matches.first['role_id'].toString()) ?? 0;
            
                          await _addHolds(
                            creativeUserId: userId,
                            roleId: roleId,
                          );
                        }
            
                        context.pushNamed(RouteNames.reviewConfirm, extra: {
                          'bookingId': widget.bookingId,
                        });
                      },
            
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
            
                      child: Text(
                        showLocationCard
                            ? "Contact With Sales"
                            : "Continue with ${addedCrewUserIds.length.toString().padLeft(2, '0')} ${addedCrewUserIds.length == 1 ? "Member" : "Members"}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                    color: AppColors.surfaceVariant,
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
                              color: AppColors.white70,
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
                              onTap: () => context.pop(),
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
                                            color: AppColors.white70,
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
                                  color: AppColors.white,
                                ),
                              ),
                              RangeSlider(
                                values: priceRange,
                                min: 100,
                                max: 15000,
                                activeColor: AppColors.primary,
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
                                      color: AppColors.white70,
                                      fontSize: 11,
                                      fontFamily: "Unbounded",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Maximum\n\$${priceRange.end.toInt()}",
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color: AppColors.white70,
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
                                  Border.all(color: AppColors.white60
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
                                      color: AppColors.white,
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
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    final sortKey = _getSortKey(selectedIndex);

                                    context.pop();

                                    onApply(sortKey); // 🔥 YAHI MAIN LINE HAI
                                  },
                                  child: const Text(
                                      "Apply",
                                      style: TextStyle(
                                        fontFamily: "Unbounded",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.black,
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
        top: MediaQuery.of(context).padding.top + 100,
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
                const Icon(Icons.favorite, color: AppColors.primary, size: 18),
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
                      color: AppColors.primary,
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
                      color: AppColors.primary,
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
                              context.pop();
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
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () {
                              context.pop();
                              context.pushNamed(RouteNames.reviewConfirm, extra: {
                                'bookingId': widget.bookingId,
                              });
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
  void showSalesDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
              children: [

                /// 🔥 SMALL ICON / LOTTIE
                SizedBox(

                  child: Lottie.asset(

                    "assets/lottie/success_animation.json",
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 12),

                /// 🔹 TITLE
                const Text(
                  "Request Received",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD6C29C),
                    fontSize: 16, // 🔽 reduce
                    fontFamily: "Unbounded",
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                /// 🔹 DESCRIPTION
                const Text(
                  "Our Sales team will shortly reach out to you to finalize your creative requirements.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12, // 🔽 reduce
                    fontFamily: "Outfit",
                  ),
                ),

                const SizedBox(height: 16),

                /// 🔹 BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 45, // 🔽 reduce
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6C29C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text(
                      "Got It",
                      style: TextStyle(
                        color: Color(0xFF1D1D1B),
                        fontSize: 13,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
