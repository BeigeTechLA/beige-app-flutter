import '../../Model/HomeModel.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';


class HomeController {
  Future<HomeModel?> fetchHomeData() async {
    try {
      final response = await ApiService().fetchData(
        ApiEndpoints.home_data,
      );

      print("HOME_RESPONSE = $response");

      if (response != null && response['error'] == false) {
        return HomeModel.fromJson(response['data']);
      }
    } catch (e) {
      print("ERROR = $e");
    }

    return null;
  }
}