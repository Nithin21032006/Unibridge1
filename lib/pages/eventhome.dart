import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/task.dart' as task;
import '../pages/inbox.dart' as inbox;

void main() {
  runApp(const UnibridgeApp());
}

class UnibridgeApp extends StatelessWidget {
  const UnibridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unibridge',
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A5F),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E3A5F),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// Models
class EventModel {
  int id;
  String username;
  String caption;
  String dateTime;
  String place;
  String price;
  String regLink;
  String contactInfo;
  String? mediaBase64;
  String? mediaType;
  int likes;
  bool liked;
  bool reminded;
  List<Comment> comments;
  String timestamp;

  EventModel({
    required this.id,
    required this.username,
    required this.caption,
    required this.dateTime,
    required this.place,
    required this.price,
    required this.regLink,
    required this.contactInfo,
    this.mediaBase64,
    this.mediaType,
    this.likes = 0,
    this.liked = false,
    this.reminded = false,
    this.comments = const [],
    this.timestamp = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'caption': caption,
      'dateTime': dateTime,
      'place': place,
      'price': price,
      'regLink': regLink,
      'contactInfo': contactInfo,
      'mediaBase64': mediaBase64,
      'mediaType': mediaType,
      'likes': likes,
      'liked': liked,
      'reminded': reminded,
      'comments': comments.map((c) => c.toJson()).toList(),
      'timestamp': timestamp,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      username: json['username'],
      caption: json['caption'],
      dateTime: json['dateTime'],
      place: json['place'],
      price: json['price'],
      regLink: json['regLink'],
      contactInfo: json['contactInfo'],
      mediaBase64: json['mediaBase64'],
      mediaType: json['mediaType'],
      likes: json['likes'] ?? 0,
      liked: json['liked'] ?? false,
      reminded: json['reminded'] ?? false,
      comments: (json['comments'] as List?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class Comment {
  String user;
  String text;

  Comment({required this.user, required this.text});

  Map<String, dynamic> toJson() {
    return {'user': user, 'text': text};
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(user: json['user'], text: json['text']);
  }
}

class Complaint {
  int id;
  String name;
  String title;
  String description;
  String status;
  String date;

  Complaint({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'status': status,
      'date': date,
    };
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      date: json['date'],
    );
  }
}

class TaskItem {
  int id;
  String text;
  bool completed;
  String date;

  TaskItem({
    required this.id,
    required this.text,
    required this.completed,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'completed': completed,
      'date': date,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'],
      text: json['text'],
      completed: json['completed'],
      date: json['date'],
    );
  }
}

class InboxMessage {
  int id;
  String message;
  String time;

  InboxMessage({
    required this.id,
    required this.message,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'time': time,
    };
  }

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    return InboxMessage(
      id: json['id'],
      message: json['message'],
      time: json['time'],
    );
  }
}

// Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<EventModel> events = [];
  List<Complaint> complaints = [];
  List<TaskItem> tasks = [];
  List<InboxMessage> inboxMessages = [];
  
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await loadEvents();
    await loadComplaints();
    await loadTasks();
    await loadInbox();
    setState(() {});
  }

  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString('unibridge_events');
    
