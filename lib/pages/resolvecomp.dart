import 'package:flutter/material.dart';

void main() {
  runApp(const ResolutionCentreApp());
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
  List<String> notes;

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
    List<String>? notes,
  }) : notes = notes ?? [];
}

// ─────────────────────────────────────────
// SAMPLE DATA
// ─────────────────────────────────────────
List<Complaint> sampleComplaints() => [
      Complaint(
        id: 'UNI-4821',
        category: 'Faculty Conduct',
        priority: 'High',
        text:
            'Professor did not return exam papers for 3 weeks despite repeated requests. Several students are worried about their grades before the semester ends.',
        name: 'Priya Sharma',
        rollNo: '21CS045',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isFake: false,
        realConfidence: 91,
        fakeConfidence: 9,
        detectionSummary:
            'Complaint contains specific verifiable claims with dates and context. Language is measured and professional with no exaggeration markers.',
        suggestedSolution:
            '1. HOD to contact faculty member within 24 hours.\n2. Require paper return within 48 hours.\n3. Send confirmation to student.\n4. Document in faculty conduct log.\n5. Follow up after resolution.',
        escalate: true,
        estimatedResolution: '2 working days',
        assignedDepartment: 'Academic Affairs',
        status: ComplaintStatus.open,
      ),
      Complaint(
        id: 'UNI-3917',
        category: 'Wi-Fi & IT Infrastructure',
        priority: 'Medium',
        text:
            'The hostel block C has had no internet since Monday. It has been 4 days and no response from IT helpdesk despite 3 tickets raised.',
        name: 'Anonymous',
        rollNo: '—',
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        isFake: false,
        realConfidence: 88,
        fakeConfidence: 12,
        detectionSummary:
            'Infrastructure complaint with specific location and timeline. Multiple ticket references add credibility.',
        suggestedSolution:
            '1. Dispatch IT team to Block C within 4 hours.\n2. Diagnose router or fiber fault.\n3. Provide ETA to hostel warden.\n4. Close all open tickets with resolution note.',
        escalate: false,
        estimatedResolution: '1 working day',
        assignedDepartment: 'IT Infrastructure',
        status: ComplaintStatus.pending,
      ),
      Complaint(
        id: 'UNI-3305',
        category: 'Canteen & Food Quality',
        priority: 'Low',
        text:
            'The canteen food quality has drastically dropped. Found a foreign object in rice on Tuesday. Other students have also complained informally.',
        name: 'Rahul Menon',
        rollNo: '20ME112',
        timestamp: DateTime.now().subtract(const Duration(hours: 48)),
        isFake: false,
        realConfidence: 79,
        fakeConfidence: 21,
        detectionSummary:
            'Food quality complaint is plausible and specific. Confidence slightly reduced as the foreign object claim is unverified.',
        suggestedSolution:
            '1. Issue formal notice to canteen contractor.\n2. Conduct unannounced food quality inspection.\n3. Review recent supplier batch.\n4. Gather written statements from affected students.',
        escalate: false,
        estimatedResolution: '3 working days',
        assignedDepartment: 'Student Welfare',
        status: ComplaintStatus.resolved,
      ),
      Complaint(
        id: 'UNI-2741',
        category: 'Ragging / Bullying',
        priority: 'High',
        text:
            'I am a fresher and some seniors came to my room last night and tried to force me to do things. I am scared and do not want to name them yet.',
        name: 'Anonymous',
        rollNo: '—',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isFake: false,
        realConfidence: 94,
        fakeConfidence: 6,
        detectionSummary:
            'Ragging complaint with high authenticity indicators — anonymity, fear language, and specificity of incident time. Requires immediate escalation.',
        suggestedSolution:
            '1. Warden to conduct welfare check immediately.\n2. Anti-ragging committee to be convened within 24 hours.\n3. Assign student a confidential counsellor.\n4. Review hostel CCTV footage.\n5. File FIR if student consents.',
        escalate: true,
        estimatedResolution: 'Immediate',
        assignedDepartment: 'Anti-Ragging Committee',
        status: ComplaintStatus.pending,
      ),
      Complaint(
        id: 'UNI-2410',
        category: 'Fees & Scholarship',
        priority: 'Medium',
        text:
            'I submitted all scholarship documents on time but the portal still shows unpaid fees. I may get detained from exams if this is not resolved.',
        name: 'Arjun Nair',
        rollNo: '21BA033',
        timestamp: DateTime.now().subtract(const Duration(hours: 72)),
        isFake: true,
        realConfidence: 22,
        fakeConfidence: 78,
        detectionSummary:
            'Several inconsistencies detected: claim of on-time submission conflicts with portal status. Language patterns match previously flagged template complaints.',
        suggestedSolution:
            '1. Manually verify document submission timestamps.\n2. Cross-check scholarship portal logs.\n3. Contact financial aid office for clarification.\n4. Respond to student within 2 days.',
        escalate: false,
        estimatedResolution: 'TBD',
        assignedDepartment: 'Finance & Scholarships',
        status: ComplaintStatus.fake,
      ),
    ];

