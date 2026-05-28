import 'package:flutter/material.dart';

import '../utils/routes.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SignupPage  —  Pure Purple scheme
//  Matches login_page.dart palette exactly.
// ════════════════════════════════════════════════════════════════════════════

// ── Palette ───────────────────────────────────────────────────────────────────
const _bgA        = Color(0xFF3B0FAB);
const _bgB        = Color(0xFF6C3FC9);
const _bgC        = Color(0xFF0D0730);
const _accentA    = Color(0xFF9B72F7);
const _accentB    = Color(0xFF7C3AED);
const _fuchsia    = Color(0xFFE879F9);
const _white      = Colors.white;
const _glass      = Color(0x1AFFFFFF);
const _glassBorder= Color(0x33FFFFFF);
const _wText      = Color(0xFFFFFFFF);
const _wMuted     = Color(0x99FFFFFF);
const _wHint      = Color(0x44FFFFFF);

const _roleColors = {
  _Role.student : [Color(0xFF818CF8), Color(0xFF6366F1)],
  _Role.faculty : [Color(0xFFA78BFA), Color(0xFF7C3AED)],
  _Role.admin   : [Color(0xFFC084FC), Color(0xFF9333EA)],
  _Role.event   : [Color(0xFFE879F9), Color(0xFFD946EF)],
};

// ── Role data ─────────────────────────────────────────────────────────────────
enum _Role { student, faculty, admin, event }

class _RoleInfo {
  final String label, emoji, btnText, sectionTitle;
  const _RoleInfo({required this.label, required this.emoji,
      required this.btnText, required this.sectionTitle});
}

const Map<_Role, _RoleInfo> _roles = {
  _Role.student: _RoleInfo(label: 'Student',       emoji: '🧑‍🎓',
      btnText: 'Create Student Account',    sectionTitle: 'Student Details'),
  _Role.faculty: _RoleInfo(label: 'Faculty',       emoji: '👨‍🏫',
      btnText: 'Register as Faculty',       sectionTitle: 'Faculty Details'),
  _Role.admin:   _RoleInfo(label: 'Admin',         emoji: '🛡️',
      btnText: 'Request Admin Account',     sectionTitle: 'Admin Details'),
  _Role.event:   _RoleInfo(label: 'Event Manager', emoji: '🎪',
      btnText: 'Register as Event Manager', sectionTitle: 'Event Manager Details'),
};

// ════════════════════════════════════════════════════════════════════════════
class SignupPage extends StatefulWidget {
  final _Role initialRole;
  const SignupPage({super.key, this.initialRole = _Role.student});
  @override State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  late _Role _role;
  bool  _terms    = false;
  bool  _obscPw   = true;
  bool  _obscPw2  = true;
  int   _pwStr    = 0;
  final _pwCtrl   = TextEditingController();

