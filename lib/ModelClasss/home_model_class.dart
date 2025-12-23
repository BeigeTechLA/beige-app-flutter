import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../service/api_endpoints.dart';

/// ================= MODELS =================

class HomeResponse {
  final bool error;
  final int code;
  final String message;
  final HomeData data;

  HomeResponse({
    required this.error,
    required this.code,
    required this.message,
    required this.data,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      error: json['error'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: HomeData.fromJson(json['data'] ?? {}),
    );
  }
}

class HomeData {
  final String location;
  final List<Specialty> specialties;
  final Creative? mainCreative;
  final List<Creative> featuredCreatives;

  HomeData({
    required this.location,
    required this.specialties,
    required this.mainCreative,
    required this.featuredCreatives,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      location: json['location'] ?? '',
      specialties: (json['specialties'] as List? ?? [])
          .map((e) => Specialty.fromJson(e))
          .toList(),
      mainCreative: json['mainCreative'] != null
          ? Creative.fromJson(json['mainCreative'])
          : null,
      featuredCreatives: (json['featuredCreatives'] as List? ?? [])
          .map((e) => Creative.fromJson(e))
          .toList(),
    );
  }
}

class Specialty {
  final int specialtyId;
  final String name;
  final String imageUrl;

  Specialty({
    required this.specialtyId,
    required this.name,
    required this.imageUrl,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      specialtyId: json['specialty_id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class Creative {
  final int id;
  final String name;
  final String? profileImageUrl;
  final String hourlyRate;
  final String averageRating;
  final int totalReviews;
  final double distanceKm;
  final String primaryTitle;

  Creative({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.hourlyRate,
    required this.averageRating,
    required this.totalReviews,
    required this.distanceKm,
    required this.primaryTitle,
  });

  factory Creative.fromJson(Map<String, dynamic> json) {
    return Creative(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profileImageUrl: json['profile_image_url'],
      hourlyRate: json['hourly_rate'] ?? '',
      averageRating: json['average_rating'] ?? '',
      totalReviews: json['total_reviews'] ?? 0,
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      primaryTitle: json['primary_title'] ?? '',
    );
  }
}

/// ================= UI SCREEN =================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  HomeResponse? homeResponse;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    try {
      final response =
      await ApiService().fetchData(ApiEndpoints.home_data);

      if (response != null && response['error'] == false) {
        setState(() {
          homeResponse = HomeResponse.fromJson(response);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Home API Error: $e");
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = homeResponse!.data;

    return Scaffold(
      appBar: AppBar(
        title: Text(data.location),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ===== SPECIALTIES =====
            const Text(
              "Book a Shoot",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.specialties.length,
                itemBuilder: (context, index) {
                  final item = data.specialties[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        item.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            /// ===== MAIN CREATIVE =====
            const Text(
              "Top Creative",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (data.mainCreative != null)
              _creativeCard(data.mainCreative!),

            const SizedBox(height: 24),

            /// ===== FEATURED CREATIVES =====
            const Text(
              "Featured Creatives",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              itemCount: data.featuredCreatives.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _creativeCard(data.featuredCreatives[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ===== CREATIVE CARD =====
  Widget _creativeCard(Creative creative) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage("assets/Icons/profile.png"),
        ),
        title: Text(creative.name),
        subtitle: Text(
          "${creative.primaryTitle}\n⭐ ${creative.averageRating} • ${creative.distanceKm.toStringAsFixed(1)} km",
        ),
        trailing: Text("₹${creative.hourlyRate}/hr"),
        isThreeLine: true,
      ),
    );
  }
}
