import 'package:connect_hub/Pages/ChatPage.dart';
import 'package:flutter/material.dart';

class ChatListBlock extends StatefulWidget {
  final List peopleList;
  const ChatListBlock({super.key, required this.peopleList});

  @override
  State<ChatListBlock> createState() => _ChatListBlockState();
}

class _ChatListBlockState extends State<ChatListBlock> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.peopleList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.peopleList[index]["isDualChat"]
              ? Container(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            name: widget.peopleList[index]["name"],
                            isDualChat: widget.peopleList[index]["isDualChat"],
                            PhNumber: widget.peopleList[index]["PhNumber"],
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      minTileHeight: 70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // Adjust the radius value here
                      ),
                      tileColor: Theme.of(context).colorScheme.secondary,
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          size: 35,
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        widget.peopleList[index]["name"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        widget.peopleList[index]["PhNumber"],
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            name: widget.peopleList[index]["name"],
                            isDualChat: widget.peopleList[index]["isDualChat"],
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      minTileHeight: 70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // Adjust the radius value here
                      ),
                      tileColor: Theme.of(context).colorScheme.secondary,
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          size: 35,
                          Icons.person,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      title: Text(
                        widget.peopleList[index]["name"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