  String? _gender, _dept, _enrollY, _sem, _design, _accessLvl, _evtCat, _exp;

  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 520))..forward();
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override void dispose() { _ctrl.dispose(); _pwCtrl.dispose(); super.dispose(); }

  void _checkPw(String pw) {
    int s = 0;
    if (pw.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(pw) && RegExp(r'[a-z]').hasMatch(pw)) s++;
    if (RegExp(r'[0-9]').hasMatch(pw) && RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) s++;
    setState(() => _pwStr = s);
  }

  @override
  Widget build(BuildContext context) {
    final info = _roles[_role]!;
    final clrs = _roleColors[_role]!;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: _PurpleBg(size: size, child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
            child: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Back + Brand
                Row(children: [
                  _BackBtn(onTap: () => Navigator.maybePop(context)),
                  const SizedBox(width: 14),
                  const Expanded(child: _Brand()),
                ]),
                const SizedBox(height: 28),

                // Role tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _Role.values.map((r) {
                      final d = _roles[r]!;
                      final rc = _roleColors[r]!;
                      final active = _role == r;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _role = r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: active ? LinearGradient(
                                colors: [rc[0].withOpacity(.35), rc[1].withOpacity(.18)],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              ) : null,
                              color: active ? null : _white.withOpacity(.07),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: active ? rc[0] : _white.withOpacity(.20),
                                width: 1.5),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(d.emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(d.label, style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: active ? _wText : _white.withOpacity(.60))),
                            ]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Form card
                _GlassCard(accentColor: clrs[0], child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // ── Personal Info ─────────────────────────────────────────
                  _SecTitle('Personal Information'),
                  _R2(children: [
                    _GF(label: 'First Name',    hint: 'Arjun',  req: true),
                    _GF(label: 'Last Name',     hint: 'Sharma', req: true),
                  ]),
                  const SizedBox(height: 14),
                  _R2(children: [
                    _GF(label: 'Date of Birth', hint: 'YYYY-MM-DD', req: true,
                        kt: TextInputType.datetime),
                    _GDD(label: 'Gender', value: _gender,
                        items: const ['Male','Female','Non-binary','Prefer not to say'],
                        onCh: (v) => setState(() => _gender = v)),
                  ]),
                  const SizedBox(height: 14),
                  _R2(children: [
                    _GF(label: 'Phone Number', hint: '+91 98765 43210',
                        kt: TextInputType.phone),
                    _GF(label: 'Email Address', hint: 'you@edu.ac', req: true,
                        kt: TextInputType.emailAddress),
                  ]),

                  // ── Role fields ───────────────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: KeyedSubtree(key: ValueKey(_role),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SecTitle(info.sectionTitle),
                          _buildRoleFields(),
                        ]),
                    ),
                  ),

                  // ── Security ──────────────────────────────────────────────
                  _SecTitle('Security'),
                  _R2(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _GF(label: 'Password', hint: 'Min. 8 characters',
                        req: true, obs: _obscPw, ctrl: _pwCtrl, onCh: _checkPw,
                        suffix: IconButton(
                          icon: Icon(_obscPw
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                            color: _white.withOpacity(.50), size: 16),
                          onPressed: () => setState(() => _obscPw = !_obscPw))),
                      const SizedBox(height: 8),
                      _PwBar(strength: _pwStr),
                    ]),
                    _GF(label: 'Confirm Password', hint: 'Re-enter password',
                      req: true, obs: _obscPw2,
                      suffix: IconButton(
                        icon: Icon(_obscPw2
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                          color: _white.withOpacity(.50), size: 16),
                        onPressed: () => setState(() => _obscPw2 = !_obscPw2))),
                  ]),
                  const SizedBox(height: 20),

                  // ── Terms ─────────────────────────────────────────────────
                  GestureDetector(
                    onTap: () => setState(() => _terms = !_terms),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(width: 20, height: 20,
                        child: Checkbox(
                          value: _terms,
                          onChanged: (v) => setState(() => _terms = v!),
                          activeColor: _white, checkColor: _accentB,
                          side: BorderSide(color: _white.withOpacity(.45)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        'I agree to the Terms of Service and Privacy Policy of UniBridge. I confirm all information is accurate.',
                        style: TextStyle(fontSize: 12,
                            color: _white.withOpacity(.60), height: 1.5))),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // ── CTA button ────────────────────────────────────────────
                  _PillBtn(
                    text: '${info.btnText}  →',
                    onTap: () {
                      if (!_terms) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please accept the Terms of Service.'),
                          backgroundColor: Color(0xFF7C3AED)));
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Creating ${info.label} account…'),
                        backgroundColor: _accentB));
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                  ),
                  const SizedBox(height: 22),

                  // Divider + back to login
                  _WDiv(label: 'Already have an account?'),
                  const SizedBox(height: 14),
                  Center(child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    ),
                    child: const Text('Back to Login', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _wText,
                      decoration: TextDecoration.underline,
                      decorationColor: _wText)),
                  )),
                ])),

                const SizedBox(height: 28),
                Center(child: Text(
                  '© 2026 UniBridge — Empowering Campus Connections',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _white.withOpacity(.28)))),
                const SizedBox(height: 20),
              ]),
            )),
          ),
        ),
      )),
    );
  }

  // ── Role-specific fields ───────────────────────────────────────────────────
  Widget _buildRoleFields() {
    switch (_role) {
      case _Role.student:
        return Column(children: [
          _R2(children: [
            _GF(label: 'Student ID',     hint: 's2024001', req: true),
            _GDD(label: 'Enrollment Year', req: true, value: _enrollY,
                items: const ['2024','2023','2022','2021'],
                onCh: (v) => setState(() => _enrollY = v)),
          ]),
          const SizedBox(height: 14),
          _R2(children: [
            _GDD(label: 'Department', req: true, value: _dept,
                items: const ['Computer Science','Electronics Engineering',
                  'Mechanical Engineering','Civil Engineering',
                  'Business Administration','Arts & Humanities'],
                onCh: (v) => setState(() => _dept = v)),
            _GDD(label: 'Semester', value: _sem,
                items: List.generate(8, (i) => 'Semester ${i+1}'),
                onCh: (v) => setState(() => _sem = v)),
          ]),
        ]);

      case _Role.faculty:
        return Column(children: [
          _R2(children: [
            _GF(label: 'Faculty ID', hint: 'FAC2024001', req: true),
            _GDD(label: 'Designation', req: true, value: _design,
                items: const ['Assistant Professor','Associate Professor',
                  'Professor','Head of Department','Dean'],
                onCh: (v) => setState(() => _design = v)),
          ]),
          const SizedBox(height: 14),
          _R2(children: [
            _GDD(label: 'Department', req: true, value: _dept,
                items: const ['Computer Science','Electronics Engineering',
                  'Mechanical Engineering','Civil Engineering',
                  'Business Administration'],
                onCh: (v) => setState(() => _dept = v)),
            _GF(label: 'Specialization', hint: 'e.g. Machine Learning'),
          ]),
          const SizedBox(height: 14),
          _GF(label: 'Joining Date', hint: 'YYYY-MM-DD',
              kt: TextInputType.datetime),
        ]);

      case _Role.admin:
        return Column(children: [
          _R2(children: [
            _GF(label: 'Admin ID', hint: 'ADM2024001', req: true),
            _GDD(label: 'Access Level', req: true, value: _accessLvl,
                items: const ['Super Admin','Department Admin',
                  'Finance Admin','IT Admin'],
                onCh: (v) => setState(() => _accessLvl = v)),
          ]),
          const SizedBox(height: 14),
          _R2(children: [
            _GF(label: 'Department / Division',
                hint: 'e.g. IT Department', req: true),
            _GF(label: 'Employee ID', hint: 'EMP20240XX'),
          ]),
          const SizedBox(height: 14),
          _GF(label: 'Authorization Code',
              hint: 'Provided by institution', req: true, obs: true),
        ]);

      case _Role.event:
        return Column(children: [
          _R2(children: [
            _GF(label: 'Manager ID', hint: 'EVT2024001', req: true),
            _GF(label: 'Organization / Club',
                hint: 'e.g. Student Council', req: true),
          ]),
          const SizedBox(height: 14),
          _R2(children: [
            _GDD(label: 'Event Category', value: _evtCat,
                items: const ['Cultural & Arts','Technical & Hackathons',
                  'Sports','Academic Conferences','Social & Networking','General'],
                onCh: (v) => setState(() => _evtCat = v)),
            _GDD(label: 'Experience', value: _exp,
                items: const ['0–1 year','1–3 years','3–5 years','5+ years'],
                onCh: (v) => setState(() => _exp = v)),
          ]),
          const SizedBox(height: 14),
          _GF(label: 'Brief Bio', hint: 'Tell us a little about yourself…'),
        ]);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Shared widgets
// ════════════════════════════════════════════════════════════════════════════

class _SecTitle extends StatelessWidget {
  final String t; const _SecTitle(this.t);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(children: [
      Text(t.toUpperCase(), style: TextStyle(fontSize: 10,
          fontWeight: FontWeight.w700, color: _white.withOpacity(.50),
          letterSpacing: 2)),
      const SizedBox(width: 10),
      Expanded(child: Divider(color: _white.withOpacity(.15), thickness: 1)),
    ]),
  );
}

class _R2 extends StatelessWidget {
  final List<Widget> children; const _R2({required this.children});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: children[0]),
      const SizedBox(width: 12),
      Expanded(child: children[1]),
    ],
  );
}

