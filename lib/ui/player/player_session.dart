import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../data/database/schema.dart';
import '../../state/app_state.dart';
import 'play_request.dart';

/// Saves where a movie/episode stopped (live channels are recorded when opened).
Future<void> saveWatchProgress(AppState state, PlayRequest r, Duration position, Duration duration) async {
  if (r.kind != PlayKind.movie && r.kind != PlayKind.episode) return;
  if (position < const Duration(seconds: 5)) return;
  final e = r.episode;
  await state.repo.recordWatch(
      sourceId: r.item.sourceId,
      type: r.kind == PlayKind.movie ? 'movie' : 'episode',
      itemId: r.kind == PlayKind.movie ? r.item.id : e!.id,
      seriesId: r.kind == PlayKind.movie ? null : r.item.id,
      name: r.item.name,
      icon: r.item.icon,
      season: e?.season,
      episode: e?.episode,
      positionMs: position.inMilliseconds,
      durationMs: duration.inMilliseconds);
}

/// A playing stream that outlives the full-screen player (picture in picture).
class PlayerSession {
  PlayerSession({
    required this.state,
    required this.player,
    required this.video,
    required this.req,
    required this.source,
    required this.volume,
    required this.rate,
  });

  final AppState state;
  final Player player;
  final VideoController video;
  final PlayRequest req;
  final Source? source;
  final double volume, rate;
  Timer? _save;

  /// Keeps recording progress while the player is minimized.
  void startSaving() {
    _save?.cancel();
    _save = Timer.periodic(const Duration(seconds: 10), (_) => _saveNow());
  }

  void stopSaving() {
    _save?.cancel();
    _save = null;
  }

  Future<void> _saveNow() => saveWatchProgress(state, req, player.state.position, player.state.duration);

  /// Stops playback for good.
  Future<void> close() async {
    stopSaving();
    await _saveNow();
    await player.dispose();
  }
}

/// Holds the minimized player, if any. Only one stream plays at a time.
class PlayerHub {
  static final current = ValueNotifier<PlayerSession?>(null);

  static void minimize(PlayerSession s) {
    s.startSaving();
    current.value = s;
  }

  /// Hands the session back to the full-screen player.
  static PlayerSession? take() {
    final s = current.value;
    s?.stopSaving();
    current.value = null;
    return s;
  }

  /// Closes the minimized player (the user pressed x, or started something new).
  static Future<void> discard() async {
    final s = current.value;
    current.value = null;
    await s?.close();
  }
}
