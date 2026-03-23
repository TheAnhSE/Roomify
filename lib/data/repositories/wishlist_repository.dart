import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _docRef {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    return _db.collection('users').doc(uid);
  }

  // ── Stream wishlisted hotel IDs (realtime) ─────────────────────────────────
  Stream<Set<String>> watchWishlistedIds() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return <String>{};
      final list = List<String>.from(data['wishlistIds'] ?? []);
      return list.toSet();
    });
  }

  // ── Toggle hotel in wishlist ───────────────────────────────────────────────
  Future<void> toggleWishlist(String hotelId) async {
    final snap = await _docRef.get();
    final data = snap.data() ?? {};
    final current = List<String>.from(data['wishlistIds'] ?? []);

    if (current.contains(hotelId)) {
      current.remove(hotelId);
    } else {
      current.add(hotelId);
    }

    await _docRef.set({'wishlistIds': current}, SetOptions(merge: true));
  }

  // ── Remove hotel from wishlist ─────────────────────────────────────────────
  Future<void> removeFromWishlist(String hotelId) async {
    final snap = await _docRef.get();
    final data = snap.data() ?? {};
    final current = List<String>.from(data['wishlistIds'] ?? []);
    current.remove(hotelId);
    await _docRef.set({'wishlistIds': current}, SetOptions(merge: true));
  }

  // ── Check if hotel is wishlisted ───────────────────────────────────────────
  Future<bool> isWishlisted(String hotelId) async {
    final snap = await _docRef.get();
    final data = snap.data() ?? {};
    final list = List<String>.from(data['wishlistIds'] ?? []);
    return list.contains(hotelId);
  }
}
