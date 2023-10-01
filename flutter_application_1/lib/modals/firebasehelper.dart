import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/modals/userModals.dart';

class FirebaseHelper {
  static Future<UserModal?> getUserModalById(String uid) async {
    UserModal? userModal;
    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (docSnap.data() != null) {
      userModal = UserModal.fromMap(docSnap.data() as Map<String, dynamic>);
    }
    return userModal;
  }
}
