import 'dart:io';
import 'package:chat_app_harsh_rp/model/chat_user.dart';
import 'package:chat_app_harsh_rp/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class APis {
  static late ChatUser currentUser;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static User? get authUser => auth.currentUser;
  static final FirebaseStorage storage = FirebaseStorage.instance;

  // Check whether the user exists
  static Future<bool> userExists() async {
    if (authUser == null) return false;
    try {
      final userDoc = await firestore.collection('users').doc(authUser!.uid).get();
      return userDoc.exists;
    } catch (e) {
      print("Error checking if user exists: $e");
      return false;
    }
  }

  // Create a new user
  static Future<void> createUser() async {
    if (authUser == null) return;

    final chatUser = ChatUser(
      id: authUser!.uid,
      image: authUser!.photoURL,
      name: authUser!.displayName ?? 'Unknown',
      email: authUser!.email,
      about: 'Hey there! I am using We Chat.',
      createdAt: DateTime.now().toIso8601String(),
      lastActive: DateTime.now().toIso8601String(),
      isOnline: true,
      pushToken: '',
    );

    try {
      await firestore.collection('users').doc(authUser!.uid).set(chatUser.toJson());
    } catch (e) {
      print("Error creating user: $e");
    }
  }

  // Get all users except the current user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    if (authUser == null) return Stream.empty();
    try {
      return firestore.collection('users').where('id', isNotEqualTo: authUser!.uid).snapshots();
    } catch (e) {
      print("Error fetching users: $e");
      return Stream.empty();
    }
  }

  // Get current user's information
  static Future<void> getCurrentUserInfo() async {
    if (authUser == null) return;

    try {
      final userDoc = await firestore.collection('users').doc(authUser!.uid).get();
      if (userDoc.exists) {
        currentUser = ChatUser.fromJson(userDoc.data()!);
        print("Current user info: ${currentUser.toJson()}");
      } else {
        await createUser();
        await getCurrentUserInfo(); // Retry getting user info after creation
      }
    } catch (e) {
      print("Error getting current user info: $e");
    }
  }

  // Update profile picture
  static Future<void> updateProfilePicture(File file) async {
    if (authUser == null) return;

    try {
      final ext = file.path.split('.').last;
      final ref = storage.ref().child('profile_pic/${authUser!.uid}.$ext');

      // Upload the file to Firebase Storage
      await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0) {
        print("Data transferred: ${p0.bytesTransferred / 1000} KB");
      });

      // Get the download URL
      currentUser.image = await ref.getDownloadURL();
      print("Profile picture URL: ${currentUser.image}");

      // Update the user's document in Firestore with the new image URL
      await firestore.collection('users').doc(authUser!.uid).update({
        'image': currentUser.image,
      });

    } catch (e) {
      print("Error updating profile picture: $e");
    }
  }

  // Check connectivity
  static Future<void> checkConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://firestore.googleapis.com'));
      if (response.statusCode == 200) {
        print('Connectivity is working.');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Network request failed: $e');
    }
  }

  // Get all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(String conversationId) {
    try {
      //chats(collection) --> conversationId(doc) --> messages(collection) -->message(doc)
      return firestore.collection('chats/$conversationId/messages/').snapshots().handleError((error) {
        print("Error fetching messages: $error");
      });
    } catch (e) {
      print("Error setting up messages stream: $e");
      return Stream.empty();
    }
  }

  // Get user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser) {
    return firestore.collection('users').where('id', isEqualTo: chatUser.id).snapshots();
  }

  // Update online status and last active time
  static Future<void> updateActiveStatus(bool isOnline) async {
    if (authUser == null) return;
    await firestore.collection('users').doc(authUser!.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().toIso8601String()
    });
  }

  // Generate conversation ID
  static String getConversationId(String Id) => authUser!.uid.hashCode <= Id.hashCode
      ? '${authUser!.uid}_$Id'
      : '${Id}_${authUser!.uid}';

  // Send message
  static Future<void> sendMessage(String msg, ChatUser chatUser, Type type) async {
    final userId = authUser?.uid ?? '';
    final recipientId = chatUser.id ?? '';

    if (userId.isEmpty || recipientId.isEmpty) {
      print("Error: User ID or Recipient ID is empty.");
      return;
    }

    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final Message message = Message(
      toId: recipientId,
      msg: msg,
      read: '',
      type: type,
      sent: time,
      fromId: userId,
    );

    final ref = firestore.collection('chats/${getConversationId(recipientId)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  // Update message read status
  static Future<void> markMessageAsRead(Message message) async {
    if (authUser == null) return;

    try {
      await firestore.collection('chats/${getConversationId(message.fromId)}/messages/')
          .doc(message.sent)
          .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});
    } catch (e) {
      print("Error marking message as read: $e");
    }
  }

  // Send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    if (authUser == null) return;

    try {
      final ext = file.path.split('.').last;
      final ref = storage.ref().child('images/${getConversationId(chatUser.id ?? '')}/${DateTime.now().microsecondsSinceEpoch}.$ext');

      // Upload the file to Firebase Storage
      await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0) {
        print("Data transferred: ${p0.bytesTransferred / 1000} KB");
      });

      // Get the download URL
      final imageUrl = await ref.getDownloadURL();
      sendMessage(imageUrl, chatUser, Type.image);

    } catch (e) {
      print("Error sending chat image: $e");
    }
  }
}
