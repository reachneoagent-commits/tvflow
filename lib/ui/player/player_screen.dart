import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../cast/cast_service.dart';
import '../cast_ui.dart';
import '../../core/platform.dart';

import '../../data/database/schema.dart';
import '../../data/repository.dart';
import '../../data/services/metadata.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'play_request.dart';
import 'player_session.dart';
import 'player_panels.dart';
import 'subtitle_search.dart';

enum _Aspect { fit, fill, stretch, r16x9, r4x3 }

/// Side panel open over the video.
enum _Panel { none, tracks, remote }

extension on _Aspect {
  String get label => switch (this) {
    _Aspect.fit => 'Fit',
    _Aspect.fill => 'Zoom to fill',
    _Aspect.stretch => 'Stretch',
    _Aspect.r16x9 => '16:9',
    _Aspect.r4x3 => '4:3',
  };
}

/// Full-window player for live channels, catch-up, movies and episodes.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.request, this.adopt});
  final PlayRequest request;

  /// A minimized stream to take back over instead of opening [request] again.
  final PlayerSession? adopt;
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final AppState state = AppScope.read(context);
  late PlayRequest req = widget.adopt?.req ?? widget.request;
  bool _handedOff = false;
  late final Player player;
  late final VideoController video;
  final focus = FocusNode();
  final _subs = <StreamSubscription>[];

  Source? source;
  String? error;
  bool opening = true;
  bool showControls = true;
  double _doubleTapX = 0;
  Timer? _hideTimer;
  Timer? _saveTimer;
  bool _enteredFullscreen = false;
  bool fullscreen = false;
  _Aspect aspect = _Aspect.fit;
  double rate = 1;
  int _retries = 0;
  bool _seekingStart = false;

  // Live stream state mirrors.
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool playing = false;
  bool buffering = true;
  double volume = 100;
  Tracks tracks = const Tracks();
  Track track = const Track();

  // Intro / credits.
  SkipSegments segments = SkipSegments();
  final _autoSkipped = <int>{};
  Segment? activeSkip;
  String? activeSkipKind; // intro | recap | credits

  // Next episode countdown.
  Timer? _nextTimer;
  int nextCountdown = 0;

  // Live EPG line.
  Programme? nowProg;
  Programme? nextProg;

  // Side panels, favourite state, and the stream facts shown as chips.
  _Panel panel = _Panel.none;
  bool fav = false;
  Timer? _infoTimer;
  List<ItemView>? _remoteChannels;
  Map<String, ({double fraction, bool finished})> _epProgress = {};
  String? infoRes, infoVideo, infoAudio, infoChannels, infoFps;

  @override
  void initState() {
    super.initState();
    CastService.instance.addListener(_onCast);
    CastService.instance.onStopped = _onCastStopped;
    final adopted = widget.adopt;
    player =
        adopted?.player ??
        Player(
          configuration: const PlayerConfiguration(
            title: 'TVflow',
            bufferSize: 64 * 1024 * 1024,
          ),
        );
    video = adopted?.video ?? VideoController(player);
    volume =
        adopted?.volume ??
        (state.flag(P.rememberVolume, true) ? state.dbl(P.volume, 100) : 100);
    _subs.addAll([
      player.stream.position.listen((p) {
        position = p;
        _checkSegments();
        if (mounted && showControls) setState(() {});
      }),
      player.stream.duration.listen((d) => setState(() => duration = d)),
      player.stream.playing.listen((v) {
        setState(() => playing = v);
        // Remote: the first time playback starts, show the controls with the main button focused.
        if (isTv && v && !_tvStartFocused) {
          _tvStartFocused = true;
          _focusPrimary();
        }
      }),
      player.stream.buffering.listen((v) => setState(() => buffering = v)),
      player.stream.volume.listen((v) => volume = v),
      player.stream.tracks.listen((t) {
        tracks = t;
        _applyPreferredTracks();
        if (mounted) setState(() {});
      }),
      player.stream.track.listen((t) => setState(() => track = t)),
      player.stream.error.listen(_onError),
      player.stream.completed.listen((done) {
        if (done) _onCompleted();
      }),
    ]);
    fav = req.item.isFavorite;
    _saveTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _saveProgress(),
    );
    _infoTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollInfo());
    if (adopted != null) {
      // Picking up a stream that kept playing in the corner.
      source = adopted.source;
      rate = adopted.rate;
      final st = player.state;
      position = st.position;
      duration = st.duration;
      playing = st.playing;
      buffering = st.buffering;
      tracks = st.tracks;
      track = st.track;
      opening = false;
      _loadExtras();
    } else {
      if (isTouch || state.flag(P.fullscreenOnOpen)) {
        _setFullscreen(true);
      }
      _open();
    }
    _armHide();
  }

  /// Remote: play/pause and the skip button, so the first OK always does something sensible.
  final _ppNode = FocusNode(debugLabel: 'play-pause');
  final _skipNode = FocusNode(debugLabel: 'skip');
  bool _tvStartFocused = false;

  /// Shows the controls and focuses Skip (when offered) or play/pause.
  void _focusPrimary() {
    if (error != null) return;
    if (!showControls) setState(() => showControls = true);
    _armHide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final n = activeSkip != null && _skipNode.context != null ? _skipNode : _ppNode;
      if (n.context != null && n.canRequestFocus) {
        n.requestFocus();
      } else {
        tvEnterFocus();
      }
    });
  }

  // Casting: this device goes quiet while the TV plays, and picks up where the TV got to afterwards.
  void _onCast() {
    if (!mounted) return;
    if (CastService.instance.casting && playing) player.pause();
    setState(() {});
  }

  void _onCastStopped(Duration pos) {
    if (!mounted) return;
    if (req.isVod && pos > Duration.zero) player.seek(pos);
    player.play();
  }

  @override
  void dispose() {
    CastService.instance.removeListener(_onCast);
    if (CastService.instance.onStopped == _onCastStopped) CastService.instance.onStopped = null;
    _ppNode.dispose();
    _skipNode.dispose();
    _saveProgress(final_: true);
    for (final s in _subs) {
      s.cancel();
    }
    _hideTimer?.cancel();
    _saveTimer?.cancel();
    _infoTimer?.cancel();
    _nextTimer?.cancel();
    if (_enteredFullscreen || fullscreen) setWindowFullScreen(false);
    if (!_handedOff) player.dispose();
    focus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Opening

  Future<void> _open({bool isRetry = false}) async {
    _nextTimer?.cancel();
    setState(() {
      opening = true;
      error = null;
      nextCountdown = 0;
      segments = SkipSegments();
      activeSkip = null;
      _autoSkipped.clear();
      if (!isRetry) {
        position = Duration.zero;
        duration = Duration.zero;
      }
    });
    try {
      source ??= await state.repo.source(req.item.sourceId);
      final src = source;
      if (src == null) throw StateError('This playlist was removed.');
      final url = switch (req.kind) {
        PlayKind.live ||
        PlayKind.movie => await state.catalog.streamUrl(src, req.item),
        PlayKind.episode => await state.catalog.episodeUrl(src, req.episode!),
        PlayKind.catchup =>
          state.catalog.catchupUrl(src, req.item, req.programme!) ??
              (throw StateError('Replay is not available for this programme.')),
      };
      final ua = state.userAgent;
      final native = player.platform;
      if (native is NativePlayer) {
        await native.setProperty('user-agent', ua);
        await native.setProperty('network-timeout', '20');
        if (req.kind == PlayKind.live) {
          await native.setProperty('cache-secs', '20');
        }
      }
      await player.setVolume(volume);
      final start = isRetry && req.isVod ? position : req.start;
      _seekingStart = start > Duration.zero;
      await player.open(
        Media(
          url,
          httpHeaders: {'User-Agent': ua},
          start: start > Duration.zero ? start : null,
        ),
      );
      await player.setRate(rate);
      CastService.instance.setSource(CastSource(
        url: url,
        title: req.title,
        subtitle: req.subtitle,
        isLive: req.kind == PlayKind.live,
        position: () => position,
      ));
      if (mounted) setState(() => opening = false);
      _recordOpen();
      _loadExtras();
    } catch (e) {
      if (mounted) {
        setState(() {
          opening = false;
          error = '$e';
        });
      }
    }
  }

  /// mpv also reports non-fatal problems (e.g. "cannot seek") on the error
  /// stream, so an error only counts when playback is not moving afterwards.
  void _onError(String e) {
    if (!mounted) return;
    debugPrint('player error: $e');
    final before = position;
    final r = req;
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted || !identical(r, req) || error != null) return;
      final moving =
          position != before ||
          (playing && !buffering && duration > Duration.zero);
      if (moving) return;
      // Live streams drop now and then; try again quietly a couple of times.
      if (req.kind == PlayKind.live && _retries < 2) {
        _retries++;
        _open(isRetry: true);
        return;
      }
      setState(() => error = e.isEmpty ? 'The stream could not be played.' : e);
    });
  }

  Future<void> _recordOpen() async {
    if (req.kind == PlayKind.live) {
      await state.repo.recordWatch(
        sourceId: req.item.sourceId,
        type: 'live',
        itemId: req.item.id,
        name: req.item.name,
        icon: req.item.icon,
      );
    }
  }

  /// Skip segments and the live "now playing" line.
  Future<void> _loadExtras() async {
    final r = req;
    if (r.kind == PlayKind.live) {
      _loadNowPlaying();
      return;
    }
    if (r.kind == PlayKind.catchup) return;
    try {
      int? tmdb;
      String? imdb;
      if (r.kind == PlayKind.movie) {
        tmdb = r.movie?.tmdbId ?? r.item.tmdbId;
        imdb = r.movie?.imdbId;
        if (tmdb == null && imdb == null) {
          final ids = await state.ids.resolve(
            r.item.name,
            tv: false,
            year: r.item.year,
          );
          tmdb = ids.tmdb;
          imdb = ids.imdb;
        }
      } else {
        tmdb = r.series?.tmdbId ?? r.item.tmdbId;
        if (tmdb == null) {
          final ids = await state.ids.resolve(
            r.item.name,
            tv: true,
            year: r.item.year,
          );
          tmdb = ids.tmdb;
          imdb = ids.imdb;
        }
      }
      _ids = (tmdb: tmdb, imdb: imdb);
      // Wait briefly for the duration so the service can pick the right cut.
      for (var i = 0; i < 20 && duration == Duration.zero; i++) {
        await Future.delayed(const Duration(milliseconds: 250));
      }
      final seg = await state.introDb.lookup(
        tmdbId: tmdb,
        imdbId: imdb,
        season: r.kind == PlayKind.episode ? r.episode!.season : null,
        episode: r.kind == PlayKind.episode ? r.episode!.episode : null,
        durationMs: duration.inMilliseconds,
      );
      if (mounted && identical(r, req)) setState(() => segments = seg);
    } catch (_) {
      /* no skip data: nothing shown */
    }
  }

  ({int? tmdb, String? imdb}) _ids = (tmdb: null, imdb: null);

  Future<void> _loadNowPlaying() async {
    final src = source;
    if (src == null) return;
    final list = await state.catalog.channelGuide(
      src,
      req.item,
      back: const Duration(hours: 1),
      ahead: const Duration(hours: 4),
    );
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        nowProg = list.where((p) => p.isLiveAt(now)).firstOrNull;
        nextProg = list.where((p) => p.start.isAfter(now)).firstOrNull;
      });
    }
  }

  void _applyPreferredTracks() {
    final sub = state.str(P.subLang);
    final audio = state.str(P.audioLang);
    if (audio.isNotEmpty && track.audio.id == 'auto') {
      final a = tracks.audio
          .where((t) => _langMatch(t.language, audio))
          .firstOrNull;
      if (a != null) player.setAudioTrack(a);
    }
    if (sub.isNotEmpty && track.subtitle.id == 'auto') {
      final s = tracks.subtitle
          .where((t) => _langMatch(t.language, sub))
          .firstOrNull;
      if (s != null) player.setSubtitleTrack(s);
    }
  }

  bool _langMatch(String? trackLang, String want) {
    if (trackLang == null) return false;
    final t = trackLang.toLowerCase();
    final w = want.toLowerCase().split('-').first;
    const three = {
      'en': 'eng',
      'fr': 'fre',
      'de': 'ger',
      'es': 'spa',
      'it': 'ita',
      'pt': 'por',
      'nl': 'dut',
      'ar': 'ara',
      'tr': 'tur',
      'ru': 'rus',
      'pl': 'pol',
      'sv': 'swe',
      'el': 'gre',
      'ja': 'jpn',
      'ko': 'kor',
      'zh': 'chi',
    };
    return t == w ||
        t.startsWith(w) ||
        t == three[w] ||
        (w == 'fr' && t == 'fra') ||
        (w == 'de' && t == 'deu');
  }

  // ---------------------------------------------------------------------------
  // Progress, segments, completion

  Future<void> _saveProgress({bool final_ = false}) async {
    final r = req;
    if (r.kind != PlayKind.movie && r.kind != PlayKind.episode) return;
    if (position < const Duration(seconds: 5) ||
        _seekingStart && position < r.start)
      return;
    await saveWatchProgress(state, r, position, duration);
  }

  void _checkSegments() {
    if (_seekingStart && position >= req.start - const Duration(seconds: 2))
      _seekingStart = false;
    if (segments.isEmpty) {
      if (activeSkip != null) setState(() => activeSkip = null);
      return;
    }
    final ms = position.inMilliseconds;
    final endMs = duration.inMilliseconds;
    Segment? hit;
    String? kind;
    for (final (k, list) in [
      ('intro', segments.intro),
      ('recap', segments.recap),
      ('credits', segments.credits),
    ]) {
      for (final s in list) {
        final end = s.endMs ?? endMs;
        if (ms >= s.startMs && ms < end - 500) {
          hit = s;
          kind = k;
        }
      }
    }
    if (hit != activeSkip) {
      setState(() {
        activeSkip = hit;
        activeSkipKind = kind;
      });
      if (isTv) {
        // The skip button appears: it gets focus. When it goes away, focus returns to the player.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (hit != null) {
            _skipNode.requestFocus();
          } else if (_skipNode.hasPrimaryFocus) {
            focus.requestFocus();
          }
        });
      }
    }
    if (hit == null || _autoSkipped.contains(hit.startMs)) return;
    final isEpisode = req.kind == PlayKind.episode;
    final auto = switch (kind) {
      'intro' || 'recap' =>
        isEpisode
            ? state.flag(P.seriesSkipIntro)
            : state.flag(P.movieSkipIntro),
      'credits' =>
        isEpisode && state.flag(P.seriesSkipCredits) && req.nextEpisode != null,
      _ => false,
    };
    if (auto) {
      _autoSkipped.add(hit.startMs);
      _doSkip();
    }
  }

  void _doSkip() {
    final s = activeSkip;
    if (s == null) return;
    if (activeSkipKind == 'credits' &&
        req.kind == PlayKind.episode &&
        req.nextEpisode != null) {
      _playNext();
      return;
    }
    final end = s.endMs;
    if (end == null) {
      player.seek(duration - const Duration(seconds: 1));
    } else {
      player.seek(Duration(milliseconds: end));
    }
    toast(
      context,
      activeSkipKind == 'credits' ? 'Credits skipped' : 'Intro skipped',
    );
  }

  void _onCompleted() {
    _saveProgress();
    if (req.kind == PlayKind.episode &&
        req.nextEpisode != null &&
        state.flag(P.autoplayNext, true)) {
      setState(() => nextCountdown = 8);
      _nextTimer?.cancel();
      _nextTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return t.cancel();
        if (nextCountdown <= 1) {
          t.cancel();
          _playNext();
        } else {
          setState(() => nextCountdown--);
        }
      });
    }
  }

  Future<void> _playNext() async {
    final n = req.nextEpisode;
    if (n == null) return;
    await _saveProgress();
    _nextTimer?.cancel();
    req = req.withEpisode(n);
    await _open();
  }

  Future<void> _zap(int delta) async {
    final list = req.channels ?? _remoteChannels;
    if (req.kind != PlayKind.live || list == null || list.length < 2) return;
    final i = list.indexWhere((c) => c.id == req.item.id);
    final next =
        list[(i + delta) % list.length < 0
            ? list.length - 1
            : (i + delta) % list.length];
    req = req.withChannel(next, channels: list);
    fav = next.isFavorite;
    _retries = 0;
    nowProg = null;
    await _open();
  }

  // ---------------------------------------------------------------------------
  // UI helpers

  void _armHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: isTv ? 8 : 3), () {
      if (mounted && playing && panel == _Panel.none) {
        setState(() => showControls = false);
        if (isTv) focus.requestFocus();
      }
    });
  }

  /// Room to keep controls away from the screen edges: cutouts on phones, the overscan margin on TVs.
  EdgeInsets get _safe {
    if (!isTv) return MediaQuery.paddingOf(context);
    final pct = state.integer(P.tvMargin, 5).clamp(0, 15);
    final s = MediaQuery.sizeOf(context);
    return EdgeInsets.symmetric(
      horizontal: s.width * pct / 100,
      vertical: s.height * pct / 100,
    );
  }

  /// Remote: shows the controls and puts focus on the bottom row (audio & subtitles, speed,
  /// channels), the part of the screen people reach for most.
  bool _focusPending = false;

  void _focusControls() {
    if (!showControls) setState(() => showControls = true);
    _armHide();
    _focusPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusPending = false;
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);
      FocusNode? best;
      var bestTop = -1.0;
      final nodes = <FocusNode>[
        for (final n in FocusScope.of(context).traversalDescendants)
          if (n is! FocusScopeNode &&
              n.canRequestFocus &&
              n.context != null &&
              n != focus &&
              n.rect.height < size.height / 2)
            n,
      ];
      for (final n in nodes) {
        if (n.rect.top > bestTop) bestTop = n.rect.top;
      }
      var bestD = double.infinity;
      for (final n in nodes) {
        if (n.rect.top < bestTop - 8) continue;
        final d = (n.rect.center.dx - size.width / 2).abs();
        if (d < bestD) {
          bestD = d;
          best = n;
        }
      }
      if (best != null) {
        best.requestFocus();
      } else {
        tvEnterFocus();
      }
    });
  }

  void _poke() {
    if (!state.flag(P.controlsOnMove, true) && !showControls) return;
    if (!showControls) setState(() => showControls = true);
    _armHide();
  }

  /// Shrinks the player into the corner so the rest of the app can be used.
  void _minimize() {
    if (error != null || _handedOff) return;
    _handedOff = true;
    PlayerHub.minimize(
      PlayerSession(
        state: state,
        player: player,
        video: video,
        req: req,
        source: source,
        volume: volume,
        rate: rate,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _setFullscreen(bool v) async {
    await setWindowFullScreen(v);
    if (v) _enteredFullscreen = true;
    if (mounted) setState(() => fullscreen = v);
  }

  Future<void> _setVolume(double v) async {
    volume = v.clamp(0, 100);
    await player.setVolume(volume);
    if (state.flag(P.rememberVolume, true))
      await state.setPref(P.volume, volume.round());
    setState(() {});
  }

  void _seekBy(int seconds) {
    if (!req.isVod) return;
    final t = position + Duration(seconds: seconds);
    player.seek(
      t < Duration.zero
          ? Duration.zero
          : (duration > Duration.zero && t > duration ? duration : t),
    );
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent)
      return KeyEventResult.ignored;
    final k = e.logicalKey;
    final step = state.integer(P.skipSeconds, 10);
    _poke();
    final isBack =
        k == LogicalKeyboardKey.escape || k == LogicalKeyboardKey.goBack;
    // Play/pause has focus (remote): Left/Right still seek, like a normal player.
    if (isTv &&
        _ppNode.hasPrimaryFocus &&
        req.isVod &&
        (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.arrowRight)) {
      _seekBy(k == LogicalKeyboardKey.arrowLeft ? -step : step);
      return KeyEventResult.handled;
    }
    // A control button has focus (remote): arrows move between buttons, OK presses one.
    if (isTv && !focus.hasPrimaryFocus && !isBack)
      return KeyEventResult.ignored;
    // The controls are being shown and given focus; keys pressed meanwhile must not seek or zap.
    if (isTv && _focusPending && !isBack) return KeyEventResult.handled;
    if (isTv && k == LogicalKeyboardKey.contextMenu) {
      _focusControls();
    } else if (isTv &&
        !isBack &&
        (k == LogicalKeyboardKey.arrowUp ||
            k == LogicalKeyboardKey.arrowDown) &&
        req.kind != PlayKind.live) {
      _focusControls();
    } else if (isTv && k == LogicalKeyboardKey.mediaPlayPause) {
      player.playOrPause();
    } else if (isTv &&
        (k == LogicalKeyboardKey.select || k == LogicalKeyboardKey.enter)) {
      // Live: OK opens the controls (Up/Down change channel). Movies: OK pauses, Up/Down open them.
      if (req.kind == PlayKind.live) {
        _focusControls();
      } else {
        player.playOrPause();
      }
    } else if (k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.keyK) {
      player.playOrPause();
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _seekBy(-step);
    } else if (k == LogicalKeyboardKey.arrowRight) {
      _seekBy(step);
    } else if (k == LogicalKeyboardKey.arrowUp) {
      if (req.kind == PlayKind.live &&
          (isTv || HardwareKeyboard.instance.isMetaPressed)) {
        _zap(-1);
      } else {
        _setVolume(volume + 5);
      }
    } else if (k == LogicalKeyboardKey.arrowDown) {
      if (req.kind == PlayKind.live &&
          (isTv || HardwareKeyboard.instance.isMetaPressed)) {
        _zap(1);
      } else {
        _setVolume(volume - 5);
      }
    } else if (k == LogicalKeyboardKey.pageUp ||
        k == LogicalKeyboardKey.channelUp) {
      _zap(-1);
    } else if (k == LogicalKeyboardKey.pageDown ||
        k == LogicalKeyboardKey.channelDown) {
      _zap(1);
    } else if (k == LogicalKeyboardKey.keyF) {
      _setFullscreen(!fullscreen);
    } else if (k == LogicalKeyboardKey.keyP) {
      _minimize();
    } else if (k == LogicalKeyboardKey.keyM) {
      _setVolume(volume > 0 ? 0 : 100);
    } else if (k == LogicalKeyboardKey.keyN) {
      _playNext();
    } else if (k == LogicalKeyboardKey.keyS && activeSkip != null) {
      _doSkip();
    } else if (isBack) {
      if (!focus.hasPrimaryFocus) {
        focus.requestFocus();
      } else if (panel != _Panel.none) {
        setState(() => panel = _Panel.none);
      } else if (fullscreen && !isTv) {
        _setFullscreen(false);
      } else {
        Navigator.maybePop(context);
      }
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  // ---------------------------------------------------------------------------
  // Tracks & subtitles

  /// Stream facts for the chips: resolution, frame rate, codecs, audio layout.
  Future<void> _pollInfo() async {
    final n = player.platform;
    if (!mounted || n is! NativePlayer || !showControls) return;
    Future<String?> prop(String name) async {
      try {
        final v = await n.getProperty(name);
        return v.isEmpty ? null : v;
      } catch (_) {
        return null;
      }
    }

    final h = int.tryParse(await prop('video-params/h') ?? '');
    final fps = double.tryParse(await prop('container-fps') ?? '');
    final vc = await prop('video-format');
    final ac = await prop('audio-codec-name');
    final ch = int.tryParse(await prop('audio-params/channel-count') ?? '');
    if (!mounted) return;
    setState(() {
      infoRes = h == null || h <= 0 ? null : (h >= 2000 ? '4K' : '${h}p');
      infoFps = fps == null || fps <= 0 ? null : '${fps.round()} fps';
      infoVideo = vc;
      infoAudio = ac;
      infoChannels = switch (ch) {
        1 => '1.0',
        2 => '2.0',
        6 => '5.1',
        8 => '7.1',
        null => null,
        _ => '$ch ch',
      };
    });
  }

  Future<void> _toggleFav() async {
    final it = req.item;
    await state.repo.toggleFavorite(it.sourceId, it.type, it.id);
    if (mounted) setState(() => fav = !fav);
  }

  Future<void> _togglePanel(_Panel p) async {
    if (panel == p) {
      setState(() => panel = _Panel.none);
      return;
    }
    setState(() => panel = p);
    _poke();
    if (p != _Panel.remote) return;
    if (req.kind == PlayKind.live) {
      if (req.channels == null && _remoteChannels == null) {
        // Opened from somewhere without a list (Home, favourites): use the channel's own category.
        final list = await state.repo.browse(
          BrowseQuery(
            sourceId: req.item.sourceId,
            type: ContentType.live,
            categoryId: req.item.categoryId,
          ),
          limit: 400,
        );
        if (!mounted) return;
        setState(() => _remoteChannels = list);
      }
    } else if (req.kind == PlayKind.episode) {
      final m = await state.repo.seriesProgress(req.item.sourceId, req.item.id);
      if (!mounted) return;
      setState(
        () => _epProgress = {
          for (final e in m.entries)
            e.key: (
              fraction: e.value.durationMs > 0
                  ? (e.value.positionMs / e.value.durationMs).clamp(0.0, 1.0)
                  : 0.0,
              finished: e.value.finished,
            ),
        },
      );
    }
  }

  Future<void> _switchChannel(ItemView c) async {
    if (c.id == req.item.id) return;
    req = req.withChannel(c, channels: req.channels ?? _remoteChannels);
    fav = c.isFavorite;
    _retries = 0;
    nowProg = null;
    nextProg = null;
    await _open();
  }

  Future<void> _pickEpisode(EpisodeInfo e) async {
    if (e.id == req.episode?.id) return;
    await _saveProgress();
    _nextTimer?.cancel();
    req = req.withEpisode(e);
    await _open();
  }

  Future<void> _playPrevious() async {
    final n = req.previousEpisode;
    if (n == null) return;
    await _saveProgress();
    _nextTimer?.cancel();
    req = req.withEpisode(n);
    await _open();
  }

  Future<void> _searchSubtitles() async {
    final r = req;
    final res = await showDialog<(File, String)>(
      context: context,
      builder: (_) => SubtitleSearchDialog(
        title: r.item.name,
        tmdbId:
            _ids.tmdb ??
            (r.kind == PlayKind.episode ? r.series?.tmdbId : r.movie?.tmdbId) ??
            r.item.tmdbId,
        imdbId: _ids.imdb ?? r.movie?.imdbId,
        season: r.episode?.season,
        episode: r.episode?.episode,
        tv: r.kind == PlayKind.episode,
      ),
    );
    if (res == null) return;
    await player.setSubtitleTrack(
      SubtitleTrack.uri(
        Uri.file(res.$1.path).toString(),
        title: 'OpenSubtitles',
        language: res.$2,
      ),
    );
    if (mounted) toast(context, 'Subtitles loaded.');
  }

  Future<void> _loadSubtitleFile() async {
    final f = await FilePicker.pickFile(
      dialogTitle: 'Choose a subtitle file',
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass', 'ssa', 'sub'],
    );
    final path = f?.path;
    if (path == null) return;
    await player.setSubtitleTrack(
      SubtitleTrack.uri(Uri.file(path).toString(), title: path.split('/').last),
    );
  }

  Future<void> _pickSpeed() async {
    final v = await pickOption<double>(
      context,
      title: 'Playback speed',
      current: rate,
      options: [
        for (final r in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
          (r, r == 1 ? 'Normal' : '${r}x'),
      ],
    );
    if (v == null) return;
    rate = v;
    await player.setRate(v);
    setState(() {});
  }

  Future<void> _pickAspect() async {
    final v = await pickOption<_Aspect>(
      context,
      title: 'Picture',
      current: aspect,
      options: [for (final a in _Aspect.values) (a, a.label)],
    );
    if (v != null) setState(() => aspect = v);
  }

  SubtitleViewConfiguration _subStyle() {
    final color = switch (state.str(P.subColor, 'white')) {
      'yellow' => const Color(0xFFFFE14D),
      'cyan' => const Color(0xFF6FF3FF),
      'green' => const Color(0xFF7CFF8A),
      _ => Colors.white,
    };
    return SubtitleViewConfiguration(
      style: TextStyle(
        height: 1.4,
        fontSize: state.dbl(P.subSize, 32),
        letterSpacing: 0,
        wordSpacing: 0,
        color: color,
        fontWeight: FontWeight.w600,
        backgroundColor: state.flag(P.subBg) ? const Color(0xAA000000) : null,
        shadows: const [
          Shadow(blurRadius: 4, color: Colors.black),
          Shadow(offset: Offset(1, 1), color: Colors.black),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
    );
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final (fit, ratio) = switch (aspect) {
      _Aspect.fit => (BoxFit.contain, null),
      _Aspect.fill => (BoxFit.cover, null),
      _Aspect.stretch => (BoxFit.fill, null),
      _Aspect.r16x9 => (BoxFit.contain, 16 / 9),
      _Aspect.r4x3 => (BoxFit.contain, 4 / 3),
    };
    final dark = buildTheme(Brightness.dark);
    return Theme(
      // The player is always dark, whatever the app theme.
      data: dark.copyWith(
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        sliderTheme: dark.sliderTheme.copyWith(
          activeTrackColor: Colors.white,
          inactiveTrackColor: Colors.white24,
          thumbColor: Colors.white,
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 7,
            elevation: 0,
          ),
        ),
      ),
      child: PopScope(
        canPop: panel == _Panel.none,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => panel = _Panel.none);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Focus(
            focusNode: focus,
            autofocus: true,
            onKeyEvent: _onKey,
            child: MouseRegion(
              cursor: showControls
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.none,
              onHover: (_) => _poke(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isTouch) {
                    // Touch: a tap shows or hides the controls; the buttons do the rest.
                    if (showControls && playing && panel == _Panel.none) {
                      _hideTimer?.cancel();
                      setState(() => showControls = false);
                    } else {
                      setState(() => showControls = true);
                      _armHide();
                    }
                    return;
                  }
                  if (showControls) {
                    player.playOrPause();
                  }
                  _poke();
                },
                onDoubleTapDown: (d) => _doubleTapX = d.localPosition.dx,
                onDoubleTap: () {
                  // Touch: double-tap the left or right half to skip back or forward.
                  if (isTouch && req.isVod) {
                    final left =
                        _doubleTapX < MediaQuery.sizeOf(context).width / 2;
                    final s = state.integer(P.skipSeconds, 10);
                    _seekBy(left ? -s : s);
                    return;
                  }
                  _setFullscreen(!fullscreen);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Video(
                      controller: video,
                      controls: NoVideoControls,
                      fit: fit,
                      aspectRatio: ratio,
                      subtitleViewConfiguration: _subStyle(),
                    ),
                    if ((buffering || opening) && error == null && !CastService.instance.casting)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    if (CastService.instance.casting)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ColoredBox(
                            color: const Color(0xCC080D0F),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.cast, size: 56, color: context.pal.accent),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Casting to ${CastService.instance.target?.name ?? 'TV'}',
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text('Use the cast button to pause, seek or stop.',
                                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (error != null) _errorView(),
                    if (activeSkip != null && error == null) _skipButton(),
                    if (nextCountdown > 0) _nextCard(),
                    AnimatedOpacity(
                      opacity: showControls || error != null ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: ExcludeFocus(
                        excluding: !(showControls || error != null),
                        child: IgnorePointer(
                          ignoring: !(showControls || error != null),
                          child: _controls(),
                        ),
                      ),
                    ),
                    if (panel != _Panel.none && error == null)
                      Positioned(
                        right: 24 + _safe.right,
                        top: 74 + _safe.top,
                        bottom: 150 + _safe.bottom,
                        child: _sidePanel(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorView() => Center(
    child: _Glass(
      radius: 18,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.circleAlert, color: Colors.white, size: 38),
            const SizedBox(height: 12),
            const Text(
              'Playback failed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GhostButton(
                  label: 'Close',
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: 'Retry',
                  icon: LucideIcons.rotateCcw,
                  onPressed: () {
                    _retries = 0;
                    _open(isRetry: true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _skipButton() {
    final isCredits = activeSkipKind == 'credits';
    final label = isCredits
        ? (req.kind == PlayKind.episode && req.nextEpisode != null
              ? 'Next episode'
              : 'Skip credits')
        : activeSkipKind == 'recap'
        ? 'Skip recap'
        : 'Skip intro';
    return Positioned(
      right: 32 + _safe.right,
      bottom: 170 + _safe.bottom,
      child: PrimaryButton(
        focusNode: _skipNode,
        label: label,
        icon: LucideIcons.skipForward,
        height: 44,
        onPressed: _doSkip,
      ),
    );
  }

  Widget _nextCard() {
    final n = req.nextEpisode!;
    return Positioned(
      right: 32 + _safe.right,
      bottom: 170 + _safe.bottom,
      child: _Glass(
        radius: 16,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next episode in $nextCountdown s',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'S${n.season} E${n.episode}${n.title.isEmpty ? '' : ' · ${n.title}'}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  PrimaryButton(
                    label: 'Play now',
                    icon: LucideIcons.play,
                    height: 36,
                    onPressed: _playNext,
                  ),
                  const SizedBox(width: 10),
                  GhostButton(
                    label: 'Cancel',
                    height: 36,
                    onPressed: () {
                      _nextTimer?.cancel();
                      setState(() => nextCountdown = 0);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sidePanel() {
    final live = req.kind == PlayKind.live;
    if (panel == _Panel.tracks) {
      final auds = tracks.audio
          .where((t) => t.id != 'auto' && t.id != 'no')
          .toList();
      final subs = tracks.subtitle
          .where((t) => t.id != 'auto' && t.id != 'no')
          .toList();
      return PlayerSidePanel(
        width: 680,
        child: TracksPanel(
          audio: auds,
          subtitles: subs,
          currentAudio: track.audio,
          currentSubtitle: track.subtitle,
          onAudio: (a) async {
            await player.setAudioTrack(a);
            if (mounted) setState(() {});
          },
          onSubtitle: (s) async {
            await player.setSubtitleTrack(s);
            if (mounted) setState(() {});
          },
          onSearchOpenSubtitles: _searchSubtitles,
          onLoadFile: _loadSubtitleFile,
          canAddSubtitles: req.isVod,
          subSize: state.dbl(P.subSize, 32),
          subColor: state.str(P.subColor, 'white'),
          subBackground: state.flag(P.subBg),
          onSubSize: (v) =>
              state.setPref(P.subSize, v).then((_) => setState(() {})),
          onSubColor: (v) =>
              state.setPref(P.subColor, v).then((_) => setState(() {})),
          onSubBackground: (v) =>
              state.setPref(P.subBg, v).then((_) => setState(() {})),
          onClose: () => setState(() => panel = _Panel.none),
        ),
      );
    }
    if (live) {
      final list = req.channels ?? _remoteChannels;
      return PlayerSidePanel(
        width: 400,
        child: list == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : ChannelsPanel(
                channels: list,
                currentId: req.item.id,
                onPick: _switchChannel,
                onClose: () => setState(() => panel = _Panel.none),
              ),
      );
    }
    return PlayerSidePanel(
      // Wider than the channel list: episodes carry a picture and a description.
      width: 560,
      child: EpisodesPanel(
        episodes: req.series?.episodes ?? const [],
        currentId: req.episode?.id ?? '',
        progress: _epProgress,
        onPick: _pickEpisode,
        onClose: () => setState(() => panel = _Panel.none),
      ),
    );
  }

  Widget _chip(String text) => Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white54, width: 1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _controls() {
    final p = context.pal;
    final live = req.kind == PlayKind.live;
    const dim = Color(0xB3FFFFFF);
    final canSeek = req.isVod && duration > Duration.zero;
    final step = state.integer(P.skipSeconds, 10);
    final hasChannels =
        live && ((req.channels ?? _remoteChannels)?.length ?? 0) > 1;
    final isEpisode = req.kind == PlayKind.episode;
    final hasRemote = live || isEpisode;
    final narrow = MediaQuery.sizeOf(context).width < 700;
    final now = DateTime.now();
    final chips = [?infoFps, ?infoRes, ?infoVideo, ?infoChannels, ?infoAudio];

    Widget seekGlyph(IconData icon, String tip, int secs) => Pressable(
      onTap: () => _seekBy(secs),
      radius: 30,
      tooltip: tip,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '${secs.abs()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Widget transport(IconData icon, String tip, VoidCallback? onTap) => IconBtn(
      icon,
      color: Colors.white,
      size: 30,
      pad: 12,
      tooltip: tip,
      onTap: onTap,
    );
    Widget textButton(
      IconData icon,
      String label,
      VoidCallback onTap, {
      bool on = false,
    }) => Pressable(
      onTap: onTap,
      radius: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: on ? p.accent : Colors.white),
            if (!narrow) const SizedBox(width: 8),
            if (!narrow)
              Text(
                label,
                style: TextStyle(
                  color: on ? p.accent : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        // Top: close, stream facts, volume, picture, full screen.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              (isDesktop && !fullscreen ? 86 : 24) + _safe.left,
              14 + _safe.top,
              24 + _safe.right,
              40,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xB3000000), Color(0x00000000)],
              ),
            ),
            child: Row(
              children: [
                RoundIconButton(
                  LucideIcons.x,
                  size: 38,
                  color: Colors.white,
                  bg: Colors.white24,
                  tooltip: 'Close (Esc)',
                  onTap: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 12),
                if (live) ...[const LiveBadge(), const SizedBox(width: 8)],
                if (req.kind == PlayKind.catchup) ...[
                  const LiveBadge(label: 'REPLAY', color: Colors.white30),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                // Stream facts and the volume slider need room; phones use the device volume keys.
                if (!isTouch && !isTv && !narrow) ...[
                  for (final c in chips) _chip(c),
                  const SizedBox(width: 8),
                  IconBtn(
                    volume == 0 ? LucideIcons.volumeX : LucideIcons.volume2,
                    color: Colors.white,
                    size: 22,
                    tooltip: 'Mute (M)',
                    onTap: () => _setVolume(volume > 0 ? 0 : 100),
                  ),
                  SizedBox(
                    width: 110,
                    child: Slider(
                      value: volume.clamp(0, 100),
                      max: 100,
                      onChanged: _setVolume,
                    ),
                  ),
                ],
                if (!isTv) CastButton(color: Colors.white, size: 22),
                IconBtn(
                  LucideIcons.ratio,
                  color: Colors.white,
                  size: 22,
                  tooltip: 'Picture: ${aspect.label}',
                  onTap: _pickAspect,
                ),
                if (isDesktop)
                  IconBtn(
                    LucideIcons.pictureInPicture2,
                    color: Colors.white,
                    size: 22,
                    tooltip: 'Minimize to corner (P)',
                    onTap: _minimize,
                  ),
                if (isDesktop)
                  IconBtn(
                    fullscreen ? LucideIcons.minimize : LucideIcons.maximize,
                    color: Colors.white,
                    size: 22,
                    tooltip: fullscreen
                        ? 'Exit full screen (F)'
                        : 'Full screen (F)',
                    onTap: () => _setFullscreen(!fullscreen),
                  ),
              ],
            ),
          ),
        ),
        // Centre: transport.
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canSeek)
                seekGlyph(LucideIcons.rotateCcw, 'Back $step s', -step),
              if (hasChannels)
                transport(
                  LucideIcons.skipBack,
                  'Previous channel (Page Up)',
                  () => _zap(-1),
                )
              else if (isEpisode)
                transport(
                  LucideIcons.skipBack,
                  'Previous episode',
                  req.previousEpisode == null ? null : _playPrevious,
                ),
              const SizedBox(width: 10),
              IconBtn(
                playing ? LucideIcons.pause : LucideIcons.play,
                focusNode: _ppNode,
                color: Colors.white,
                size: 54,
                pad: 12,
                tooltip: playing ? 'Pause (Space)' : 'Play (Space)',
                onTap: player.playOrPause,
              ),
              const SizedBox(width: 10),
              if (hasChannels)
                transport(
                  LucideIcons.skipForward,
                  'Next channel (Page Down)',
                  () => _zap(1),
                )
              else if (isEpisode)
                transport(
                  LucideIcons.skipForward,
                  'Next episode (N)',
                  req.nextEpisode == null ? null : _playNext,
                ),
              if (canSeek)
                seekGlyph(LucideIcons.rotateCw, 'Forward $step s', step),
            ],
          ),
        ),
        // Bottom: title, time, progress, and the three panels.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              28 + _safe.left,
              60,
              28 + _safe.right,
              14 + _safe.bottom,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xCC000000)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconBtn(
                      LucideIcons.heart,
                      filled: fav,
                      color: fav ? p.accent : Colors.white,
                      size: 26,
                      pad: 6,
                      tooltip: fav
                          ? 'In favourites. Click to remove'
                          : 'Add to favourites',
                      onTap: _toggleFav,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (req.subtitle != null)
                            Text(
                              req.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: dim, fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                    if (canSeek)
                      Text(
                        '${fmtDuration(position)} / ${fmtDuration(duration)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    if (hasChannels)
                      Text(
                        '${(req.channels ?? _remoteChannels)!.indexWhere((c) => c.key == req.item.key) + 1} / ${(req.channels ?? _remoteChannels)!.length}',
                        style: const TextStyle(color: dim, fontSize: 13),
                      ),
                  ],
                ),
                if (live && nowProg != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: nowProg!.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '   ${fmtTime(nowProg!.start)}–${fmtTime(nowProg!.stop)}',
                                style: const TextStyle(
                                  color: dim,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (nextProg != null)
                        Flexible(
                          child: Text(
                            'Next  ${fmtTime(nextProg!.start)}  ${nextProg!.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: dim, fontSize: 12.5),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ThinBar(
                    nowProg!.progressAt(now),
                    height: 4,
                    color: p.accent,
                    track: Colors.white24,
                  ),
                ],
                if (canSeek && isTv)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ThinBar(
                      duration.inMilliseconds > 0
                          ? (position.inMilliseconds / duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                          : 0,
                      height: 5,
                      color: p.accent,
                      track: Colors.white24,
                    ),
                  ),
                if (canSeek && !isTv)
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: p.accent,
                      thumbColor: p.accent,
                      inactiveTrackColor: Colors.white24,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                        elevation: 0,
                      ),
                    ),
                    child: Slider(
                      value: position.inMilliseconds
                          .clamp(0, duration.inMilliseconds)
                          .toDouble(),
                      max: duration.inMilliseconds.toDouble(),
                      onChanged: (v) => setState(
                        () => position = Duration(milliseconds: v.round()),
                      ),
                      onChangeEnd: (v) =>
                          player.seek(Duration(milliseconds: v.round())),
                    ),
                  ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    textButton(
                      LucideIcons.captions,
                      'Audio & Subtitles',
                      () => _togglePanel(_Panel.tracks),
                      on: panel == _Panel.tracks,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (req.isVod)
                            textButton(
                              LucideIcons.gauge,
                              rate == 1 ? 'Speed' : 'Speed ${rate}x',
                              _pickSpeed,
                            ),
                          if (hasRemote)
                            textButton(
                              LucideIcons.listVideo,
                              isEpisode ? 'Episodes' : 'Channels',
                              () => _togglePanel(_Panel.remote),
                              on: panel == _Panel.remote,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Frosted dark panel used for player overlays.
class _Glass extends StatelessWidget {
  const _Glass({required this.child, this.radius = 16});
  final Widget child;
  final double radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x8C1C1C1E),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white12, width: 0.5),
        ),
        child: child,
      ),
    ),
  );
}
