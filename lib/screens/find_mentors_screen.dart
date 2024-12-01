import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pmu_mentor/screens/chat_screen.dart';
import '../services/connection_service.dart';
import '../services/auth_service.dart';

class FindMentorsScreen extends StatefulWidget {
  const FindMentorsScreen({Key? key}) : super(key: key);

  @override
  _FindMentorsScreenState createState() => _FindMentorsScreenState();
}

class _FindMentorsScreenState extends State<FindMentorsScreen> {
  final ConnectionService _connectionService = ConnectionService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  Map<String, bool> _pendingRequests = {};

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    if (_authService.currentUser == null) return;

    final requests = await _firestore
        .collection('connections')
        .where('menteeId', isEqualTo: _authService.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    setState(() {
      _pendingRequests = {
        for (var doc in requests.docs) doc.get('mentorId') as String: true
      };
    });
  }

  Stream<QuerySnapshot> _getMentors() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'Mentor')
        .snapshots();
  }

  Future<void> _sendFollowRequest(String mentorId, Map<String, dynamic> mentorData) async {
    try {
      // Check if request already exists
      bool exists = await _connectionService.checkExistingRequest(
        _authService.currentUser!.uid,
        mentorId,
      );

      if (exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already sent a request to this mentor'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show dialog to enter message
      final messageController = TextEditingController();
      final message = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Send request to ${mentorData['username']}'),
          content: TextField(
            controller: messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter a message for the mentor...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, messageController.text),
              child: const Text('Send'),
            ),
          ],
        ),
      );

      if (message != null && message.isNotEmpty) {
        await _connectionService.sendFollowRequest(
          menteeId: _authService.currentUser!.uid,
          mentorId: mentorId,
          message: message,
        );

        setState(() {
          _pendingRequests[mentorId] = true;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Follow request sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Mentors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search mentors...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMentors(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mentors = snapshot.data!.docs
                    .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
                    .where((mentor) =>
                        mentor['username'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (mentor['expertise'] as List<dynamic>)
                            .any((exp) => exp.toString().toLowerCase().contains(_searchQuery.toLowerCase())))
                    .toList();

                if (mentors.isEmpty) {
                  return const Center(child: Text('No mentors found'));
                }

                return ListView.builder(
                  itemCount: mentors.length,
                  itemBuilder: (context, index) {
                    final mentor = mentors[index];
                    final expertise = (mentor['expertise'] as List<dynamic>).join(', ');
                    final isPending = _pendingRequests[mentor['id']] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  child: Text(mentor['username'][0].toUpperCase()),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mentor['username'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(mentor['email']),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (isPending)
                                      OutlinedButton(
                                        onPressed: null,
                                        child: const Text('Pending'),
                                      )
                                    else
                                      FutureBuilder<bool>(
                                        future: _connectionService.isConnected(
                                          _authService.currentUser!.uid,
                                          mentor['id'],
                                        ),
                                        builder: (context, snapshot) {
                                          final isConnected = snapshot.data ?? false;
                                          
                                          return Row(
                                            children: [
                                              if (isConnected) ...[
                                                IconButton(
                                                  icon: const Icon(Icons.chat),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ChatScreen(
                                                          otherUser: mentor,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              ElevatedButton(
                                                onPressed: isConnected
                                                    ? null
                                                    : () => _sendFollowRequest(mentor['id'], mentor),
                                                child: Text(isConnected ? 'Connected' : 'Follow'),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            if (mentor['bio'] != null && mentor['bio'].isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                mentor['bio'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              children: (mentor['expertise'] as List<dynamic>)
                                  .map((exp) => Chip(
                                        label: Text(exp.toString()),
                                        backgroundColor: Colors.blue.shade100,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
