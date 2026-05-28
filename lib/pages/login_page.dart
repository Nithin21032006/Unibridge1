import 'package:flutter/material.dart';

import '../utils/routes.dart';
import 'studenthome.dart';
import 'facultyhome.dart';
import 'eventhome.dart';

// ════════════════════════════════════════════════════════════════════════════
//  LoginPage  —  Pure Purple scheme
//  Deep violet gradient · frosted glass card · white pill CTA
// ════════════════════════════════════════════════════════════════════════════

// ── Palette ───────────────────────────────────────────────────────────────────
const _bgA   = Color(0xFF3B0FAB); // rich violet
const _bgB   = Color(0xFF6C3FC9); // mid purple
const _bgC   = Color(0xFF0D0730); // near-black navy
const _accentA = Color(0xFF9B72F7); // lavender highlight
const _accentB = Color(0xFF7C3AED); // vivid purple
const _white   = Colors.white;
const _glass   = Color(0x1AFFFFFF); // white 10%
const _glassBorder = Color(0x33FFFFFF); // white 20%
const _wText   = Color(0xFFFFFFFF);
const _wMuted  = Color(0x99FFFFFF); // white 60%
const _wHint   = Color(0x44FFFFFF); // white 27%

// Role accent colours — all purple-family tints
const _roleColors = {
  _Role.student : [Color(0xFF818CF8), Color(0xFF6366F1)], // indigo
  _Role.faculty : [Color(0xFFA78BFA), Color(0xFF7C3AED)], // violet
  _Role.admin   : [Color(0xFFC084FC), Color(0xFF9333EA)], // purple
  _Role.event   : [Color(0xFFE879F9), Color(0xFFD946EF)], // fuchsia
};

// ── Role data ─────────────────────────────────────────────────────────────────
enum _Role { student, faculty, admin, event }

class _RoleInfo {
  final String label, emoji, title, subtitle, idLabel, idHint, btnText, signupText;
  const _RoleInfo({
    required this.label, required this.emoji, required this.title,
    required this.subtitle, required this.idLabel, required this.idHint,
    required this.btnText, required this.signupText,
  });
}

const Map<_Role, _RoleInfo> _roles = {
  _Role.student: _RoleInfo(
    label: 'Student', emoji: '🧑‍🎓',
    title: 'Student Login', subtitle: 'Access your courses, grades & resources',
    idLabel: 'Student ID / Email', idHint: 'e.g. s2024001@edu.ac',
    btnText: 'Sign In as Student', signupText: 'Create a Student Account',
  ),
  _Role.faculty: _RoleInfo(
    label: 'Faculty', emoji: '👨‍🏫',
    title: 'Faculty Login', subtitle: 'Manage classes, assignments & student records',
    idLabel: 'Faculty ID / Email', idHint: 'e.g. prof.sharma@edu.ac',
    btnText: 'Sign In as Faculty', signupText: 'Register as Faculty',
  ),
  _Role.admin: _RoleInfo(
    label: 'Admin', emoji: '🛡️',
    title: 'Admin Login', subtitle: 'System administration & institutional management',
    idLabel: 'Admin ID / Email', idHint: 'e.g. admin@edu.ac',
    btnText: 'Sign In as Admin', signupText: 'Request Admin Access',
  ),
  _Role.event: _RoleInfo(
    label: 'Event Manager', emoji: '🎪',
    title: 'Event Manager Login', subtitle: 'Create, schedule & manage campus events',
    idLabel: 'Event Manager ID / Email', idHint: 'e.g. events@edu.ac',
    btnText: 'Sign In as Event Manager', signupText: 'Register as Event Manager',
  ),
};

