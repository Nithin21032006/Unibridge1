import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const UniBridgeApp());
}

// ─────────────────────────────────────────
// COLOUR PALETTE — Purple Theme
// ─────────────────────────────────────────
class AppColors {
  static const bg          = Color(0xFF07030F);
  static const bgCard      = Color(0xFF0F0820);
  static const bgCard2     = Color(0xFF160D2C);
  static const border      = Color(0x1A9D6FFF);
  static const borderGlow  = Color(0x339D6FFF);

  static const purple      = Color(0xFF9D6FFF);
  static const purpleLight = Color(0xFFBB93FF);
  static const purpleDark  = Color(0xFF6C3FD4);
  static const violet      = Color(0xFFD17FFF);
  static const pink        = Color(0xFFF472B6);
  static const green       = Color(0xFF22D3A5);
  static const amber       = Color(0xFFFBBF24);
  static const red         = Color(0xFFF87171);
  static const blue        = Color(0xFF818CF8);

  static const textPrimary = Color(0xFFEDE8FF);
  static const textSec     = Color(0xFF9A82C5);
  static const textMuted   = Color(0xFF4A3570);

  static const gradPurple  = [Color(0xFF9D6FFF), Color(0xFFD17FFF)];
  static const gradViolet  = [Color(0xFFA78BFA), Color(0xFFF472B6)];
  static const gradGreen   = [Color(0xFF22D3A5), Color(0xFF818CF8)];
}

// ─────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser, required this.time});
}

class ReminderItem {
  final int id;
  final String title;
  final String date;
  final String time;
  final String category;
  ReminderItem({required this.id, required this.title, required this.date, required this.time, required this.category});
}

class AttendanceRow {
  final String subject;
  final int attended;
  final int total;
  final String status;
  AttendanceRow({required this.subject, required this.attended, required this.total, required this.status});
  double get pct => attended / total * 100;
}

class ExamRow {
  final String subject;
  final String date;
  final String time;
  final String hall;
  final String status;
  ExamRow({required this.subject, required this.date, required this.time, required this.hall, required this.status});
}

class EventItem {
  final String name;
  final String meta;
  final String badge;
  final Color color;
  EventItem({required this.name, required this.meta, required this.badge, required this.color});
}

// ─────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────
class UniBridgeApp extends StatelessWidget {
  const UniBridgeApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'UniBridge',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'sans-serif',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purple,
        secondary: AppColors.violet,
        surface: AppColors.bgCard,
      ),
    ),
    home: const StudentDashboard(),
  );
}

// ─────────────────────────────────────────
// MAIN DASHBOARD
// ─────────────────────────────────────────
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  int _selectedNav = 0;
  bool _sidebarExpanded = false;
  late AnimationController _sidebarAnim;
  late Animation<double> _sidebarWidth;

  final List<String> _affirmations = [
    '✨ You are doing great — every step forward counts!',
    '💜 Progress, not perfection. You\'re exactly where you need to be.',
    '🌱 Difficult days make you stronger. Believe in yourself!',
    '🎯 Focus on what you can control today. One task at a time.',
    '🧠 Your hard work is building something great. Rest when needed.',
  ];
  int _affIdx = 0;
  Timer? _affTimer;

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.home_rounded,      label: 'Overview',        section: 'main'),
    NavItem(icon: Icons.person_rounded,    label: 'Student Info',    section: 'main'),
    NavItem(icon: Icons.psychology_rounded,label: 'Stress & Wellness',section: 'academics'),
    NavItem(icon: Icons.check_circle_rounded,label: 'Attendance',   section: 'academics'),
    NavItem(icon: Icons.edit_note_rounded, label: 'Exam Schedule',   section: 'academics'),
    NavItem(icon: Icons.calendar_month_rounded,label: 'Timetable',  section: 'academics'),
    NavItem(icon: Icons.celebration_rounded,label: 'Events',        section: 'campus'),
    NavItem(icon: Icons.notifications_rounded,label: 'Notifications',section: 'campus', badge: '4'),
    NavItem(icon: Icons.alarm_rounded,     label: 'Reminders',       section: 'campus'),
    NavItem(icon: Icons.beach_access_rounded,label: 'Leave',        section: 'campus'),
    NavItem(icon: Icons.chat_bubble_rounded,label: 'Chat Serenity', section: 'wellness'),
    NavItem(icon: Icons.account_balance_wallet_rounded,label: 'Fees',section: 'wellness'),
  ];

  @override
  void initState() {
    super.initState();
    _sidebarAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _sidebarWidth = Tween<double>(begin: 64, end: 208).animate(
      CurvedAnimation(parent: _sidebarAnim, curve: Curves.easeInOut));
    _affTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      setState(() => _affIdx = (_affIdx + 1) % _affirmations.length);
    });
  }

  @override
  void dispose() {
    _sidebarAnim.dispose();
    _affTimer?.cancel();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
    _sidebarExpanded ? _sidebarAnim.forward() : _sidebarAnim.reverse();
  }

  Widget _buildPage() {
    switch (_selectedNav) {
      case 0: return const OverviewPage();
      case 1: return const StudentInfoPage();
      case 2: return const StressWellnessPage();
      case 3: return const AttendancePage();
      case 4: return const ExamPage();
      case 5: return const TimetablePage();
      case 6: return const EventsPage();
      case 7: return const NotificationsPage();
      case 8: return const RemindersPage();
      case 9: return const LeavePage();
      case 10: return const ChatPage();
      case 11: return const FeesPage();
      default: return const OverviewPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background glow
          Positioned.fill(child: CustomPaint(painter: _BgGlowPainter())),

          Column(children: [
            // Affirmation bar
            _AffirmationBar(text: _affirmations[_affIdx]),

            Expanded(child: Row(children: [
              // Sidebar
              AnimatedBuilder(
                animation: _sidebarWidth,
                builder: (ctx, _) => _Sidebar(
                  width: _sidebarWidth.value,
                  expanded: _sidebarExpanded,
                  navItems: _navItems,
                  selectedIndex: _selectedNav,
                  onItemTap: (i) => setState(() => _selectedNav = i),
                  onToggle: _toggleSidebar,
                ),
              ),

              // Main content
              Expanded(child: _buildPage()),
            ])),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BG GLOW PAINTER
// ─────────────────────────────────────────
class _BgGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..shader = RadialGradient(
      colors: [AppColors.purple.withOpacity(0.07), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.1, size.height * 0.2), radius: 400));
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 400, p1);

    final p2 = Paint()..shader = RadialGradient(
      colors: [AppColors.violet.withOpacity(0.05), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.9, size.height * 0.8), radius: 350));
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 350, p2);
  }
  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────