// Short-named glass field
class _GF extends StatefulWidget {
  final String label, hint;
  final bool req, obs;
  final TextInputType? kt;
  final TextEditingController? ctrl;
  final void Function(String)? onCh;
  final Widget? suffix;
  const _GF({required this.label, required this.hint,
      this.req=false, this.obs=false, this.kt, this.ctrl, this.onCh, this.suffix});
  @override State<_GF> createState() => _GFState();
}
class _GFState extends State<_GF> {
  bool _f = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    RichText(text: TextSpan(
      text: widget.label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: _white.withOpacity(.72), letterSpacing: .3),
      children: widget.req ? [TextSpan(text: ' *',
          style: TextStyle(color: _fuchsia.withOpacity(.9)))] : [],
    )),
    const SizedBox(height: 7),
    Focus(
      onFocusChange: (f) => setState(() => _f = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _f ? _white.withOpacity(.18) : _white.withOpacity(.09),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: _f ? _white.withOpacity(.60) : _glassBorder, width: 1.5),
          boxShadow: _f ? [BoxShadow(
              color: _accentA.withOpacity(.18), blurRadius: 10)] : [],
        ),
        child: TextField(
          controller: widget.ctrl,
          obscureText: widget.obs,
          keyboardType: widget.kt,
          onChanged: widget.onCh,
          style: const TextStyle(fontSize: 13, color: _wText),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(fontSize: 13, color: _white.withOpacity(.28)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 13, vertical: 11),
            suffixIcon: widget.suffix,
          ),
        ),
      ),
    ),
  ]);
}

