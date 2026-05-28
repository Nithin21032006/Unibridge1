import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────
// PURPLE COLOUR PALETTE
// ─────────────────────────────────────────────

const _primary       = Color(0xFF7C3AED); // violet-600
const _primaryLight  = Color(0xFFEDE9FE); // violet-100
const _primaryMid    = Color(0xFFA78BFA); // violet-400
const _gradStart     = Color(0xFF7C3AED); // violet
const _gradMid       = Color(0xFFDB2777); // pink
const _gradEnd       = Color(0xFF9333EA); // purple

const _bg            = Color(0xFFF5F3FF); // violet-50
const _surface       = Color(0xFFFFFFFF);
const _surface2      = Color(0xFFF5F3FF);
const _border        = Color(0x22000000);
const _borderFocus   = Color(0xFF7C3AED);
const _textPrimary   = Color(0xFF1E1B4B); // indigo-950
const _textSecondary = Color(0xFF6D28D9); // violet-700
const _textMuted     = Color(0xFF8B5CF6); // violet-500
const _textHint      = Color(0xFFBBB3D8);
const _danger        = Color(0xFFEF4444);
const _success       = Color(0xFF22C55E);
const _warning       = Color(0xFFF59E0B);
const _badgeBg       = Color(0xFFEDE9FE);
const _badgeText     = Color(0xFF5B21B6);

// ─────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────

const _classes = [
  '1st Year', '2nd Year', '3rd Year', '4th Year',
  '5th Year', 'Postgraduate', 'Alumni',
];

const _courses = {
  'Engineering': [
    'Computer Science', 'Software Engineering',
    'Electrical Engineering', 'Mechanical Engineering', 'Civil Engineering',
  ],
  'Science': ['Physics', 'Chemistry', 'Biology', 'Mathematics'],
  'Business': ['Business Administration', 'Accounting', 'Economics', 'Marketing'],
  'Arts & Humanities': ['English Literature', 'History', 'Psychology', 'Sociology'],
  'Health': ['Medicine', 'Nursing', 'Pharmacy'],
};

List<String> get _allCourses =>
    _courses.values.expand((list) => list).toList();

const _takenUsernames = ['admin', 'instagram', 'user', 'support', 'help', 'test'];

// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: _primary,
          secondary: _primaryMid,
          surface: _surface,
          background: _bg,
        ),
        scaffoldBackgroundColor: _bg,
        fontFamily: 'sans-serif',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface2,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _borderFocus, width: 1.5),
          ),
          hintStyle: const TextStyle(color: _textHint, fontSize: 14),
        ),
      ),
      home: const ProfileRoot(),
    );
  }
}

// ─────────────────────────────────────────────
// ROOT — switches between edit & view
// ─────────────────────────────────────────────

class ProfileRoot extends StatefulWidget {
  const ProfileRoot({super.key});
  @override
  State<ProfileRoot> createState() => _ProfileRootState();
}

class _ProfileRootState extends State<ProfileRoot> {
  bool _showProfile = false;
  ProfileData _data = const ProfileData();

  void _onSave(ProfileData d) => setState(() { _data = d; _showProfile = true; });
  void _onEdit()              => setState(() { _showProfile = false; });

  @override
  Widget build(BuildContext context) {
    return _showProfile
        ? ProfileViewPage(data: _data, onEdit: _onEdit)
        : ProfileEditPage(initial: _data, onSave: _onSave);
  }
}

// ─────────────────────────────────────────────
// PROFILE DATA MODEL
// ─────────────────────────────────────────────

class ProfileData {
  final String username;
  final String displayName;
  final String bio;
  final String className;
  final String course;
  final XFile?  photo;

  const ProfileData({
    this.username   = '',
    this.displayName= '',
    this.bio        = '',
    this.className  = '',
    this.course     = '',
    this.photo,
  });