// AFFIRMATION BAR
// ─────────────────────────────────────────
class _AffirmationBar extends StatelessWidget {
  final String text;
  const _AffirmationBar({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
        AppColors.purple.withOpacity(0.15),
        AppColors.violet.withOpacity(0.1),
        AppColors.pink.withOpacity(0.08),
      ]),
      border: Border(bottom: BorderSide(color: AppColors.purple.withOpacity(0.2))),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _PulseDot(), const SizedBox(width: 10),
      Flexible(child: Text(text,
        style: const TextStyle(color: AppColors.purpleLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
      const SizedBox(width: 10), _PulseDot(),
    ]),
  );
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}
class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _a = Tween<double>(begin: 0.4, end: 1.0).animate(_c);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.purple, shape: BoxShape.circle)),
  );
}

// ─────────────────────────────────────────
// NAV ITEM MODEL
// ─────────────────────────────────────────
class NavItem {
  final IconData icon;
  final String label;
  final String section;
  final String? badge;
  NavItem({required this.icon, required this.label, required this.section, this.badge});
}

// ─────────────────────────────────────────
// SIDEBAR
// ─────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final double width;
  final bool expanded;
  final List<NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  final VoidCallback onToggle;

  const _Sidebar({
    required this.width, required this.expanded,
    required this.navItems, required this.selectedIndex,
    required this.onItemTap, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final sections = ['main', 'academics', 'campus', 'wellness'];
    final sectionLabels = {'main': 'Main', 'academics': 'Academics', 'campus': 'Campus', 'wellness': 'Wellness'};

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(children: [
        // Brand
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(colors: AppColors.gradPurple).createShader(b),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
              ),
              if (expanded) ...[
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(colors: AppColors.gradPurple).createShader(b),
                    child: const Text('UniBridge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                  const Text('student portal', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                ])),
              ],
            ]),
          ),
        ),

        // Nav items grouped by section
        Expanded(child: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections.expand((sec) {
            final items = navItems.where((n) => n.section == sec).toList();
            return [
              if (expanded) Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Text(sectionLabels[sec]!.toUpperCase(),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ) else const SizedBox(height: 8),
              ...items.map((item) {
                final idx = navItems.indexOf(item);
                final isActive = selectedIndex == idx;
                return _NavTile(item: item, isActive: isActive, expanded: expanded, onTap: () => onItemTap(idx));
              }),
              if (!expanded) const SizedBox(height: 4),
            ];
          }).toList(),
        ))),
      ]),
    );
  }
}

class _NavTile extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final bool expanded;
  final VoidCallback onTap;
  const _NavTile({required this.item, required this.isActive, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 0, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.purple.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(
          color: isActive ? AppColors.purple : Colors.transparent,
          width: 2,
        )),
      ),
      child: Row(mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center, children: [
        Stack(children: [
          Icon(item.icon, size: 20,
            color: isActive ? AppColors.purple : AppColors.textMuted),
          if (item.badge != null) Positioned(
            top: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
              child: Text(item.badge!, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
            ),
          ),
        ]),
        if (expanded) ...[
          const SizedBox(width: 10),
          Expanded(child: Text(item.label,
            style: TextStyle(color: isActive ? AppColors.purpleLight : AppColors.textSec,
              fontSize: 12, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis)),
        ],
      ]),
    ),
  );
}

// ─────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const AppCard({super.key, required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

class CardTitle extends StatelessWidget {
  final String title;
  const CardTitle(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(title, style: const TextStyle(
      color: AppColors.textMuted, fontSize: 10,
      fontWeight: FontWeight.w900, letterSpacing: 1.0)),
  );
}

class GradientBadge extends StatelessWidget {
  final String text;
  final Color color;
  const GradientBadge(this.text, {super.key, this.color = AppColors.purple});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
  );
}

class GradButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final List<Color> colors;
  const GradButton({super.key, required this.label, required this.onTap, this.colors = AppColors.gradPurple});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
    ),
  );
}

Widget pageHeader(String title, {Widget? action}) => Padding(
  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
  child: Row(children: [
    ShaderMask(
      shaderCallback: (b) => const LinearGradient(colors: AppColors.gradPurple).createShader(b),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
    ),
    const Spacer(),
    if (action != null) action,
  ]),
);

// ─────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String delta;
  final Color color;
  final bool deltaUp;
  const StatCard({super.key, required this.icon, required this.value, required this.label, required this.delta, required this.color, this.deltaUp = true});

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40, height: 40, decoration: BoxDecoration(
          color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 10),
      Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w900, height: 1)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      const SizedBox(height: 4),
      Text(delta, style: TextStyle(color: deltaUp ? AppColors.green : AppColors.red, fontSize: 10)),
    ]),
  );
}

// ─────────────────────────────────────────
// STRESS GAUGE PAINTER
// ─────────────────────────────────────────
class StressGaugePainter extends CustomPainter {
  final double value; // 0–100
  StressGaugePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = pi * 0.8;
    const sweepAngle = pi * 1.4;
    final center = Offset(size.width / 2, size.height * 0.85);
    const radius = 80.0;