    if (eventsJson != null) {
      final List<dynamic> decoded = json.decode(eventsJson);
      events = decoded.map((e) => EventModel.fromJson(e)).toList();
    } else {
      events = [
        EventModel(
          id: 1001,
          username: "Unibridge Hub",
          caption: "Global Student Summit 2026 — connect with mentors worldwide.",
          dateTime: "June 12-13, 2026 · 10 AM IST",
          place: "Bangalore International Centre + Virtual",
          price: "₹1499 (early bird)",
          regLink: "https://unibridge.global/register",
          contactInfo: "support@unibridge.com | +91 9876543210",
          likes: 124,
          comments: [Comment(user: "sarah_design", text: "Can't wait! 🙌")],
          timestamp: "2 hours ago",
        ),
        EventModel(
          id: 1002,
          username: "Unibridge Fest",
          caption: "Cultural night & networking mixer.",
          dateTime: "May 30, 2026 · 5 PM - 11 PM",
          place: "Juhu Beach, Mumbai",
          price: "₹499 (includes drink)",
          regLink: "https://unibridge.fest/register",
          contactInfo: "hello@unibridge.com | 1800-202-5050",
          likes: 458,
          comments: [Comment(user: "rave_aniket", text: "Lit 🔥")],
          timestamp: "1 day ago",
        ),
      ];
      await saveEvents();
    }
  }

  Future<void> loadComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final String? complaintsJson = prefs.getString('unibridge_complaints');
    if (complaintsJson != null) {
      final List<dynamic> decoded = json.decode(complaintsJson);
      complaints = decoded.map((c) => Complaint.fromJson(c)).toList();
    } else {
      complaints = [];
    }
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('unibridge_tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = json.decode(tasksJson);
      tasks = decoded.map((t) => TaskItem.fromJson(t)).toList();
    } else {
      tasks = [];
    }
  }

  Future<void> loadInbox() async {
    final prefs = await SharedPreferences.getInstance();
    final String? inboxJson = prefs.getString('unibridge_inbox');
    if (inboxJson != null) {
      final List<dynamic> decoded = json.decode(inboxJson);
      inboxMessages = decoded.map((i) => InboxMessage.fromJson(i)).toList();
    } else {
      inboxMessages = [
        InboxMessage(id: 1, message: "Welcome to Unibridge! Your hub for events and tasks.", time: "Just now"),
      ];
      await saveInbox();
    }
  }

  Future<void> saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String eventsJson = json.encode(events.map((e) => e.toJson()).toList());
    await prefs.setString('unibridge_events', eventsJson);
  }

  Future<void> saveComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final String complaintsJson = json.encode(complaints.map((c) => c.toJson()).toList());
    await prefs.setString('unibridge_complaints', complaintsJson);
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = json.encode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('unibridge_tasks', tasksJson);
  }

  Future<void> saveInbox() async {
    final prefs = await SharedPreferences.getInstance();
    final String inboxJson = json.encode(inboxMessages.map((i) => i.toJson()).toList());
    await prefs.setString('unibridge_inbox', inboxJson);
  }

  void addEvent(EventModel event) {
    setState(() {
      events.insert(0, event);
    });
    saveEvents();
  }

  void addComplaint(Complaint complaint) {
    setState(() {
      complaints.insert(0, complaint);
    });
    saveComplaints();
    // Add to inbox
    inboxMessages.insert(0, InboxMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      message: "New report: \"${complaint.title}\" submitted. Status: Pending",
      time: "Just now",
    ));
    saveInbox();
  }

  void addTask(String taskText) {
    final newTask = TaskItem(
      id: DateTime.now().millisecondsSinceEpoch,
      text: taskText,
      completed: false,
      date: DateTime.now().toLocal().toString().split(' ')[0],
    );
    setState(() {
      tasks.insert(0, newTask);
    });
    saveTasks();
  }

  void toggleTask(int taskId) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks[index].completed = !tasks[index].completed;
      }
    });
    saveTasks();
  }

  void deleteTask(int taskId) {
    setState(() {
      tasks.removeWhere((t) => t.id == taskId);
    });
    saveTasks();
  }

  void toggleLike(int eventId) {
    setState(() {
      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index].liked = !events[index].liked;
        events[index].likes += events[index].liked ? 1 : -1;
      }
    });
    saveEvents();
  }

  void toggleRemind(int eventId) {
    setState(() {
      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index].reminded = !events[index].reminded;
      }
    });
    saveEvents();
    final event = events.firstWhere((e) => e.id == eventId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(event.reminded ? "✅ Reminder set!" : "Reminder removed.")),
    );
  }

  void addComment(int eventId, String text) {
    if (text.isEmpty) return;
    setState(() {
      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index].comments.add(Comment(user: "You", text: text));
      }
    });
    saveEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'Unibridge', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
              TextSpan(text: ' · hub', style: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF6C757D), fontSize: 16)),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showCreateEventModal(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            events: events,
            onLike: toggleLike,
            onRemind: toggleRemind,
            onComment: addComment,
          ),
          DashboardScreen(
            events: events,
            complaints: complaints,
            tasks: tasks,
            inboxMessages: inboxMessages,
          ),
          TaskManagerScreen(
            tasks: tasks,
            onAddTask: addTask,
            onToggleTask: toggleTask,
            onDeleteTask: deleteTask,
          ),
          InboxScreen(inboxMessages: inboxMessages),
        ],
      ),
      bottomNavigationBar: InstagramBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              setState(() {
                _selectedIndex = 0;
              });
              break;
            case 1:
              setState(() {
                _selectedIndex = 1;
              });
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const task.TaskManagerPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const inbox.DMScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  void _showCreateEventModal() {
    showDialog(
      context: context,
      builder: (context) => CreateEventDialog(onEventCreated: addEvent),
    );
  }
}