// ─────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────
class ResolutionCentreApp extends StatelessWidget {
  const ResolutionCentreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniBridge Resolution Centre',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.bg,
        useMaterial3: true,
      ),
      home: const ResolutionCentreScreen(),
    );
  }
}

// ─────────────────────────────────────────
// RESOLUTION CENTRE SCREEN
// ─────────────────────────────────────────
class ResolutionCentreScreen extends StatefulWidget {
  const ResolutionCentreScreen({super.key});

  @override
  State<ResolutionCentreScreen> createState() => _ResolutionCentreScreenState();
}

class _ResolutionCentreScreenState extends State<ResolutionCentreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Complaint> _complaints = sampleComplaints();
  final List<ActivityEntry> _activityLog = [];
  ComplaintStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Complaint> get _filtered {
    if (_filterStatus == null) return _complaints;
    return _complaints.where((c) => c.status == _filterStatus).toList();
  }

  void _setStatus(Complaint c, ComplaintStatus status) {
    setState(() {
      c.status = status;
      if (status == ComplaintStatus.fake) c.isFake = true;
      _activityLog.insert(
        0,
        ActivityEntry(
          id: c.id,
          category: c.category,
          action: _statusActionLabel(status),
          status: status,
          time: DateTime.now(),
        ),
      );
    });
  }

  String _statusActionLabel(ComplaintStatus s) {
    switch (s) {
      case ComplaintStatus.resolved:
        return 'Marked as resolved';
      case ComplaintStatus.pending:
        return 'Moved to under review';
      case ComplaintStatus.fake:
        return 'Flagged as fake';
      case ComplaintStatus.open:
        return 'Reopened';
    }
  }

  void _addNote(Complaint c, String note) {
    setState(() {
      c.notes.add(note);
      _activityLog.insert(
        0,
        ActivityEntry(
          id: c.id,
          category: c.category,
          action: 'Note: ${note.length > 40 ? note.substring(0, 40) + '…' : note}',
          status: c.status,
          time: DateTime.now(),
        ),
      );
    });
  }

  int get _openCount => _complaints.where((c) => c.status == ComplaintStatus.open).length;
  int get _resolvedCount => _complaints.where((c) => c.status == ComplaintStatus.resolved).length;
  int get _fakeCount => _complaints.where((c) => c.isFake || c.status == ComplaintStatus.fake).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CasesTab(
                    complaints: _filtered,
                    allComplaints: _complaints,
                    filterStatus: _filterStatus,
                    onFilterChanged: (s) => setState(() => _filterStatus = s),
                    onSetStatus: _setStatus,
                    onAddNote: _addNote,
                    openCount: _openCount,
                    resolvedCount: _resolvedCount,
                    fakeCount: _fakeCount,
                  ),
                  _ActivityTab(log: _activityLog),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 14)],
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('UniBridge',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2)),
              Text('Resolution Centre',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 0.5),
            ),
            child: const Text('Admin view',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentMid)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.accent,
        indicatorWeight: 2,
        labelColor: AppColors.accentMid,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        tabs: const [
          Tab(text: 'Cases'),
          Tab(text: 'Activity'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// CASES TAB
// ─────────────────────────────────────────
class _CasesTab extends StatelessWidget {
  final List<Complaint> complaints;
  final List<Complaint> allComplaints;
  final ComplaintStatus? filterStatus;
  final ValueChanged<ComplaintStatus?> onFilterChanged;
  final void Function(Complaint, ComplaintStatus) onSetStatus;
  final void Function(Complaint, String) onAddNote;
  final int openCount;
  final int resolvedCount;
  final int fakeCount;

  const _CasesTab({
    required this.complaints,
    required this.allComplaints,
    required this.filterStatus,
    required this.onFilterChanged,
    required this.onSetStatus,
    required this.onAddNote,
    required this.openCount,
    required this.resolvedCount,
    required this.fakeCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatsRow(
              total: allComplaints.length,
              open: openCount,
              resolved: resolvedCount,
              fake: fakeCount),
          const SizedBox(height: 16),
          _FilterChips(current: filterStatus, onChanged: onFilterChanged),
          const SizedBox(height: 12),
          if (complaints.isEmpty)
            const _EmptyState(message: 'No complaints found', sub: 'Change filter to see more')
          else
            ...complaints.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ComplaintCard(
                    complaint: c,
                    onTap: () => _openDetail(context, c),
                  ),
                )),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, Complaint c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DetailSheet(
        complaint: c,
        onSetStatus: (s) {
          onSetStatus(c, s);
          Navigator.pop(context);
        },
        onAddNote: (note) => onAddNote(c, note),
      ),
    );
  }
}

