import '../../core/platform.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/database/schema.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'detail_common.dart';
import 'phone_setup_screen.dart';
import '../navigation.dart';

/// Add or edit an M3U URL, local file, Xtream Codes account or Stalker portal.
class AddSourceScreen extends StatefulWidget {
  const AddSourceScreen({super.key, this.edit, this.initialKind});
  final Source? edit;
  final SourceKind? initialKind;
  @override
  State<AddSourceScreen> createState() => _AddSourceScreenState();
}

class _AddSourceScreenState extends State<AddSourceScreen> {
  late SourceKind kind;
  final name = TextEditingController();
  final url = TextEditingController();
  final server = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();
  final mac = TextEditingController();
  String? filePath;
  bool showPass = false;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    kind = e == null ? (widget.initialKind ?? SourceKind.m3u) : SourceKind.of(e.kind);
    if (e != null) {
      name.text = e.name;
      url.text = e.url ?? '';
      server.text = e.server ?? '';
      user.text = e.username ?? '';
      pass.text = e.password ?? '';
      mac.text = e.mac ?? '';
      filePath = e.filePath;
    } else {
      mac.text = '00:1A:79:';
    }
  }

  @override
  void dispose() {
    for (final c in [name, url, server, user, pass, mac]) {
      c.dispose();
    }
    super.dispose();
  }

  String _defaultName() {
    switch (kind) {
      case SourceKind.m3u:
        return Uri.tryParse(url.text.trim())?.host ?? 'Playlist';
      case SourceKind.file:
        return filePath?.split('/').last.replaceAll(RegExp(r'\.m3u8?$'), '') ?? 'Local playlist';
      case SourceKind.xtream:
      case SourceKind.stalker:
        final s = server.text.trim();
        return Uri.tryParse(s.contains('://') ? s : 'http://$s')?.host ?? 'Playlist';
    }
  }

  String? _localCheck() {
    switch (kind) {
      case SourceKind.m3u:
        if (url.text.trim().isEmpty) return 'Enter the playlist URL.';
      case SourceKind.file:
        if (filePath == null) return 'Choose an .m3u or .m3u8 file.';
      case SourceKind.xtream:
        if (server.text.trim().isEmpty || user.text.trim().isEmpty || pass.text.isEmpty) {
          return 'Server, username and password are required.';
        }
      case SourceKind.stalker:
        if (server.text.trim().isEmpty) return 'Enter the portal URL.';
    }
    return null;
  }

  Future<void> _pickFile() async {
    final f = await FilePicker.pickFile(
      dialogTitle: 'Choose a playlist',
      type: FileType.custom,
      allowedExtensions: ['m3u', 'm3u8', 'txt'],
    );
    if (f?.path != null) setState(() => filePath = f!.path);
  }

  Future<void> _save() async {
    final local = _localCheck();
    if (local != null) {
      setState(() => error = local);
      return;
    }
    final state = AppScope.read(context);
    setState(() {
      busy = true;
      error = null;
    });
    final err = await state.catalog.validate(kind,
        url: url.text.trim(),
        file: filePath,
        server: server.text.trim(),
        user: user.text.trim(),
        pass: pass.text,
        mac: mac.text.trim());
    if (!mounted) return;
    if (err != null) {
      setState(() {
        busy = false;
        error = err;
      });
      return;
    }
    final s = await state.repo.saveSource(
      id: widget.edit?.id,
      name: name.text.trim().isEmpty ? _defaultName() : name.text.trim(),
      kind: kind,
      url: kind == SourceKind.m3u ? url.text.trim() : null,
      filePath: kind == SourceKind.file ? filePath : null,
      server: kind == SourceKind.xtream || kind == SourceKind.stalker ? server.text.trim() : null,
      username: kind == SourceKind.xtream ? user.text.trim() : null,
      password: kind == SourceKind.xtream ? pass.text : null,
      mac: kind == SourceKind.stalker ? mac.text.trim() : null,
    );
    await state.sourceSaved(s);
    if (!mounted) return;
    toast(context, widget.edit == null ? '"${s.name}" added. Loading content…' : '"${s.name}" saved. Reloading…');
    Navigator.pop(context, s);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final editing = widget.edit != null;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          BackBar(title: editing ? 'Edit playlist' : 'Add playlist'),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: context.gutter),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(editing ? 'Edit playlist' : 'Add a new playlist',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Your playlists and credentials stay on this $deviceName.', style: TextStyle(color: p.ink2)),
                    if (isTv && !editing) ...[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GhostButton(
                          label: 'Paste from your phone instead',
                          icon: LucideIcons.smartphone,
                          onPressed: () async {
                            final added = await Navigator.of(context).push(fadeRoute(const PhoneSetupScreen()));
                            if (added != null && context.mounted) Navigator.pop(context, added);
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Segmented<SourceKind>(
                      values: const [SourceKind.m3u, SourceKind.xtream, SourceKind.stalker, SourceKind.file],
                      labels: const ['M3U URL', 'Xtream Codes', 'Stalker', 'Local file'],
                      selected: kind,
                      check: false,
                      onChanged: editing ? (_) {} : (k) => setState(() {
                            kind = k;
                            error = null;
                          }),
                    ),
                    const SizedBox(height: 24),
                    _field(name, 'Name', hint: 'Optional — e.g. My provider'),
                    ..._kindFields(p),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: p.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: p.danger.withValues(alpha: 0.4)),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(LucideIcons.circleAlert, color: p.danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: SelectableText(error!, style: TextStyle(color: p.danger))),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: busy ? 'Checking…' : (editing ? 'Save' : 'Add playlist'),
                      icon: busy ? null : LucideIcons.check,
                      busy: busy,
                      onPressed: busy ? null : _save,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _kindFields(Palette p) {
    switch (kind) {
      case SourceKind.m3u:
        return [
          _field(url, 'Playlist URL', hint: 'https://example.com/playlist.m3u', keyboard: TextInputType.url),
          Text('Xtream "get.php" links are detected automatically and loaded through the Xtream API.',
              style: TextStyle(color: p.ink3, fontSize: 12.5)),
        ];
      case SourceKind.file:
        return [
          OutlineBox(
            height: 52,
            onTap: _pickFile,
            child: Row(children: [
              const Icon(LucideIcons.folderOpen),
              const SizedBox(width: 12),
              Expanded(
                child: Text(filePath ?? 'Choose an .m3u / .m3u8 file…',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: filePath == null ? p.ink3 : p.ink)),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Text('The file is read from its location each time the playlist refreshes.',
              style: TextStyle(color: p.ink3, fontSize: 12.5)),
        ];
      case SourceKind.xtream:
        return [
          _field(server, 'Server URL', hint: 'http://provider.example:8080', keyboard: TextInputType.url),
          _field(user, 'Username'),
          _field(pass, 'Password',
              obscure: !showPass,
              suffix: IconBtn(showPass ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18, onTap: () => setState(() => showPass = !showPass))),
        ];
      case SourceKind.stalker:
        return [
          _field(server, 'Portal URL', hint: 'http://portal.example/c/', keyboard: TextInputType.url),
          _field(mac, 'MAC address', hint: '00:1A:79:XX:XX:XX'),
          Text('Stalker / Ministra portals are supported for live TV, movies and series.',
              style: TextStyle(color: p.ink3, fontSize: 12.5)),
        ];
    }
  }

  Widget _field(TextEditingController c, String label,
      {String? hint, bool obscure = false, Widget? suffix, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TvEditGate(child: TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        autocorrect: false,
        enableSuggestions: false,
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(labelText: label, hintText: hint, suffixIcon: suffix),
      )),
    );
  }
}
