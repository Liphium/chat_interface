import 'package:chat_interface/services/squares/square_shared_space.dart';
import 'package:chat_interface/util/web.dart';
import 'package:signals/signals_flutter.dart';

class SharedSpaceController {
  static final sharedSpaceMap = mapSignal<LPHAddress, Map<String, SharedSpace>>({});

  /// Add or update a shared space to a conversation.
  static void addSharedSpace(LPHAddress convId, SharedSpace space) {
    final map = sharedSpaceMap.peek()[convId] ?? {};
    map[space.getKey()] = space;
    sharedSpaceMap[convId] = map;
  }

  /// Delete a shared space from a conversation.
  static void deleteSharedSpace(LPHAddress convId, String spaceId, String underlyingId) {
    final map = sharedSpaceMap.peek()[convId];
    if (map == null) {
      return;
    }

    // Remove the things from the map
    map.remove(SharedSpace.getKeySpace(spaceId));
    map.remove(SharedSpace.getKeyUnderlying(underlyingId));

    // Update the map
    sharedSpaceMap[convId] = map;
  }

  static void clearAll() {
    sharedSpaceMap.clear();
  }
}