// ─────────────────────────────────────────
// STATS ROW
// ─────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int total, open, resolved, fake;
  const _StatsRow({required this.total, required this.open, required this.resolved, required this.fake});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Total', value: '$total', color: AppColors.textPrimary),
        const SizedBox(width: 10),
        _StatCard(label: 'Open', value: '$open', color: AppColors.blue),
        const SizedBox(width: 10),
        _StatCard(label: 'Resolved', value: '$resolved', color: AppColors.green),
        const SizedBox(width: 10),
        _StatCard(label: 'Flagged', value: '$fake', color: AppColors.red),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// FILTER CHIPS
// ─────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final ComplaintStatus? current;
  final ValueChanged<ComplaintStatus?> onChanged;

  const _FilterChips({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = <ComplaintStatus?>[null, ComplaintStatus.open, ComplaintStatus.pending, ComplaintStatus.resolved, ComplaintStatus.fake];
    final labels = ['All', 'Open', 'Under review', 'Resolved', 'Flagged'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final active = current == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onChanged(filters[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? AppColors.accentLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: active ? AppColors.accent.withOpacity(0.4) : AppColors.border,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? AppColors.accentMid : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────
// COMPLAINT CARD
// ─────────────────────────────────────────
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
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textFaint, fontFamily: 'monospace')),
                  const SizedBox(height: 2),
                  Text(c.category,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ]),
              ),
              _StatusBadge(c.status),
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
              if (c.escalate)
                _Pill(label: '⚡ Escalate', color: AppColors.amber),
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
class _DetailSheet extends StatefulWidget {
  final Complaint complaint;
  final ValueChanged<ComplaintStatus> onSetStatus;
  final ValueChanged<String> onAddNote;

  const _DetailSheet({
    required this.complaint,
    required this.onSetStatus,
    required this.onAddNote,
  });

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Complaint get c => widget.complaint;

  @override
  Widget build(BuildContext context) {
    final isReal = !c.isFake;
    final conf = isReal ? c.realConfidence : c.fakeConfidence;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: AppColors.textFaint, borderRadius: BorderRadius.circular(99)),
            ),
          ),

          // Header
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.id,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textFaint, fontFamily: 'monospace')),
                const SizedBox(height: 2),
                Text(c.category,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ]),
            ),
            _StatusBadge(c.status),
          ]),
          const SizedBox(height: 14),

          // Complaint text
          _SectionLabel('Complaint'),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Text(c.text,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.7)),
          ),
          const SizedBox(height: 14),

          // AI Analysis
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 0.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.smart_toy_rounded, size: 16, color: AppColors.accentMid),
                const SizedBox(width: 6),
                const Text('AI analysis',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(width: 8),
                _AuthBadge(isReal: isReal),
              ]),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Authenticity confidence',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Text('$conf%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isReal ? AppColors.green : AppColors.red)),
              ]),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: conf / 100,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(isReal ? AppColors.green : AppColors.red),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 10),
              Text(c.detectionSummary,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.65)),
            ]),
          ),
          const SizedBox(height: 14),

          // Solution
          _SectionLabel('Suggested resolution steps'),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Text(c.suggestedSolution,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.7)),
          ),

          // Escalation warning
          if (c.escalate) ...[
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
          const SizedBox(height: 14),

          // Info table
          _InfoRow('Student', c.name),
          if (c.rollNo != '—') _InfoRow('Roll no.', c.rollNo),
          _InfoRow('Priority', c.priority, valueColor: _priorityColor(c.priority)),
          _InfoRow('Authenticity', c.isFake ? '⚠ Flagged' : '✓ Authentic',
              valueColor: c.isFake ? AppColors.red : AppColors.green),
          _InfoRow('Department', c.assignedDepartment.isEmpty ? c.category : c.assignedDepartment),
          _InfoRow('Est. resolution', c.estimatedResolution),
          _InfoRow('Submitted',
              '${c.timestamp.day}/${c.timestamp.month}/${c.timestamp.year}'),
          if (c.escalate) _InfoRow('⚡ Escalation', 'Required', valueColor: AppColors.amber),
          const SizedBox(height: 14),

          // Notes
          if (c.notes.isNotEmpty) ...[
            _SectionLabel('Notes'),
            const SizedBox(height: 6),
            ...c.notes.map((n) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(n,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
                )),
            const SizedBox(height: 8),
          ],

          // Add note
          _SectionLabel('Add note'),
          const SizedBox(height: 6),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Internal note for this complaint…',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textFaint),
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
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                final note = _noteCtrl.text.trim();
                if (note.isEmpty) return;
                widget.onAddNote(note);
                setState(() => _noteCtrl.clear());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.accent.withOpacity(0.35), width: 0.5),
                ),
                child: const Text('Add note',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentMid)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          _SectionLabel('Actions'),
          const SizedBox(height: 8),
          _ActionButtons(complaint: c, onSetStatus: widget.onSetStatus),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Color _priorityColor(String p) =>
      p == 'High' ? AppColors.red : p == 'Medium' ? AppColors.amber : AppColors.green;
}

