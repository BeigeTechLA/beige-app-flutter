import '../../Model/HomeModel.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';

class HomeController {

  Future<HomeModel?> fetchHomeData() async {
    try {
      final response = await ApiService().fetchData(
        ApiEndpoints.home_data,
      );

      if (response != null && response['error'] == false) {
        return HomeModel.fromJson(response['data']);
      }
    } catch (e) {
      print("ERROR = $e");
    }

    return null;
  }

  Future<Map<String, dynamic>?> createBooking(int contentType, int? bookingId) async {
    try {
      final body = {
        if (bookingId != null) "booking_id": bookingId,
        "content_type": contentType,
        "shoot_type_id": 2
      };

      final response =
      await ApiService().postData(ApiEndpoints.booking, body);

      return response;
    } catch (e) {
      print("Booking Error → $e");
      return null;
    }
  }

  Future<List<int>> getShootTypes(int contentTypeId) async {
    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking_shoot_types}$contentTypeId",
      );

      if (response['error'] == false && response['data'] is List) {
        return response['data']
            .map<int>((e) => e['shoot_type_id'] as int)
            .toList();
      }
    } catch (e) {
      print("API Error → $e");
    }

    return [];
  }
}