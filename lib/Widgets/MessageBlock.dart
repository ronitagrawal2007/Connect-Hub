import 'package:flutter/material.dart';

class MessageBlock extends StatelessWidget {
  final bool fromUser;
  final String name;
  final String message;
  final bool isDualChat;

  const MessageBlock({
    super.key,
    required this.fromUser,
    required this.name,
    required this.message,
    required this.isDualChat,
  });

  @override
  Widget build(BuildContext context) {
    return isDualChat
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: fromUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fromUser
                          ? Theme.of(context).colorScheme.tertiary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      message,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontSize: 20,
                        color: const Color(0xFFC08552),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: fromUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fromUser
                          ? Theme.of(context).colorScheme.tertiary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(radius: 30),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