    // Track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = AppColors.border;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, trackPaint);

    // Fill
    final shader = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [AppColors.green, AppColors.amber, AppColors.red],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = shader;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle * (value / 100), false, fillPaint);
  }

  @override
  bool shouldRepaint(StressGaugePainter old) => old.value != value;
}

// ─────────────────────────────────────────
// OVERVIEW PAGE
// ─────────────────────────────────────────
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top bar
        Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(colors: AppColors.gradPurple).createShader(b),
                child: const Text('UniBridge', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              ),
              const Text('student wellness · academics · balance',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ]),
            const Spacer(),
            _StressPill(value: 62, label: 'Moderate Stress'),
          ]),
        ),

        // Stat cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: StatCard(icon: Icons.book_rounded, value: '78%', label: 'Attendance Rate', delta: '↑ 3% from last month', color: AppColors.purple)),
            const SizedBox(width: 12),
            Expanded(child: StatCard(icon: Icons.emoji_events_rounded, value: '7.4', label: 'Avg Exam Score', delta: '↑ 0.6 from last sem', color: AppColors.green)),
            const SizedBox(width: 12),
            Expanded(child: StatCard(icon: Icons.account_balance_wallet_rounded, value: '₹12k', label: 'Fees Due', delta: 'Due: 30 Jun 2025', color: AppColors.amber, deltaUp: false)),
          ]),
        ),

        const SizedBox(height: 16),

        // Stress + Events row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Stress card
            SizedBox(width: 220, child: AppCard(child: Column(children: [
              const CardTitle('🧠  STRESS INDEX'),
              SizedBox(
                height: 130,
                child: Stack(alignment: Alignment.center, children: [
                  CustomPaint(size: const Size(180, 130), painter: StressGaugePainter(62)),
                  Positioned(bottom: 8, child: Column(children: [
                    const Text('62', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w900)),
                    const Text('Moderate — manageable', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                  ])),
                ]),
              ),
              const SizedBox(height: 12),
              _StressBar(label: 'Academic', value: 0.72, color: AppColors.amber),
              _StressBar(label: 'Social',   value: 0.45, color: AppColors.green),
              _StressBar(label: 'Sleep',    value: 0.58, color: AppColors.purple),
              _StressBar(label: 'Finance',  value: 0.35, color: AppColors.green),
            ]))),
            const SizedBox(width: 14),

            // Trend chart placeholder
            Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CardTitle('📈  STRESS & WELLNESS TREND'),
              SizedBox(height: 150, child: CustomPaint(size: const Size(double.infinity, 150), painter: _TrendPainter())),
            ]))),
            const SizedBox(width: 14),

            // Events
            SizedBox(width: 240, child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CardTitle('🗓️  REGISTERED EVENTS'),
              _EventTile(name: 'Hackathon 2025', meta: 'May 18 · CS Block Hall', badge: 'Tech', color: AppColors.violet),
              _EventTile(name: 'Annual Sports Day', meta: 'May 22 · Ground A', badge: 'Sports', color: AppColors.purple),
              _EventTile(name: 'Career Fair', meta: 'Jun 1 · Main Auditorium', badge: 'Career', color: AppColors.green),
              _EventTile(name: 'Alumni Talk', meta: 'Jun 5 · Seminar Hall 2', badge: 'Talk', color: AppColors.amber),
            ]))),
          ]),
        ),

        const SizedBox(height: 16),

        // Attendance + Exams
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CardTitle('📋  ATTENDANCE SUMMARY'),
              _AttendanceTable(),
            ]))),
            const SizedBox(width: 14),
            Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CardTitle('📝  EXAM SCHEDULE'),
              _ExamTable(),
            ]))),
          ]),
        ),
      ]),
    );
  }
}

class _StressPill extends StatelessWidget {
  final int value;
  final String label;
  const _StressPill({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    final c = value < 40 ? AppColors.green : value < 70 ? AppColors.amber : AppColors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(width: 5),
        Text('$value', style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

class _StressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _StressBar({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 58, child: Text(label, style: const TextStyle(color: AppColors.textSec, fontSize: 10))),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value, minHeight: 5,
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      )),
      const SizedBox(width: 6),
      Text('${(value * 100).toInt()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
    ]),
  );
}

class _EventTile extends StatelessWidget {
  final String name, meta, badge;
  final Color color;
  const _EventTile({required this.name, required this.meta, required this.badge, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
        Text(meta, style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
      ])),
      GradientBadge(badge, color: color),
    ]),
  );
}

