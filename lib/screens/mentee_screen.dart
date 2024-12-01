import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pmu_mentor/main.dart';
import 'find_mentors_screen.dart';
import 'connected_mentors_screen.dart';
import 'chat_list_screen.dart';
import 'mentee_profile_screen.dart';

class MenteeScreen extends StatefulWidget {
  const MenteeScreen({Key? key}) : super(key: key);

  @override
  _MenteeScreenState createState() => _MenteeScreenState();
}

class _MenteeScreenState extends State<MenteeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => AuthWrapper(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDashboardCard(
              'Profile',
              'Update your profile information',
              Icons.person,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenteeProfileScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              'Find Mentors',
              'Discover and connect with mentors',
              Icons.search,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FindMentorsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              'My Mentors',
              'View your connected mentors',
              Icons.people,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectedMentorsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              'Messages',
              'Chat with your mentors',
              Icons.chat,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatListScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
