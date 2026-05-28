import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const UniVoiceApp());
}

// ─────────────────────────────────────────
// THEME COLOURS
// ─────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFF08060F);
  static const surface = Color(0xFF100D1A);
  static const card = Color(0xFF150F24);
  static const border = Color(0x1AA082FF);
  static const textPrimary = Color(0xFFEDE8FF);
  static const textMuted = Color(0xFF9B8FC2);
  static const textFaint = Color(0xFF4A3F6B);
  static const accent = Color(0xFF7C3AED);
  static const accentMid = Color(0xFF9D5FF5);
  static const accentLight = Color(0x2E7C3AED);
  static const green = Color(0xFF22C893);
  static const greenBg = Color(0x1F22C893);
  static const red = Color(0xFFF05252);
  static const redBg = Color(0x1FF05252);
  static const amber = Color(0xFFF59E0B);
  static const amberBg = Color(0x1FF59E0B);
  static const blue = Color(0xFF818CF8);
  static const blueBg = Color(0x24818CF8);
}

// ─────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────
enum ComplaintStatus { open, pending, resolved, fake }

class Complaint {
  final String id;
  final String category;
  final String priority;
  final String text;
  final String name;
  final String rollNo;
  final DateTime timestamp;
  bool isFake;
  int realConfidence;
  int fakeConfidence;
  String detectionSummary;
  String suggestedSolution;
  bool escalate;
  String estimatedResolution;
  String assignedDepartment;
  ComplaintStatus status;

  Complaint({
    required this.id,
    required this.category,
    required this.priority,
    required this.text,
    required this.name,
    required this.rollNo,
    required this.timestamp,
    this.isFake = false,
    this.realConfidence = 0,
    this.fakeConfidence = 0,
    this.detectionSummary = '',
    this.suggestedSolution = '',
    this.escalate = false,
    this.estimatedResolution = 'TBD',
    this.assignedDepartment = '',
    this.status = ComplaintStatus.open,
  });
}

// ─────────────────────────────────────────
// CATEGORIES
// ─────────────────────────────────────────
const Map<String, List<String>> categoryGroups = {
  'Academic': [
    'Examination & Results',
    'Faculty Conduct',
    'Course & Curriculum',
    'Attendance & Leave',
    'Project / Thesis Supervision',
    'Unfair Evaluation / Marks',
  ],
  'Administration': [
    'Fees & Scholarship',
    'Admission & Documents',
    'ID Card / Certificates',
    'Timetable & Scheduling',
  ],
  'Campus Life': [
    'Hostel & Accommodation',
    'Canteen & Food Quality',
    'Library Facilities',
    'Labs & Equipment',
    'Wi-Fi & IT Infrastructure',
    'Transport & Bus',
  ],
  'Wellbeing & Safety': [
    'Ragging / Bullying',
    'Harassment or Discrimination',
    'Mental Health Support',
    'Campus Safety & Security',
    'Medical / Health Centre',
  ],
  'Placements & Career': [
    'Placement Cell',
    'Internship Issues',
    'Career Guidance',
  ],
  'General': ['Other / General'],
};

List<String> get allCategories =>
    categoryGroups.values.expand((e) => e).toList();

// ─────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────
class UniVoiceApp extends StatelessWidget {
  const UniVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniVoice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: 'SF Pro Text',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────
// HOME (tab container)
// ─────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final List<Complaint> _complaints = [];

  void _addComplaint(Complaint c) {
    setState(() => _complaints.insert(0, c));
  }