class _TrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pts = [0.55, 0.68, 0.72, 0.65, 0.60, 0.58, 0.62];
    final w = size.width / (pts.length - 1);
    final paint = Paint()..color = AppColors.purple..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final fillPaint = Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [AppColors.purple.withOpacity(0.3), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = i * w;
      final y = size.height - pts[i] * size.height * 0.85 - 10;
      if (i == 0) { path.moveTo(x, y); fillPath.moveTo(x, y); }
      else {
        final px = (i - 1) * w;
        final py = size.height - pts[i-1] * size.height * 0.85 - 10;
        path.cubicTo(px + w/2, py, x - w/2, y, x, y);
        fillPath.cubicTo(px + w/2, py, x - w/2, y, x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Dots
    final dotPaint = Paint()..color = AppColors.purple..style = PaintingStyle.fill;
    for (int i = 0; i < pts.length; i++) {
      final x = i * w;
      final y = size.height - pts[i] * size.height * 0.85 - 10;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _AttendanceTable extends StatelessWidget {
  final _rows = const [
    ('DBMS', '22/28', '78.6%', 'Below 80', AppColors.amber),
    ('OS', '25/28', '89.3%', 'Safe', AppColors.green),
    ('Comp. Networks', '20/26', '76.9%', 'Critical', AppColors.red),
    ('Machine Learning', '24/27', '88.9%', 'Safe', AppColors.green),
    ('Elective (IoT)', '14/15', '93.3%', 'Excellent', AppColors.green),
  ];
  const _AttendanceTable();
  @override
  Widget build(BuildContext context) => Column(children: [
    _TblHeader(cols: ['Subject', 'Attended', '%', 'Status']),
    ..._rows.map((r) => _TblRow(cells: [r.$1, r.$2, r.$3], badge: r.$4, badgeColor: r.$5)),
  ]);
}

class _ExamTable extends StatelessWidget {
  final _rows = const [
    ('DBMS', 'May 20', '9:00 AM', 'EH-1', 'Upcoming', AppColors.amber),
    ('OS', 'May 23', '2:00 PM', 'EH-2', 'Upcoming', AppColors.amber),
    ('CN', 'May 27', '9:00 AM', 'EH-1', 'Upcoming', AppColors.amber),
    ('ML', 'Jun 2', '11:00 AM', 'EH-3', 'Scheduled', AppColors.purple),
    ('Elective', 'Jun 5', '2:00 PM', 'EH-2', 'Scheduled', AppColors.purple),
  ];
  const _ExamTable();
  @override
  Widget build(BuildContext context) => Column(children: [
    _TblHeader(cols: ['Subject', 'Date', 'Time', 'Hall', 'Status']),
    ..._rows.map((r) => _TblRow(cells: [r.$1, r.$2, r.$3, r.$4], badge: r.$5, badgeColor: r.$6)),
  ]);
}

class _TblHeader extends StatelessWidget {
  final List<String> cols;
  const _TblHeader({required this.cols});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: cols.map((c) => Expanded(
      child: Text(c.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    )).toList()),
  );
}

class _TblRow extends StatelessWidget {
  final List<String> cells;
  final String badge;
  final Color badgeColor;
  const _TblRow({required this.cells, required this.badge, required this.badgeColor});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
    child: Row(children: [
      ...cells.map((c) => Expanded(child: Text(c, style: const TextStyle(color: AppColors.textPrimary, fontSize: 10)))),
      GradientBadge(badge, color: badgeColor),
    ]),
  );
}

// ─────────────────────────────────────────
// STRESS & WELLNESS PAGE
// ─────────────────────────────────────────
class StressWellnessPage extends StatelessWidget {
  const StressWellnessPage({super.key});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(children: [
      pageHeader('🧠  Stress & Wellness'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 240, child: AppCard(child: Column(children: [
            const CardTitle('🎯  STRESS INDEX'),
            SizedBox(height: 140, child: Stack(alignment: Alignment.center, children: [
              CustomPaint(size: const Size(200, 140), painter: StressGaugePainter(62)),
              Positioned(bottom: 6, child: Column(children: [
                const Text('62', style: TextStyle(color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w900)),
                const Text('Moderate — manageable', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
              ])),
            ])),
            const SizedBox(height: 14),
            _StressBar(label: 'Academic', value: 0.72, color: AppColors.amber),
            _StressBar(label: 'Social',   value: 0.45, color: AppColors.green),
            _StressBar(label: 'Sleep',    value: 0.58, color: AppColors.purple),
            _StressBar(label: 'Finance',  value: 0.35, color: AppColors.green),
          ]))),
          const SizedBox(width: 14),
          Expanded(child: Column(children: [
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CardTitle('💡  WELLNESS TIPS'),
              ...['🌬️ Try 4-7-8 breathing before exams to calm nerves.',
                  '🚶 A 10-min walk between classes improves focus by 20%.',
                  '💧 Drink water before each study session.',
                  '📵 Phone-free 30 min before bed for better sleep.',
                  '🧘 5 min gratitude journaling before sleep.']
                .map((t) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(t, style: const TextStyle(color: AppColors.textSec, fontSize: 11, height: 1.5)),
                )),
            ])),
            const SizedBox(height: 14),
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CardTitle('📊  WELLNESS METRICS'),
              Row(children: [
                Expanded(child: _MetricBox(label: 'Wellness Score', value: '76', color: AppColors.purple)),
                const SizedBox(width: 10),
                Expanded(child: _MetricBox(label: 'Focus Score', value: '68%', color: AppColors.amber)),
                const SizedBox(width: 10),
                Expanded(child: _MetricBox(label: 'Sleep Avg', value: '6.8h', color: AppColors.green)),
              ]),
            ])),
          ])),
        ]),
      ),
    ]),
  );
}

class _MetricBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MetricBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.bgCard2, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 9), textAlign: TextAlign.center),
    ]),
  );
}

// ─────────────────────────────────────────
// ATTENDANCE PAGE
// ─────────────────────────────────────────
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  static const _data = [
    ('DBMS', 22, 28, AppColors.amber),
    ('OS', 25, 28, AppColors.green),
    ('Comp. Networks', 20, 26, AppColors.red),
    ('Machine Learning', 24, 27, AppColors.green),
    ('Elective (IoT)', 14, 15, AppColors.green),
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageHeader('✅  Attendance'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle('📊  SUBJECT-WISE ATTENDANCE'),
          ..._data.map((d) {
            final pct = d.$2 / d.$3;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(d.$1, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700))),
                  Text('${d.$2}/${d.$3}', style: const TextStyle(color: AppColors.textSec, fontSize: 11)),
                  const SizedBox(width: 8),
                  Text('${(pct * 100).toStringAsFixed(1)}%', style: TextStyle(color: d.$4, fontSize: 11, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct, minHeight: 7,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(d.$4),
                  ),
                ),
              ]),
            );
          }),
        ])),
      ),
    ]),
  );
}