// Short-named glass dropdown
class _GDD extends StatelessWidget {
  final String label; final String? value;
  final List<String> items; final ValueChanged<String?> onCh;
  final bool req;
  const _GDD({required this.label, required this.value,
      required this.items, required this.onCh, this.req=false});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    RichText(text: TextSpan(
      text: label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: _white.withOpacity(.72)),
      children: req ? [TextSpan(text: ' *',
          style: TextStyle(color: _fuchsia.withOpacity(.9)))] : [],
    )),
    const SizedBox(height: 7),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: _white.withOpacity(.09),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _glassBorder, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          dropdownColor: const Color(0xFF3B1D8A),
          hint: Text('Select…', style: TextStyle(
              fontSize: 13, color: _white.withOpacity(.28))),
          icon: Icon(Icons.keyboard_arrow_down,
              color: _white.withOpacity(.50), size: 18),
          style: const TextStyle(fontSize: 13, color: _wText),
          items: items.map((i) =>
              DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onCh,
        ),
      ),
    ),
  ]);
}

// Password strength
class _PwBar extends StatelessWidget {
  final int strength; const _PwBar({required this.strength});
  @override
  Widget build(BuildContext context) {
    const c = [Color(0xFFEF4444), Color(0xFFFBBF24), Color(0xFF34D399)];
    const l = ['Weak', 'Fair — add symbols & numbers', 'Strong ✓'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: List.generate(3, (i) => Expanded(
        child: Container(height: 3,
          margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
          decoration: BoxDecoration(
            color: (strength > 0 && i < strength)
                ? c[strength-1] : _white.withOpacity(.18),
            borderRadius: BorderRadius.circular(3)))))),
      if (strength > 0) ...[
        const SizedBox(height: 5),
        Text(l[strength-1], style: TextStyle(fontSize: 10, color: c[strength-1])),
      ],
    ]);
  }
}

// White pill button
class _PillBtn extends StatefulWidget {
  final String text; final VoidCallback onTap;
  const _PillBtn({required this.text, required this.onTap});
  @override State<_PillBtn> createState() => _PillBtnState();
}
class _PillBtnState extends State<_PillBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: _h ? _white.withOpacity(.90) : _white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15),
              blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Text(widget.text, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
              color: _accentB, letterSpacing: .4)),
      ),
    ),
  );
}

class _WDiv extends StatelessWidget {
  final String label; const _WDiv({required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Divider(color: _white.withOpacity(.18))),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(label, style: TextStyle(
          fontSize: 11, color: _white.withOpacity(.50)))),
    Expanded(child: Divider(color: _white.withOpacity(.18))),
  ]);
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9B72F7), Color(0xFF6C3FC9)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(11),
          boxShadow: [BoxShadow(color: _accentB.withOpacity(.4), blurRadius: 10)]),
        child: const Center(child: Icon(Icons.school_rounded, color: _white, size: 22))),
      const SizedBox(width: 10),
      const Text('UniBridge', style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800, color: _wText, letterSpacing: -.3)),
    ],
  );
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap; const _BackBtn({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 38, height: 38,
      decoration: BoxDecoration(color: _white.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _white.withOpacity(.22))),
      child: const Icon(Icons.arrow_back_ios_new, color: _white, size: 15)));
}

class _GlassCard extends StatelessWidget {
  final Widget child; final Color accentColor;
  const _GlassCard({required this.child, required this.accentColor});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: _glass,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: accentColor.withOpacity(.40), width: 1.5),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.20),
            blurRadius: 32, offset: const Offset(0, 12)),
        BoxShadow(color: accentColor.withOpacity(.08),
            blurRadius: 20, spreadRadius: -4),
      ],
    ),
    child: child,
  );
}

// Shared purple bg + blobs
class _PurpleBg extends StatelessWidget {
  final Size size; final Widget child;
  const _PurpleBg({required this.size, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, height: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [_bgA, _bgB, _bgC], stops: [0, .55, 1])),
    child: Stack(children: [
      _b(const Color(0xFF9B72F7), size.width-160, -100, 280, .20),
      _b(const Color(0xFF7C3AED), -100, size.height-180, 260, .18),
      _b(const Color(0xFFC084FC), size.width*.35, size.height*.35, 180, .10),
      CustomPaint(painter: _Grid(), size: Size.infinite),
      SafeArea(child: child),
    ]),
  );
  Widget _b(Color c, double x, double y, double r, double op) => Positioned(
    left: x, top: y,
    child: Container(width: r*2, height: r*2,
      decoration: BoxDecoration(shape: BoxShape.circle,
          color: c.withOpacity(op))));
}

class _Grid extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(.04)..strokeWidth = 1;
    for (double x = 0; x < size.width;  x += 60)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 60)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override bool shouldRepaint(_) => false;
}
