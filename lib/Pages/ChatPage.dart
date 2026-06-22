import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_hub/Call_Func/calling_page.dart';
import 'package:connect_hub/Data/LocalVariable.dart';
import 'package:connect_hub/Widgets/MessageBlock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String PhNumber;
  final bool isDualChat;

  const ChatPage({
    super.key,
    required this.name,
    this.PhNumber = "",
    required this.isDualChat,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _msgController;
  List<Map<String, dynamic>> messages = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _callSubscription;

  bool _isShowingNotification = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _msgController = TextEditingController();

    _usersSubscription = FirebaseFirestore.instance
        .collection('Users')
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;

          Users = snapshot.docs
              .map((doc) => doc.data()..addAll({'id': doc.id}))
              .toList();

          setState(() {
            Listing();
          });
          _scrollToBottom();
        });

    _listenForIncomingCalls();
    Listing();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _callSubscription?.cancel();
    _scrollController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  void _listenForIncomingCalls() {
    final currentPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
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
    final currentPhone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final bool isVideo = callData['isVideo'] ?? false;
        final String callerName =
            callData['senderName'] ?? 'Someone'; // Shows caller name accurately

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
                    // DECLINE ACTION: Updates status to 'declined' instead of instant deletion
                    IconButton(
                      onPressed: () async {
                        Navigator.pop(context);
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
                    IconButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _isShowingNotification = false;

                        // Set status to accepted so the document tracks structural connection
                        await FirebaseFirestore.instance
                            .collection('Calls')
                            .doc(callId)
                            .update({'status': 'accepted'});

                        if (!mounted) return;

                        Navigator.push(
                          context,
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

  bool _matchesThread(Map<String, dynamic> message) {
    final currentPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (currentPhone == null || widget.PhNumber.isEmpty) return false;

    final senderPhone = (message['senderPhone'] ?? '').toString();
    final receiverPhone = (message['receiverPhone'] ?? '').toString();

    return (senderPhone == currentPhone && receiverPhone == widget.PhNumber) ||
        (senderPhone == widget.PhNumber && receiverPhone == currentPhone);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void Listing() {
    if (widget.PhNumber.isEmpty) return;

    final index = Users.indexWhere(
      (item) => item['PhNumber'] == widget.PhNumber,
    );

    if (index != -1) {
      final rawMessages = Users[index]['messages'];
      if (rawMessages is List) {
        messages = rawMessages
            .map((e) => Map<String, dynamic>.from(e))
            .where((e) => _matchesThread(e))
            .toList();

        messages.sort((a, b) {
          final aTime = (a['timestamp'] ?? '').toString();
          final bTime = (b['timestamp'] ?? '').toString();
          return aTime.compareTo(bTime);
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final currentPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (currentPhone == null || widget.PhNumber.isEmpty) return;

    final senderIndex = Users.indexWhere(
      (item) => item['PhNumber'] == currentPhone,
    );
    final receiverIndex = Users.indexWhere(
      (item) => item['PhNumber'] == widget.PhNumber,
    );

    if (senderIndex == -1 || receiverIndex == -1) return;

    final timestamp = DateTime.now().toIso8601String();
    final payload = {
      'senderPhone': currentPhone,
      'receiverPhone': widget.PhNumber,
      'message': text,
      'timestamp': timestamp,
    };

    setState(() {
      messages.add(payload);
    });
    _msgController.clear();
    _scrollToBottom();

    try {
      final senderDocId = Users[senderIndex]['id'];
      final receiverDocId = Users[receiverIndex]['id'];

      await Future.wait([
        FirebaseFirestore.instance.collection('Users').doc(senderDocId).update({
          'messages': FieldValue.arrayUnion([payload]),
        }),
        FirebaseFirestore.instance
            .collection('Users')
            .doc(receiverDocId)
            .update({
              'messages': FieldValue.arrayUnion([payload]),
            }),
      ]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save message: $e')));
    }
  }

  Future<void> _deleteMessage(int index) async {
    final currentPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (currentPhone == null || widget.PhNumber.isEmpty) return;

    final messageToDelete = Map<String, dynamic>.from(messages[index]);
    final senderIndex = Users.indexWhere(
      (item) => item['PhNumber'] == currentPhone,
    );
    final receiverIndex = Users.indexWhere(
      (item) => item['PhNumber'] == widget.PhNumber,
    );

    if (senderIndex == -1 || receiverIndex == -1) return;

    setState(() {
      messages.removeAt(index);
    });

    try {
      final senderDocId = Users[senderIndex]['id'];
      final receiverDocId = Users[receiverIndex]['id'];

      await Future.wait([
        FirebaseFirestore.instance.collection('Users').doc(senderDocId).update({
          'messages': FieldValue.arrayRemove([messageToDelete]),
        }),
        FirebaseFirestore.instance
            .collection('Users')
            .doc(receiverDocId)
            .update({
              'messages': FieldValue.arrayRemove([messageToDelete]),
            }),
      ]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete message: $e')));
    }
  }

  Future<void> _openCall({required bool isVideo}) async {
    final currentPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (currentPhone == null || widget.PhNumber.isEmpty) return;

    PermissionStatus micStatus = await Permission.microphone.request();
    PermissionStatus cameraStatus = isVideo
        ? await Permission.camera.request()
        : PermissionStatus.granted;

    if (micStatus.isGranted && cameraStatus.isGranted) {
      // Pass the actual current user's name setup securely inside Firebase Profile
      final currentName =
          FirebaseAuth.instance.currentUser?.displayName ?? 'ConnectHub User';

      final cleanSelf = currentPhone.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      final cleanTarget = widget.PhNumber.replaceAll(
        RegExp(r'[^a-zA-Z0-9]'),
        '',
      );
      final callId = 'call_${cleanSelf}_$cleanTarget';

      if (!mounted) return;

      await FirebaseFirestore.instance.collection('Calls').doc(callId).set({
        'senderPhone': currentPhone,
        'senderName':
            currentName, // Saved into doc so receiver sees it on notification
        'receiverPhone': widget.PhNumber,
        'isVideo': isVideo,
        'status': 'dialing',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallingPage(
            userId: currentPhone,
            userName: widget.name,
            callId: callId,
            isVideo: isVideo,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'Camera and Microphone permissions are required to make calls.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isDualChat ? _buildChatLayout(true) : _buildChatLayout(false);
  }

  Widget _buildChatLayout(bool isDual) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      if (isDual)
                        Text(
                          widget.PhNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => _openCall(isVideo: true),
                          icon: const Icon(
                            Icons.video_call,
                            size: 35,
                            color: const Color(0xFF4B2E2B),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openCall(isVideo: false),
                          icon: const Icon(
                            Icons.call,
                            size: 35,
                            color: const Color(0xFF4B2E2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final currentPhone =
                              FirebaseAuth.instance.currentUser?.phoneNumber;
                          final isFromUser =
                              currentPhone != null &&
                              (message['senderPhone'] ?? '') == currentPhone;

                          return Dismissible(
                            key: ValueKey(
                              '${message['timestamp'] ?? ''}_$index',
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deleteMessage(index),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: MessageBlock(
                              fromUser: isFromUser,
                              name: isFromUser
                                  ? 'You'
                                  : (message['name'] ?? widget.name),
                              message: message['message'] ?? '',
                              isDualChat: widget.isDualChat,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextField(
                                controller: _msgController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  hintText: 'Type Here ...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _sendMessage,
                              child: const CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFFC08552),
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