// ─────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final Complaint complaint;
  final ValueChanged<ComplaintStatus> onSetStatus;

  const _ActionButtons({required this.complaint, required this.onSetStatus});

  @override
  Widget build(BuildContext context) {
    final s = complaint.status;
    return Wrap(spacing: 8, runSpacing: 8, children: [
      if (s != ComplaintStatus.resolved && s != ComplaintStatus.fake)
        _ActionBtn(
          label: 'Mark resolved',
          icon: Icons.check_circle_rounded,
          bg: AppColors.greenBg,
          fg: AppColors.green,
          onTap: () => onSetStatus(ComplaintStatus.resolved),
        ),
      if (s == ComplaintStatus.open)
        _ActionBtn(
          label: 'Under review',
          icon: Icons.hourglass_top_rounded,
          bg: AppColors.amberBg,
          fg: AppColors.amber,
          onTap: () => onSetStatus(ComplaintStatus.pending),
        ),
      if (s != ComplaintStatus.fake)
        _ActionBtn(
          label: 'Flag as fake',
          icon: Icons.flag_rounded,
          bg: AppColors.redBg,
          fg: AppColors.red,
          onTap: () => onSetStatus(ComplaintStatus.fake),
        ),
      if (s == ComplaintStatus.resolved || s == ComplaintStatus.fake)
        _ActionBtn(
          label: 'Reopen',
          icon: Icons.refresh_rounded,
          onTap: () => onSetStatus(ComplaintStatus.open),
        ),
    ]);
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: bg ?? Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: bg == null ? Border.all(color: AppColors.border, width: 0.5) : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: fg ?? AppColors.textPrimary),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg ?? AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ACTIVITY TAB
// ─────────────────────────────────────────
class ActivityEntry {
  final String id, category, action;
  final ComplaintStatus status;
  final DateTime time;

