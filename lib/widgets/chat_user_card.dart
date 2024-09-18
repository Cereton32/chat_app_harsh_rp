import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_harsh_rp/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import '../model/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;  // Accept ChatUser object
  

  const ChatUserCard({
    Key? key,
    required this.user,
    
  }) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatUser: widget.user)));

        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.user.image ?? '',
                        width: 60, // Ensure the image fits within the CircleAvatar
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person, // Default user icon
                          size: 30,
                          color: Colors.grey,
                        ),
                        placeholder: (context, url) => const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: widget.user.isOnline ?? false ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    Text(
                      widget.user.about ?? 'No message',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Assuming you will add unreadMessages to ChatUser later
                  // if (widget.user.unreadMessages > 0)
                  //   Container(
                  //     padding: const EdgeInsets.all(8),
                  //     decoration: const BoxDecoration(
                  //       color: Colors.blueAccent,
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child: Text(
                  //       widget.user.unreadMessages.toString(),
                  //       style: const TextStyle(
                  //         fontSize: 12,
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
