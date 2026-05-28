import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

enum Priority { critical, high, medium, low }

enum TaskStatus { pending, completed }

extension PriorityExt on Priority {
  String get label => name[0].toUpperCase() + name.substring(1);
  int get score {
    switch (this) {
      case Priority.critical: return 4;
      case Priority.high:     return 3;
      case Priority.medium:   return 2;
      case Priority.low:      return 1;
    }
  }
  Color get color {
    switch (this) {
      case Priority.critical: return const Color(0xFFF87171);
      case Priority.high:     return const Color(0xFFFB923C);
      case Priority.medium:   return const Color(0xFF4F8EF7);
      case Priority.low:      return const Color(0xFF9CA3AF);
    }
  }
  Color get bgColor {
    switch (this) {
      case Priority.critical: return const Color(0xFF4D1C1C);
      case Priority.high:     return const Color(0xFF4D2A0A);
      case Priority.medium:   return const Color(0xFF0F1F3D);
      case Priority.low:      return const Color(0xFF1F2937);
    }
  }
}

class Task {
  int id;
  String title;
  String desc;
  String proj;
  String owner;
  Priority pri;
  TaskStatus status;
  DateTime due;
  double est;
  DateTime created;
  DateTime? completedAt;
  int? dep; // id of dependency task

  Task({
    required this.id,
    required this.title,
    this.desc = '',
    required this.proj,
    this.owner = 'John Doe',
    required this.pri,
    this.status = TaskStatus.pending,
    required this.due,
    this.est = 0,
    required this.created,
    this.completedAt,
    this.dep,
  });

  Task copyWith({
    String? title,
    String? desc,
    String? proj,
    String? owner,
    Priority? pri,
    TaskStatus? status,
    DateTime? due,
    double? est,
    DateTime? completedAt,
    int? dep,
    bool clearDep = false,
    bool clearCompleted = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      proj: proj ?? this.proj,
      owner: owner ?? this.owner,
      pri: pri ?? this.pri,
      status: status ?? this.status,
      due: due ?? this.due,
      est: est ?? this.est,
      created: created,
      completedAt: clearCompleted ? null : (completedAt ?? this.completedAt),
      dep: clearDep ? null : (dep ?? this.dep),
    );
  }
}

// ─────────────────────────────────────────────
// COLORS & THEME
// ─────────────────────────────────────────────

const _bg      = Color(0xFF0B0D14);
const _surface = Color(0xFF111520);
const _surface2= Color(0xFF161B2E);
const _border  = Color(0x12FFFFFF);
const _blue    = Color(0xFF4F8EF7);
const _purple  = Color(0xFFA78BFA);
const _green   = Color(0xFF34D399);
const _orange  = Color(0xFFFB923C);
const _red     = Color(0xFFF87171);
const _textCol = Color(0xFFE8EAF0);
const _muted   = Color(0xFF6B7280);
const _dim     = Color(0xFF374151);

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

String _dateStr(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _offset(int days) => _today().add(Duration(days: days));

bool _isToday(DateTime dt) => _dateStr(dt) == _dateStr(_today());
bool _isThisWeek(DateTime dt) {
  final start = _today().subtract(Duration(days: _today().weekday - 1));
  final end   = start.add(const Duration(days: 6));
  return dt.isAfter(start.subtract(const Duration(days: 1))) &&
         dt.isBefore(end.add(const Duration(days: 1)));
}
bool _isOverdue(Task t) =>
    t.status != TaskStatus.completed && t.due.isBefore(_today());

int _daysOverdue(Task t) => _today().difference(t.due).inDays;

String _dueLabel(Task t) {
  if (t.status == TaskStatus.completed) return '✓ Done';
  if (_isToday(t.due))                  return '⏰ Due today';
  if (_dateStr(t.due) == _dateStr(_offset(1))) return '📅 Due tomorrow';
  if (_isOverdue(t))                    return '⚠ ${_daysOverdue(t)}d overdue';
  final diff = t.due.difference(_today()).inDays;
  return '📅 Due in ${diff}d';
}

int _priScore(Task t) {
  final urgency = _isOverdue(t) ? 10
      : (_isToday(t.due) ? 5
      : (_dateStr(t.due) == _dateStr(_offset(1)) ? 3 : 1));
  return t.pri.score * urgency;
}

// ─────────────────────────────────────────────
// SEED DATA
// ─────────────────────────────────────────────

List<Task> _seedTasks() => [
  Task(id:1, title:'Review Q2 design specs',       desc:'Go through Figma files and leave feedback',       proj:'WorkSphere v2', pri:Priority.high,     due:_offset(0),  est:2,   created:_offset(-3)),
  Task(id:2, title:'Fix auth bug in login flow',    desc:'JWT token not refreshing properly on expiry',    proj:'WorkSphere v2', pri:Priority.critical,  due:_offset(-1), est:3,   created:_offset(-5)),
  Task(id:3, title:'Write deployment runbook',      desc:'Document steps for production release',          proj:'DevOps',        pri:Priority.medium,    due:_offset(-2), est:1.5, created:_offset(-7),  status:TaskStatus.completed, completedAt:_offset(-1)),
  Task(id:4, title:'Conduct intern interviews',     desc:'Panel interview for 3 backend intern candidates',proj:'Hiring',        pri:Priority.high,      due:_offset(1),  est:2,   created:_offset(-2)),
  Task(id:5, title:'Update API documentation',      desc:'Swagger docs for the new endpoints',             proj:'WorkSphere v2', pri:Priority.medium,    due:_offset(3),  est:1,   created:_offset(-1),  dep:2),
  Task(id:6, title:'Monthly team retrospective',    desc:'Facilitate the retro session',                   proj:'Team Ops',      pri:Priority.medium,    due:_offset(-3), est:1.5, created:_offset(-10), status:TaskStatus.completed, completedAt:_offset(-3)),
  Task(id:7, title:'Migrate DB schema for v2.1',    desc:'Run migration scripts on staging first',         proj:'DevOps',        pri:Priority.critical,  due:_offset(-2), est:4,   created:_offset(-4)),
  Task(id:8, title:'Prepare Q2 OKR slides',         desc:'Deck for all-hands presentation',                proj:'Team Ops',      pri:Priority.low,       due:_offset(6),  est:2,   created:_offset(0)),
  Task(id:9, title:'Set up monitoring alerts',      desc:'Grafana + PagerDuty for prod services',          proj:'DevOps',        pri:Priority.high,      due:_offset(0),  est:1,   created:_offset(-6),  status:TaskStatus.completed, completedAt:_offset(0)),
  Task(id:10,title:'Draft product roadmap email',   desc:'Summary to share with stakeholders',             proj:'WorkSphere v2', pri:Priority.medium,    due:_offset(2),  est:1,   created:_offset(0),   dep:8),
];

// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Task Manager — WorkSphere',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(primary: _blue, surface: _surface),
    ),
    home: const TaskManagerPage(),
  );
}

