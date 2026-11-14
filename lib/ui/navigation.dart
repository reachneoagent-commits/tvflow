import 'package:flutter/material.dart';
import '../core/platform.dart';

import '../data/database/schema.dart';
import '../data/repository.dart';
import '../data/sources/models.dart';
import '../state/app_state.dart';
import 'player/play_request.dart';
import 'player/multiview_screen.dart';
import 'player/player_screen.dart';
import 'player/player_session.dart';
import 'screens/add_source_screen.dart';
import 'screens/guide_sheet.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/series_detail_screen.dart';
import 'widgets.dart';

/// Route without the default slide animation (desktop feel).
Route<T> fadeRoute<T>(Widget page, {bool safe = true}) => PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => safe ? TvSafeArea(child: page) : page,
      transitionDuration: const Duration(milliseconds: 140),
      reverseTransitionDuration: const Duration(milliseconds: 100),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    );

/// Opens a channel (plays), a movie or a series (detail page).
void openItem(BuildContext context, ItemView it, {List<ItemView>? channels}) {
  switch (it.type) {
    case ContentType.live:
      openPlayer(context, PlayRequest.live(it, channels: channels));
    case ContentType.movie:
      Navigator.of(context).push(fadeRoute(MovieDetailScreen(item: it)));
    case ContentType.series:
      Navigator.of(context).push(fadeRoute(SeriesDetailScreen(item: it)));
  }
}

/// Opens the multi-view grid, optionally putting [add] into the first free tile.
Future<void> openMultiView(BuildContext context, {ItemView? add}) =>
    Navigator.of(context, rootNavigator: true).push(fadeRoute(MultiViewScreen(add: add), safe: false));

Future<void> openPlayer(BuildContext context, PlayRequest req) async {
  // Something new takes over from a minimized player.
  await PlayerHub.discard();
  if (!context.mounted) return;
  await Navigator.of(context, rootNavigator: true).push(fadeRoute(PlayerScreen(request: req), safe: false));
}

Future<void> openAddSource(BuildContext context, {Source? edit}) async {
  await Navigator.of(context).push(fadeRoute(AddSourceScreen(edit: edit)));
}

Future<void> openGuide(BuildContext context, ItemView channel) =>
    showDialog(context: context, builder: (_) => GuideSheet(channel: channel));

/// Asks "Resume or restart?" when there is a saved position.
/// Returns the start position, or null when the user cancelled.
Future<Duration?> askResume(BuildContext context, WatchRow? w, {String? title}) async {
  if (w == null || w.finished || w.positionMs < 15000) return Duration.zero;
  final pos = Duration(milliseconds: w.positionMs);
  final r = await showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title ?? 'Continue watching?'),
      content: Text('You stopped at ${fmtDuration(pos)}'
          '${w.durationMs > 0 ? ' of ${fmtDuration(Duration(milliseconds: w.durationMs))}' : ''}.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(c, 'restart'), child: const Text('Restart')),
        TextButton(
            onPressed: () => Navigator.pop(c, 'resume'),
            autofocus: true,
            child: Text('Resume from ${fmtDuration(pos)}')),
      ],
    ),
  );
  if (r == null) return null;
  return r == 'resume' ? pos : Duration.zero;
}

/// Plays a movie, asking resume/restart first when relevant.
Future<void> playMovie(BuildContext context, ItemView movie, {MovieDetail? detail}) async {
  final state = AppScope.read(context);
  final w = await state.repo.watch(movie.sourceId, 'movie', movie.id);
  if (!context.mounted) return;
  final start = await askResume(context, w);
  if (start == null || !context.mounted) return;
  await openPlayer(context, PlayRequest.movie(movie, detail: detail, start: start));
}

/// Plays an episode of [series], asking resume/restart first when relevant.
Future<void> playEpisode(BuildContext context, ItemView series, SeriesDetail detail, EpisodeInfo ep,
    {bool ask = true}) async {
  final state = AppScope.read(context);
  final w = await state.repo.watch(series.sourceId, 'episode', ep.id);
  if (!context.mounted) return;
  final start = ask ? await askResume(context, w, title: 'S${ep.season} E${ep.episode}') : Duration.zero;
  if (start == null || !context.mounted) return;
  await openPlayer(context, PlayRequest.episode(series, detail, ep, start: start));
}