// ─────────────────────────────────────────
// EXAM PAGE
// ─────────────────────────────────────────
class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  static const _exams = [
    ('DBMS (Theory)', 'May 20', '9:00 AM', 'EH-1', 'Upcoming'),
    ('OS (Theory)', 'May 23', '2:00 PM', 'EH-2', 'Upcoming'),
    ('CN (Theory)', 'May 27', '9:00 AM', 'EH-1', 'Upcoming'),
    ('ML (Theory)', 'Jun 2', '11:00 AM', 'EH-3', 'Scheduled'),
    ('Elective (IoT)', 'Jun 5', '2:00 PM', 'EH-2', 'Scheduled'),
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageHeader('📝  Exam Schedule'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle('📅  UPCOMING EXAMS'),
          _TblHeader(cols: ['Subject', 'Date', 'Time', 'Hall', 'Status']),
          ..._exams.map((e) {
            final c = e.$5 == 'Upcoming' ? AppColors.amber : AppColors.purple;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(children: [
                Expanded(child: Text(e.$1, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11))),
                Expanded(child: Text(e.$2, style: const TextStyle(color: AppColors.textSec, fontSize: 11))),
                Expanded(child: Text(e.$3, style: const TextStyle(color: AppColors.textSec, fontSize: 11))),
                Expanded(child: Text(e.$4, style: const TextStyle(color: AppColors.textSec, fontSize: 11))),
                GradientBadge(e.$5, color: c),
              ]),
            );
          }),
        ])),
      ),
    ]),
  );
}

// ─────────────────────────────────────────
// TIMETABLE PAGE
// ─────────────────────────────────────────
class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI'];
  static const _times = ['9–10', '10–11', '11–12', '12–1', '2–3', '3–4'];

  static const _schedule = [
    ['DBMS\nCS101', '', 'DBMS\nCS101', '', 'OS\nCS202'],
    ['OS\nCS202', 'CN\nLH3', '', 'ML\nCS303', ''],
    ['BREAK', 'BREAK', 'BREAK', 'BREAK', 'BREAK'],
    ['', 'LAB:DBMS\nLab 1', 'CN\nLH3', '', 'LAB:OS\nLab 2'],
    ['ML\nCS303', '', 'Elective\nCS104', 'CN\nLH3', ''],
    ['', 'Elective\nCS104', 'LAB:ML\nLab 3', '', 'DBMS\nCS101'],
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageHeader('📅  Timetable'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppCard(padding: const EdgeInsets.all(14), child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header row
            Row(children: [
              const SizedBox(width: 48),
              ..._days.map((d) => SizedBox(width: 88, child: Center(
                child: Text(d, style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
              ))),
            ]),
            const SizedBox(height: 6),
            ..._schedule.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                SizedBox(width: 48, child: Text(_times[entry.key],
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 9), textAlign: TextAlign.right)),
                const SizedBox(width: 4),
                ...entry.value.map((cell) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _TtCell(content: cell),
                )),
              ]),
            )),
          ]),
        )),
      ),
    ]),
  );
}

class _TtCell extends StatelessWidget {
  final String content;
  const _TtCell({required this.content});
  @override
  Widget build(BuildContext context) {
    Color bg; Color border; Color textColor = AppColors.textPrimary;
    if (content.isEmpty) {
      bg = AppColors.bgCard2.withOpacity(0.4); border = Colors.transparent;
    } else if (content == 'BREAK') {
      bg = AppColors.green.withOpacity(0.07); border = AppColors.green.withOpacity(0.15);
      textColor = AppColors.green;
    } else if (content.startsWith('LAB:')) {
      bg = AppColors.violet.withOpacity(0.1); border = AppColors.violet.withOpacity(0.2);
      textColor = AppColors.violet;
    } else {
      bg = AppColors.purple.withOpacity(0.1); border = AppColors.purple.withOpacity(0.2);
    }

    final parts = content.startsWith('LAB:') ? content.substring(4).split('\n') : content.split('\n');
    return Container(
      width: 84, height: 52,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
      padding: const EdgeInsets.all(5),
      child: content.isEmpty ? null : Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(content == 'BREAK' ? 'Break' : parts[0],
          style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
        if (parts.length > 1) Text(parts[1], style: const TextStyle(color: AppColors.textMuted, fontSize: 8), overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

// ─────────────────────────────────────────
// EVENTS PAGE
// ─────────────────────────────────────────
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  static const _events = [
    ('Hackathon 2025', 'May 18 · CS Block Hall', 'Tech', AppColors.violet),
    ('Annual Sports Day', 'May 22 · Ground A', 'Sports', AppColors.purple),
    ('Career Fair', 'Jun 1 · Main Auditorium', 'Career', AppColors.green),
    ('Alumni Talk', 'Jun 5 · Seminar Hall 2', 'Talk', AppColors.amber),
    ('AI Workshop', 'Jun 12 · Online', 'Workshop', AppColors.blue),
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageHeader('🎓  Events'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: _events.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: e.$4, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.$1, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(e.$2, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ])),
            GradientBadge(e.$3, color: e.$4),
          ]),
        )).toList()),
      ),
    ]),
  );
}

// ─────────────────────────────────────────
// NOTIFICATIONS PAGE
// ─────────────────────────────────────────
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}
class _NotificationsPageState extends State<NotificationsPage> {
  final _notifs = [
    ('🔔', 'Exam Reminder', 'DBMS exam on May 20 at 9 AM in EH-1', '2h ago', true),
    ('📢', 'Attendance Alert', 'CN attendance below 75%. Attend next 3 classes.', '5h ago', true),
    ('✅', 'Assignment Graded', 'OS Assignment 3 graded: 18/20', '1d ago', true),
    ('🎓', 'Event Registration', 'You\'re registered for Hackathon 2025.', '2d ago', true),
    ('💰', 'Fees Reminder', 'Semester fees due by June 30, 2025.', '3d ago', false),
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageHeader('🔔  Notifications',
        action: GradButton(label: 'Mark all read', onTap: () => setState(() {}), colors: AppColors.gradPurple)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: _notifs.map((n) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: n.$5 ? AppColors.purple : Colors.transparent, width: 3),
              top: BorderSide(color: AppColors.border), right: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n.$1, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n.$2, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(n.$3, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ])),
            Text(n.$4, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ]),
        )).toList()),
      ),
    ]),
  );
}

