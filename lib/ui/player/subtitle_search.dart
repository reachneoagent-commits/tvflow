import '../../core/platform.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/services/metadata.dart';
import '../../state/app_state.dart';
import '../theme.dart';
import '../widgets.dart';

/// OpenSubtitles search dialog. Returns the downloaded subtitle file.
class SubtitleSearchDialog extends StatefulWidget {
  const SubtitleSearchDialog({
    super.key,
    required this.title,
    this.tmdbId,
    this.imdbId,
    this.season,
    this.episode,
    this.tv = false,
  });
  final String title;
  final int? tmdbId;
  final String? imdbId;
  final int? season;
  final int? episode;
  final bool tv;

  @override
  State<SubtitleSearchDialog> createState() => _SubtitleSearchDialogState();
}

class _SubtitleSearchDialogState extends State<SubtitleSearchDialog> {
  late final AppState state = AppScope.read(context);
  late String lang = state.str(P.subLang).isEmpty ? 'en' : state.str(P.subLang);
  late final titleCtl = TextEditingController(text: cleanTitle(widget.title));
  List<SubtitleResult>? results;
  String? error;
  bool searching = false;
  int? downloading;

  @override
  void initState() {
    super.initState();
    if (state.subtitles.configured) _search();
  }

  @override
  void dispose() {
    titleCtl.dispose();
    super.dispose();
  }

  Future<void> _search({bool byTitle = false}) async {
    setState(() {
      searching = true;
      error = null;
    });
    try {
      final r = await state.subtitles.search(
        title: titleCtl.text,
        tmdbId: byTitle ? null : widget.tmdbId,
        imdbId: byTitle ? null : widget.imdbId,
        season: widget.season,
        episode: widget.episode,
        tv: widget.tv,
        languages: [lang],
      );
      if (mounted) setState(() => results = r);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  Future<void> _download(SubtitleResult s) async {
    setState(() {
      downloading = s.fileId;
      error = null;
    });
    try {
      final File f = await state.subtitles.download(s);
      if (mounted) Navigator.pop(context, (f, s.language));
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          downloading = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final configured = state.subtitles.configured;
    return AlertDialog(
      title: const Text('Search subtitles'),
      content: SizedBox(
        width: 620,
        height: 520,
        child: !configured
            ? const EmptyState(
                icon: LucideIcons.keyRound,
                title: 'OpenSubtitles is not set up',
                message: 'Add your OpenSubtitles API key, username and password in Settings → Subtitles.')
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Expanded(
                    child: TvEditGate(child: TextField(
                      controller: titleCtl,
                      decoration: const InputDecoration(labelText: 'Title'),
                      onSubmitted: (_) => _search(byTitle: true),
                    )),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    child: TvEditGate(child: TextField(
                      controller: TextEditingController(text: lang),
                      decoration: const InputDecoration(labelText: 'Language'),
                      onChanged: (v) => lang = v.trim().toLowerCase(),
                      onSubmitted: (_) => _search(),
                    )),
                  ),
                  const SizedBox(width: 10),
                  GhostButton(label: 'Search', icon: LucideIcons.search, onPressed: searching ? null : () => _search(byTitle: true)),
                ]),
                if (widget.season != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Season ${widget.season}, episode ${widget.episode}', style: TextStyle(color: p.ink2, fontSize: 12.5)),
                  ),
                const SizedBox(height: 10),
                if (searching) const LinearProgressIndicator(minHeight: 2),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(error!, style: TextStyle(color: p.danger)),
                  ),
                Expanded(
                  child: results == null
                      ? const SizedBox()
                      : results!.isEmpty
                          ? const EmptyState(icon: LucideIcons.captionsOff, title: 'No subtitles found')
                          : ListView.separated(
                              itemCount: results!.length,
                              separatorBuilder: (_, _) => Divider(height: 1, color: p.border),
                              itemBuilder: (_, i) {
                                final s = results![i];
                                return ListTile(
                                  dense: true,
                                  title: Text(s.release.isEmpty ? (s.title ?? 'Subtitle') : s.release,
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                  subtitle: Text([
                                    s.language.toUpperCase(),
                                    '${s.downloads} downloads',
                                    if (s.hearingImpaired) 'hearing impaired',
                                    if (s.trusted) 'trusted',
                                  ].join(' · ')),
                                  trailing: downloading == s.fileId
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(LucideIcons.download),
                                  onTap: downloading == null ? () => _download(s) : null,
                                );
                              },
                            ),
                ),
              ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    );
  }
}
