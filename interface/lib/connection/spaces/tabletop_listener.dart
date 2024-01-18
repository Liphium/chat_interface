import 'package:chat_interface/connection/spaces/space_connection.dart';

void setupTabletopListeners() {
  spaceConnector.listen("table_obj", (event) {
    print(event.data["obj"]);
  });
}
