import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_hub/Call_Func/constants.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallingPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String callId;
  final bool isVideo;

  const CallingPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.callId,
    this.isVideo = true,
  });

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _statusSubscription;
  bool _isDisposed = false;

  String _sanitize(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  @override
  void initState() {
    super.initState();

    final safeCallId = _sanitize(widget.callId);
    if (safeCallId.isNotEmpty) {
      _statusSubscription = FirebaseFirestore.instance
          .collection('Calls')
          .doc(safeCallId)
          .snapshots()
          .listen((snapshot) {
            // Safe-guard checks to make sure widget is still actively on-screen
            if (_isDisposed || !mounted) return;

            if (snapshot.exists) {
              final status = snapshot.data()?['status'] ?? '';

              if (status == 'declined') {
                _statusSubscription?.cancel();
                _cleanUpCallSession();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call declined by user')),
                );
                Navigator.of(context).pop();
              }
            }
          });
    }
  }

  // FIXED: No longer touches, references, or expects UI context targets
  void _cleanUpCallSession() {
    final safeCallId = _sanitize(widget.callId);
    if (safeCallId.isEmpty) return;

    FirebaseFirestore.instance
        .collection('Calls')
        .doc(safeCallId)
        .delete()
        .then((_) {
          debugPrint("Call session cleaned up successfully.");
        })
        .catchError((e) {
          // FIXED: Use localized console debug logs instead of UI Snackbars here
          debugPrint("Silent Error clearing call session: $e");
        });
  }

  @override
  void dispose() {
    _isDisposed = true; // Block incoming async events immediately
    _statusSubscription?.cancel();
    _cleanUpCallSession(); // Safely executes standard database background drop
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeUserId = _sanitize(widget.userId).isNotEmpty
        ? _sanitize(widget.userId)
        : 'user_${DateTime.now().millisecondsSinceEpoch}';
    final safeUserName = widget.userName.trim().isNotEmpty
        ? widget.userName.trim()
        : 'User';
    final safeCallId = _sanitize(widget.callId).isNotEmpty
        ? _sanitize(widget.callId)
        : 'call_${DateTime.now().millisecondsSinceEpoch}';

    final callConfig = widget.isVideo
        ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    return ZegoUIKitPrebuiltCall(
      appID: AppInfo.appId,
      appSign: AppInfo.appSign,
      userID: safeUserId,
      userName: safeUserName,
      callID: safeCallId,
      config: callConfig,
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
          _statusSubscription?.cancel();
          _cleanUpCallSession();
          defaultAction.call();
        },
      ),
    );
  }
}
