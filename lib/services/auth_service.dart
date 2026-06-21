import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Register ─────────────────────────────────────────────────────────────
  static Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'instagram': '',
      'photoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _saveSession(credential.user!.uid);
    return credential;
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveSession(credential.user!.uid);
    return credential;
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Upload & update profile photo ─────────────────────────────────────────
  static Future<String> uploadProfilePhoto(File imageFile) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception('User tidak ditemukan');

    // Upload ke Firebase Storage: profile_photos/{uid}.jpg
    final ref = _storage.ref().child('profile_photos/$uid.jpg');
    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Simpan URL ke Firestore
    await _firestore.collection('users').doc(uid).update({
      'photoUrl': downloadUrl,
    });

    return downloadUrl;
  }

  // ── Session helpers ───────────────────────────────────────────────────────
  static Future<void> _saveSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setBool('isLoggedIn', true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static User? get currentUser => _auth.currentUser;

  // ── Firestore: favorites ──────────────────────────────────────────────────
  static Future<void> addFavorite(int articleId, String title) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('favorites')
        .doc('${uid}_$articleId')
        .set({'id': articleId, 'title': title, 'uid': uid});
  }

  static Future<void> removeFavorite(int articleId) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('favorites')
        .doc('${uid}_$articleId')
        .delete();
  }

  static Stream<QuerySnapshot> favoritesStream() {
    final uid = currentUser?.uid ?? '';
    return _firestore
        .collection('favorites')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  // ── Firestore: user profile ───────────────────────────────────────────────
  static Stream<DocumentSnapshot> profileStream() {
    final uid = currentUser?.uid ?? '';
    return _firestore.collection('users').doc(uid).snapshots();
  }
}
