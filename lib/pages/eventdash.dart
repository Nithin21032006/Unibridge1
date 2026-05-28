import 'dart:async';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COLOUR PALETTE  (purple dark, matching student dashboard vibe)
// ─────────────────────────────────────────────

const _bg        = Color(0xFF03070F);
const _card      = Color(0xFF080F1E);
const _card2     = Color(0xFF0D1628);
const _border    = Color(0x12789BFF);
const _borderG   = Color(0x2D63A0FF);

const _purple    = Color(0xFF7C3AED);
const _violet    = Color(0xFFA78BFA);
const _pink      = Color(0xFFF472B6);
const _blue      = Color(0xFF4F8FFF);
const _cyan      = Color(0xFF00D4C8);
const _green     = Color(0xFF22D3A5);
const _amber     = Color(0xFFFBBF24);
const _red       = Color(0xFFF87171);

const _text      = Color(0xFFE8F0FF);
const _text2     = Color(0xFF7A9AC5);
const _text3     = Color(0xFF3A5070);

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

enum EventStatus { upcoming, ongoing, completed, cancelled }
enum ClubCategory { tech, cultural, sports, social, arts, dsa }

extension EventStatusExt on EventStatus {
  String get label => name[0].toUpperCase() + name.substring(1);
  Color get color {
    switch (this) {
      case EventStatus.upcoming:  return _blue;
      case EventStatus.ongoing:   return _green;
      case EventStatus.completed: return _text3;
      case EventStatus.cancelled: return _red;
    }
  }
}

extension ClubCategoryExt on ClubCategory {
  String get label {
    if (this == ClubCategory.dsa) return 'DSA';
    return name[0].toUpperCase() + name.substring(1);
  }
  Color get color {
    switch (this) {
      case ClubCategory.tech:     return _violet;
      case ClubCategory.cultural: return _pink;
      case ClubCategory.sports:   return _cyan;
      case ClubCategory.social:   return _green;
      case ClubCategory.arts:     return _amber;
      case ClubCategory.dsa:      return _blue;
    }
  }
}

class ClubHead {
  final String name;
  final String role;
  final String club;
  final ClubCategory category;
  final String email;
  final String avatar; // initials
  ClubHead({required this.name, required this.role, required this.club,
      required this.category, required this.email, required this.avatar});
}

class AppEvent {
  final int id;
  final String title;
  final String club;
  final ClubCategory category;
  final DateTime date;
  final String venue;
  final int registrations;
  final int capacity;
  EventStatus status;
  AppEvent({required this.id, required this.title, required this.club,
      required this.category, required this.date, required this.venue,
      required this.registrations, required this.capacity, required this.status});
}

class Reminder {
  final int id;
  final String text;
  final String date;
  final String time;
  Reminder({required this.id, required this.text, required this.date, required this.time});
}

class AppNotif {
  final String icon;
  final String title;
  final String sub;
  final String time;
  bool unread;
  AppNotif({required this.icon, required this.title, required this.sub,
      required this.time, this.unread = false});
}

// ─────────────────────────────────────────────
// SEED DATA
// ─────────────────────────────────────────────

final _clubHeads = [
  ClubHead(name: 'Aryan Mehta',   role: 'President',   club: 'Coding Club',      category: ClubCategory.tech,     email: 'aryan@college.edu',   avatar: 'AM'),
  ClubHead(name: 'Priya Sharma',  role: 'Head',        club: 'Cultural Society',  category: ClubCategory.cultural, email: 'priya@college.edu',   avatar: 'PS'),
  ClubHead(name: 'Rohan Das',     role: 'Captain',     club: 'Sports Council',    category: ClubCategory.sports,   email: 'rohan@college.edu',   avatar: 'RD'),
  ClubHead(name: 'Sneha Verma',   role: 'Coordinator', club: 'Social Welfare',    category: ClubCategory.social,   email: 'sneha@college.edu',   avatar: 'SV'),
  ClubHead(name: 'Dev Kapoor',    role: 'President',   club: 'Fine Arts Club',    category: ClubCategory.arts,     email: 'dev@college.edu',     avatar: 'DK'),
  ClubHead(name: 'Anika Joshi',   role: 'Lead',        club: 'DSA Cell',          category: ClubCategory.dsa,      email: 'anika@college.edu',   avatar: 'AJ'),
  ClubHead(name: 'Raj Patel',     role: 'Secretary',   club: 'Drama Society',     category: ClubCategory.cultural, email: 'raj@college.edu',     avatar: 'RP'),
  ClubHead(name: 'Meera Nair',    role: 'Head',        club: 'Music Club',        category: ClubCategory.arts,     email: 'meera@college.edu',   avatar: 'MN'),
];

