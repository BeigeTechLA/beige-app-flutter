import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/addon_catalogue_item.dart';
import '../booking_providers.dart';

/// Loads the active add-ons catalogue (`GET /bookings/addons`).
final addonCatalogueProvider =
    FutureProvider.autoDispose<List<AddonCatalogueItem>>((ref) async {
      final repo = ref.read(bookingRepositoryProvider);
      final result = await repo.getAddonCatalogue();
      return result.fold(
        (failure) => throw failure,
        (items) => items,
      );
    });
