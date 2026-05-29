import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/shared_service.dart';

final drawerUserProvider =
FutureProvider<Map<String, dynamic>>((ref) async {
  return await SharedService.getUserData();
});