// ════════════════════════════════════════════════════════════════════════════
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  _Role _role    = _Role.student;
  bool  _remember = false;
  bool  _obscure  = true;

  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 520))..forward();
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
        begin: const Offset(0, .18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  String get _homeRoute {
    switch (_role) {
      case _Role.student:
        return AppRoutes.studentHome;
      case _Role.faculty:
        return AppRoutes.facultyHome;
      case _Role.admin:
      case _Role.event:
        return AppRoutes.eventHome;
    }
  }
  @override
  Widget build(BuildContext context) {
    final info  = _roles[_role]!;
    final size  = MediaQuery.sizeOf(context);
    final clrs  = _roleColors[_role]!;

    return Scaffold(
      body: _PurpleBg(size: size, child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
            child: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(children: [

                // Back + Brand
                Row(children: [
                  _BackBtn(onTap: () => Navigator.maybePop(context)),
                  const SizedBox(width: 14),
                  const Expanded(child: _Brand()),
                ]),
                const SizedBox(height: 32),

                // WHO ARE YOU label
                Text('WHO ARE YOU?', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: _white.withOpacity(.55), letterSpacing: 2.5)),
                const SizedBox(height: 14),

                // Role cards
                GridView.count(
                  crossAxisCount: 4, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10,
                  childAspectRatio: .82,
                  children: _Role.values.map((r) => _RoleCard(
                    role: r, active: _role == r,
                    onTap: () => setState(() => _role = r),
                  )).toList(),
                ),
                const SizedBox(height: 24),

                // Glass form card
                _GlassCard(
                  accentColor: clrs[0],
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // Title
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(info.title, key: ValueKey(_role),
                        style: const TextStyle(fontSize: 22,
                            fontWeight: FontWeight.w800, color: _wText,
                            letterSpacing: -.3)),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(info.subtitle, key: ValueKey('s$_role'),
                        style: TextStyle(fontSize: 12.5,
                            color: _white.withOpacity(.65))),
                    ),
                    const SizedBox(height: 26),

                    // ID
                    _FLabel(info.idLabel),
                    const SizedBox(height: 7),
                    _GInput(hint: info.idHint,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),

                    // Password
                    const _FLabel('Password'),
                    const SizedBox(height: 7),
                    _GInput(hint: 'Enter your password', obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                          color: _white.withOpacity(.50), size: 18),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )),
                    const SizedBox(height: 18),

                    // Remember + forgot
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _remember = !_remember),
                          child: Row(children: [
                            SizedBox(width: 18, height: 18,
                              child: Checkbox(
                                value: _remember,
                                onChanged: (v) => setState(() => _remember = v!),
                                activeColor: _white, checkColor: _accentB,
                                side: BorderSide(color: _white.withOpacity(.45)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              )),
                            const SizedBox(width: 7),
                            Text('Remember me', style: TextStyle(
                                fontSize: 12, color: _white.withOpacity(.65))),
                          ]),
                        ),
                        Text('Forgot password?', style: TextStyle(
                            fontSize: 12, color: _white.withOpacity(.65))),
                      ],
                    ),
                    const SizedBox(height: 26),

                    // CTA
                    _PillButton(
                      text: '${info.btnText}  →',
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        _homeRoute,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Divider
                    _WDivider(label: "Don't have an account?"),
                    const SizedBox(height: 16),

                    // Sign up link
                    Center(child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                        // Navigate to SignupPage — import signup_page.dart
                        // Navigator.push(context, MaterialPageRoute(
                        //   builder: (_) => SignupPage(initialRole: _role)));
                      },
                      child: RichText(text: TextSpan(
                        text: 'New here? ',
                        style: TextStyle(fontSize: 13,
                            color: _white.withOpacity(.60)),
                        children: [TextSpan(
                          text: info.signupText,
                          style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w700, color: _wText,
                              decoration: TextDecoration.underline,
                              decorationColor: _wText),
                        )],
                      )),
                    )),
                  ]),
                ),

                const SizedBox(height: 28),
                Text('© 2026 UniBridge — Empowering Campus Connections',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11,
                      color: _white.withOpacity(.28))),
                const SizedBox(height: 20),
              ]),
            )),
          ),
        ),
      )),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Role card