  void _updateComplaint() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      SubmitTab(onSubmit: _addComplaint),
      CasesTab(complaints: _complaints, onUpdate: _updateComplaint),
      StatsTab(complaints: _complaints),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(currentTab: _tab, onTabChanged: (i) => setState(() => _tab = i)),
            Expanded(child: tabs[_tab]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// HEADER + TABS
// ─────────────────────────────────────────
class _Header extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  const _Header({required this.currentTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.accent.withOpacity(0.07), Colors.transparent],
        ),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppColors.accent.withOpacity(0.45), blurRadius: 16),
                  ],
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('UniVoice',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2)),
                  const Text('Student Grievance & Complaint Portal',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                _TabBtn(icon: Icons.edit_rounded, label: 'Submit', active: currentTab == 0, onTap: () => onTabChanged(0)),
                _TabBtn(icon: Icons.checklist_rounded, label: 'My Cases', active: currentTab == 1, onTap: () => onTabChanged(1)),
                _TabBtn(icon: Icons.bar_chart_rounded, label: 'Stats', active: currentTab == 2, onTap: () => onTabChanged(2)),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabBtn({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppColors.accentLight : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: active ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 0.5) : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 15, color: active ? AppColors.accentMid : AppColors.textMuted),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: active ? AppColors.accentMid : AppColors.textMuted,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// SUBMIT TAB
// ─────────────────────────────────────────
class SubmitTab extends StatefulWidget {
  final ValueChanged<Complaint> onSubmit;
  const SubmitTab({super.key, required this.onSubmit});

  @override
  State<SubmitTab> createState() => _SubmitTabState();
}

class _SubmitTabState extends State<SubmitTab> {
  String? _selectedCategory;
  String _priority = 'Medium';
  final _textCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  bool _loading = false;
  Complaint? _result;

  @override
  void dispose() {
    _textCtrl.dispose();
    _nameCtrl.dispose();
    _rollCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cat = _selectedCategory;
    final text = _textCtrl.text.trim();
    if (cat == null || cat.isEmpty) {
      _snack('Please select a category');
      return;
    }
    if (text.length < 20) {
      _snack('Please describe the issue in more detail');
      return;
    }

    setState(() { _loading = true; _result = null; });

    final name = _nameCtrl.text.trim().isEmpty ? 'Anonymous' : _nameCtrl.text.trim();
    final rollNo = _rollCtrl.text.trim().isEmpty ? '—' : _rollCtrl.text.trim();
    final id = 'UNI-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    try {
      final prompt = '''You are an AI grievance analysis assistant for a university student complaint portal. Analyse this complaint for authenticity and provide resolution guidance. Respond ONLY with a valid JSON object — no markdown, no preamble.

Category: $cat
Priority: $_priority
Student Roll No: $rollNo
Complaint: "$text"

Return exactly this JSON:
{
  "is_fake": false,
  "real_confidence": 85,
  "fake_confidence": 15,
  "detection_summary": "2-3 sentences explaining authenticity assessment",
  "suggested_solution": "4-5 specific actionable steps the university should take",
  "escalate": false,
  "estimated_resolution": "3-5 working days",
  "assigned_department": "which university department should handle this"
}''';

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'messages': [{'role': 'user', 'content': prompt}],
        }),
      );

      final data = jsonDecode(response.body);
      final raw = (data['content'] as List)
          .map((c) => c['text'] ?? '')
          .join('');
      final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final parsed = jsonDecode(cleaned);

      final isFake = parsed['is_fake'] == true;
      final c = Complaint(
        id: id,
        category: cat,
        priority: _priority,
        text: text,
        name: name,
        rollNo: rollNo,
        timestamp: DateTime.now(),
        isFake: isFake,
        realConfidence: (parsed['real_confidence'] as num).toInt(),
        fakeConfidence: (parsed['fake_confidence'] as num).toInt(),
        detectionSummary: parsed['detection_summary'] ?? '',
        suggestedSolution: parsed['suggested_solution'] ?? '',
        escalate: parsed['escalate'] == true,
        estimatedResolution: parsed['estimated_resolution'] ?? 'TBD',
        assignedDepartment: parsed['assigned_department'] ?? cat,
        status: isFake ? ComplaintStatus.fake : ComplaintStatus.open,
      );

      widget.onSubmit(c);
      setState(() { _result = c; _loading = false; });
      _snack(isFake ? 'Flagged for manual review' : 'Complaint submitted ✓');
    } catch (e) {
      final c = Complaint(
        id: id,
        category: cat,
        priority: _priority,
        text: text,
        name: name,
        rollNo: rollNo,
        timestamp: DateTime.now(),
        detectionSummary: 'Auto-analysis unavailable. Saved for manual review.',
        suggestedSolution: 'A staff member will review and respond within 3-5 working days.',
        estimatedResolution: 'TBD',
        assignedDepartment: cat,
        status: ComplaintStatus.pending,
      );
      widget.onSubmit(c);
      setState(() { _result = c; _loading = false; });
      _snack('Saved — pending manual review');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('Department / Category'),
          const SizedBox(height: 5),
          _CategoryPicker(
            value: _selectedCategory,
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),
          const SizedBox(height: 12),
          _FieldLabel('Priority'),
          const SizedBox(height: 5),
          _StyledDropdown<String>(
            value: _priority,
            items: const ['Low', 'Medium', 'High'],
            labels: const [
              'Low — general feedback or suggestion',
              'Medium — needs timely attention',
              'High — urgent, affecting academics or safety',
            ],
            onChanged: (v) => setState(() => _priority = v!),
          ),
          const SizedBox(height: 12),
          _FieldLabel('Roll Number / Student ID (optional)'),
          const SizedBox(height: 5),
          _StyledTextField(controller: _rollCtrl, hint: 'e.g. 21CS045'),
          const SizedBox(height: 12),
          _FieldLabel('Describe your complaint'),
          const SizedBox(height: 5),
          _StyledTextField(
            controller: _textCtrl,
            hint: 'Be specific — mention dates, faculty names, incident details…',
            maxLines: 5,
            onChanged: (_) => setState(() {}),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('${_textCtrl.text.length} / 1000',
                  style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
            ),
          ),
          const SizedBox(height: 12),
          _FieldLabel('Your name (optional — leave blank to stay anonymous)'),
          const SizedBox(height: 5),
          _StyledTextField(controller: _nameCtrl, hint: 'Anonymous'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_rounded, size: 16),
              label: Text(_loading ? 'Analysing…' : 'Analyse & Submit Complaint'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            _AIResultCard(complaint: _result!),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// CATEGORY PICKER
// ─────────────────────────────────────────
class _CategoryPicker extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CategoryPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? 'Select a category...',
                style: TextStyle(
                    fontSize: 14,
                    color: value == null ? AppColors.textFaint : AppColors.textPrimary),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CategorySheet(selected: value, onSelect: (v) {
        onChanged(v);
        Navigator.pop(context);
      }),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _CategorySheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.textFaint, borderRadius: BorderRadius.circular(99))),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categoryGroups.entries.map((group) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(group.key,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textFaint,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.09)),
                    ),
                    ...group.value.map((cat) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(cat,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: selected == cat ? AppColors.accentMid : AppColors.textPrimary,
                                  fontWeight: selected == cat ? FontWeight.w600 : FontWeight.w400)),
                          trailing: selected == cat
                              ? const Icon(Icons.check_rounded, color: AppColors.accentMid, size: 16)
                              : null,
                          onTap: () => onSelect(cat),
                        )),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// AI RESULT CARD