// ─────────────────────────────────────────
// REMINDERS PAGE
// ─────────────────────────────────────────
class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});
  @override
  State<RemindersPage> createState() => _RemindersPageState();
}
class _RemindersPageState extends State<RemindersPage> {
  final List<Map<String, String>> _reminders = [
    {'title': 'Study DBMS Chapter 5', 'date': 'May 16', 'time': '8:00 PM', 'cat': '📚'},
    {'title': 'Submit OS Assignment 4', 'date': 'May 18', 'time': '11:59 PM', 'cat': '📝'},
    {'title': 'Hackathon Registration Check', 'date': 'May 17', 'time': '10:00 AM', 'cat': '🎓'},
  ];
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageHeader('⏰  Reminders'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CardTitle('➕  ADD REMINDER'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgCard2, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                Expanded(child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'New reminder...', hintStyle: TextStyle(color: AppColors.textMuted)),
                )),
                GestureDetector(
                  onTap: () {
                    if (_ctrl.text.isNotEmpty) {
                      setState(() => _reminders.insert(0, {'title': _ctrl.text, 'date': 'Today', 'time': '—', 'cat': '🔔'}));
                      _ctrl.clear();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.gradPurple),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
              ]),
            ),
          ])),
          const SizedBox(height: 14),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CardTitle('📌  ACTIVE REMINDERS'),
            ..._reminders.asMap().entries.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgCard2, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                Text(e.value['cat']!, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.value['title']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                  Text('${e.value['date']} · ${e.value['time']}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ])),
                GestureDetector(
                  onTap: () => setState(() => _reminders.removeAt(e.key)),
                  child: const Icon(Icons.close, color: AppColors.textMuted, size: 16),
                ),
              ]),
            )),
          ])),
        ]),
      ),
    ]),
  );
}

// ─────────────────────────────────────────
// LEAVE PAGE
// ─────────────────────────────────────────
class LeavePage extends StatefulWidget {
  const LeavePage({super.key});
  @override
  State<LeavePage> createState() => _LeavePageState();
}
class _LeavePageState extends State<LeavePage> {
  String _leaveType = 'Medical Leave';
  final _reasonCtrl = TextEditingController();
  bool _submitted = false;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageHeader('🏖️  Leave Application'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CardTitle('📋  APPLY FOR LEAVE'),
            if (_submitted) Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green.withOpacity(0.3)),
              ),
              child: const Row(children: [
                Icon(Icons.check_circle, color: AppColors.green, size: 18),
                SizedBox(width: 8),
                Text('Leave application submitted successfully!', style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 12),
            const Text('Leave Type', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: AppColors.bgCard2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: DropdownButton<String>(
                value: _leaveType,
                dropdownColor: AppColors.bgCard2,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                underline: const SizedBox(),
                isExpanded: true,
                items: ['Medical Leave', 'Casual Leave', 'Duty Leave', 'Special Leave']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _leaveType = v!),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Reason', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bgCard2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: TextField(
                controller: _reasonCtrl,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Reason for leave...', hintStyle: TextStyle(color: AppColors.textMuted)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: GradButton(
              label: 'Submit Application',
              onTap: () => setState(() => _submitted = true),
            )),
          ]))),
          const SizedBox(width: 14),
          SizedBox(width: 260, child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CardTitle('📊  LEAVE BALANCE'),
            _LeaveBalance(type: 'Medical Leave', used: 2, total: 10, color: AppColors.green),
            _LeaveBalance(type: 'Casual Leave', used: 3, total: 8, color: AppColors.purple),
            _LeaveBalance(type: 'Duty Leave', used: 1, total: 5, color: AppColors.blue),
            _LeaveBalance(type: 'Special Leave', used: 0, total: 3, color: AppColors.amber),
          ]))),
        ]),
      ),
    ]),
  );
}

class _LeaveBalance extends StatelessWidget {
  final String type; final int used, total; final Color color;
  const _LeaveBalance({required this.type, required this.used, required this.total, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(type, style: const TextStyle(color: AppColors.textSec, fontSize: 11))),
        Text('$used/$total days', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ]),
      const SizedBox(height: 5),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
        value: used / total, minHeight: 6,
        backgroundColor: AppColors.border,
        valueColor: AlwaysStoppedAnimation(color),
      )),
    ]),
  );
}

