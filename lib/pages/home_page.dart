// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages

import 'dart:io';

import 'package:nexus/components/post_field.dart';
import 'package:path/path.dart' as Path;
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus/components/drawer.dart';
import 'package:nexus/components/wall_post.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/admin_chat.dart';
import 'package:nexus/pages/livechat_page.dart';
import 'package:nexus/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();
  Widget _selectedImageWidget = Container();

  bool isAdminState = false;
  String usernameState = "Test";
  String emailState = "Test";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  //sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  // Fetch user data from Firebase
  void fetchUserData() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email",
            isEqualTo: currentUser.email) // Use the current user's email
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // Check if any documents match the query
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      var username = userData['username'];
      var isAdmin = userData['admin'];
      var email = userData['email'];

      setState(() {
        // Update isAdmin and username in the state
        usernameState = username;
        isAdminState = isAdmin;
        emailState = email;
      });
    } else {
      //print("User data not found");
    }
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();

        // Display the selected image
        _selectedImageWidget = Image.file(_photo!);

        // Uncomment the following line to clear the selected image when a new one is selected
        // _photo = null;
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = Path.basename(_photo!.path);
    final destination = 'files/';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('media/$fileName');
      await ref.putFile(_photo!);
    } catch (e) {
      print('Error occurred while uploading file: $e');
      // You can add more specific error handling here.
    }
  }

  // post message
  void postMessage() async {
    // only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      String? fileName;

      if (_photo != null) {
        fileName = Path.basename(_photo!.path);
      }

      // store in firebase
      FirebaseFirestore.instance.collection("Posts").add({
        'UserEmail': emailState,
        'User': usernameState,
        'Message': textController.text,
        'isAdminPost': isAdminState,
        'TimeStamp': Timestamp.now(),
        'MediaDestination': fileName != null ? 'media/$fileName' : null,
        'Likes': [],
      });
      textController.clear();

      // Clear the selected image
      setState(() {
        _selectedImageWidget = Container();
        _photo = null; // Clear the selected photo
      });
    }
  }

  // navigate to profile page
  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(),
      ),
    );
  }

  void goToLiveChatPage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LiveChatPage(),
      ),
    );
  }

  void goToAdminChatPage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminChatPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          "N E X U S",
          selectionColor: Theme.of(context).colorScheme.primary,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        actions: [
          // sign out button
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout),
            color: Theme.of(context).colorScheme.tertiary,
          )
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onLiveChatTap: goToLiveChatPage,
        onAdminChatTap: goToAdminChatPage,
        isAdmin: isAdminState,
        onThemeTap: () {
          AdaptiveTheme.of(context).toggleThemeMode();
          // Wrap in a function
        },
        onSignOut: signOut,
      ),
      body: Center(
        child: Column(
          children: [
            // the wall
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Posts')
                    .orderBy(
                      "TimeStamp",
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get messages
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['Message'],
                          user: post['User'],
                          userEmail: post['UserEmail'],
                          isAdminPost: post['isAdminPost'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
                  );
                },
              ),
            ),

            if (_selectedImageWidget != null)
              _selectedImageWidget = Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    bottomLeft: Radius.circular(2.0),
                    topRight: Radius.circular(25.0),
                    bottomRight: Radius.circular(2.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    bottomLeft: Radius.circular(2.0),
                    topRight: Radius.circular(25.0),
                    bottomRight: Radius.circular(2.0),
                  ),
                  child: _selectedImageWidget,
                ),
              ),

            // post message
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  // textfield
                  Expanded(
                    child: MyPostField(
                      controller: textController,
                      hintText: "Post a message...",
                      obscureText: false,
                      imgFromGallery: imgFromGallery,
                      imgFromCamera: imgFromCamera,
                    ),
                  ),

                  // post button
                  IconButton(
                      onPressed: postMessage,
                      icon: const Icon(Icons.arrow_circle_up))
                ],
              ),
            ),

            // loged in as
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Text("Logged in as : ${currentUser.email!}"),
            ),
          ],
        ),
      ),
    );
  }
}
