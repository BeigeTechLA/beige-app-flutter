import 'dart:convert';
import 'dart:developer';

class HomeModel {
  final String name;
  final String location;
  final String latitude;
  final String longitude;
  final String profileImageUrl;
  final List<Your_Booking> yourBookings;
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
    required this.featuredCreatives, required this.name,
    required this.yourBookings,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      name: json['name'] ?? "",
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
      yourBookings: (json['your_bookings'] as List? ?? [])
          .map((e) => Your_Booking.fromJson(e))
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
      id: json['crew_member_id'] ?? 0,
      name: json['name'] ?? "",
      profileImage: json['profile_image_url'] ?? "",
      hourlyRate: json['hourly_rate']?.toString(),
      rating: json['average_rating']?.toString(),
      totalReviews: json['total_reviews'],

      // ✅ crash-proof conversion
      distance: (json['distance_km'] is num)
          ? (json['distance_km'] as num).toDouble()
          : 0.0,

      title: json['primary_title'],
    );
  }
}

//////////////////////

class ContinueBooking {
  final bool show;
  final int bookingId;
  final String title;
  final String? imageUrl;
  final String currentScreen;
  final String currentScreenLabel;
  final int currentScreenOrder;
  final int totalSteps;
  final double progress;
  final String resumeApi;
  final List<Flow> flow;

  ContinueBooking({
    required this.show,
    required this.bookingId,
    required this.title,
    this.imageUrl,
    required this.currentScreen,
    required this.currentScreenLabel,
    required this.currentScreenOrder,
    required this.totalSteps,
    required this.progress,
    required this.resumeApi,
    required this.flow,
  });

  factory ContinueBooking.fromJson(Map<String, dynamic> json) {
    return ContinueBooking(
      show: json['show'] ?? false,
      bookingId: json['booking_id'] ?? 0,
      title: json['title'] ?? "",
      imageUrl: json['image_url'],
      currentScreen: json['current_screen'] ?? "",
      currentScreenLabel: json['current_screen_label'] ?? "",
      currentScreenOrder: json['current_screen_order'] ?? 0,
      totalSteps: json['total_steps'] ?? 0,
      progress: (json['progress'] is num)
          ? (json['progress'] as num).toDouble()
          : 0.0,
      resumeApi: json['resume_api'] ?? "",
      flow: (json['flow'] as List? ?? [])
          .map((e) => Flow.fromJson(e))
          .toList(),
    );
  }
}

////////
class Flow {
  final String key;
  final String label;
  final String status;
  final int order;

  Flow({
    required this.key,
    required this.label,
    required this.status,
    required this.order,
  });

  factory Flow.fromJson(Map<String, dynamic> json) {
    return Flow(
      key: json['key'] ?? "",
      label: json['label'] ?? "",
      status: json['status'] ?? "",
      order: json['order'] ?? 0,
    );
  }
}
//////

class Your_Booking {
  final int bookingId;
  final String title;
  final String? imageUrl;
  final String? eventDate;
  final String? startTime;
  final String? endTime;
  final String status;
  final String statusLabel;
  final String cta;

  Your_Booking({
    required this.bookingId,
    required this.title,
    this.imageUrl,
    this.eventDate,
    this.startTime,
    this.endTime,
    required this.status,
    required this.statusLabel,
    required this.cta,
  });

  factory Your_Booking.fromJson(Map<String, dynamic> json) {
    return Your_Booking(
      bookingId: json['booking_id'] ?? 0,
      title: json['title'] ?? "",
      imageUrl: json['image_url'],
      eventDate: json['event_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'] ?? "",
      statusLabel: json['status_label'] ?? "",
      cta: json['cta'] ?? "",
    );
  }
}