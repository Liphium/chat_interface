import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  @override
  Widget build(BuildContext context) {
    FriendController controller = Get.find();

    return ListView.builder(
      itemCount: controller.friends.length,
      itemBuilder: (context, index) {
        Friend friend = controller.friends[index];

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Text("${friend.name}#${friend.tag}"),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
                    onPressed: () {},
                  ),
                ],
              )
            ]
          ),
        );
      },
    );
  }
}