// Instagram-style Bottom Navigation Bar
class InstagramBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const InstagramBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, '🏠', 'Home'),
              _buildNavItem(1, '📊', 'Dashboard'),
              _buildNavItem(2, '📋', 'Tasks'),
              _buildNavItem(3, '📥', 'Inbox'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String icon, String label) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: isSelected ? 1.05 : 1.0),
                duration: const Duration(milliseconds: 200),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Text(
                      icon,
                      style: TextStyle(
                        fontSize: 24,
                        color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey.shade600,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNavItem(int index, String icon, String label) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2B4F8C)]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Screen (Events Feed)
class HomeScreen extends StatelessWidget {
  final List<EventModel> events;
  final Function(int) onLike;
  final Function(int) onRemind;
  final Function(int, String) onComment;

  const HomeScreen({
    super.key,
    required this.events,
    required this.onLike,
    required this.onRemind,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: events.reversed.length,
      itemBuilder: (context, index) {
        final event = events.reversed.toList()[index];
        return EventCard(
          event: event,
          onLike: () => onLike(event.id),
          onRemind: () => onRemind(event.id),
          onComment: (text) => onComment(event.id, text),
        );
      },
    );
  }
}

// Event Card Widget
class EventCard extends StatefulWidget {
  final EventModel event;
  final VoidCallback onLike;
  final VoidCallback onRemind;
  final Function(String) onComment;

