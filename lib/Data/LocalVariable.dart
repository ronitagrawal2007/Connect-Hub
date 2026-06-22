import 'package:cloud_firestore/cloud_firestore.dart';

List<Map<String, dynamic>> Users = [];

Future<void> addData() async {
  final snapshot = await FirebaseFirestore.instance.collection('Users').get();
  Users = snapshot.docs
      .map((doc) => doc.data()..addAll({'id': doc.id}))
      .toList();
}
