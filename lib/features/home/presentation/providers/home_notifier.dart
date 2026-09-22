import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beige/core/providers/guest_mode_provider.dart';
import 'package:beige/features/home/data/models/home_model.dart';
import 'home_providers.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final HomeModel? homeData;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.homeData,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    HomeModel? homeData,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      homeData: homeData ?? this.homeData,
      errorMessage: errorMessage,
    );
  }
}

class HomeNotifier extends AutoDisposeNotifier<HomeState> {
  @override
  HomeState build() {
    final isGuest = ref.read(guestModeProvider);
    if (isGuest) {
      // Guest mode renders static UI only — skip network entirely.
      return const HomeState(status: HomeStatus.loaded);
    }
    fetchHomeData();
    return const HomeState(status: HomeStatus.loading);
  }

  Future<void> fetchHomeData() async {
    final repo = ref.read(homeRepositoryProvider);
    final result = await repo.getHomeData();

    result.fold(
      (error) => state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: error.message,
      ),
      (data) => state = state.copyWith(
        status: HomeStatus.loaded,
        homeData: HomeModel.fromJson(data),
      ),
    );
  }
}

final homeNotifierProvider =
    NotifierProvider.autoDispose<HomeNotifier, HomeState>(HomeNotifier.new);