List<AppEvent> _buildEvents() => [
  AppEvent(id:1, title:'Hackathon 2025',         club:'Coding Club',    category:ClubCategory.tech,     date:DateTime(2025,6,18), venue:'CS Block Hall',   registrations:142, capacity:200, status:EventStatus.upcoming),
  AppEvent(id:2, title:'Annual Culturals',        club:'Cultural Society',category:ClubCategory.cultural,date:DateTime(2025,6,22), venue:'Main Auditorium', registrations:310, capacity:400, status:EventStatus.upcoming),
  AppEvent(id:3, title:'Inter-College Sports',    club:'Sports Council', category:ClubCategory.sports,   date:DateTime(2025,6,10), venue:'Ground A',        registrations:88,  capacity:100, status:EventStatus.ongoing),
  AppEvent(id:4, title:'Blood Donation Drive',    club:'Social Welfare', category:ClubCategory.social,   date:DateTime(2025,5,28), venue:'Health Centre',   registrations:55,  capacity:80,  status:EventStatus.completed),
  AppEvent(id:5, title:'Art Exhibition',          club:'Fine Arts Club', category:ClubCategory.arts,     date:DateTime(2025,7,5),  venue:'Gallery Hall',    registrations:72,  capacity:150, status:EventStatus.upcoming),
  AppEvent(id:6, title:'DSA Bootcamp',            club:'DSA Cell',       category:ClubCategory.dsa,      date:DateTime(2025,6,30), venue:'Seminar Hall 1',  registrations:98,  capacity:120, status:EventStatus.upcoming),
  AppEvent(id:7, title:'Street Play Festival',    club:'Drama Society',  category:ClubCategory.cultural, date:DateTime(2025,5,20), venue:'Open Amphitheatre',registrations:180,capacity:250, status:EventStatus.completed),
  AppEvent(id:8, title:'Battle of Bands',         club:'Music Club',     category:ClubCategory.arts,     date:DateTime(2025,7,12), venue:'Auditorium',      registrations:40,  capacity:300, status:EventStatus.upcoming),
];

final _notifications = [
  AppNotif(icon:'🎯', title:'Hackathon registrations open', sub:'142 students registered so far', time:'2h ago', unread:true),
  AppNotif(icon:'⚠️', title:'Sports Day venue changed',      sub:'Shifted to Ground B — update attendees', time:'5h ago', unread:true),
  AppNotif(icon:'✅', title:'Blood Drive completed',          sub:'55 donors — great turnout!', time:'1d ago', unread:false),
  AppNotif(icon:'📢', title:'DSA Bootcamp reminder sent',    sub:'Email blast to 98 registrants', time:'2d ago', unread:false),
];

// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────

void main() => runApp(const EventManagerApp());

class EventManagerApp extends StatelessWidget {
  const EventManagerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'EventHub — Manager Dashboard',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(primary: _purple, secondary: _violet, surface: _card),
    ),
    home: const DashboardPage(),
  );
}

