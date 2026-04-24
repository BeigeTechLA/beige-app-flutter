import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shoot_providers.dart';

enum MyShootsStatus { initial, loading, loaded, error }

class MyShootsState {
  final MyShootsStatus status;
  final List<dynamic> upcomingShoots;
  final List<dynamic> completedShoots;
  final String? errorMessage;

  const MyShootsState({
    this.status = MyShootsStatus.initial,
    this.upcomingShoots = const [],
    this.completedShoots = const [],
    this.errorMessage,
  });

  MyShootsState copyWith({
    MyShootsStatus? status,
    List<dynamic>? upcomingShoots,
    List<dynamic>? completedShoots,
    String? errorMessage,
  }) {
    return MyShootsState(
      status: status ?? this.status,
      upcomingShoots: upcomingShoots ?? this.upcomingShoots,
      completedShoots: completedShoots ?? this.completedShoots,
      errorMessage: errorMessage,
    );
  }
}

class MyShootsNotifier extends AutoDisposeNotifier<MyShootsState> {
  @override
  MyShootsState build() {
    fetchAll();
    return const MyShootsState(status: MyShootsStatus.loading);
  }

  Future<void> fetchAll() async {
    final repo = ref.read(shootRepositoryProvider);

    final results = await Future.wait([
      repo.getMyShoots(status: 'upcoming'),
      repo.getMyShoots(status: 'completed'),
    ]);

    final upcomingResult = results[0];
    final completedResult = results[1];

    List<dynamic> upcoming = state.upcomingShoots;
    List<dynamic> completed = state.completedShoots;
    String? error;

    upcomingResult.fold(
      (e) => error = e.message,
      (data) => upcoming = data,
    );

    completedResult.fold(
      (e) => error ??= e.message,
      (data) => completed = data,
    );

    state = state.copyWith(
      status: error != null ? MyShootsStatus.error : MyShootsStatus.loaded,
      upcomingShoots: upcoming,
      completedShoots: completed,
      errorMessage: error,
    );
  }
}

final myShootsNotifierProvider =
    NotifierProvider.autoDispose<MyShootsNotifier, MyShootsState>(
  MyShootsNotifier.new,
);