  const ActivityEntry({
    required this.id,
    required this.category,
    required this.action,
    required this.status,
    required this.time,
  });
}

class _ActivityTab extends StatelessWidget {
  final List<ActivityEntry> log;
  const _ActivityTab({required this.log});

  Color _dotColor(ComplaintStatus s) {
    switch (s) {
      case ComplaintStatus.resolved: return AppColors.green;
      case ComplaintStatus.pending: return AppColors.amber;
      case ComplaintStatus.fake: return AppColors.red;
      case ComplaintStatus.open: return AppColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (log.isEmpty) {
      return const _EmptyState(
        message: 'No activity yet',
        sub: 'Resolve or update complaints to see the log',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: log.length,
      itemBuilder: (_, i) {
        final entry = log[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: _dotColor(entry.status),
                  shape: BoxShape.circle,
                ),
              ),
              if (i < log.length - 1)
                Container(width: 1, height: 32, color: AppColors.border),
            ]),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
                      children: [
                        TextSpan(
                            text: entry.action,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                        const TextSpan(text: ' — '),
                        TextSpan(
                            text: entry.category,
                            style: const TextStyle(color: AppColors.accentMid)),
                        const TextSpan(text: ' '),
                        TextSpan(
                            text: entry.id,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textFaint,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(_timeAgo(entry.time),
                      style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final ComplaintStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ComplaintStatus.resolved:
        return _Badge(label: 'Resolved', bg: AppColors.greenBg, fg: AppColors.green);
      case ComplaintStatus.fake:
        return _Badge(label: 'Flagged', bg: AppColors.redBg, fg: AppColors.red);
      case ComplaintStatus.pending:
        return _Badge(label: 'Under review', bg: AppColors.amberBg, fg: AppColors.amber);
      case ComplaintStatus.open:
        return _Badge(label: 'Open', bg: AppColors.blueBg, fg: AppColors.blue);
    }
  }
}

class _AuthBadge extends StatelessWidget {
  final bool isReal;
  const _AuthBadge({required this.isReal});

  @override
  Widget build(BuildContext context) {
    return _Badge(
      label: isReal ? '✓ Authentic' : '⚠ Flagged',
      bg: isReal ? AppColors.greenBg : AppColors.redBg,
      fg: isReal ? AppColors.green : AppColors.red,
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
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
        border: Border.all(
            color: color?.withOpacity(0.25) ?? AppColors.border, width: 0.5),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 10,
            color: AppColors.textFaint,
            letterSpacing: 0.09,
            fontWeight: FontWeight.w600),
      );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted))),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message, sub;
  const _EmptyState({required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inbox_rounded, size: 44, color: AppColors.textFaint),
          const SizedBox(height: 10),
          Text(message,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(fontSize: 12, color: AppColors.textFaint)),
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