// ─────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────

enum TabFilter { today, week, overdue, all }
enum SortMode  { due, priority, est }

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({super.key});
  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  List<Task> tasks = _seedTasks();
  int nextId = 11;

  TabFilter currentTab = TabFilter.today;
  SortMode  sortMode   = SortMode.due;
  String    projFilter = '';
  String    priFilter  = '';

  List<int>? aiPriorityOrder;
  String?    scheduleHint;
  String     aiInsight = '';

  // Focus timer
  int?  focusTaskId;
  int   focusSeconds = 0;
  Timer? focusTimer;

  // AI loading
  bool aiPrioritizing = false;
  bool aiCleaning     = false;

  // Toast queue
  OverlayEntry? _toastEntry;

  @override
  void initState() {
    super.initState();
    _setDefaultInsight();
  }

  @override
  void dispose() {
    focusTimer?.cancel();
    super.dispose();
  }

  // ── Computed ──────────────────────────────

  List<String> get projects => tasks.map((t) => t.proj).toSet().toList();

  List<Task> get filteredTasks {
    List<Task> list = [...tasks];

    switch (currentTab) {
      case TabFilter.today:
        list = list.where((t) => _isToday(t.due) || (t.status == TaskStatus.pending && _isOverdue(t))).toList();
      case TabFilter.week:
        list = list.where((t) => _isThisWeek(t.due)).toList();
      case TabFilter.overdue:
        list = list.where((t) => _isOverdue(t)).toList();
      case TabFilter.all:
        break;
    }

    if (projFilter.isNotEmpty) list = list.where((t) => t.proj == projFilter).toList();
    if (priFilter.isNotEmpty)  list = list.where((t) => t.pri.name == priFilter).toList();

    if (aiPriorityOrder != null) {
      final order = aiPriorityOrder!;
      list.sort((a, b) {
        final ai = order.indexOf(a.id);
        final bi = order.indexOf(b.id);
        if (ai == -1 && bi == -1) return 0;
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai - bi;
      });
    } else {
      switch (sortMode) {
        case SortMode.due:
          list.sort((a, b) {
            if (a.status == TaskStatus.completed && b.status != TaskStatus.completed) return 1;
            if (b.status == TaskStatus.completed && a.status != TaskStatus.completed) return -1;
            return a.due.compareTo(b.due);
          });
        case SortMode.priority:
          list.sort((a, b) => _priScore(b) - _priScore(a));
        case SortMode.est:
          list.sort((a, b) => (a.est).compareTo(b.est));
      }
    }
    return list;
  }

  Task? _getDepTask(int? id) => id == null ? null : tasks.cast<Task?>().firstWhere((t) => t?.id == id, orElse: () => null);

  bool _isBlocked(Task t) {
    final dep = _getDepTask(t.dep);
    return dep != null && dep.status != TaskStatus.completed;
  }

  // ── Summary stats ─────────────────────────

  int get totalCount    => tasks.length;
  int get doneCount     => tasks.where((t) => t.status == TaskStatus.completed).length;
  int get overdueCount  => tasks.where((t) => _isOverdue(t)).length;
  int get pendingCount  => tasks.where((t) => t.status == TaskStatus.pending).length;
  int get pct           => totalCount > 0 ? (doneCount * 100 ~/ totalCount) : 0;
  double get remHours   => tasks.where((t) => t.status == TaskStatus.pending).fold(0, (s, t) => s + t.est);
  int get doneTodayCount=> tasks.where((t) => t.completedAt != null && _isToday(t.completedAt!)).length;

  // ── Actions ───────────────────────────────

  void _toggleTask(int id) {
    setState(() {
      final idx = tasks.indexWhere((t) => t.id == id);
      if (idx < 0) return;
      final t = tasks[idx];
      if (t.status == TaskStatus.completed) {
        tasks[idx] = t.copyWith(status: TaskStatus.pending, clearCompleted: true);
      } else {
        tasks[idx] = t.copyWith(status: TaskStatus.completed, completedAt: _today());
        if (focusTaskId == id) _stopFocus();
        _showToast('Nice! $doneTodayCount task${doneTodayCount != 1 ? 's' : ''} done today 🎉', type: 'success');
      }
      _setDefaultInsight();
    });
  }

  void _deleteTask(int id) {
    setState(() {
      tasks.removeWhere((t) => t.id == id);
      if (focusTaskId == id) _stopFocus();
    });
  }

  void _toggleFocus(int id) {
    if (focusTaskId == id) { _stopFocus(); return; }
    if (focusTaskId != null) _stopFocus(rerender: false);
    setState(() {
      focusTaskId   = id;
      focusSeconds  = 0;
    });
    focusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => focusSeconds++);
    });
    _showToast('Focus session started — stay in the zone! 🎯', type: 'ai');
  }

  void _stopFocus({bool rerender = true}) {
    focusTimer?.cancel();
    focusTimer = null;
    if (rerender) setState(() { focusTaskId = null; focusSeconds = 0; });
    else { focusTaskId = null; focusSeconds = 0; }
  }

  void _focusDone() {
    if (focusTaskId != null) {
      _toggleTask(focusTaskId!);
      _stopFocus();
    }
  }

  String get _focusClock {
    final m = (focusSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (focusSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Add / Edit Task ───────────────────────

  void _openAddTaskModal({Task? editing}) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (_) => _TaskModal(
        editing: editing,
        tasks: tasks,
        nextId: nextId,
      ),
    );
    if (result == null) return;
    setState(() {
      if (editing != null) {
        final idx = tasks.indexWhere((t) => t.id == editing.id);
        if (idx >= 0) tasks[idx] = result;
      } else {
        tasks.add(result);
        nextId++;
      }
    });
    _showToast(editing != null ? 'Task updated ✓' : 'Task added ✓', type: 'success');
  }

  // ── AI Prioritize ─────────────────────────

  Future<void> _aiPrioritize() async {
    setState(() => aiPrioritizing = true);
    final pending = tasks.where((t) => t.status == TaskStatus.pending).toList();
    final taskList = pending.map((t) =>
        '- [${t.pri.name.toUpperCase()}] "${t.title}" | Due: ${_dateStr(t.due)} | Est: ${t.est}h | Project: ${t.proj}${_isOverdue(t) ? ' | OVERDUE' : ''}').join('\n');

    try {
      final res = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
          'anthropic-dangerous-direct-browser-access': 'true',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 800,
          'messages': [{
            'role': 'user',
            'content': 'You are a productivity AI. Given these pending tasks for today, suggest the optimal order to tackle them (most important first) and provide a brief smart scheduling suggestion. Also give 1-2 lines of actionable insight about workload. Return ONLY valid JSON with no markdown: {"order":["exact task title 1","exact task title 2"],"schedule":"your schedule suggestion","insight":"your insight"}\n\nTasks:\n$taskList'
          }]
        }),
      );

      final data   = jsonDecode(res.body);
      final raw    = (data['content'] as List).map((b) => b['text'] ?? '').join('');
      final clean  = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final parsed = jsonDecode(clean);

      final order = (parsed['order'] as List).map((title) {
        final t = tasks.firstWhere(
          (x) => x.title == title || x.title.toLowerCase() == (title as String).toLowerCase(),
          orElse: () => Task(id: -1, title: '', proj: '', pri: Priority.medium, due: _today(), created: _today()),
        );
        return t.id;
      }).where((id) => id != -1).toList();

      // append any remaining
      for (final t in pending) {
        if (!order.contains(t.id)) order.add(t.id);
      }

      setState(() {
        aiPriorityOrder = order;
        currentTab = TabFilter.today;
        if (parsed['schedule'] != null) scheduleHint = '✨ Smart Schedule: ${parsed['schedule']}';
        if (parsed['insight'] != null)  aiInsight = parsed['insight'];
      });
      _showToast('Tasks prioritized by AI ⚡', type: 'ai');

    } catch (e) {
      _showToast('AI error: $e', type: '');
    }

    setState(() => aiPrioritizing = false);
  }

  // ── AI Cleanup ────────────────────────────

  Future<void> _aiCleanup() async {
    setState(() => aiCleaning = true);
    final taskList = tasks.map((t) =>
        '- id:${t.id} | "${t.title}" | ${t.status.name} | ${t.pri.name} | due:${_dateStr(t.due)} | created:${_dateStr(t.created)}').join('\n');

    try {
      final res = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
          'anthropic-dangerous-direct-browser-access': 'true',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 600,
          'messages': [{
            'role': 'user',
            'content': 'You are a productivity assistant. Analyze these tasks and suggest cleanup actions. Return ONLY valid JSON with no markdown: {"actions":[{"id":number,"action":"complete or deprioritize","reason":"short reason"}],"summary":"1 sentence summary"}\n\nRules: suggest marking stale old pending tasks as complete if they seem done, or deprioritize low-priority old tasks. Max 3 actions. Use exact numeric task ids.\n\nTasks:\n$taskList'
          }]
        }),
      );

      final data   = jsonDecode(res.body);
      final raw    = (data['content'] as List).map((b) => b['text'] ?? '').join('');
      final clean  = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final parsed = jsonDecode(clean);

      setState(() {
        for (final a in parsed['actions'] as List) {
          final idx = tasks.indexWhere((t) => t.id == a['id']);
          if (idx < 0) continue;
          if (a['action'] == 'complete') {
            tasks[idx] = tasks[idx].copyWith(status: TaskStatus.completed, completedAt: _today());
          } else if (a['action'] == 'deprioritize') {
            final cur = tasks[idx].pri;
            final next = cur == Priority.critical ? Priority.high
                : cur == Priority.high ? Priority.medium : Priority.low;
            tasks[idx] = tasks[idx].copyWith(pri: next);
          }
        }
        aiInsight = 'Cleanup complete: ${parsed['summary']}';
      });
      _showToast('✦ ${parsed['summary']}', type: 'ai');

    } catch (e) {
      _showToast('AI error: $e', type: '');
    }

    setState(() => aiCleaning = false);
  }

  void _setDefaultInsight() {
    final overdue   = tasks.where((t) => _isOverdue(t)).toList();
    final critical  = tasks.where((t) => t.pri == Priority.critical && t.status == TaskStatus.pending).toList();
    final doneToday = tasks.where((t) => t.completedAt != null && _isToday(t.completedAt!)).length;

    if (critical.isNotEmpty) {
      aiInsight = 'You have ${critical.length} critical task${critical.length > 1 ? 's' : ''} pending. Tackle those first.';
    } else if (overdue.isNotEmpty) {
      aiInsight = '${overdue.length} task${overdue.length > 1 ? 's are' : ' is'} overdue. Tap "Prioritize my day" to catch up.';
    } else if (doneToday > 0) {
      aiInsight = 'Great start — $doneToday task${doneToday > 1 ? 's' : ''} done today. Keep that momentum!';
    } else {
      aiInsight = 'Tap "Prioritize my day" to get a smart schedule and workload advice.';
    }
  }

  // ── Toast ─────────────────────────────────

  void _showToast(String msg, {String type = ''}) {
    _toastEntry?.remove();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) => _Toast(msg: msg, type: type, onDone: () {
      entry.remove();
      if (_toastEntry == entry) _toastEntry = null;
    }));
    _toastEntry = entry;
    overlay.insert(entry);
  }

  // ── Build ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 780;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _buildTopBar(),
        _buildSummaryStrip(),
        Expanded(
          child: isWide
              ? Row(children: [
                  Flexible(flex: 55, child: _buildTaskColumn()),
                  Flexible(flex: 45, child: _buildAnalyticsColumn()),
                ])
              : Column(children: [
                  Flexible(child: _buildTaskColumn()),
                  SizedBox(height: 380, child: _buildAnalyticsColumn()),
                ]),
        ),
      ]),
    );
  }

  // ── TopBar ────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xEB0B0D14),
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(children: [
        const Icon(Icons.check_box, color: _blue, size: 22),
        const SizedBox(width: 8),
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Task Manager', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const Text('AI-Assisted · Personalized', style: TextStyle(color: _muted, fontSize: 10)),
        ]),
        const Spacer(),
        _aiBtn(
          label: aiCleaning ? 'Analysing…' : '✦ Clean up tasks',
          loading: aiCleaning,
          onTap: aiCleaning ? null : _aiCleanup,
        ),
        const SizedBox(width: 8),
        _aiBtn(
          label: aiPrioritizing ? 'Thinking…' : '⚡ Prioritize my day',
          loading: aiPrioritizing,
          onTap: aiPrioritizing ? null : _aiPrioritize,
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _openAddTaskModal(),
          child: const Text('+ New Task', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _aiBtn({required String label, required bool loading, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _purple.withOpacity(0.12),
          border: Border.all(color: _purple.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          if (loading) ...[
            SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: _purple)),
            const SizedBox(width: 5),
          ],
          Text(label, style: const TextStyle(color: _purple, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  // ── Summary Strip ─────────────────────────

  Widget _buildSummaryStrip() {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          _sumCard('$totalCount',   'Total tasks',      'this week',         _blue),
          _sumCard('$doneCount',    'Completed',        '$doneTodayCount done today', _green),
          _sumCard('$overdueCount', 'Overdue',          'need attention',    _red),
          _sumCard('$pendingCount', 'Pending',          'in progress',       _orange),
          _ringCard(),
          _sumCard('${remHours}h', 'Est. remaining',   'this week',         _purple),
        ]),
      ),
    );
  }

  Widget _sumCard(String num, String label, String sub, Color c) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(num,   style: TextStyle(color: c, fontSize: 26, fontWeight: FontWeight.w800, height: 1)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
        Text(sub,   style: const TextStyle(color: _dim,   fontSize: 10)),
      ]),
    );
  }

  Widget _ringCard() {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        SizedBox(
          width: 52, height: 52,
          child: PieChart(PieChartData(
            sections: [
              PieChartSectionData(value: doneCount.toDouble(),    color: _green,  radius: 8, showTitle: false),
              PieChartSectionData(value: pendingCount.toDouble(), color: _blue,   radius: 8, showTitle: false),
              PieChartSectionData(value: overdueCount.toDouble(), color: _red,    radius: 8, showTitle: false),
            ],
            centerSpaceRadius: 18,
            sectionsSpace: 1,
          )),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$pct%', style: const TextStyle(color: _green, fontSize: 20, fontWeight: FontWeight.w800)),
          const Text('Done rate', style: TextStyle(color: _muted, fontSize: 11)),
        ]),
      ]),
    );
  }

  // ── Task Column ───────────────────────────

  Widget _buildTaskColumn() {
    return Container(
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: _border))),
      child: Column(children: [
        _buildToolbar(),
        if (scheduleHint != null) _buildScheduleHint(),
        Expanded(child: _buildTaskList()),
      ]),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
      child: Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        // Tabs
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: _surface2, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            for (final tab in TabFilter.values)
              _tabBtn(tab),
          ]),
        ),
        // Project filter
        _filterSelect(
          value: projFilter,
          items: ['', ...projects],
          labels: ['All Projects', ...projects],
          onChanged: (v) => setState(() { projFilter = v ?? ''; aiPriorityOrder = null; }),
        ),
        // Priority filter
        _filterSelect(
          value: priFilter,
          items: ['', 'critical', 'high', 'medium', 'low'],
          labels: ['All Priorities', 'Critical', 'High', 'Medium', 'Low'],
          onChanged: (v) => setState(() { priFilter = v ?? ''; aiPriorityOrder = null; }),
        ),
        // Sort
        GestureDetector(
          onTap: () => setState(() {
            sortMode = SortMode.values[(sortMode.index + 1) % SortMode.values.length];
            aiPriorityOrder = null;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(border: Border.all(color: _border), borderRadius: BorderRadius.circular(7)),
            child: Text('⇅ ${['Due date', 'Priority', 'Est. time'][sortMode.index]}',
                style: const TextStyle(color: _muted, fontSize: 11)),
          ),
        ),
      ]),
    );
  }

  Widget _tabBtn(TabFilter tab) {
    final active = currentTab == tab;
    final label  = ['Today', 'This Week', 'Overdue', 'All'][tab.index];
    return GestureDetector(
      onTap: () => setState(() {
        currentTab = tab;
        aiPriorityOrder = null;
        scheduleHint = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? _surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : [],
        ),
        child: Text(label, style: TextStyle(
          color: active ? _textCol : _muted,
          fontSize: 11, fontWeight: FontWeight.w500,
        )),
      ),
    );
  }

  Widget _filterSelect({
    required String value,
    required List<String> items,
    required List<String> labels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: _surface2,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: _surface2,
          style: const TextStyle(color: _muted, fontSize: 11, fontFamily: 'sans-serif'),
          isDense: true,
          items: List.generate(items.length, (i) =>
            DropdownMenuItem(value: items[i], child: Text(labels[i]))),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildScheduleHint() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _blue.withOpacity(0.07),
        border: Border.all(color: _blue.withOpacity(0.18)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(scheduleHint!, style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12)),
    );
  }

  Widget _buildTaskList() {
    final list = filteredTasks;
    if (list.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🎉', style: TextStyle(fontSize: 36)),
          SizedBox(height: 10),
          Text('No tasks here.\nYou\'re all caught up!',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 13, height: 1.7)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildTaskCard(list[i], i),
    );
  }

  Widget _buildTaskCard(Task t, int idx) {
    final overdue  = _isOverdue(t);
    final blocked  = _isBlocked(t);
    final focusing = focusTaskId == t.id;
    final dep      = _getDepTask(t.dep);

    BorderSide leftBorder = BorderSide.none;
    if (overdue && t.status != TaskStatus.completed) leftBorder = const BorderSide(color: _red,    width: 3);
    if (blocked)                                      leftBorder = const BorderSide(color: _orange, width: 3);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: t.status == TaskStatus.completed ? 0.5 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: focusing ? const Color(0xFF0F1828) : _surface,
          border: Border(
            top:    BorderSide(color: focusing ? _blue : _border),
            right:  BorderSide(color: focusing ? _blue : _border),
            bottom: BorderSide(color: focusing ? _blue : _border),
            left:   leftBorder != BorderSide.none ? leftBorder : BorderSide(color: focusing ? _blue : _border),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: focusing ? [BoxShadow(color: _blue.withOpacity(0.15), blurRadius: 8, spreadRadius: 1)] : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Checkbox
              GestureDetector(
                onTap: () => _toggleTask(t.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: t.status == TaskStatus.completed ? _green : Colors.transparent,
                    border: Border.all(
                      color: t.status == TaskStatus.completed ? _green : _dim, width: 1.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: t.status == TaskStatus.completed
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Title
                Row(children: [
                  Expanded(
                    child: Text(t.title,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500, color: _textCol,
                        decoration: t.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                        decorationColor: _muted,
                      ),
                    ),
                  ),
                  if (focusing)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _blue.withOpacity(0.15),
                        border: Border.all(color: _blue.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text('🎯 Focus', style: TextStyle(color: _blue, fontSize: 9)),
                    ),
                ]),
                // Desc
                if (t.desc.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(t.desc, style: const TextStyle(color: _muted, fontSize: 11, height: 1.5)),
                ],
                const SizedBox(height: 6),
                // Meta tags
                Wrap(spacing: 6, runSpacing: 4, children: [
                  _priTag(t.pri),
                  _projTag(t.proj),
                  _dueTagWidget(t, overdue),
                  if (t.est > 0)
                    Text('⏱ ${t.est}h', style: const TextStyle(color: _dim, fontSize: 10)),
                ]),
                // Dependency warning
                if (blocked && dep != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _orange.withOpacity(0.07),
                      border: Border.all(color: _orange.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('⚠ First finish: ${dep.title}',
                        style: const TextStyle(color: _orange, fontSize: 10)),
                  ),
                ],
              ])),
            ]),
            const SizedBox(height: 8),
            // Action buttons
            Wrap(spacing: 6, children: [
              if (t.status != TaskStatus.completed)
                _tcBtn(
                  focusing ? '⏸ Focusing' : '🎯 Focus',
                  color: _blue,
                  active: focusing,
                  onTap: () => _toggleFocus(t.id),
                ),
              _tcBtn('✏ Edit', onTap: () => _openAddTaskModal(editing: t)),
              _tcBtn('🗑 Delete', onTap: () => _deleteTask(t.id)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _priTag(Priority p) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: p.bgColor, borderRadius: BorderRadius.circular(4)),
    child: Text(p.label, style: TextStyle(color: p.color, fontSize: 9, fontWeight: FontWeight.w600)),
  );

  Widget _projTag(String proj) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: _purple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
    child: Text(proj, style: const TextStyle(color: _purple, fontSize: 9)),
  );

  Widget _dueTagWidget(Task t, bool overdue) {
    Color c = _muted;
    if (overdue && t.status != TaskStatus.completed) c = _red;
    else if (_dateStr(t.due) == _dateStr(_offset(1)))    c = _orange;
    return Text(_dueLabel(t), style: TextStyle(color: c, fontSize: 10));
  }

  Widget _tcBtn(String label, {Color? color, bool active = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? (color ?? _blue).withOpacity(0.15) : Colors.transparent,
          border: Border.all(color: (color ?? _border).withOpacity(color != null ? 0.3 : 1)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label, style: TextStyle(color: color ?? _muted, fontSize: 10, fontWeight: FontWeight.w500)),
      ),
    );
  }

  // ── Analytics Column ──────────────────────

  Widget _buildAnalyticsColumn() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Focus timer
        if (focusTaskId != null) _buildFocusTimer(),

        // Weekly win
        _buildWinCard(),
        const SizedBox(height: 12),

        // AI Insight
        _buildAiInsight(),
        const SizedBox(height: 12),

        // Daily completions chart
        _buildDailyChart(),
        const SizedBox(height: 12),

        // Priority breakdown
        _buildPriorityChart(),
        const SizedBox(height: 12),

        // Project progress
        _buildProjectProgress(),
      ],
    );
  }

  Widget _buildFocusTimer() {
    final task = tasks.firstWhere((t) => t.id == focusTaskId, orElse: () => tasks.first);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _blue.withOpacity(0.07),
        border: Border.all(color: _blue.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🎯 FOCUS SESSION',
            style: TextStyle(color: _blue, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(_focusClock,
            style: const TextStyle(color: _blue, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _ftBtn('✕ Stop', Colors.transparent, _red, _stopFocus)),
          const SizedBox(width: 8),
          Expanded(child: _ftBtn('✓ Mark Done', _green, Colors.white, _focusDone)),
        ]),
      ]),
    );
  }

  Widget _ftBtn(String label, Color bg, Color fg, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: bg == Colors.transparent ? _red.withOpacity(0.15) : bg,
        border: bg == Colors.transparent ? Border.all(color: _red.withOpacity(0.25)) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _buildWinCard() {
    final projDone  = <String, int>{};
    final projTotal = <String, int>{};
    for (final t in tasks) {
      projTotal[t.proj] = (projTotal[t.proj] ?? 0) + 1;
      if (t.status == TaskStatus.completed) projDone[t.proj] = (projDone[t.proj] ?? 0) + 1;
    }
    final winProj = projDone.keys.firstWhere(
        (p) => projDone[p] == projTotal[p], orElse: () => '');
    final msg = winProj.isNotEmpty
        ? 'You finished all tasks for "$winProj" this week! 🎉'
        : 'You\'ve completed $doneCount task${doneCount != 1 ? 's' : ''} so far. Keep going!';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_green.withOpacity(0.08), _blue.withOpacity(0.06)]),
        border: Border.all(color: _green.withOpacity(0.18)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🏆 WEEKLY WIN',
            style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 5),
        Text(msg, style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 12, height: 1.6)),
      ]),
    );
  }

  Widget _buildAiInsight() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _purple.withOpacity(0.06),
        border: Border.all(color: _purple.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('✦ AI Insight',
            style: TextStyle(color: _purple, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(aiInsight, style: const TextStyle(color: Color(0xFFC4B5FD), fontSize: 12, height: 1.7)),
      ]),
    );
  }

  Widget _buildDailyChart() {
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final now  = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final counts = List.generate(7, (i) {
      final dt = startOfWeek.add(Duration(days: i));
      final ds = _dateStr(dt);
      return tasks.where((t) => t.completedAt != null && _dateStr(t.completedAt!) == ds).length.toDouble();
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, border: Border.all(color: _border), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Daily completion — this week',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: BarChart(BarChartData(
            barGroups: List.generate(7, (i) => BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(
                toY: counts[i],
                color: _blue.withOpacity(0.7),
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              )],
            )),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) =>
                  Text(days[v.toInt()], style: const TextStyle(color: _muted, fontSize: 9)))),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                interval: 1, getTitlesWidget: (v, _) =>
                  Text(v.toInt().toString(), style: const TextStyle(color: _muted, fontSize: 9)))),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(getDrawingHorizontalLine: (_) => const FlLine(color: Color(0x0AFFFFFF), strokeWidth: 1)),
            borderData: FlBorderData(show: false),
          )),
        ),
      ]),
    );
  }

  Widget _buildPriorityChart() {
    final counts = [Priority.critical, Priority.high, Priority.medium, Priority.low]
        .map((p) => tasks.where((t) => t.pri == p && t.status != TaskStatus.completed).length.toDouble())
        .toList();
    final labels = ['Critical', 'High', 'Medium', 'Low'];
    final colors = [_red, _orange, _blue, _muted];
    final total  = counts.fold(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, border: Border.all(color: _border), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tasks by priority',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: total == 0
              ? const Center(child: Text('No pending tasks', style: TextStyle(color: _muted)))
              : PieChart(PieChartData(
                  sections: List.generate(4, (i) => PieChartSectionData(
                    value: counts[i],
                    color: colors[i],
                    title: counts[i] > 0 ? labels[i] : '',
                    titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
                    radius: 50,
                  )),
                  centerSpaceRadius: 28,
                  sectionsSpace: 2,
                )),
        ),
      ]),
    );
  }

  Widget _buildProjectProgress() {
    final projs = tasks.map((t) => t.proj).toSet().toList();
    final colors = {'WorkSphere v2': _blue, 'DevOps': _green, 'Hiring': _purple, 'Team Ops': _orange};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, border: Border.all(color: _border), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Project progress',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...projs.map((p) {
          final total = tasks.where((t) => t.proj == p).length;
          final done  = tasks.where((t) => t.proj == p && t.status == TaskStatus.completed).length;
          final pct   = total > 0 ? done / total : 0.0;
          final col   = colors[p] ?? _blue;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(p,          style: const TextStyle(color: _textCol, fontSize: 12)),
                Text('$done/$total', style: const TextStyle(color: _muted, fontSize: 11)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: _surface2,
                  color: col,
                  minHeight: 6,
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// TASK MODAL
// ─────────────────────────────────────────────

class _TaskModal extends StatefulWidget {
  final Task? editing;
  final List<Task> tasks;
  final int nextId;
  const _TaskModal({this.editing, required this.tasks, required this.nextId});
  @override
  State<_TaskModal> createState() => _TaskModalState();
}

class _TaskModalState extends State<_TaskModal> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _projCtrl  = TextEditingController();
  final _ownerCtrl = TextEditingController();
  Priority _pri   = Priority.medium;
  DateTime _due   = _offset(7);
  double   _est   = 0;
  int?     _dep;

  @override
  void initState() {
    super.initState();
    final t = widget.editing;
    if (t != null) {
      _titleCtrl.text = t.title;
      _descCtrl.text  = t.desc;
      _projCtrl.text  = t.proj;
      _ownerCtrl.text = t.owner;
      _pri  = t.pri;
      _due  = t.due;
      _est  = t.est;
      _dep  = t.dep;
    } else {
      _ownerCtrl.text = 'John Doe';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _projCtrl.dispose();  _ownerCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final data = Task(
      id:      widget.editing?.id ?? widget.nextId,
      title:   _titleCtrl.text.trim(),
      desc:    _descCtrl.text.trim(),
      proj:    _projCtrl.text.trim().isEmpty ? 'General' : _projCtrl.text.trim(),
      owner:   _ownerCtrl.text.trim().isEmpty ? 'John Doe' : _ownerCtrl.text.trim(),
      pri:     _pri,
      due:     _due,
      est:     _est,
      dep:     _dep,
      created: widget.editing?.created ?? _today(),
      status:  widget.editing?.status ?? TaskStatus.pending,
      completedAt: widget.editing?.completedAt,
    );
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = widget.tasks.where((t) => t.status != TaskStatus.completed && t.id != widget.editing?.id).toList();

    return Dialog(
      backgroundColor: const Color(0xFF111520),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: _border)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.editing != null ? 'Edit Task' : 'New Task',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),

          _mfield('Task title *', _titleCtrl, hint: 'e.g. Review Q2 design specs'),
          _mfield('Description',  _descCtrl,  hint: 'Optional details…', maxLines: 3),

          Row(children: [
            Expanded(child: _mfield('Project', _projCtrl, hint: 'e.g. WorkSphere v2')),
            const SizedBox(width: 12),
            Expanded(child: _mfield('Owner',   _ownerCtrl)),
          ]),

          Row(children: [
            Expanded(child: _priSelect()),
            const SizedBox(width: 12),
            Expanded(child: _duePicker()),
          ]),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: _estField()),
            const SizedBox(width: 12),
            Expanded(child: _depSelect(pendingTasks)),
          ]),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel', style: TextStyle(color: _muted)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(widget.editing != null ? 'Save Changes' : 'Add Task'),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _mfield(String label, TextEditingController ctrl, {String hint = '', int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Color(0xFFC9CCD4), fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: _textCol, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _dim, fontSize: 13),
            filled: true,
            fillColor: _bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide(color: _blue.withOpacity(0.4))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          ),
        ),
      ]),
    );
  }

  Widget _priSelect() => _dropdownField<Priority>(
    label: 'Priority',
    value: _pri,
    items: Priority.values,
    labels: ['🔴 Critical', '🟠 High', '🔵 Medium', '⚪ Low'],
    onChanged: (v) => setState(() => _pri = v!),
  );

  Widget _depSelect(List<Task> pending) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Depends on task', style: TextStyle(color: Color(0xFFC9CCD4), fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: _bg, border: Border.all(color: _border), borderRadius: BorderRadius.circular(7)),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _dep,
              dropdownColor: _surface2,
              style: const TextStyle(color: _textCol, fontSize: 13),
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('None', style: TextStyle(color: _muted))),
                ...pending.map((t) => DropdownMenuItem<int?>(value: t.id, child: Text(t.title, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) => setState(() => _dep = v),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required List<String> labels,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Color(0xFFC9CCD4), fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(color: _bg, border: Border.all(color: _border), borderRadius: BorderRadius.circular(7)),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              dropdownColor: _surface2,
              style: const TextStyle(color: _textCol, fontSize: 13),
              isExpanded: true,
              items: List.generate(items.length, (i) =>
                  DropdownMenuItem<T>(value: items[i], child: Text(labels[i]))),
              onChanged: onChanged,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _duePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Due date', style: TextStyle(color: Color(0xFFC9CCD4), fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _due,
              firstDate: _today(),
              lastDate: _offset(365),
              builder: (_, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(primary: _blue, surface: _surface2),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _due = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(color: _bg, border: Border.all(color: _border), borderRadius: BorderRadius.circular(7)),
            child: Row(children: [
              Expanded(child: Text(_dateStr(_due), style: const TextStyle(color: _textCol, fontSize: 13))),
              const Icon(Icons.calendar_today, size: 14, color: _muted),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _estField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Estimated time (hrs)', style: TextStyle(color: Color(0xFFC9CCD4), fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => _est = double.tryParse(v) ?? 0,
          controller: TextEditingController(text: _est > 0 ? _est.toString() : ''),
          style: const TextStyle(color: _textCol, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'e.g. 2',
            hintStyle: const TextStyle(color: _dim, fontSize: 13),
            filled: true, fillColor: _bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide(color: _blue.withOpacity(0.4))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// TOAST WIDGET
// ─────────────────────────────────────────────

class _Toast extends StatefulWidget {
  final String msg;
  final String type;
  final VoidCallback onDone;
  const _Toast({required this.msg, required this.type, required this.onDone});
  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide   = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 3200), () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    Color borderColor = _border;
    Color textColor   = _textCol;
    if (widget.type == 'success') { borderColor = _green.withOpacity(0.3); textColor = _green; }
    if (widget.type == 'ai')      { borderColor = _purple.withOpacity(0.3); textColor = const Color(0xFFC4B5FD); }

    return Positioned(
      bottom: 24,
      left: 0, right: 0,
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _slide,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _surface2,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(widget.msg, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }
}