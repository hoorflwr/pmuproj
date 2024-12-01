import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class MenteeProfileScreen extends StatefulWidget {
  const MenteeProfileScreen({Key? key}) : super(key: key);

  @override
  _MenteeProfileScreenState createState() => _MenteeProfileScreenState();
}

class _MenteeProfileScreenState extends State<MenteeProfileScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isEditing = false;

  String username = '';
  String email = '';
  String bio = '';
  List<String> goals = [];
  String goalsString = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_auth.currentUser != null) {
      try {
        final userData = await _auth.getUserProfile(_auth.currentUser!.uid);
        if (userData != null) {
          setState(() {
            username = userData['username'] ?? '';
            email = userData['email'] ?? '';
            bio = userData['bio'] ?? '';
            goals = List<String>.from(userData['goals'] ?? []);
            goalsString = goals.join(', ');
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading profile: $e');
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await _auth.updateUserProfile(
          uid: _auth.currentUser!.uid,
          username: username,
          bio: bio,
          goals: goalsString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        );
        setState(() {
          isEditing = false;
          isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _updateProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              if (isEditing) ...[
                TextFormField(
                  initialValue: username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                  onChanged: (val) => setState(() => username = val),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: bio,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (val) => val!.isEmpty ? 'Enter a bio' : null,
                  onChanged: (val) => setState(() => bio = val),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: goalsString,
                  decoration: const InputDecoration(
                    labelText: 'Academic Goals (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (val) => val!.isEmpty ? 'Enter your goals' : null,
                  onChanged: (val) => setState(() => goalsString = val),
                ),
              ] else ...[
                ListTile(
                  title: const Text('Username'),
                  subtitle: Text(username),
                ),
                ListTile(
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
                ListTile(
                  title: const Text('Bio'),
                  subtitle: Text(bio),
                ),
                const ListTile(
                  title: Text('Academic Goals'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: goals.map((goal) => Chip(
                      label: Text(goal),
                      backgroundColor: Colors.blue.shade100,
                    )).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