// ─────────────────────────────────────────
// CHAT PAGE (THERAPIST)
// ─────────────────────────────────────────
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;

  static const _chips = [
    ('😰 Exam anxiety', 'I\'m feeling really anxious about my exams'),
    ('🌬️ Breathe with me', 'Guide me through a breathing exercise'),
    ('😴 Sleep issues', 'I haven\'t been sleeping well lately'),
    ('💪 Manage stress', 'How do I manage my stress better?'),
    ('🌊 Overwhelmed', 'I feel overwhelmed and don\'t know what to do'),
  ];

  final _responses = {
    'exam': 'Exam anxiety is incredibly common — almost every student experiences it. What your brain is doing is actually trying to protect you by flagging something important.\n\n💜 Here\'s what I\'d suggest:\n• Break study material into 30-min chunks\n• After each session, write 3 things you understood\n• Night before: review only summaries, no new material\n\nWhat subject are you most worried about? 📖',
    'breath': 'Let\'s do a 4-7-8 breathing exercise together. This activates your parasympathetic nervous system and reduces anxiety within minutes.\n\n🌬️ Follow along:\n1. Inhale through your nose for 4 seconds\n2. Hold your breath for 7 seconds\n3. Exhale fully through your mouth for 8 seconds\n\nRepeat this 4 times. How do you feel? 💚',
    'sleep': 'Sleep deprivation is one of the biggest amplifiers of stress and affects memory retention significantly.\n\n🌙 Tonight, try:\n• No screens 45 min before bed\n• Write 3 worries in a journal and close it\n• Keep your room cool (18–21°C)\n• 10-min body scan meditation\n\nHow many hours are you averaging? 😴',
    'overwhelm': 'I hear you. That feeling of being overwhelmed is real and valid. When everything feels urgent, nothing gets done. Let\'s slow down.\n\n💜 Right now, just do this:\n1. Take 3 slow breaths 🌬️\n2. Write down everything that feels heavy\n3. Circle the ONE thing that matters most today\n4. Everything else can wait\n\nI\'m right here with you. 💙',
    'stress': 'Managing stress is a skill, and like any skill — it gets better with practice.\n\n🌿 Daily habits research backs:\n• 20-min walk (reduces cortisol by 15–20%)\n• Limit caffeine after 2pm\n• 5-min gratitude journaling\n• Social connection — even a 10-min call\n\nWould you like help designing a 7-day stress reset plan? 🧘',
    'default': 'Thank you for sharing that with me. Whatever you\'re going through, you don\'t have to face it alone. 💙\n\nAs your wellness companion, I\'m here to listen without judgment. Can you tell me more about what\'s been weighing on you? Sometimes just putting words to feelings is the first step toward feeling lighter.',
  };

  String _getReply(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('exam') || m.contains('anxious') || m.contains('anxiety')) return _responses['exam']!;
    if (m.contains('breath') || m.contains('relax') || m.contains('calm')) return _responses['breath']!;
    if (m.contains('sleep') || m.contains('tired')) return _responses['sleep']!;
    if (m.contains('overwhelm') || m.contains('too much') || m.contains('cant')) return _responses['overwhelm']!;
    if (m.contains('stress') || m.contains('help') || m.contains('manage')) return _responses['stress']!;
    if (m.contains('hi') || m.contains('hello') || m.contains('hey')) return 'Hey! I\'m Serenity, your wellness companion. 💜 I\'m here to listen, support, and guide you. Your stress index is at 62 — manageable, but I\'d love to hear how you\'re really feeling. What\'s on your mind today?';
    return _responses['default']!;
  }

  void _send(String msg) {
    if (msg.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: msg, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _ctrl.clear();
    _scroll();
    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: _getReply(msg), isUser: false, time: DateTime.now()));
      });
      _scroll();
    });
  }

  void _scroll() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () => setState(() =>
      _messages.add(ChatMessage(
        text: 'Hey! I\'m Serenity, your wellness companion. 💜 I\'m here to listen and support you. Your stress index is at 62 today — manageable, but I\'d love to hear how you\'re really feeling. What\'s on your mind?',
        isUser: false, time: DateTime.now()))));
  }

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    // Header
    Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.gradViolet),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('🧘', style: TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Serenity — Wellness Companion', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800)),
          Row(children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            const Text('Online · Therapist mode active', style: TextStyle(color: AppColors.green, fontSize: 10)),
          ]),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _messages.clear()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgCard2, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border)),
            child: const Text('Clear', style: TextStyle(color: AppColors.textSec, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    ),

    // Messages
    Expanded(child: ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (_isTyping && i == _messages.length) return _TypingBubble();
        final m = _messages[i];
        return _MessageBubble(message: m);
      },
    )),

    // Chips
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(children: _chips.map((c) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: GestureDetector(
          onTap: () => _send(c.$2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgCard2, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border)),
            child: Text(c.$1, style: const TextStyle(color: AppColors.textSec, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      )).toList()),
    ),

    // Input
    Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.bgCard2, borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border)),
          child: TextField(
            controller: _ctrl,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration.collapsed(
              hintText: 'Talk to me… I\'m here for you 💙',
              hintStyle: TextStyle(color: AppColors.textMuted)),
            onSubmitted: _send,
          ),
        )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _send(_ctrl.text),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.gradViolet),
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ),
      ]),
    ),
  ]);
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!message.isUser) ...[
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.gradViolet),
              borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text('🧘', style: TextStyle(fontSize: 13))),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: message.isUser ? null : AppColors.bgCard2,
            gradient: message.isUser ? const LinearGradient(colors: [Color(0x4A9D6FFF), Color(0x30D17FFF)]) : null,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(message.isUser ? 14 : 3),
              bottomRight: Radius.circular(message.isUser ? 3 : 14),
            ),
            border: Border.all(color: message.isUser ? AppColors.purple.withOpacity(0.3) : AppColors.border),
          ),
          child: Text(message.text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.55)),
        )),
        if (message.isUser) ...[
          const SizedBox(width: 8),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: AppColors.bgCard2, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border)),
            child: const Center(child: Text('👤', style: TextStyle(fontSize: 13))),
          ),
        ],
      ],
    ),
  );
}

class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}
class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(width: 28, height: 28, decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.gradViolet), borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text('🧘', style: TextStyle(fontSize: 13)))),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: AppColors.bgCard2, borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14), topRight: Radius.circular(14), bottomRight: Radius.circular(14), bottomLeft: Radius.circular(3)),
          border: Border.all(color: AppColors.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 5, height: 5,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(i == 0 ? _c.value : i == 1 ? (_c.value + 0.3).clamp(0,1) : (_c.value + 0.6).clamp(0,1)),
              shape: BoxShape.circle),
          ),
        ))),
      ),
    ]),
  );
}

