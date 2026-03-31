class HomeModel {
  final String location;
  final String latitude;
  final String longitude;
  final String profileImageUrl;

  final List<Specialty> specialties;
  final List<Creative> mainCreatives;
  final List<Creative> featuredCreatives;

  HomeModel({
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.profileImageUrl,
    required this.specialties,
    required this.mainCreatives,
    required this.featuredCreatives,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      location: json['location'] ?? "",
      latitude: json['location_coordinates']?['latitude'] ?? "",
      longitude: json['location_coordinates']?['longitude'] ?? "",
      profileImageUrl: json['profile_image_url'] ?? "",

      specialties: (json['specialties'] as List? ?? [])
          .map((e) => Specialty.fromJson(e))
          .toList(),

      mainCreatives: (json['mainCreatives'] as List? ?? [])
          .map((e) => Creative.fromJson(e))
          .toList(),

      featuredCreatives: (json['featuredCreatives'] as List? ?? [])
          .map((e) => Creative.fromJson(e))
          .toList(),
    );
  }
}

//////////////////////////////////////////////////////////////

class Specialty {
  final int id;
  final String name;
  final String? imageUrl;

  Specialty({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['specialty_id'] ?? 0,
      name: json['name'] ?? "",
      imageUrl: json['image_url'],
    );
  }
}

//////////////////////////////////////////////////////////////

class Creative {
  final int id;
  final String name;
  final String profileImage;
  final String? hourlyRate;
  final String? rating;
  final int? totalReviews;
  final double distance;
  final String? title;

  Creative({
    required this.id,
    required this.name,
    required this.profileImage,
    this.hourlyRate,
    this.rating,
    this.totalReviews,
    required this.distance,
    this.title,
  });

  factory Creative.fromJson(Map<String, dynamic> json) {
    return Creative(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      profileImage: json['profile_image_url'] ?? "",
      hourlyRate: json['hourly_rate']?.toString(),
      rating: json['average_rating']?.toString(),
      totalReviews: json['total_reviews'],
      distance: (json['distance_km'] ?? 0).toDouble(),
      title: json['primary_title'],
    );
  }
}