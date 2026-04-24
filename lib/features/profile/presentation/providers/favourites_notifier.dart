import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_providers.dart';

enum FavouritesStatus { initial, loading, loaded, error }

class FavouritesState {
  final FavouritesStatus status;
  final List<dynamic> favourites;
  final String? errorMessage;
  final String? toastMessage;

  const FavouritesState({
    this.status = FavouritesStatus.initial,
    this.favourites = const [],
    this.errorMessage,
    this.toastMessage,
  });

  FavouritesState copyWith({
    FavouritesStatus? status,
    List<dynamic>? favourites,
    String? errorMessage,
    String? toastMessage,
  }) {
    return FavouritesState(
      status: status ?? this.status,
      favourites: favourites ?? this.favourites,
      errorMessage: errorMessage ?? this.errorMessage,
      toastMessage: toastMessage,
    );
  }
}

class FavouritesNotifier extends AutoDisposeNotifier<FavouritesState> {
  @override
  FavouritesState build() {
    fetchFavourites();
    return const FavouritesState(status: FavouritesStatus.loading);
  }

  Future<void> fetchFavourites() async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getFavourites();

    result.fold(
      (error) => state = state.copyWith(
        status: FavouritesStatus.error,
        errorMessage: error.message,
      ),
      (favourites) => state = state.copyWith(
        status: FavouritesStatus.loaded,
        favourites: favourites,
      ),
    );
  }

  Future<void> removeFavourite({
    required int creativeId,
    required int index,
  }) async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.removeFavourite(creativeId: creativeId);

    result.fold(
      (error) => state = state.copyWith(
        errorMessage: error.message,
      ),
      (_) {
        final updated = List<dynamic>.from(state.favourites)..removeAt(index);
        state = state.copyWith(
          favourites: updated,
          toastMessage: 'Removed from Favourite',
        );
      },
    );
  }

  void clearToast() {
    state = state.copyWith(toastMessage: null);
  }
}

final favouritesNotifierProvider =
    NotifierProvider.autoDispose<FavouritesNotifier, FavouritesState>(
  FavouritesNotifier.new,
);