// ─────────────────────────────────────────
// STUDENT INFO PAGE
// ─────────────────────────────────────────
class StudentInfoPage extends StatefulWidget {
  const StudentInfoPage({super.key});
  @override
  State<StudentInfoPage> createState() => _StudentInfoPageState();
}
class _StudentInfoPageState extends State<StudentInfoPage> {
  int _tab = 0;
  final _tabs = ['🎓 Profile', '💰 Fees', '📊 Academic', '🏆 Achievements'];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageHeader('👤  Student Info'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          // Profile card
          AppCard(child: Row(children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradPurple),
                borderRadius: BorderRadius.circular(18)),
              child: const Center(child: Text('A', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900))),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Arjun Mehta', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
              const Text('CSE · 3rd Year · Roll No. CS21047', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: const [
                GradientBadge('Active Student', color: AppColors.purple),
                GradientBadge('GPA 8.2', color: AppColors.green),
                GradientBadge('Scholar', color: AppColors.violet),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Batch', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
              const Text('2021–2025', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
            ]),
          ])),
          const SizedBox(height: 14),

          // Tabs
          Row(children: _tabs.asMap().entries.map((e) => Expanded(child: GestureDetector(
            onTap: () => setState(() => _tab = e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                gradient: _tab == e.key ? const LinearGradient(colors: AppColors.gradPurple) : null,
                color: _tab == e.key ? null : AppColors.bgCard2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _tab == e.key ? Colors.transparent : AppColors.border),
              ),
              child: Text(e.value, textAlign: TextAlign.center,
                style: TextStyle(color: _tab == e.key ? Colors.white : AppColors.textMuted,
                  fontSize: 11, fontWeight: FontWeight.w800)),
            ),
          ))).toList()),
          const SizedBox(height: 14),

          // Tab content
          AppCard(child: [
            _ProfileTab(),
            _FeesTab(),
            _AcademicTab(),
            _AchievementsTab(),
          ][_tab]),
        ]),
      ),
    ]),
  );
}

Widget _infoRow(String label, String value, {Color? valueColor}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 9),
  child: Row(children: [
    Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
    const Spacer(),
    Text(value, style: TextStyle(color: valueColor ?? AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
  ]),
);

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [
    _infoRow('Full Name', 'Arjun Mehta'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Roll Number', 'CS21047'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Department', 'Computer Science & Engineering'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Semester', '6th Semester'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Section', 'B'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Advisor', 'Dr. Priya Mehta'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Email', 'arjun.cs21047@uni.edu'),
  ]);
}

class _FeesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [
    _infoRow('Tuition Fee', '₹85,000', valueColor: AppColors.purple),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Hostel Fee', '₹42,000'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Library Fee', '₹2,000'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Sports Fee', '₹1,500'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Total Paid', '₹1,18,500', valueColor: AppColors.green),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Balance Due', '₹12,000', valueColor: AppColors.amber),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Due Date', '30 Jun 2025', valueColor: AppColors.red),
  ]);
}

class _AcademicTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [
    _infoRow('Current GPA', '8.2 / 10', valueColor: AppColors.purple),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Credits Completed', '108 / 160'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Backlogs', 'None', valueColor: AppColors.green),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Best Semester', 'Sem 4 — 9.0 GPA', valueColor: AppColors.green),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Overall Attendance', '82.4%'),
  ]);
}

class _AchievementsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [
    _infoRow('Scholarship', 'Merit Scholar 2023–24', valueColor: AppColors.amber),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Hackathon', '2nd Place — HackIIIT 2024', valueColor: AppColors.violet),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Paper Published', '1 IEEE Conference Paper'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Coding Rank', 'Top 5% on LeetCode'),
    Divider(color: AppColors.border, height: 1),
    _infoRow('Club', 'Tech Club President'),
  ]);
}

// ─────────────────────────────────────────
// FEES PAGE
// ─────────────────────────────────────────
class FeesPage extends StatelessWidget {
  const FeesPage({super.key});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageHeader('💰  Fees & Finance'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CardTitle('📊  FEE BREAKDOWN'),
            _FeesBar('Tuition', 85000, 130500, AppColors.purple),
            _FeesBar('Hostel', 42000, 130500, AppColors.violet),
            _FeesBar('Library', 2000, 130500, AppColors.blue),
            _FeesBar('Sports', 1500, 130500, AppColors.green),
            const Divider(color: AppColors.border, height: 24),
            _infoRow('Total Paid', '₹1,18,500', valueColor: AppColors.green),
            _infoRow('Balance Due', '₹12,000', valueColor: AppColors.amber),
            _infoRow('Due Date', 'June 30, 2025', valueColor: AppColors.red),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: GradButton(label: '💳  Pay Now', onTap: () {})),
          ]))),
          const SizedBox(width: 14),
          SizedBox(width: 260, child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CardTitle('🏦  SCHOLARSHIP'),
            _infoRow('Name', 'Merit Scholarship'),
            Divider(color: AppColors.border, height: 1),
            _infoRow('Amount', '₹25,000/year', valueColor: AppColors.green),
            Divider(color: AppColors.border, height: 1),
            _infoRow('Status', 'Active', valueColor: AppColors.green),
            Divider(color: AppColors.border, height: 1),
            _infoRow('Next Disbursement', 'Jul 2025'),
          ]))),
        ]),
      ),
    ]),
  );
}

class _FeesBar extends StatelessWidget {
  final String label; final int amount, total; final Color color;
  const _FeesBar(this.label, this.amount, this.total, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSec, fontSize: 11))),
        Text('₹${(amount/1000).toStringAsFixed(0)}k', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 5),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
        value: amount / total, minHeight: 7,
        backgroundColor: AppColors.border,
        valueColor: AlwaysStoppedAnimation(color),
      )),
    ]),
  );
}