  ProfileData copyWith({
    String? username, String? displayName, String? bio,
    String? className, String? course, XFile? photo, bool clearPhoto = false,
  }) => ProfileData(
    username:    username    ?? this.username,
    displayName: displayName ?? this.displayName,
    bio:         bio         ?? this.bio,
    className:   className   ?? this.className,
    course:      course      ?? this.course,
    photo:       clearPhoto  ? null : (photo ?? this.photo),
  );

  String get initials {
    final parts = displayName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

// ─────────────────────────────────────────────
// EDIT PAGE
// ─────────────────────────────────────────────

class ProfileEditPage extends StatefulWidget {
  final ProfileData initial;
  final ValueChanged<ProfileData> onSave;
  const ProfileEditPage({super.key, required this.initial, required this.onSave});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

enum _UnStatus { none, checking, available, taken, invalid }

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _unCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;

  String  _className = '';
  String  _course    = '';
  XFile?  _photo;
  bool    _dirty     = false;

  _UnStatus _unStatus = _UnStatus.none;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    _unCtrl   = TextEditingController(text: d.username);
    _nameCtrl = TextEditingController(text: d.displayName);
    _bioCtrl  = TextEditingController(text: d.bio);
    _className = d.className;
    _course    = d.course;
    _photo     = d.photo;

    _unCtrl.addListener(_onUsernameChange);
    _nameCtrl.addListener(_markDirty);
    _bioCtrl.addListener(_markDirty);
  }

  @override
  void dispose() {
    _unCtrl.dispose(); _nameCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  void _markDirty() => setState(() => _dirty = true);

  // ── Username validation ───────────────────

  void _onUsernameChange() {
    final raw = _unCtrl.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._]'), '');
    if (_unCtrl.text != raw) {
      _unCtrl.value = _unCtrl.value.copyWith(
        text: raw,
        selection: TextSelection.collapsed(offset: raw.length),
      );
    }
    setState(() { _dirty = true; _unStatus = _UnStatus.none; });
    if (raw.isEmpty) return;
    if (!RegExp(r'^[a-z0-9._]{1,30}$').hasMatch(raw)) {
      setState(() => _unStatus = _UnStatus.invalid);
      return;
    }
    setState(() => _unStatus = _UnStatus.checking);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _unStatus = _takenUsernames.contains(raw)
          ? _UnStatus.taken : _UnStatus.available);
    });
  }

  // ── Photo picker ──────────────────────────

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) setState(() { _photo = img; _dirty = true; });
  }

  // ── Save ──────────────────────────────────

  void _save() {
    if (_unStatus == _UnStatus.taken || _unStatus == _UnStatus.invalid) {
      _showSnack('Fix the username before saving');
      return;
    }
    widget.onSave(ProfileData(
      username:    _unCtrl.text.trim(),
      displayName: _nameCtrl.text.trim(),
      bio:         _bioCtrl.text.trim(),
      className:   _className,
      course:      _course,
      photo:       _photo,
    ));
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Edit profile',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary)),
        actions: [
          TextButton(
            onPressed: _dirty ? _save : null,
            child: Text('Save',
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: _dirty ? _primary : _textHint,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: _border),
        ),
      ),
      body: ListView(
        children: [
          _buildAvatarSection(),
          _sectionDivider(),
          _sectionLabel('Account'),
          _buildUsernameField(),
          _buildTextField('Display name', _nameCtrl, hint: 'Your full name', maxLen: 50),
          _sectionDivider(),
          _sectionLabel('About you'),
          _buildBioField(),
          _sectionDivider(),
          _sectionLabel('Academic'),
          _buildClassDropdown(),
          _buildCourseDropdown(),
          const SizedBox(height: 8),
          _buildSaveButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Avatar section ────────────────────────

  Widget _buildAvatarSection() {
    return Column(children: [
      const SizedBox(height: 28),
      GestureDetector(
        onTap: _pickPhoto,
        child: Stack(children: [
          _GradientAvatarRing(
            size: 96,
            photo: _photo,
            initials: ProfileData(displayName: _nameCtrl.text).initials,
            ringWidth: 3,
          ),
          Positioned(
            bottom: 2, right: 2,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: _primary,
                shape: BoxShape.circle,
                border: Border.all(color: _surface, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: _pickPhoto,
        child: const Text('Change profile photo',
            style: TextStyle(color: _primary, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
      const SizedBox(height: 24),
    ]);
  }

  // ── Username field ────────────────────────

  Widget _buildUsernameField() {
    Color dotColor = Colors.transparent;
    String statusText = '';
    if (_unStatus == _UnStatus.available) { dotColor = _success; statusText = 'Username available'; }
    else if (_unStatus == _UnStatus.taken)   { dotColor = _danger;  statusText = 'Username taken'; }
    else if (_unStatus == _UnStatus.invalid) { dotColor = _danger;  statusText = 'Invalid characters'; }
    else if (_unStatus == _UnStatus.checking){ dotColor = _warning; statusText = 'Checking…'; }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _FieldLabel('Username'),
        const SizedBox(height: 5),
        TextField(
          controller: _unCtrl,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            prefixText: '@',
            prefixStyle: const TextStyle(color: _textMuted, fontSize: 14),
            hintText: 'yourname',
          ),
        ),
        if (_unStatus != _UnStatus.none) ...[
          const SizedBox(height: 5),
          Row(children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(statusText, style: const TextStyle(fontSize: 11, color: _textSecondary)),
          ]),
        ],
        const SizedBox(height: 4),
        const Text('Letters, numbers, underscores and periods only.',
            style: TextStyle(fontSize: 11, color: _textMuted)),
      ]),
    );
  }

  // ── Generic text field ────────────────────

  Widget _buildTextField(String label, TextEditingController ctrl,
      {String hint = '', int maxLen = 100}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _FieldLabel(label),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          maxLength: maxLen,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(hintText: hint, counterText: ''),
        ),
      ]),
    );
  }

  // ── Bio field ─────────────────────────────

  Widget _buildBioField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _FieldLabel('Bio'),
        const SizedBox(height: 5),
        ValueListenableBuilder(
          valueListenable: _bioCtrl,
          builder: (_, v, __) => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            TextField(
              controller: _bioCtrl,
              maxLength: 150,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: _textPrimary),
              decoration: const InputDecoration(
                hintText: 'Tell people a little about yourself…',
                counterText: '',
              ),
            ),
            const SizedBox(height: 3),
            Text('${v.text.length} / 150',
                style: TextStyle(
                  fontSize: 11,
                  color: v.text.length > 130 ? _danger : _textMuted,
                )),
          ]),
        ),
      ]),
    );
  }

  // ── Class dropdown ────────────────────────

  Widget _buildClassDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _FieldLabel('Class / Year'),
        const SizedBox(height: 5),
        _PurpleDropdown<String>(
          value: _className.isEmpty ? null : _className,
          hint: 'Select your class',
          items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() { _className = v ?? ''; _dirty = true; }),
        ),
      ]),
    );
  }

  // ── Course dropdown ───────────────────────

  Widget _buildCourseDropdown() {
    final items = <DropdownMenuItem<String>>[];
    for (final group in _courses.entries) {
      items.add(DropdownMenuItem<String>(
        enabled: false,
        value: '__${group.key}',
        child: Text(group.key,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted)),
      ));
      for (final c in group.value) {
        items.add(DropdownMenuItem<String>(
          value: c,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(c, style: const TextStyle(fontSize: 14)),
          ),
        ));
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _FieldLabel('Course / Programme'),
        const SizedBox(height: 5),
        _PurpleDropdown<String>(
          value: _course.isEmpty ? null : _course,
          hint: 'Select your course',
          items: items,
          onChanged: (v) {
            if (v != null && !v.startsWith('__')) setState(() { _course = v; _dirty = true; });
          },
        ),
      ]),
    );
  }

  // ── Save button ───────────────────────────

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _dirty ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            disabledBackgroundColor: _primaryLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Save profile',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────

  Widget _sectionDivider() => Container(
    height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 0),
    color: _border,
  );

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    child: Text(label.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: _textMuted, letterSpacing: 0.7)),
  );
}