// ─────────────────────────────────────────
class _AIResultCard extends StatelessWidget {
  final Complaint complaint;
  const _AIResultCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final isReal = !complaint.isFake;
    final score = isReal ? complaint.realConfidence : complaint.fakeConfidence;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.25), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.smart_toy_rounded, size: 17, color: AppColors.accentMid),
            const SizedBox(width: 8),
            const Text('AI Analysis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            _StatusBadge(
              label: isReal ? '✓ Authentic' : '⚠ Flagged',
              bg: isReal ? AppColors.greenBg : AppColors.redBg,
              fg: isReal ? AppColors.green : AppColors.red,
            ),
          ]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Authenticity confidence', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text('$score%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isReal ? AppColors.green : AppColors.red)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(isReal ? AppColors.green : AppColors.red),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 12),
          _SectionLabel('Detection Summary'),
          const SizedBox(height: 4),
          Text(complaint.detectionSummary,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.65)),
          const SizedBox(height: 12),
          _SectionLabel('Suggested Resolution'),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Text(complaint.suggestedSolution,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.65)),
          ),
          if (complaint.escalate) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.amberBg, borderRadius: BorderRadius.circular(9)),
              child: const Row(children: [
                Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.amber),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Escalation recommended — requires Dean / HOD attention',
                      style: TextStyle(fontSize: 12, color: AppColors.amber)),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionLabel('Complaint ID'),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.accent.withOpacity(0.25), width: 0.5),
                ),
                child: Text(complaint.id,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accentMid,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _SectionLabel('Assigned to'),
              const SizedBox(height: 3),
              Text(complaint.assignedDepartment,
                  style: const TextStyle(fontSize: 12, color: AppColors.accentMid, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// CASES TAB
// ─────────────────────────────────────────
class CasesTab extends StatefulWidget {
  final List<Complaint> complaints;
  final VoidCallback onUpdate;

  const CasesTab({super.key, required this.complaints, required this.onUpdate});

  @override
  State<CasesTab> createState() => _CasesTabState();
}

class _CasesTabState extends State<CasesTab> {
  String _filterStatus = 'all';
  String _filterPriority = 'all';

  List<Complaint> get _filtered => widget.complaints.where((c) {
        final statusMatch = _filterStatus == 'all' ||
            (_filterStatus == 'Open' && c.status == ComplaintStatus.open) ||
            (_filterStatus == 'Pending' && c.status == ComplaintStatus.pending) ||
            (_filterStatus == 'Resolved' && c.status == ComplaintStatus.resolved) ||
            (_filterStatus == 'Fake' && c.status == ComplaintStatus.fake);
        final prioMatch = _filterPriority == 'all' || c.priority == _filterPriority;
        return statusMatch && prioMatch;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            Expanded(
              child: _StyledDropdown<String>(
                value: _filterStatus,
                items: const ['all', 'Open', 'Pending', 'Resolved', 'Fake'],
                labels: const ['All statuses', 'Open', 'Under review', 'Resolved', 'Flagged'],
                onChanged: (v) => setState(() => _filterStatus = v!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StyledDropdown<String>(
                value: _filterPriority,
                items: const ['all', 'High', 'Medium', 'Low'],
                labels: const ['All priorities', 'High', 'Medium', 'Low'],
                onChanged: (v) => setState(() => _filterPriority = v!),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.inbox_rounded, size: 44, color: AppColors.textFaint),
                    SizedBox(height: 10),
                    Text('No complaints found', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                    SizedBox(height: 4),
                    Text('Submit one from the Submit tab', style: TextStyle(fontSize: 12, color: AppColors.textFaint)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _ComplaintCard(
                    complaint: _filtered[i],
                    onTap: () => _openDetail(_filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  void _openDetail(Complaint c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DetailSheet(
        complaint: c,
        onUpdate: () { widget.onUpdate(); setState(() {}); },
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;

  const _ComplaintCard({required this.complaint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = complaint;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.id,
                      style: const TextStyle(fontSize: 10, color: AppColors.textFaint, fontFamily: 'Courier')),
                  const SizedBox(height: 2),
                  Text(c.category,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ]),
              ),
              _StatusBadgeFromStatus(c.status),
            ]),
            const SizedBox(height: 6),
            Text(
              c.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 4, children: [
              _Pill(label: _timeAgo(c.timestamp), icon: Icons.access_time_rounded),
              _PriorityPill(c.priority),
              if (c.rollNo != '—') _Pill(label: c.rollNo),
              if (c.escalate) _Pill(label: '⚡ Escalate', color: AppColors.amber),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// DETAIL SHEET
// ─────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onUpdate;

  const _DetailSheet({required this.complaint, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final c = complaint;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.textFaint, borderRadius: BorderRadius.circular(99))),
          ),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.id, style: const TextStyle(fontSize: 10, color: AppColors.textFaint, fontFamily: 'Courier')),
              const SizedBox(height: 2),
              Text(c.category, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ])),
            _StatusBadgeFromStatus(c.status),
          ]),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Text(c.text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.7)),
          ),
          const SizedBox(height: 12),
          _InfoRow('Student', c.name),
          if (c.rollNo != '—') _InfoRow('Roll No.', c.rollNo),
          _InfoRow('Priority', c.priority, valueColor: _priorityColor(c.priority)),
          _InfoRow('Authenticity', c.isFake ? '⚠ Flagged as fake' : '✓ Authentic',
              valueColor: c.isFake ? AppColors.red : AppColors.green),
          _InfoRow('Assigned to', c.assignedDepartment.isEmpty ? c.category : c.assignedDepartment),
          _InfoRow('Est. resolution', c.estimatedResolution),
          _InfoRow('Submitted', '${c.timestamp.day}/${c.timestamp.month}/${c.timestamp.year}'),
          if (c.escalate) _InfoRow('⚡ Escalation', 'Required', valueColor: AppColors.amber),
          const SizedBox(height: 14),
          _SectionLabel('AI Detection Summary'),
          const SizedBox(height: 4),
          Text(c.detectionSummary.isEmpty ? '—' : c.detectionSummary,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.65)),
          const SizedBox(height: 12),
          _SectionLabel('Suggested Resolution Steps'),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Text(c.suggestedSolution.isEmpty ? '—' : c.suggestedSolution,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.7)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            if (c.status != ComplaintStatus.resolved && c.status != ComplaintStatus.fake)
              Expanded(
                child: _ActionBtn(
                  label: 'Mark Resolved',
                  icon: Icons.check_circle_rounded,
                  bg: AppColors.greenBg,
                  fg: AppColors.green,
                  onTap: () {
                    c.status = ComplaintStatus.resolved;
                    onUpdate();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Complaint resolved ✓', style: TextStyle(fontWeight: FontWeight.w600)),
                      backgroundColor: AppColors.accent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ));
                  },
                ),
              ),
            if (c.status != ComplaintStatus.resolved && c.status != ComplaintStatus.fake) const SizedBox(width: 8),
            if (c.status == ComplaintStatus.open)
              Expanded(
                child: _ActionBtn(
                  label: 'Under Review',
                  icon: Icons.hourglass_top_rounded,
                  onTap: () {
                    c.status = ComplaintStatus.pending;
                    onUpdate();
                    Navigator.pop(context);
                  },
                ),
              )
            else
              Expanded(
                child: _ActionBtn(
                  label: 'Close',
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ),
          ]),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Color _priorityColor(String p) =>
      p == 'High' ? AppColors.red : p == 'Medium' ? AppColors.amber : AppColors.green;
}

// ─────────────────────────────────────────
// STATS TAB
// ─────────────────────────────────────────
class StatsTab extends StatelessWidget {
  final List<Complaint> complaints;
  const StatsTab({super.key, required this.complaints});

  @override
  Widget build(BuildContext context) {
    final total = complaints.length;
    final open = complaints.where((c) => c.status == ComplaintStatus.open).length;
    final resolved = complaints.where((c) => c.status == ComplaintStatus.resolved).length;
    final fake = complaints.where((c) => c.isFake).length;

    final catCounts = <String, int>{};
    for (final cat in allCategories) catCounts[cat] = 0;
    for (final c in complaints) {
      if (catCounts.containsKey(c.category)) catCounts[c.category] = catCounts[c.category]! + 1;
    }
    final sorted = catCounts.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isNotEmpty ? sorted.first.value : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            _StatCard(label: 'Total complaints', value: '$total', color: AppColors.textPrimary),
            _StatCard(label: 'Open', value: '$open', color: AppColors.blue),
            _StatCard(label: 'Resolved', value: '$resolved', color: AppColors.green),
            _StatCard(label: 'Flagged fake', value: '$fake', color: AppColors.red),
          ],
        ),
        const SizedBox(height: 20),
        Row(children: const [
          Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.accentMid),
          SizedBox(width: 6),
          Text('Category breakdown',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 12),
        if (sorted.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(children: [
                Icon(Icons.pie_chart_outline_rounded, size: 44, color: AppColors.textFaint),
                SizedBox(height: 10),
                Text('No data yet', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                SizedBox(height: 4),
                Text('Submit complaints to see breakdown', style: TextStyle(fontSize: 12, color: AppColors.textFaint)),
              ]),
            ),
          )
        else
          ...sorted.map((e) {
            final pct = e.value / maxVal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: Text(e.key,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text('${e.value}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 5,
                  ),
                ),
              ]),
            );
          }),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ─────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500, letterSpacing: 0.02));
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(fontSize: 10, color: AppColors.textFaint, letterSpacing: 0.09, fontWeight: FontWeight.w600));
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textFaint),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final List<String> labels;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({required this.value, required this.items, required this.labels, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.card,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 18),
        items: items.asMap().entries.map((e) => DropdownMenuItem<T>(
          value: e.value,
          child: Text(labels[e.key], style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _StatusBadge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _StatusBadgeFromStatus extends StatelessWidget {
  final ComplaintStatus status;
  const _StatusBadgeFromStatus(this.status);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ComplaintStatus.resolved:
        return _StatusBadge(label: 'Resolved', bg: AppColors.greenBg, fg: AppColors.green);
      case ComplaintStatus.fake:
        return _StatusBadge(label: 'Flagged', bg: AppColors.redBg, fg: AppColors.red);
      case ComplaintStatus.pending:
        return _StatusBadge(label: 'Under Review', bg: AppColors.amberBg, fg: AppColors.amber);
      case ComplaintStatus.open:
        return _StatusBadge(label: 'Open', bg: AppColors.blueBg, fg: AppColors.blue);
    }
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const _Pill({required this.label, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color?.withOpacity(0.25) ?? AppColors.border, width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 11, color: color ?? AppColors.textMuted),
          const SizedBox(width: 3),
        ],
        Text(label, style: TextStyle(fontSize: 11, color: color ?? AppColors.textMuted)),
      ]),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final String priority;
  const _PriorityPill(this.priority);

  @override
  Widget build(BuildContext context) {
    final color = priority == 'High'
        ? AppColors.red
        : priority == 'Medium'
            ? AppColors.amber
            : AppColors.green;
    return _Pill(label: priority, color: color);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted))),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary)),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? bg;
  final Color? fg;

  const _ActionBtn({required this.label, required this.icon, required this.onTap, this.bg, this.fg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg ?? Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: bg == null ? Border.all(color: AppColors.border, width: 0.5) : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 15, color: fg ?? AppColors.textPrimary),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: fg ?? AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────
// UTILS
// ─────────────────────────────────────────
String _timeAgo(DateTime d) {
  final s = DateTime.now().difference(d).inSeconds;
  if (s < 60) return 'just now';
  if (s < 3600) return '${s ~/ 60}m ago';
  if (s < 86400) return '${s ~/ 3600}h ago';
  return '${s ~/ 86400}d ago';
}