// ════════════════════════════════════════════════════════════════════════════
class _RoleCard extends StatelessWidget {
  final _Role role; final bool active; final VoidCallback onTap;
  const _RoleCard({required this.role, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final d    = _roles[role]!;
    final clrs = _roleColors[role]!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          gradient: active ? LinearGradient(
            colors: [clrs[0].withOpacity(.30), clrs[1].withOpacity(.15)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ) : null,
          color: active ? null : _white.withOpacity(.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? clrs[0] : _white.withOpacity(.18),
            width: active ? 2 : 1.5,
          ),
          boxShadow: active ? [BoxShadow(
            color: clrs[0].withOpacity(.35),
            blurRadius: 18, offset: const Offset(0, 5))] : [],
        ),
        child: Stack(clipBehavior: Clip.none, children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedScale(
              scale: active ? 1.18 : 1.0,
              duration: const Duration(milliseconds: 220),
              child: Text(d.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 8),
            Text(d.label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: active ? _wText : _white.withOpacity(.65),
                letterSpacing: .3)),
          ]),
          if (active) Positioned(top: -4, right: -4,
            child: Container(
              width: 18, height: 18,
              decoration: BoxDecoration(color: clrs[0], shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: clrs[0].withOpacity(.5),
                    blurRadius: 6)]),
              child: const Icon(Icons.check, size: 11, color: _white),
            )),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Shared widgets
// ════════════════════════════════════════════════════════════════════════════

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9B72F7), Color(0xFF6C3FC9)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(11),
          boxShadow: [BoxShadow(color: _accentB.withOpacity(.4), blurRadius: 10)],
        ),
        child: const Center(child: Icon(Icons.school_rounded, color: _white, size: 22)),
      ),
      const SizedBox(width: 10),
      const Text('UniBridge', style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800, color: _wText, letterSpacing: -.3)),
    ],
  );
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: _white.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _white.withOpacity(.22)),
      ),
      child: const Icon(Icons.arrow_back_ios_new, color: _white, size: 15),
    ),
  );
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  const _GlassCard({required this.child, required this.accentColor});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 280),
    padding: const EdgeInsets.all(26),
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

class _FLabel extends StatelessWidget {
  final String text;
  const _FLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600,
      color: _white.withOpacity(.75), letterSpacing: .3));
}

class _GInput extends StatefulWidget {
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  const _GInput({required this.hint, this.obscure = false,
      this.keyboardType, this.suffix, this.controller, this.onChanged});
  @override State<_GInput> createState() => _GInputState();
}
class _GInputState extends State<_GInput> {
  bool _f = false;
  @override
  Widget build(BuildContext context) => Focus(
    onFocusChange: (f) => setState(() => _f = f),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: _f ? _white.withOpacity(.18) : _white.withOpacity(.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _f ? _white.withOpacity(.65) : _glassBorder, width: 1.5),
        boxShadow: _f ? [BoxShadow(
            color: _accentA.withOpacity(.20), blurRadius: 12)] : [],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        style: const TextStyle(fontSize: 14, color: _wText),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(fontSize: 14, color: _white.withOpacity(.28)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          suffixIcon: widget.suffix,
        ),
      ),
    ),
  );
}

class _PillButton extends StatefulWidget {
  final String text; final VoidCallback onTap;
  const _PillButton({required this.text, required this.onTap});
  @override State<_PillButton> createState() => _PillButtonState();
}
class _PillButtonState extends State<_PillButton> {
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

class _WDivider extends StatelessWidget {
  final String label;
  const _WDivider({required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Divider(color: _white.withOpacity(.18))),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(label, style: TextStyle(
          fontSize: 11, color: _white.withOpacity(.50)))),
    Expanded(child: Divider(color: _white.withOpacity(.18))),
  ]);
}

// Purple gradient background wrapper
class _PurpleBg extends StatelessWidget {
  final Size size; final Widget child;
  const _PurpleBg({required this.size, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, height: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [_bgA, _bgB, _bgC], stops: [0, .55, 1]),
    ),
    child: Stack(children: [
      // Blobs
      _blob(Color(0xFF7C3AED), -80, -80, 300, .22),
      _blob(Color(0xFF9B72F7), size.width - 160, size.height - 180, 280, .18),
      _blob(Color(0xFFC084FC), size.width * .35, size.height * .3, 200, .10),
      // Grid
      CustomPaint(painter: _Grid(), size: Size.infinite),
      SafeArea(child: child),
    ]),
  );

  Widget _blob(Color c, double x, double y, double r, double op) => Positioned(
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
