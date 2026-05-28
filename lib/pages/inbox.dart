import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const DMApp());

// ─── COLORS ──────────────────────────────────────────────────────────────────
class C {
  static const bg         = Color(0xFFFFFFFF);
  static const bgRight    = Color(0xFFFAFAFE);
  static const header     = Color(0xFF3C3489);
  static const headerMid  = Color(0xFF534AB7);
  static const purple     = Color(0xFF7F77DD);
  static const purpleLight= Color(0xFFEEEDFE);
  static const purpleMid  = Color(0xFFCECBF6);
  static const purpleDark = Color(0xFF26215C);
  static const border     = Color(0xFFEEEDFE);
  static const textMuted  = Color(0xFFAFA9EC);
  static const textSub    = Color(0xFF888780);
  static const online     = Color(0xFF1D9E75);
  static const bubbleMine = Color(0xFF534AB7);
  static const bubbleText = Color(0xFFEEEDFE);
}

// ─── MODELS ───────────────────────────────────────────────────────────────────
class Conversation {
  final String initials, name, lastMsg, time;
  final Color avatarBg, avatarFg;
  final bool online, hasStory;
  int unread;
  Conversation({
    required this.initials, required this.name, required this.lastMsg,
    required this.time, required this.avatarBg, required this.avatarFg,
    this.online = false, this.hasStory = false, this.unread = 0,
  });
}

class ChatMsg {
  final String text;
  final bool mine;
  final String? time, reaction;
  final bool seen;
  ChatMsg({required this.text, required this.mine,
      this.time, this.reaction, this.seen = false});
}

// ─── SAMPLE DATA ──────────────────────────────────────────────────────────────
final List<Conversation> _convos = [
  Conversation(initials:'AN', name:'Anika Nair',   lastMsg:'you: sent a photo',  time:'now',
      avatarBg: C.purpleLight, avatarFg: C.headerMid,  online:true,  hasStory:true,  unread:2),
  Conversation(initials:'RK', name:'Rohan Kumar',  lastMsg:'Haha yes exactly!',  time:'4m',
      avatarBg: const Color(0xFFE1F5EE), avatarFg: const Color(0xFF085041)),
  Conversation(initials:'PS', name:'Priya Sharma', lastMsg:'Seen',               time:'1h',
      avatarBg: const Color(0xFFFBEAF0), avatarFg: const Color(0xFF993556), hasStory:true),
  Conversation(initials:'DK', name:'Dev Kapoor',   lastMsg:'liked a message',    time:'3h',
      avatarBg: const Color(0xFFFAECE7), avatarFg: const Color(0xFF712B13)),
  Conversation(initials:'MM', name:'Maya Mehta',   lastMsg:'you: ok sounds good!',time:'1d',
      avatarBg: C.purpleLight, avatarFg: C.purpleDark),
];

final Map<String, List<ChatMsg>> _chatHistory = {
  'Anika Nair': [
    ChatMsg(text:'Hey! Did you see the new design update?', mine:false, time:'Yesterday 8:42 PM'),
    ChatMsg(text:'yeah it looks so clean', mine:true),
    ChatMsg(text:'the purple theme was my idea btw', mine:true, reaction:'haha 2'),
    ChatMsg(text:'ok sure it was', mine:false),
    ChatMsg(text:'anyway can you check the PR tonight?', mine:false),
    ChatMsg(text:'on it!', mine:true, seen:true),
  ],
  'Rohan Kumar': [
    ChatMsg(text:'dude did you watch the match?', mine:false, time:'Today 3:10 PM'),
    ChatMsg(text:'yes!! insane last 10 minutes', mine:true),
    ChatMsg(text:'Haha yes exactly!', mine:false),
  ],
  'Priya Sharma': [
    ChatMsg(text:'hey are you free this weekend?', mine:true, time:'Today 2:00 PM', seen:true),
  ],
  'Dev Kapoor': [
    ChatMsg(text:'check this meme lol', mine:false, time:'Today 10:00 AM'),
    ChatMsg(text:'💀', mine:true, reaction:'haha'),
  ],
  'Maya Mehta': [
    ChatMsg(text:'dinner at 7?', mine:false, time:'Yesterday'),
    ChatMsg(text:'ok sounds good!', mine:true, seen:true),
  ],
};

// ─── APP ──────────────────────────────────────────────────────────────────────
class DMApp extends StatelessWidget {
  const DMApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DM',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'Roboto', scaffoldBackgroundColor: C.bg),
    home: const DMScreen(),
  );
}

// ─── MAIN SCREEN ──────────────────────────────────────────────────────────────
class DMScreen extends StatefulWidget {
  const DMScreen({super.key});
  @override State<DMScreen> createState() => _DMScreenState();
}

class _DMScreenState extends State<DMScreen> {
  int _selected = 0;
  late List<Conversation> _convos;
  late Map<String, List<ChatMsg>> _history;

  @override
  void initState() {
    super.initState();
    _convos = List.from(convosGlobal);
    _history = Map.from(chatHistoryGlobal);
  }