// ─────────────────────────────────────────────
// DASHBOARD PAGE
// ─────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<AppEvent> events = _buildEvents();
  List<Reminder> reminders = [];
  List<AppNotif> notifs = List.from(_notifications);
  int _nextRemId = 1;

  int _navIdx = 0;
  String _bannerText = '🎉 Welcome back! You have 4 upcoming events this month. Keep the energy alive!';
  int _bannerIdx = 0;
  Timer? _bannerTimer;

  final _banners = [
    '🎉 Welcome back! You have 4 upcoming events this month. Keep the energy alive!',
    '📢 Hackathon 2025 registrations are flying — 142 out of 200 spots filled!',
    '✨ Great work on the Blood Donation Drive. 55 donors made a difference!',
    '🎯 DSA Bootcamp kicks off June 30 — confirm the venue and send reminders.',
    '🌟 You manage 8 clubs. Stay organised, stay ahead!',
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      setState(() {
        _bannerIdx = (_bannerIdx + 1) % _banners.length;
        _bannerText = _banners[_bannerIdx];
      });
    });
  }

  @override
  void dispose() { _bannerTimer?.cancel(); super.dispose(); }

  int get unreadCount => notifs.where((n) => n.unread).length;

  void _markAllRead() => setState(() { for (final n in notifs) n.unread = false; });

  void _addReminder(String text, String date, String time) {
    setState(() {
      reminders.add(Reminder(id: _nextRemId++, text: text, date: date, time: time));
    });
  }
  void _deleteReminder(int id) => setState(() => reminders.removeWhere((r) => r.id == id));

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: _card2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _borderG)),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Build ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _buildBanner(),
        _buildTopNav(),
        Expanded(child: _buildBody()),
      ]),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Banner ────────────────────────────────

  Widget _buildBanner() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_bannerText),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            _purple.withOpacity(0.15), _violet.withOpacity(0.1), _pink.withOpacity(0.08)]),
          border: const Border(bottom: BorderSide(color: _border)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: _violet, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Flexible(child: Text(_bannerText,
              style: const TextStyle(color: _violet, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center)),
          const SizedBox(width: 10),
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: _violet, shape: BoxShape.circle)),
        ]),
      ),
    );
  }

  // ── Top Nav ───────────────────────────────

  Widget _buildTopNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(colors: [_purple, _violet, _pink]).createShader(r),
            child: const Text('EventHub', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                color: Colors.white, letterSpacing: -0.5)),
          ),
          const Text('event manager · clubs · organisations',
              style: TextStyle(color: _text3, fontSize: 11, letterSpacing: 0.3)),
        ]),
        const Spacer(),
        _pillBtn('Reminders', Icons.alarm_outlined, onTap: () => _openRemindersSheet()),
        const SizedBox(width: 8),
        _notifBtn(),
        const SizedBox(width: 8),
        _pillBtn('Profile', Icons.person_outline, accent: false, onTap: () => _openProfileSheet()),
      ]),
    );
  }

  Widget _pillBtn(String label, IconData icon, {bool accent = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: accent ? _purple.withOpacity(0.15) : _card2,
          border: Border.all(color: accent ? _purple.withOpacity(0.4) : _border),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: accent ? _violet : _text2),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: accent ? _violet : _text2,
              fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _notifBtn() {
    return GestureDetector(
      onTap: () => _openNotifSheet(),
      child: Stack(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _purple.withOpacity(0.12),
            border: Border.all(color: _purple.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.notifications_outlined, size: 14, color: _violet),
            const SizedBox(width: 5),
            const Text('Alerts', style: TextStyle(color: _violet, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
        if (unreadCount > 0) Positioned(
          right: 0, top: 0,
          child: Container(
            width: 16, height: 16,
            decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
            child: Center(child: Text('$unreadCount',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
          ),
        ),
      ]),
    );
  }

  // ── Body ──────────────────────────────────

  Widget _buildBody() {
    switch (_navIdx) {
      case 0: return _buildOverviewTab();
      case 1: return _buildEventsTab();
      case 2: return _buildClubHeadsTab();
      case 3: return _buildCalendarTab();
      default: return _buildOverviewTab();
    }
  }

  // ── Bottom Nav ────────────────────────────

  Widget _buildBottomNav() {
    final items = [
      (Icons.dashboard_outlined,    Icons.dashboard,    'Overview'),
      (Icons.event_outlined,        Icons.event,        'Events'),
      (Icons.groups_outlined,       Icons.groups,       'Clubs'),
      (Icons.calendar_month_outlined,Icons.calendar_month,'Calendar'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = _navIdx == i;
              return GestureDetector(
                onTap: () => setState(() => _navIdx = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? _purple.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(active ? items[i].$2 : items[i].$1,
                        size: 22, color: active ? _violet : _text3),
                    const SizedBox(height: 3),
                    Text(items[i].$3,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                            color: active ? _violet : _text3)),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // OVERVIEW TAB
  // ═══════════════════════════════════════════

  Widget _buildOverviewTab() {
    final total     = events.length;
    final upcoming  = events.where((e) => e.status == EventStatus.upcoming).length;
    final ongoing   = events.where((e) => e.status == EventStatus.ongoing).length;
    final totalRegs = events.fold(0, (s, e) => s + e.registrations);

    return ListView(padding: const EdgeInsets.all(18), children: [
      // ── Stat cards ──
      Row(children: [
        Expanded(child: _statCard('Total Events', '$total', Icons.event, _violet, '↑ 2 this month')),
        const SizedBox(width: 14),
        Expanded(child: _statCard('Upcoming', '$upcoming', Icons.upcoming, _blue, 'next 30 days')),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _statCard('Ongoing', '$ongoing', Icons.play_circle_outline, _green, 'happening now')),
        const SizedBox(width: 14),
        Expanded(child: _statCard('Registrations', '$totalRegs', Icons.how_to_reg_outlined, _amber, 'across all events')),
      ]),
      const SizedBox(height: 20),

      // ── Registration fill bars ──
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardTitle('Registration Overview', Icons.bar_chart_outlined),
        const SizedBox(height: 14),
        ...events.where((e) => e.status != EventStatus.completed).map((e) {
          final pct = e.registrations / e.capacity;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text(e.title, style: const TextStyle(fontSize: 12, color: _text, fontWeight: FontWeight.w500))),
                Text('${e.registrations}/${e.capacity}', style: const TextStyle(fontSize: 11, color: _text3)),
              ]),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: _card2,
                  valueColor: AlwaysStoppedAnimation(
                    pct > 0.85 ? _red : pct > 0.6 ? _amber : e.category.color),
                ),
              ),
            ]),
          );
        }),
      ])),
      const SizedBox(height: 18),

      // ── Upcoming events quick list ──
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardTitle('Upcoming Events', Icons.calendar_today_outlined),
        const SizedBox(height: 12),
        ...events.where((e) => e.status == EventStatus.upcoming).map((e) => _eventRow(e)),
      ])),
      const SizedBox(height: 18),

      // ── Club heads quick contact ──
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardTitle('Club Heads', Icons.groups_outlined),
        const SizedBox(height: 12),
        ..._clubHeads.take(4).map((h) => _clubHeadRow(h)),
        GestureDetector(
          onTap: () => setState(() => _navIdx = 2),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('View all ${_clubHeads.length} club heads →',
                style: const TextStyle(color: _violet, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ),
      ])),
    ]);
  }

  Widget _statCard(String label, String val, IconData icon, Color c, String sub) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _card, border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38, height: 38, decoration: BoxDecoration(
            color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: c, size: 18),
        ),
        const SizedBox(height: 10),
        Text(val, style: TextStyle(color: c, fontSize: 28, fontWeight: FontWeight.w900,
            letterSpacing: -1, height: 1)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: _text3, fontSize: 12)),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(color: c.withOpacity(0.7), fontSize: 10)),
      ]),
    );
  }

  // ═══════════════════════════════════════════
  // EVENTS TAB
  // ═══════════════════════════════════════════

  Widget _buildEventsTab() {
    return ListView(padding: const EdgeInsets.all(18), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('All Events', style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w700)),
        ElevatedButton.icon(
          onPressed: () => _openAddEventSheet(),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Event', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            elevation: 0,
          ),
        ),
      ]),
      const SizedBox(height: 16),
      ...events.map((e) => _eventCard(e)),
    ]);
  }

  Widget _eventCard(AppEvent e) {
    final pct = e.registrations / e.capacity;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(
              color: e.category.color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(e.title, style: const TextStyle(color: _text,
              fontSize: 14, fontWeight: FontWeight.w600))),
          _statusBadge(e.status),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.groups_outlined, size: 13, color: _text3),
          const SizedBox(width: 4),
          Text(e.club, style: const TextStyle(color: _text2, fontSize: 11)),
          const SizedBox(width: 14),
          const Icon(Icons.calendar_today_outlined, size: 13, color: _text3),
          const SizedBox(width: 4),
          Text(_fmtDate(e.date), style: const TextStyle(color: _text2, fontSize: 11)),
          const SizedBox(width: 14),
          const Icon(Icons.location_on_outlined, size: 13, color: _text3),
          const SizedBox(width: 4),
          Flexible(child: Text(e.venue, style: const TextStyle(color: _text2, fontSize: 11),
              overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${e.registrations} / ${e.capacity} registered',
              style: const TextStyle(color: _text2, fontSize: 11)),
          Text('${(pct * 100).round()}%',
              style: TextStyle(color: pct > 0.85 ? _red : pct > 0.6 ? _amber : _green,
                  fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 5, backgroundColor: _card2,
            valueColor: AlwaysStoppedAnimation(
                pct > 0.85 ? _red : pct > 0.6 ? _amber : e.category.color),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          _miniBtn('Edit', Icons.edit_outlined, _blue, () {}),
          const SizedBox(width: 8),
          _miniBtn('Remind', Icons.notifications_outlined, _violet, () => _showSnack('Reminder sent to all registrants!')),
          const SizedBox(width: 8),
          if (e.status != EventStatus.completed && e.status != EventStatus.cancelled)
            _miniBtn('Mark Done', Icons.check_circle_outline, _green, () {
              setState(() => e.status = EventStatus.completed);
              _showSnack('${e.title} marked as completed!');
            }),
        ]),
      ]),
    );
  }

  Widget _miniBtn(String label, IconData icon, Color c, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1), border: Border.all(color: c.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // CLUB HEADS TAB
  // ═══════════════════════════════════════════

  Widget _buildClubHeadsTab() {
    return ListView(padding: const EdgeInsets.all(18), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Club Heads & Organisers',
            style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w700)),
        Text('${_clubHeads.length} heads', style: const TextStyle(color: _text3, fontSize: 12)),
      ]),
      const SizedBox(height: 16),
      // Category filter chips
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _catChip('All', null),
          ...ClubCategory.values.map((c) => _catChip(c.label, c)),
        ]),
      ),
      const SizedBox(height: 16),
      ..._clubHeads.map((h) => _clubHeadCard(h)),
    ]);
  }

  Widget _catChip(String label, ClubCategory? cat) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: cat != null ? cat.color.withOpacity(0.12) : _purple.withOpacity(0.15),
        border: Border.all(color: cat != null ? cat.color.withOpacity(0.3) : _purple.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(label,
          style: TextStyle(color: cat != null ? cat.color : _violet,
              fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _clubHeadCard(ClubHead h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        // Avatar
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [h.category.color, h.category.color.withOpacity(0.5)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Center(child: Text(h.avatar,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h.name, style: const TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Row(children: [
            Text(h.role, style: const TextStyle(color: _text2, fontSize: 12)),
            const Text(' · ', style: TextStyle(color: _text3)),
            Text(h.club, style: TextStyle(color: h.category.color, fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.mail_outline, size: 12, color: _text3),
            const SizedBox(width: 4),
            Text(h.email, style: const TextStyle(color: _text3, fontSize: 11)),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _catPill(h.category),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showSnack('Email sent to ${h.name}!'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _purple.withOpacity(0.12),
                border: Border.all(color: _purple.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Contact', style: TextStyle(color: _violet, fontSize: 11, fontWeight: FontWeight.w500)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _catPill(ClubCategory c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: c.color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(40),
      border: Border.all(color: c.color.withOpacity(0.3)),
    ),
    child: Text(c.label, style: TextStyle(color: c.color, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  // ═══════════════════════════════════════════
  // CALENDAR TAB
  // ═══════════════════════════════════════════

  Widget _buildCalendarTab() {
    final months = <String, List<AppEvent>>{};
    for (final e in events) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2,'0')}';
      months.putIfAbsent(key, () => []).add(e);
    }
    final sortedKeys = months.keys.toList()..sort();

    return ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Event Calendar', style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      ...sortedKeys.map((k) {
        final evs = months[k]!;
        final parts = k.split('-');
        final monthName = _monthName(int.parse(parts[1]));
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 8),
            child: Row(children: [
              Container(width: 3, height: 16, color: _violet, margin: const EdgeInsets.only(right: 10)),
              Text('$monthName ${parts[0]}', style: const TextStyle(
                  color: _violet, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ]),
          ),
          ...evs.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8, left: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _card, border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: e.category.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text('${e.date.day}',
                    style: TextStyle(color: e.category.color, fontSize: 16, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.title, style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('${e.club} · ${e.venue}', style: const TextStyle(color: _text3, fontSize: 11)),
              ])),
              _statusBadge(e.status),
            ]),
          )),
        ]);
      }),
    ]);
  }

  // ═══════════════════════════════════════════
  // BOTTOM SHEETS
  // ═══════════════════════════════════════════

  void _openNotifSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Alerts', style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w700)),
            TextButton(
              onPressed: () { _markAllRead(); setLocal(() {}); _showSnack('All marked as read'); },
              child: const Text('Mark all read', style: TextStyle(color: _violet, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 10),
          ...notifs.map((n) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _card2,
              border: Border(
                left: BorderSide(color: n.unread ? _blue : Colors.transparent, width: 3),
                top: const BorderSide(color: _border, width: 0.5),
                right: const BorderSide(color: _border, width: 0.5),
                bottom: const BorderSide(color: _border, width: 0.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Text(n.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.title, style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w600)),
                Text(n.sub, style: const TextStyle(color: _text3, fontSize: 10)),
              ])),
              Text(n.time, style: const TextStyle(color: _text3, fontSize: 10)),
            ]),
          )),
        ]),
      )),
    );
  }

  void _openRemindersSheet() {
    final textCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, backgroundColor: _card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Reminders', style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _sheetInput(textCtrl, 'Reminder text…'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _sheetInput(dateCtrl, 'Date (e.g. Jun 18)')),
            const SizedBox(width: 8),
            Expanded(child: _sheetInput(timeCtrl, 'Time (e.g. 10:00 AM)')),
          ]),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (textCtrl.text.trim().isEmpty) return;
                _addReminder(textCtrl.text.trim(), dateCtrl.text, timeCtrl.text);
                setLocal(() {});
                textCtrl.clear(); dateCtrl.clear(); timeCtrl.clear();
                _showSnack('Reminder set!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: _purple, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: const Text('Add Reminder'),
            ),
          ),
          if (reminders.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...reminders.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: _card2, border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.alarm_outlined, size: 14, color: _violet),
                const SizedBox(width: 8),
                Expanded(child: Text(r.text, style: const TextStyle(color: _text, fontSize: 12))),
                if (r.date.isNotEmpty) Text(r.date, style: const TextStyle(color: _text3, fontSize: 10)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () { _deleteReminder(r.id); setLocal(() {}); },
                  child: const Icon(Icons.close, size: 14, color: _text3),
                ),
              ]),
            )),
          ],
        ]),
      )),
    );
  }

  void _openProfileSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(shape: BoxShape.circle,
              gradient: LinearGradient(colors: [_purple, _violet, _pink],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: const Center(child: Text('EM', style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.w700, fontSize: 22))),
          ),
          const SizedBox(height: 12),
          const Text('Event Manager', style: TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w700)),
          const Text('Head Coordinator', style: TextStyle(color: _text3, fontSize: 12)),
          const SizedBox(height: 16),
          _profileRow(Icons.event_outlined, 'Events managed', '${events.length}'),
          _profileRow(Icons.groups_outlined, 'Clubs overseen', '${_clubHeads.length}'),
          _profileRow(Icons.how_to_reg_outlined, 'Total registrations',
              '${events.fold(0,(s,e)=>s+e.registrations)}'),
          _profileRow(Icons.mail_outline, 'Contact', 'manager@college.edu'),
        ]),
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Icon(icon, size: 16, color: _violet),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: _text2, fontSize: 13)),
      const Spacer(),
      Text(val, style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );

  void _openAddEventSheet() {
    final titleCtrl  = TextEditingController();
    final clubCtrl   = TextEditingController();
    final venueCtrl  = TextEditingController();
    final capCtrl    = TextEditingController();
    showModalBottomSheet(
      context: context, backgroundColor: _card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(_).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add New Event', style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _sheetInput(titleCtrl,  'Event title *'),
          const SizedBox(height: 8),
          _sheetInput(clubCtrl,   'Organising club'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _sheetInput(venueCtrl, 'Venue')),
            const SizedBox(width: 8),
            Expanded(child: _sheetInput(capCtrl,  'Capacity', num: true)),
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                setState(() {
                  events.add(AppEvent(
                    id: events.length + 10,
                    title: titleCtrl.text.trim(),
                    club: clubCtrl.text.trim().isEmpty ? 'TBD' : clubCtrl.text.trim(),
                    category: ClubCategory.tech,
                    date: DateTime.now().add(const Duration(days: 14)),
                    venue: venueCtrl.text.trim().isEmpty ? 'TBD' : venueCtrl.text.trim(),
                    registrations: 0,
                    capacity: int.tryParse(capCtrl.text) ?? 100,
                    status: EventStatus.upcoming,
                  ));
                });
                Navigator.pop(_);
                _showSnack('Event "${titleCtrl.text.trim()}" added!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: _purple, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: const Text('Create Event'),
            ),
          ),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: _card, border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(16)),
    child: child,
  );

  Widget _cardTitle(String title, IconData icon) => Row(children: [
    Icon(icon, size: 14, color: _text3),
    const SizedBox(width: 6),
    Text(title.toUpperCase(), style: const TextStyle(color: _text3, fontSize: 10,
        fontWeight: FontWeight.w800, letterSpacing: 0.8)),
  ]);

  Widget _eventRow(AppEvent e) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: _card2, border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(
          color: e.category.color, shape: BoxShape.circle)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(e.title, style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w500)),
        Text('${_fmtDate(e.date)} · ${e.venue}', style: const TextStyle(color: _text3, fontSize: 10)),
      ])),
      _statusBadge(e.status),
    ]),
  );

  Widget _clubHeadRow(ClubHead h) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [h.category.color, h.category.color.withOpacity(0.4)])),
        child: Center(child: Text(h.avatar,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(h.name, style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w500)),
        Text('${h.role} · ${h.club}', style: const TextStyle(color: _text3, fontSize: 10)),
      ])),
      _catPill(h.category),
    ]),
  );

  Widget _statusBadge(EventStatus s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: s.color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(40),
      border: Border.all(color: s.color.withOpacity(0.3)),
    ),
    child: Text(s.label, style: TextStyle(color: s.color, fontSize: 9, fontWeight: FontWeight.w700)),
  );

  Widget _sheetInput(TextEditingController ctrl, String hint, {bool num = false}) => TextField(
    controller: ctrl,
    keyboardType: num ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: _text, fontSize: 13),
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: _text3, fontSize: 13),
      filled: true, fillColor: _card2,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border, width: 0.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border, width: 0.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _purple, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );

  String _fmtDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month-1]} ${d.day}';
  }

  String _monthName(int m) {
    const n = ['','January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    return n[m];
  }
}