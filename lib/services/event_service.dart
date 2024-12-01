import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new event
  Future<String> createEvent({
    required String mentorId,
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
    required bool isVirtual,
    required int capacity,
    String? meetingLink,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('events').add({
        'mentorId': mentorId,
        'title': title,
        'description': description,
        'dateTime': dateTime,
        'location': location,
        'isVirtual': isVirtual,
        'capacity': capacity,
        'meetingLink': meetingLink,
        'attendees': [],
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'upcoming', // upcoming, ongoing, completed, cancelled
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  // Get events created by a mentor
  Stream<QuerySnapshot> getMentorEvents(String mentorId) {
    return _firestore
        .collection('events')
        .where('mentorId', isEqualTo: mentorId)
        .snapshots();
  }

  // Update event details
  Future<void> updateEvent({
    required String eventId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    bool? isVirtual,
    int? capacity,
    String? meetingLink,
    String? status,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (dateTime != null) updates['dateTime'] = dateTime;
      if (location != null) updates['location'] = location;
      if (isVirtual != null) updates['isVirtual'] = isVirtual;
      if (capacity != null) updates['capacity'] = capacity;
      if (meetingLink != null) updates['meetingLink'] = meetingLink;
      if (status != null) updates['status'] = status;

      await _firestore.collection('events').doc(eventId).update(updates);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Get event details
  Future<DocumentSnapshot> getEventDetails(String eventId) async {
    try {
      return await _firestore.collection('events').doc(eventId).get();
    } catch (e) {
      throw Exception('Failed to get event details: $e');
    }
  }
}