  void _select(int i) => setState(() {
    _convos[i].unread = 0;
    _selected = i;
  });

  void _sendMsg(String text) {
    final name = _convos[_selected].name;
    setState(() {
      _history.putIfAbsent(name, () => []);
      _history[name]!.add(ChatMsg(text: text, mine: true));
      _convos[_selected] = Conversation(
        initials: _convos[_selected].initials,
        name: _convos[_selected].name,
        lastMsg: 'you: $text',
        time: 'now',
        avatarBg: _convos[_selected].avatarBg,
        avatarFg: _convos[_selected].avatarFg,
        online: _convos[_selected].online,
        hasStory: _convos[_selected].hasStory,
        unread: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _ConvList(
            convos: _convos,
            selected: _selected,
            onSelect: _select,
          ),
          const VerticalDivider(width: 0.5, color: C.border),
          Expanded(
            child: _ChatPanel(
              conv: _convos[_selected],
              messages: _history[_convos[_selected].name] ?? [],
              onSend: _sendMsg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CONVERSATION LIST ────────────────────────────────────────────────────────
class _ConvList extends StatelessWidget {
  final List<Conversation> convos;
  final int selected;
  final Function(int) onSelect;
  const _ConvList({required this.convos, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          color: C.header,
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Messages',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 1),
              Text('yourhandle',
                  style: TextStyle(color: C.textMuted, fontSize: 11)),
            ]),
            const Spacer(),
            Icon(Icons.edit_outlined, color: C.purpleMid, size: 22),
          ]),
        ),
        // Search
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: C.border, width: 0.5)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: C.purpleLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Icon(Icons.search, color: C.purple, size: 16),
              const SizedBox(width: 8),
              Text('Search', style: TextStyle(color: C.purple, fontSize: 13)),
            ]),
          ),
        ),
        // Label
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('MESSAGES',
                style: TextStyle(color: C.purple, fontSize: 10,
                    fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            itemCount: convos.length,
            itemBuilder: (_, i) => _ConvTile(
              conv: convos[i],
              active: selected == i,
              onTap: () => onSelect(i),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ConvTile extends StatelessWidget {
  final Conversation conv;
  final bool active;
  final VoidCallback onTap;
  const _ConvTile({required this.conv, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: active ? C.purpleLight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          // Avatar
          SizedBox(
            width: 48, height: 48,
            child: Stack(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: conv.avatarBg,
                  border: conv.hasStory
                      ? Border.all(color: C.headerMid, width: 2)
                      : null,
                ),
                child: Center(child: Text(conv.initials,
                    style: TextStyle(color: conv.avatarFg,
                        fontSize: 14, fontWeight: FontWeight.w500))),
              ),
              if (conv.online)
                Positioned(
                  bottom: 1, right: 1,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: C.online,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conv.name,
                  style: const TextStyle(color: C.purpleDark, fontSize: 13,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(conv.lastMsg,
                  style: const TextStyle(color: C.textSub, fontSize: 12),
                  overflow: TextOverflow.ellipsis),
            ],
          )),
          const SizedBox(width: 6),
          // Meta
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(conv.time,
                style: const TextStyle(color: C.textMuted, fontSize: 11)),
            if (conv.unread > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: C.headerMid,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${conv.unread}',
                    style: const TextStyle(color: C.purpleLight,
                        fontSize: 10, fontWeight: FontWeight.w500)),
              ),
            ],
          ]),
        ]),
      ),
    );
  }
}

