import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_hub/Pages/HomePage.dart';
import 'package:connect_hub/Widgets/CustomTextFieldAuth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController fullName = TextEditingController();
  TextEditingController phNumber = TextEditingController();
  final TextEditingController otpController =
      TextEditingController(); // Controller for OTP input

  Future<void> _saveCurrentUser(String name, String phone) async {
    final box = Hive.box('userBox');
    await box.put('currentUser', {'name': name, 'phone': phone});
  }

  Future<void> _createUserDocument(String name, String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final usersRef = FirebaseFirestore.instance.collection('Users');
    final existingQuery = await usersRef
        .where('PhNumber', isEqualTo: phone)
        .limit(1)
        .get();

    if (existingQuery.docs.isNotEmpty) {
      final existingDoc = existingQuery.docs.first;
      await existingDoc.reference.update({'name': name, 'uid': user.uid});
      return;
    }

    final userData = {
      'name': name,
      'PhNumber': phone,
      'isDualChat': true,
      'messages': [],
      'uid': user.uid,
    };

    await usersRef.doc(user.uid).set(userData);
  }

  /// Inline OTP verification dialog box
  void _showOtpDialog(BuildContext context, String verificationId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Verify Your Number"),
          content: TextField(
            controller: otpController,
            maxLength: 6,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter 6-digit OTP",
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.surface,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Create a PhoneAuthCredential with the code
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: verificationId,
                    smsCode: otpController.text.trim(),
                  );

                  // Sign the user in with the credential
                  UserCredential userCredential = await FirebaseAuth.instance
                      .signInWithCredential(credential);

                  if (userCredential.user != null) {
                    final name = fullName.text.trim();
                    final phone = "+91${phNumber.text.trim()}";
                    await _saveCurrentUser(name, phone);
                    await _createUserDocument(name, phone);

                    if (!mounted) return;
                    Navigator.pop(context); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Invalid OTP. Error: $e")),
                  );
                }
              },
              child: const Text("Verify & Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Prevents UI crashing when keyboard pushes elements up
            child: Column(
              children: [
                Image.asset(
                  "assets/Connect Hub Logo without BG.png",
                  height: 250,
                  width: 300,
                  fit: BoxFit.cover,
                ),
                CustomTextFieldAuth(
                  textEditingController: fullName,
                  texts: "Full Name",
                  hideText: false,
                ),
                CustomTextFieldAuth(
                  textEditingController: phNumber,
                  texts: "Phone Number",
                  hideText: false,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 10,
                    top: 10,
                  ),
                  child: InkWell(
                    onTap: () async {
                      final name = fullName.text.trim();
                      final phone = phNumber.text.trim();
                      if (name.isNotEmpty && phone.isNotEmpty) {
                        if (phone.length != 10) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a valid 10-digit phone number',
                              ),
                            ),
                          );
                          return;
                        }

                        await FirebaseAuth.instance.verifyPhoneNumber(
                          verificationCompleted:
                              (PhoneAuthCredential credential) async {
                                // Auto-resolution (Android only feature when SMS reads automatically)
                                await FirebaseAuth.instance
                                    .signInWithCredential(credential);
                                final name = fullName.text.trim();
                                final phone = "+91${phNumber.text.trim()}";
                                await _saveCurrentUser(name, phone);
                                await _createUserDocument(name, phone);

                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                  );
                                }
                              },
                          verificationFailed: (FirebaseAuthException ex) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ex.message ?? 'Phone verification failed',
                                ),
                              ),
                            );
                          },
                          codeSent: (String verificationId, int? resendToken) {
                            if (!mounted) return;
                            // Trigger dialog box here on the same page instead of navigating away
                            _showOtpDialog(context, verificationId);
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                          phoneNumber: "+91$phone",
                        );
                      }
                    },
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text("Login", style: TextStyle(fontSize: 30)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
