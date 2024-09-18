import 'package:chat_app_harsh_rp/screens/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api.dart';
import '../auth/auth_function.dart';
import '../auth/login_screen.dart';
import '../model/chat_user.dart';
import '../utils/snackbar.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  List<ChatUser> filteredList = [];
  bool _isSearching = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(); // Initialize the controller here
    APis.getCurrentUserInfo();
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredList = list.where((user) {
        final name = user.name?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          shape: const CircleBorder(),
          elevation: 10,
          onPressed: () {
            Authentication().signOut(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        appBar: AppBar(
          leading: const Icon(
            CupertinoIcons.home,
            color: Colors.white,
          ),
          title: _isSearching
              ? TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white54),
            ),
            style: const TextStyle(color: Colors.white),
          )
              : const Text(
            "We Chat",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                  }
                });
              },
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfileScreen()),
                );
              },
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: Scrollbar(
          thickness: 5.0,
          radius: const Radius.circular(10),
          thumbVisibility: true,
          child: StreamBuilder(
            stream: APis.getAllUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                CustomSnackbar.show(context, snapshot.error.toString());
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              final data = snapshot.data?.docs;
              list = data
                  ?.map((elem) => ChatUser.fromJson(elem.data() as Map<String, dynamic>))
                  .toList() ?? [];

              // Apply the filter if the user is searching
              final displayList = _isSearching ? filteredList : list;

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final user = displayList[index];
                  return ChatUserCard(
                    user: user,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
