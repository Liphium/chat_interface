import 'package:chat_interface/services/squares/square_shared_space.dart';
import 'package:chat_interface/util/web.dart';
import 'package:signals/signals_flutter.dart';

class SharedSpaceController {
  static final sharedSpaceMap = mapSignal<LPHAddress, Map<String, SharedSpace>>({});

  /// Add or update a shared space to a conversation.
  static void addSharedSpace(LPHAddress convId, SharedSpace space) {
    final map = sharedSpaceMap.peek()[convId] ?? {};
    map[space.id] = space;
    sharedSpaceMap[convId] = map;
  }

  /// Delete a shared space from a conversation.
  static void deleteSharedSpace(LPHAddress convId, String spaceId) {
    final map = sharedSpaceMap.peek()[convId];
    if (map == null) {
      return;
    }

    // Delete and update the map
    map.remove(spaceId);
    sharedSpaceMap[convId] = map;
  }

  static void clearAll() {
    sharedSpaceMap.clear();
  }
}
