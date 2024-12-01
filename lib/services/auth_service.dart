import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String userType,
    required String bio,
    required List<String> expertise,
    required List<String> goals,
  }) async {
    try {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        await _createUserInFirestore(
          uid: userCredential.user!.uid,
          email: email,
          username: username,
          userType: userType,
          bio: bio,
          expertise: expertise,
          goals: goals,
        );
      }
    } catch (e) {
      print('Error in signUpWithEmailAndPassword: $e');
      rethrow;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserInFirestore({
    required String uid,
    required String email,
    required String username,
    required String userType,
    required String bio,
    required List<String> expertise,
    required List<String> goals,
  }) async {
    try {
      // Convert lists to List<String>
      List<String> expertiseList = expertise.map((e) => e.toString()).toList();
      List<String> goalsList = goals.map((e) => e.toString()).toList();

      // Create the user document
      await _firestore.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'userType': userType,
        'bio': bio,
        'expertise': userType == 'Mentor' ? expertiseList : [],
        'goals': userType == 'Mentee' ? goalsList : [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('User document created successfully in Firestore');
    } catch (e) {
      print('Error creating user document in Firestore: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in signInWithEmailAndPassword: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user type (mentor or mentee)
  Future<String?> getUserType(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['userType'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }

  // Get user type
  Future<String?> getUserType2(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['userType'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    required String username,
    required String bio,
    required List<String> goals,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'username': username,
        'bio': bio,
        'goals': goals,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update mentor profile
  Future<void> updateMentorProfile({
    required String uid,
    required String username,
    required String bio,
    required List<String> expertise,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'username': username,
        'bio': bio,
        'expertise': expertise,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating mentor profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
