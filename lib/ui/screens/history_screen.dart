import '../../core/platform.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/database/schema.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../navigation.dart';
import '../player/play_request.dart';
import '../theme.dart';
import '../widgets.dart';
import 'detail_common.dart';

/// Everything watched on the active source, newest first.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.embedded = false});

  /// True when shown as a sidebar page (no back button).
  final bool embedded;
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final AppState state = AppScope.read(context);
  List<WatchRow>? rows;
  String filter = 'all';

  @override
  void initState() {
    super.initState();
    state.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    state.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final src = state.activeSource;
    if (src == null) return;
    final all = [
      ...await state.repo.recent(src.id, 'live', limit: 200),
      ...await state.repo.recent(src.id, 'movie', limit: 200),
      ...await state.repo.recent(src.id, 'episode', limit: 400),
    ]..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    if (mounted) setState(() => rows = all);
  }

  Future<void> _open(WatchRow r) async {
    switch (r.type) {
      case 'live':
        final it = await state.repo.item(r.sourceId, ContentType.live, r.itemId);
        if (it != null && mounted) await openPlayer(context, PlayRequest.live(it));
      case 'movie':
        final it = await state.repo.item(r.sourceId, ContentType.movie, r.itemId);
        if (it != null && mounted) openItem(context, it);
      case 'episode':
        final it = await state.repo.item(r.sourceId, ContentType.series, r.seriesId ?? '');
        if (it != null && mounted) openItem(context, it);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final list = (rows ?? []).where((r) => filter == 'all' || r.type == filter).toList();
    final filters = SizedBox(
      width: context.compact ? null : 300,
      child: Segmented<String>(
        values: const ['all', 'live', 'movie', 'episode'],
        labels: const ['All', 'TV', 'Movies', 'Series'],
        selected: filter,
        onChanged: (k) => setState(() => filter = k),
      ),
    );
    final body = Column(children: [
          if (widget.embedded && context.compact)
            Padding(padding: const EdgeInsets.fromLTRB(14, 6, 14, 10), child: filters)
          else if (widget.embedded)
            PageHeader('History', subtitle: state.activeSource?.name, trailing: [filters])
          else
            BackBar(title: 'History', trailing: [filters]),
          Expanded(
            child: rows == null
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? const EmptyState(icon: LucideIcons.history, title: 'Nothing watched yet', message: 'Channels, movies and episodes you play show up here.')
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(context.gutter, 4, context.gutter, 28),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final r = list[i];
                          final frac = r.durationMs > 0 && !r.finished ? r.positionMs / r.durationMs : null;
                          return Pressable(
                            radius: 10,
                            onTap: () => _open(r),
                            // Remote: the Menu key removes the entry (there is no small x to aim at).
                            onSecondaryTapUp: isTv ? (_) => state.repo.removeWatch(r.sourceId, r.type, r.itemId) : null,
                            child: Container(
                              height: 64,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border, width: 0.5))),
                              child: Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: SizedBox(
                                      width: 72,
                                      height: 44,
                                      child: NetImage(r.icon, fit: r.type == 'live' ? BoxFit.contain : BoxFit.cover)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            r.type == 'episode' ? '${r.name} · S${r.season} E${r.episode}' : r.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 3),
                                        Text(
                                          [
                                            fmtDateTime(DateTime.fromMillisecondsSinceEpoch(r.watchedAt)),
                                            if (r.finished) 'watched',
                                            if (frac != null) '${(frac * 100).round()}%',
                                          ].join(' · '),
                                          style: TextStyle(color: p.ink2, fontSize: 12.5),
                                        ),
                                        if (frac != null) ...[
                                          const SizedBox(height: 5),
                                          SizedBox(width: 160, child: ThinBar(frac)),
                                        ],
                                      ]),
                                ),
                                if (!isTv)
                                IconBtn(LucideIcons.x,
                                    tooltip: 'Remove from history',
                                    size: 18,
                                    onTap: () => state.repo.removeWatch(r.sourceId, r.type, r.itemId)),
                              ]),
                            ),
                          );
                        },
                      ),
          ),
        ]);
    return widget.embedded ? body : Scaffold(body: SafeArea(child: body));
  }
}
