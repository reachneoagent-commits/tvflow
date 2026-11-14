import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/database/schema.dart';
import '../state/app_state.dart';
import 'theme.dart';
import 'widgets.dart';

/// Fetches the latest channels, movies and series for one playlist and tells
/// the person how it went. Each playlist refreshes on its own; a refresh that is
/// already running is joined, not started twice.
Future<void> refreshPlaylist(AppState state, Source s, ScaffoldMessengerState? messenger, Color errorText) async {
  final r = await state.catalog.refresh(s);
  if (messenger == null) return;
  String n(int v) => v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  final lines = <String>[];
  if (!r.ok) {
    lines.add('"${s.name}": ${r.error}');
  } else {
    lines.add('"${s.name}" updated: ${n(r.live)} channels, ${n(r.movies)} movies, ${n(r.series)} series.');
    if (r.guideProgrammes != null) {
      lines.add(r.guideNote == null || (r.guideProgrammes ?? 0) > 0
          ? 'TV guide: ${n(r.guideProgrammes!)} programmes for ${n(r.guideChannels ?? 0)} channels.'
          : 'TV guide: ${r.guideNote}');
    }
    lines.addAll(r.warnings);
  }
  final problem = !r.ok || r.warnings.isNotEmpty || (r.guideNote != null && (r.guideProgrammes ?? 0) == 0);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    content: Text(lines.join('\n'), style: problem ? TextStyle(color: errorText) : null),
    backgroundColor: problem ? const Color(0xFFFFB547) : null,
    duration: Duration(seconds: problem ? 10 : 5),
  ));
}

/// Refresh icon for one playlist. Spins while that playlist is updating.
class RefreshButton extends StatelessWidget {
  const RefreshButton({super.key, required this.source, this.size = 18});
  final Source source;
  final double size;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = context.pal;
    final messenger = ScaffoldMessenger.maybeOf(context);
    return ValueListenableBuilder(
      valueListenable: state.catalog.progress,
      builder: (context, prog, _) {
        final busy = prog.containsKey(source.id) || state.catalog.isRefreshing(source.id);
        if (busy) {
          return Tooltip(
            message: prog[source.id]?.stage ?? 'Updating…',
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(strokeWidth: 2, value: prog[source.id]?.fraction, color: p.accent)),
            ),
          );
        }
        return IconBtn(LucideIcons.refreshCw,
            size: size,
            color: p.ink,
            tooltip: 'Fetch updates for "${source.name}"',
            onTap: () => refreshPlaylist(state, source, messenger, p.onPill));
      },
    );
  }
}