  const EventCard({
    super.key,
    required this.event,
    required this.onLike,
    required this.onRemind,
    required this.onComment,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2B4F8C)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('🎪', style: TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.event.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F0F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('📢 Announcement', style: TextStyle(fontSize: 11, color: Color(0xFF1E3A5F))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.event.mediaBase64 != null)
            _buildMedia(widget.event.mediaBase64!, widget.event.mediaType),
          if (widget.event.mediaBase64 == null)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: const Center(
                child: Text('✨ No media', style: TextStyle(color: Color(0xFF6C757D))),
              ),
            ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _infoRow(Icons.calendar_today, 'When:', widget.event.dateTime),
                const SizedBox(height: 12),
                _infoRow(Icons.location_on, 'Where:', widget.event.place),
                const SizedBox(height: 12),
                _infoRow(Icons.attach_money, 'Price:', widget.event.price),
                const SizedBox(height: 12),
                _infoRow(Icons.link, 'Register:', widget.event.regLink, isLink: true),
                const SizedBox(height: 12),
                _infoRow(Icons.phone, 'Contact:', widget.event.contactInfo),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('✨ ${widget.event.caption}', style: const TextStyle(fontSize: 14)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onRemind,
                    icon: Icon(widget.event.reminded ? Icons.check_circle : Icons.notifications_none, size: 18),
                    label: Text(widget.event.reminded ? 'Reminded ✓' : 'Remind me'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: widget.event.reminded ? const Color(0xFF2C5282) : null,
                      foregroundColor: widget.event.reminded ? Colors.white : const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl(widget.event.regLink),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Register'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showContactDialog(widget.event.contactInfo),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Contact'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1E3A5F)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onLike,
                  child: Row(
                    children: [
                      Icon(
                        widget.event.liked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: widget.event.liked ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text('${widget.event.likes} likes'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(Icons.comment, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${widget.event.comments.length} comments'),
                  ],
                ),
                const Spacer(),
                Text(widget.event.timestamp, style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Write a comment...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_commentController.text.isNotEmpty) {
                            widget.onComment(_commentController.text);
                            _commentController.clear();
                          }
                        },
                        child: const Text('Post', style: TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.event.comments.reversed.take(3).map((c) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: '${c.user} ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            TextSpan(text: c.text, style: const TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ),
                    )),
                if (widget.event.comments.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('📌 +${widget.event.comments.length - 3} more',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1E3A5F)),
        const SizedBox(width: 12),
        Expanded(
          child: isLink
              ? GestureDetector(
                  onTap: () => _launchUrl(value),
                  child: Text(value,
                      style: const TextStyle(color: Color(0xFF1E3A5F), decoration: TextDecoration.underline)),
                )
              : RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                      TextSpan(text: value, style: const TextStyle(color: Color(0xFF1F2A3E))),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMedia(String base64, String? mediaType) {
    if (mediaType == 'video') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: const Center(child: Icon(Icons.play_circle_filled, size: 48, color: Colors.white)),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(base64.split(',').last),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      );
    }
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showContactDialog(String contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Information'),
        content: Text(contact),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends StatelessWidget {
  final List<EventModel> events;
  final List<Complaint> complaints;
  final List<TaskItem> tasks;
  final List<InboxMessage> inboxMessages;

  const DashboardScreen({
    super.key,
    required this.events,
    required this.complaints,
    required this.tasks,
    required this.inboxMessages,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(events.length.toString(), 'Total Events', Icons.event),
              _buildStatCard(complaints.length.toString(), 'Reports', Icons.warning),
              _buildStatCard(tasks.length.toString(), 'Tasks', Icons.checklist),
              _buildStatCard(inboxMessages.length.toString(), 'Messages', Icons.inbox),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                  child: const Text('Recent Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                if (complaints.isEmpty && tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('✨ No recent activity'),
                  )
                else
                  Column(
                    children: [
                      ...complaints.take(3).map((c) => ListTile(
                            leading: const Icon(Icons.warning, color: Colors.orange),
                            title: Text(c.title),
                            subtitle: Text(c.status),
                            trailing: Text(c.date.split(' ')[0], style: const TextStyle(fontSize: 11)),
                          )),
                      ...tasks.take(3).map((t) => ListTile(
                            leading: Icon(Icons.check_circle, color: t.completed ? Colors.green : Colors.grey),
                            title: Text(t.text),
                            subtitle: Text(t.completed ? 'Completed' : 'Pending'),
                            trailing: Text(t.date, style: const TextStyle(fontSize: 11)),
                          )),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF1E3A5F)),
          const SizedBox(height: 8),
          Text(number, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
        ],
      ),
    );
  }
}

// Task Manager Screen
class TaskManagerScreen extends StatelessWidget {
  final List<TaskItem> tasks;
  final Function(String) onAddTask;
  final Function(int) onToggleTask;
  final Function(int) onDeleteTask;

  const TaskManagerScreen({
    super.key,
    required this.tasks,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController taskController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅ Task Manager', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: taskController,
                  decoration: InputDecoration(
                    hintText: 'Add a new task...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (taskController.text.isNotEmpty) {
                    onAddTask(taskController.text);
                    taskController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)),
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: tasks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('✨ No tasks yet. Add one above!')),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        leading: Checkbox(
                          value: task.completed,
                          onChanged: (_) => onToggleTask(task.id),
                          activeColor: const Color(0xFF1E3A5F),
                        ),
                        title: Text(
                          task.text,
                          style: TextStyle(
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                            color: task.completed ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Text(task.date, style: const TextStyle(fontSize: 11)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onDeleteTask(task.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Inbox Screen
class InboxScreen extends StatelessWidget {
  final List<InboxMessage> inboxMessages;

  const InboxScreen({super.key, required this.inboxMessages});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📬 Inbox', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: inboxMessages.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('📭 No messages yet.')),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inboxMessages.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final msg = inboxMessages[index];
                      return ListTile(
                        leading: const Icon(Icons.message, color: Color(0xFF1E3A5F)),
                        title: Text(msg.message),
                        subtitle: Text(msg.time, style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Create Event Dialog
class CreateEventDialog extends StatefulWidget {
  final Function(EventModel) onEventCreated;

  const CreateEventDialog({super.key, required this.onEventCreated});

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _usernameController = TextEditingController(text: 'Unibridge');
  final _captionController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _placeController = TextEditingController();
  final _priceController = TextEditingController();
  final _regLinkController = TextEditingController();
  final _contactController = TextEditingController();
  
  String? _mediaBase64;
  String? _mediaType;

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickMedia();
    
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final List<int> bytes = await file.readAsBytes();
      final String base64 = 'data:${pickedFile.mimeType ?? 'image/jpeg'};base64,${base64Encode(bytes)}';
      setState(() {
        _mediaBase64 = base64;
        _mediaType = pickedFile.mimeType?.startsWith('video') == true ? 'video' : 'image';
      });
    }
  }

  void _submit() {
    if (_captionController.text.isEmpty ||
        _dateTimeController.text.isEmpty ||
        _placeController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _regLinkController.text.isEmpty ||
        _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All mandatory fields required!')),
      );
      return;
    }
    
    if (!_regLinkController.text.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration link must start with http:// or https://')),
      );
      return;
    }
    
    final newEvent = EventModel(
      id: DateTime.now().millisecondsSinceEpoch,
      username: _usernameController.text,
      caption: _captionController.text,
      dateTime: _dateTimeController.text,
      place: _placeController.text,
      price: _priceController.text,
      regLink: _regLinkController.text,
      contactInfo: _contactController.text,
      mediaBase64: _mediaBase64,
      mediaType: _mediaType,
      timestamp: 'Just now',
    );
    
    widget.onEventCreated(newEvent);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event created successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📢 Create Event', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Organizer / username *', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))))),
              const SizedBox(height: 12),
              TextField(controller: _captionController, maxLines: 2, decoration: const InputDecoration(labelText: 'Event title / caption *', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: _dateTimeController, decoration: const InputDecoration(labelText: '📅 Date & Time *', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)))))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _placeController, decoration: const InputDecoration(labelText: '📍 Venue / Place *', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)))))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: _priceController, decoration: const InputDecoration(labelText: '💰 Price / Ticket *', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)))))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _regLinkController, decoration: const InputDecoration(labelText: '🔗 Registration Link *', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)))))),
              ]),
              const SizedBox(height: 12),
              TextField(controller: _contactController, decoration: const InputDecoration(labelText: '📞 Contact info *', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))))),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickMedia,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _mediaBase64 != null
                      ? Column(children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(height: 8),
                          Text(_mediaType == 'video' ? 'Video selected' : 'Photo selected'),
                          const Text('Tap to change', style: TextStyle(fontSize: 12)),
                        ])
                      : const Center(child: Column(children: [Icon(Icons.cloud_upload, size: 40), SizedBox(height: 8), Text('Click to upload photo or video')])),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)), child: const Text('📌 Create Event'))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}