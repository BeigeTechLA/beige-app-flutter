import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'creative_providers.dart';

enum CreativeProfileStatus { initial, loading, loaded, error }

class CreativeProfileState {
  final CreativeProfileStatus status;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  const CreativeProfileState({
    this.status = CreativeProfileStatus.initial,
    this.data,
    this.errorMessage,
  });

  CreativeProfileState copyWith({
    CreativeProfileStatus? status,
    Map<String, dynamic>? data,
    String? errorMessage,
  }) {
    return CreativeProfileState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }

  /// Convenience getters for parsed data
  Map<String, dynamic>? get creative => data?['creative'];
  Map<String, dynamic>? get stats => data?['stats'];
  Map<String, dynamic>? get about => data?['about'];
  List get portfolio => (data?['portfolio_preview'] as List?) ?? [];
  List get team => (data?['team_preview'] as List?) ?? [];
  List<String> get weeklyAvailability {
    final raw = data?['weekly_availability'];
    if (raw == null) return [];
    if (raw is String) return List<String>.from(jsonDecode(raw));
    if (raw is List) return List<String>.from(raw);
    return [];
  }
  Map<String, dynamic>? get reviews => data?['reviews'];
}

class CreativeProfileNotifier
    extends AutoDisposeFamilyNotifier<CreativeProfileState, int> {
  @override
  CreativeProfileState build(int creativeId) {
    fetchProfile(creativeId);
    return const CreativeProfileState(status: CreativeProfileStatus.loading);
  }

  Future<void> fetchProfile(int creativeId) async {
    final repo = ref.read(creativeRepositoryProvider);
    final result = await repo.getCreativeProfile(creativeId: creativeId);

    result.fold(
      (error) => state = state.copyWith(
        status: CreativeProfileStatus.error,
        errorMessage: error.message,
      ),
      (data) => state = state.copyWith(
        status: CreativeProfileStatus.loaded,
        data: data,
      ),
    );
  }
}

final creativeProfileNotifierProvider = NotifierProvider.autoDispose
    .family<CreativeProfileNotifier, CreativeProfileState, int>(
  CreativeProfileNotifier.new,
);