// ─── CHAT PANEL ───────────────────────────────────────────────────────────────
class _ChatPanel extends StatefulWidget {
  final Conversation conv;
  final List<ChatMsg> messages;
  final Function(String) onSend;
  const _ChatPanel({required this.conv, required this.messages, required this.onSend});
  @override State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(covariant _ChatPanel old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Header
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: C.header,
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.conv.avatarBg,
            ),
            child: Center(child: Text(widget.conv.initials,
                style: TextStyle(color: widget.conv.avatarFg,
                    fontSize: 13, fontWeight: FontWeight.w500))),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.conv.name,
                style: const TextStyle(color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.w500)),
            Text(widget.conv.online ? 'Active now' : 'Instagram',
                style: TextStyle(color: C.textMuted, fontSize: 11)),
          ]),
          const Spacer(),
          Icon(Icons.phone_outlined, color: C.purpleMid, size: 22),
          const SizedBox(width: 16),
          Icon(Icons.videocam_outlined, color: C.purpleMid, size: 22),
          const SizedBox(width: 16),
          Icon(Icons.info_outline, color: C.purpleMid, size: 22),
        ]),
      ),
      // Messages
      Expanded(
        child: Container(
          color: C.bgRight,
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            itemCount: widget.messages.length,
            itemBuilder: (_, i) {
              final msg = widget.messages[i];
              final prev = i > 0 ? widget.messages[i-1] : null;
              final showTime = msg.time != null;
              return Column(children: [
                if (showTime)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(msg.time!,
                        style: const TextStyle(color: C.textMuted, fontSize: 11)),
                  ),
                _BubbleRow(msg: msg, initials: widget.conv.initials,
                    showAvatar: !msg.mine && (i == widget.messages.length - 1
                        || widget.messages[i+1 < widget.messages.length ? i+1 : i].mine)),
              ]);
            },
          ),
        ),
      ),
      // Input
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          color: C.bg,
          border: Border(top: BorderSide(color: C.border, width: 0.5)),
        ),
        child: Row(children: [
          Icon(Icons.camera_alt_outlined, color: C.headerMid, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: C.purpleLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: C.purpleDark, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: const TextStyle(color: C.purple),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.mic_none, color: C.headerMid, size: 22),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 34, height: 34,
              decoration: const BoxDecoration(
                color: C.headerMid,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _BubbleRow extends StatelessWidget {
  final ChatMsg msg;
  final String initials;
  final bool showAvatar;
  const _BubbleRow({required this.msg, required this.initials, required this.showAvatar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: msg.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: msg.mine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!msg.mine) ...[
                SizedBox(
                  width: 24,
                  child: showAvatar
                      ? Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(
                            color: C.purpleMid, shape: BoxShape.circle),
                          child: Center(child: Text(initials,
                              style: const TextStyle(color: C.purpleDark,
                                  fontSize: 8, fontWeight: FontWeight.w500))),
                        )
                      : const SizedBox(),
                ),
                const SizedBox(width: 6),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  decoration: BoxDecoration(
                    color: msg.mine ? C.bubbleMine : C.purpleLight,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(msg.mine ? 18 : 4),
                      bottomRight: Radius.circular(msg.mine ? 4 : 18),
                    ),
                  ),
                  child: Text(msg.text,
                      style: TextStyle(
                          color: msg.mine ? C.bubbleText : C.purpleDark,
                          fontSize: 13, height: 1.45)),
                ),
              ),
            ],
          ),
          if (msg.reaction != null)
            Padding(
              padding: EdgeInsets.only(
                  top: 2, right: msg.mine ? 6 : 0, left: msg.mine ? 0 : 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: C.border, width: 0.5),
                ),
                child: Text(msg.reaction!,
                    style: const TextStyle(color: C.headerMid, fontSize: 11)),
              ),
            ),
          if (msg.seen)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 4),
              child: Text('Seen',
                  style: const TextStyle(color: C.textMuted, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}

// ─── GLOBALS (workaround for late init in StatefulWidget) ─────────────────────
final List<Conversation> convosGlobal = [
  Conversation(initials:'AN', name:'Anika Nair',   lastMsg:'you: sent a photo',  time:'now',
      avatarBg: C.purpleLight, avatarFg: C.headerMid,  online:true,  hasStory:true,  unread:2),
  Conversation(initials:'RK', name:'Rohan Kumar',  lastMsg:'Haha yes exactly!',  time:'4m',
      avatarBg: const Color(0xFFE1F5EE), avatarFg: const Color(0xFF085041)),
  Conversation(initials:'PS', name:'Priya Sharma', lastMsg:'Seen',               time:'1h',
      avatarBg: const Color(0xFFFBEAF0), avatarFg: const Color(0xFF993556), hasStory:true),
  Conversation(initials:'DK', name:'Dev Kapoor',   lastMsg:'liked a message',    time:'3h',
      avatarBg: const Color(0xFFFAECE7), avatarFg: const Color(0xFF712B13)),
  Conversation(initials:'MM', name:'Maya Mehta',   lastMsg:'you: ok sounds good!',time:'1d',
      avatarBg: C.purpleLight, avatarFg: C.purpleDark),
];

final Map<String, List<ChatMsg>> chatHistoryGlobal = {
  'Anika Nair': [
    ChatMsg(text:'Hey! Did you see the new design update?', mine:false, time:'Yesterday 8:42 PM'),
    ChatMsg(text:'yeah it looks so clean', mine:true),
    ChatMsg(text:'the purple theme was my idea btw', mine:true, reaction:'haha 2'),
    ChatMsg(text:'ok sure it was', mine:false),
    ChatMsg(text:'anyway can you check the PR tonight?', mine:false),
    ChatMsg(text:'on it!', mine:true, seen:true),
  ],
  'Rohan Kumar': [
    ChatMsg(text:'dude did you watch the match?', mine:false, time:'Today 3:10 PM'),
    ChatMsg(text:'yes!! insane last 10 minutes', mine:true),
    ChatMsg(text:'Haha yes exactly!', mine:false),
  ],
  'Priya Sharma': [
    ChatMsg(text:'hey are you free this weekend?', mine:true, time:'Today 2:00 PM', seen:true),
  ],
  'Dev Kapoor': [
    ChatMsg(text:'check this meme lol', mine:false, time:'Today 10:00 AM'),
    ChatMsg(text:'💀', mine:true, reaction:'haha'),
  ],
  'Maya Mehta': [
    ChatMsg(text:'dinner at 7?', mine:false, time:'Yesterday'),
    ChatMsg(text:'ok sounds good!', mine:true, seen:true),
  ],
};