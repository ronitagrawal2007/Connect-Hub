import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_hub/Call_Func/calling_page.dart';
import 'package:connect_hub/Data/LocalVariable.dart';
import 'package:connect_hub/Pages/SignUpPage.dart';
import 'package:connect_hub/Widgets/ChatListBlock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _searchedList = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _callSubscription;
  bool _isShowingNotification = false;

  String? _getCurrentPhone() {
    final box = Hive.box('userBox');
    final currentUser = box.get('currentUser');
    if (currentUser is Map) {
      final savedPhone = currentUser['phone'];
      if (savedPhone != null && savedPhone.toString().isNotEmpty) {
        return savedPhone.toString();
      }
    }
    return FirebaseAuth.instance.currentUser?.phoneNumber;
  }

  @override
  void initState() {
    super.initState();
    _applyFilter('');
    _listenForIncomingCalls();
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    super.dispose();
  }

  void _listenForIncomingCalls() {
    final currentPhone = _getCurrentPhone();
    if (currentPhone == null) return;

    _callSubscription = FirebaseFirestore.instance
        .collection('Calls')
        .where('receiverPhone', isEqualTo: currentPhone)
        .where('status', isEqualTo: 'dialing')
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty && mounted && !_isShowingNotification) {
            final callData = snapshot.docs.first.data();
            final callId = snapshot.docs.first.id;

            _showInAppCallNotification(callId, callData);
          }
        });
  }

  void _showInAppCallNotification(
    String callId,
    Map<String, dynamic> callData,
  ) {
    _isShowingNotification = true;
    final currentPhone = _getCurrentPhone() ?? '';

    // CRITICAL FIX: Save a reliable reference to the parent navigator structure
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final bool isVideo = callData['isVideo'] ?? false;
        final String callerName = callData['senderName'] ?? 'Someone';

        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1B22),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(
                        isVideo ? Icons.video_call : Icons.call,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            callerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isVideo
                                ? "Incoming Video Call..."
                                : "Incoming Voice Call...",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // DECLINE BUTTON
                    IconButton(
                      onPressed: () async {
                        // Safely dismiss dialog using the dialog's own separate layout context
                        Navigator.pop(dialogContext);
                        _isShowingNotification = false;

                        await FirebaseFirestore.instance
                            .collection('Calls')
                            .doc(callId)
                            .update({'status': 'declined'});
                      },
                      icon: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 22,
                        child: Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ACCEPT BUTTON
                    IconButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        _isShowingNotification = false;

                        await FirebaseFirestore.instance
                            .collection('Calls')
                            .doc(callId)
                            .update({'status': 'accepted'});

                        // FIXED: Uses pre-saved native root navigator token target
                        rootNavigator.push(
                          MaterialPageRoute(
                            builder: (_) => CallingPage(
                              userId: currentPhone,
                              userName: callerName,
                              callId: callId,
                              isVideo: isVideo,
                            ),
                          ),
                        );
                      },
                      icon: const CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 22,
                        child: Icon(Icons.call, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _applyFilter(String enteredKeyword) {
    final currentPhone = _getCurrentPhone();
    List result = Users.where(
      (user) => user['PhNumber'] != currentPhone,
    ).toList();

    if (enteredKeyword.isNotEmpty) {
      bool isNumeric(String str) {
        return num.tryParse(str) != null;
      }

      if (isNumeric(enteredKeyword)) {
        result = result
            .where(
              (user) => user['PhNumber'].toString().toLowerCase().contains(
                enteredKeyword.toLowerCase(),
              ),
            )
            .toList();
      } else {
        result = result
            .where(
              (user) => user['name'].toString().toLowerCase().contains(
                enteredKeyword.toLowerCase(),
              ),
            )
            .toList();
      }
    }

    setState(() {
      _searchedList = result;
    });
  }

  void _runFilter(String enteredKeyword) {
    _applyFilter(enteredKeyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      onChanged: (value) => _runFilter(value),
                      leading: const Icon(Icons.search),
                      hintText: "Search",
                      overlayColor: WidgetStatePropertyAll(
                        Colors.grey.shade100,
                      ),
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.grey.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to log out of Connect Hub?',
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();

                                if (!context.mounted) return;

                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Icon(
                      size: 35,
                      Icons.logout,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Expanded(child: ChatListBlock(peopleList: _searchedList)),
          ],
        ),
      ),
    );
  }
}
