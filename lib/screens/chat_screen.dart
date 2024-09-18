import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_harsh_rp/api/api.dart';
import 'package:chat_app_harsh_rp/screens/user_deatil.screen.dart';
import 'package:chat_app_harsh_rp/widgets/message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:velocity_x/velocity_x.dart';
import '../model/chat_user.dart';
import '../model/message.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/snackbar.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser chatUser;
  const ChatScreen({super.key, required this.chatUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messageList = [];
  bool _isEmoji = false;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    APis.updateActiveStatus(true); // Set user status to online
    WidgetsBinding.instance.addObserver(this); // Listen to app lifecycle changes
  }

  @override
  void dispose() {
    APis.updateActiveStatus(false); // Set user status to offline
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // When app is resumed, user is online
      APis.updateActiveStatus(true);
    } else if (state == AppLifecycleState.paused) {
      // When app is paused, user is offline
      APis.updateActiveStatus(false);
    }
  }

  void _showToast(String message, {required bool isError}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _pickImagesFromGallery() async {
    final pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        await APis.sendChatImage(widget.chatUser, file);
      }
      _showToast("Images sent successfully!", isError: false);
    } else {
      _showToast("No images selected.", isError: true);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _showToast("Photo taken successfully!", isError: false);
    } else {
      _showToast("No photo taken.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationId = APis.getConversationId(widget.chatUser.id ?? '');

    // Format last seen time
    String getLastSeenText() {
      if (widget.chatUser.isOnline == true) {
        return 'Online';
      } else {
        DateTime lastActive;
        try {
          lastActive = DateTime.parse(widget.chatUser.lastActive ?? DateTime.now().toIso8601String());
        } catch (e) {
          lastActive = DateTime.now();
        }

        DateTime now = DateTime.now();
        Duration difference = now.difference(lastActive);

        if (difference.inDays == 0) {
          return DateFormat('h:mm a').format(lastActive); // Today
        } else if (difference.inDays == 1) {
          return 'Yesterday at ${DateFormat('h:mm a').format(lastActive)}'; // Yesterday
        } else {
          return DateFormat('MMM d, yyyy').format(lastActive) + ' at ${DateFormat('h:mm a').format(lastActive)}'; // Older
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: CachedNetworkImageProvider(widget.chatUser.image ?? ''),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatUser.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  getLastSeenText(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 2,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserDetailsScreen(chatUser: widget.chatUser),
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: APis.getAllMessages(conversationId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    CustomSnackbar.show(context, snapshot.error.toString());
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No messages found'));
                  }

                  final data = snapshot.data?.docs;
                  _messageList = data!.map((e) => Message.fromJson(e.data())).toList();

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _messageList.length,
                    itemBuilder: (context, index) {
                      return MessageCard(message: _messageList[index]);
                    },
                  );
                },
              ),
            ),
            if (_isEmoji)
              SizedBox(
                height: 256,
                child: EmojiPicker(
                  onEmojiSelected: (Category? category, Emoji emoji) {
                    setState(() {
                      _messageController.text += emoji.emoji;
                      _isEmoji = false; // Hide emoji picker after selection
                    });
                  },
                  textEditingController: _messageController,
                  config: Config(
                    height: 256,

                  ),
                ),
              ),
            _chatInputBottom(),
          ],
        ),
      ),
    );
  }

  Widget _chatInputBottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey.shade600, size: 28),
            onPressed: () {
              setState(() {
                _isEmoji = !_isEmoji; // Toggle emoji picker
              });
            },
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      minLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.green),
                    onPressed: () {
                      String messageText = _messageController.text.trim();
                      if (messageText.isNotEmpty) {
                        APis.sendMessage( messageText,widget.chatUser, Type.text);
                        _messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.grey.shade600, size: 28),
            onPressed: _pickImageFromCamera,
          ),
          IconButton(
            icon: Icon(Icons.image, color: Colors.grey.shade600, size: 28),
            onPressed: _pickImagesFromGallery,
          ),
        ],
      ),
    );
  }
}