// ─────────────────────────────────────────────
// PROFILE VIEW PAGE
// ─────────────────────────────────────────────

class ProfileViewPage extends StatelessWidget {
  final ProfileData data;
  final VoidCallback onEdit;
  const ProfileViewPage({super.key, required this.data, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          data.username.isNotEmpty ? '@${data.username}' : (data.displayName.isNotEmpty ? data.displayName : 'Profile'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: onEdit,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: _border),
        ),
      ),
      body: ListView(children: [
        _buildCoverAndAvatar(),
        _buildInfo(),
        _buildStatsRow(),
        _buildPostsGrid(),
      ]),
    );
  }

  Widget _buildCoverAndAvatar() {
    return Stack(clipBehavior: Clip.none, children: [
      // Cover strip
      Container(
        height: 90,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF9333EA), Color(0xFFDB2777)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      // Avatar overlapping cover
      Positioned(
        left: 16,
        bottom: -48,
        child: _GradientAvatarRing(
          size: 88,
          photo: data.photo,
          initials: data.initials,
          ringWidth: 3,
          borderColor: _bg,
        ),
      ),
      // Edit button top-right of cover
      Positioned(
        right: 16,
        bottom: -19,
        child: OutlinedButton(
          onPressed: onEdit,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _border, width: 0.5),
            backgroundColor: _surface,
            foregroundColor: _textPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            elevation: 0,
          ),
          child: const Text('Edit profile'),
        ),
      ),
      // Spacer so Stack has height
      const SizedBox(height: 90 + 48 + 16),
    ]);
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 58, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (data.displayName.isNotEmpty)
          Text(data.displayName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
        if (data.username.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('@${data.username}',
                style: const TextStyle(fontSize: 13, color: _textMuted)),
          ),
        if (data.bio.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(data.bio,
                style: const TextStyle(fontSize: 14, color: _textPrimary, height: 1.5)),
          ),
        if (data.className.isNotEmpty || data.course.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, children: [
            if (data.className.isNotEmpty)
              _Badge(icon: Icons.school_outlined, label: data.className),
            if (data.course.isNotEmpty)
              _Badge(icon: Icons.menu_book_outlined, label: data.course),
          ]),
        ],
        const SizedBox(height: 4),
      ]),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: _border, width: 0.5),
          bottom: BorderSide(color: _border, width: 0.5),
        ),
        color: _surface,
      ),
      child: Row(children: [
        _StatCell(count: '0', label: 'Posts'),
        _StatCell(count: '0', label: 'Followers'),
        _StatCell(count: '0', label: 'Following'),
      ]),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        color: _primaryLight,
        child: const Icon(Icons.image_outlined, color: _primaryMid, size: 28),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class _GradientAvatarRing extends StatelessWidget {
  final double size;
  final XFile? photo;
  final String initials;
  final double ringWidth;
  final Color borderColor;

  const _GradientAvatarRing({
    required this.size,
    required this.photo,
    required this.initials,
    this.ringWidth = 3,
    this.borderColor = _surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [_gradStart, _gradMid, _gradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(ringWidth),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2.5),
          color: _primaryLight,
        ),
        clipBehavior: Clip.antiAlias,
        child: photo != null
            ? Image.file(File(photo!.path), fit: BoxFit.cover)
            : Center(
                child: Text(initials,
                    style: TextStyle(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.w500,
                      color: _primary,
                    )),
              ),
      ),
    );
  }
}

class _PurpleDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _PurpleDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface2,
        border: Border.all(color: _border, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: _surface,
          iconEnabledColor: _textMuted,
          style: const TextStyle(fontSize: 14, color: _textPrimary, fontFamily: 'sans-serif'),
          hint: Text(hint, style: const TextStyle(color: _textHint, fontSize: 14)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textSecondary));
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Badge({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _badgeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: _badgeText),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: _badgeText, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String count;
  final String label;
  const _StatCell({required this.count, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: _border, width: 0.5)),
        ),
        child: Column(children: [
          Text(count, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: _textMuted)),
        ]),
      ),
    );
  }
}