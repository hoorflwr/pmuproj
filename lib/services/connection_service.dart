import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send follow request to mentor
  Future<void> sendFollowRequest({
    required String menteeId,
    required String mentorId,
    required String message,
  }) async {
    try {
      await _firestore.collection('connections').add({
        'menteeId': menteeId,
        'mentorId': mentorId,
        'status': 'pending', // pending, accepted, rejected
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send follow request: $e');
    }
  }

  // Update connection status
  Future<void> updateConnectionStatus({
    required String connectionId,
    required String status,
  }) async {
    try {
      await _firestore.collection('connections').doc(connectionId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update connection status: $e');
    }
  }

  // Get pending requests for mentor
  Stream<QuerySnapshot> getMentorRequests(String mentorId) {
    return _firestore
        .collection('connections')
        .where('mentorId', isEqualTo: mentorId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Get all mentees for a mentor
  Stream<QuerySnapshot> getMentorMentees(String mentorId) {
    return _firestore
        .collection('connections')
        .where('mentorId', isEqualTo: mentorId)
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  // Get all mentors for a mentee
  Stream<QuerySnapshot> getMenteeMentors(String menteeId) {
    return _firestore
        .collection('connections')
        .where('menteeId', isEqualTo: menteeId)
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  // Check if a connection request already exists
  Future<bool> checkExistingRequest(String menteeId, String mentorId) async {
    final QuerySnapshot result = await _firestore
        .collection('connections')
        .where('menteeId', isEqualTo: menteeId)
        .where('mentorId', isEqualTo: mentorId)
        .where('status', whereIn: ['pending', 'accepted'])
        .get();

    return result.docs.isNotEmpty;
  }

  // Check if users are connected
  Future<bool> isConnected(String userId1, String userId2) async {
    try {
      final query = await _firestore
          .collection('connections')
          .where('menteeId', whereIn: [userId1, userId2])
          .where('mentorId', whereIn: [userId1, userId2])
          .where('status', isEqualTo: 'accepted')
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking connection: $e');
      return false;
    }
  }
}
