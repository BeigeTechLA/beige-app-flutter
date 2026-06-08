import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/messge_list_model.dart';
import 'messages_providers.dart';

enum RoomsStatus { initial, loading, loaded, error }

class RoomsState {
  final RoomsStatus status;
  final List<MessgeListModel> rooms;  // dynamic → MessgeListModel
  final String? errorMessage;

  const RoomsState({
    this.status = RoomsStatus.initial,
    this.rooms = const [],
    this.errorMessage,
  });

  RoomsState copyWith({
    RoomsStatus? status,
    List<MessgeListModel>? rooms,  // dynamic → MessgeListModel
    String? errorMessage,
  }) {
    return RoomsState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage,
    );
  }
}
class RoomsNotifier extends AutoDisposeNotifier<RoomsState> {

  @override
  RoomsState build() {

    Future.microtask(() => fetchRooms());

    return const RoomsState(
      status: RoomsStatus.loading,
    );
  }

  Future<void> fetchRooms() async {
    state = state.copyWith(
      status: RoomsStatus.loading,
    );

    final repo = ref.read(messagesRepositoryProvider);

    final result = await repo.getRooms();

    result.fold(
          (error) {
        state = state.copyWith(
          status: RoomsStatus.error,
          errorMessage: error.message,
        );
      },
          (rooms) {
        state = state.copyWith(
          status: RoomsStatus.loaded,
          rooms: (rooms as List<dynamic>)
              .map((e) => MessgeListModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      },
    );
  }
}
// ✅ YAHI MISSING THA!
final roomsNotifierProvider  =
NotifierProvider.autoDispose<RoomsNotifier, RoomsState>(
  RoomsNotifier.new,
);