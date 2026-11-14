import '../../data/repository.dart';
import '../../data/sources/models.dart';

enum PlayKind { live, catchup, movie, episode }

/// Everything the player needs to start and to save progress.
class PlayRequest {
  PlayRequest._(this.kind, this.item,
      {this.channels, this.series, this.episode, this.movie, this.programme, this.start = Duration.zero});

  factory PlayRequest.live(ItemView ch, {List<ItemView>? channels}) =>
      PlayRequest._(PlayKind.live, ch, channels: channels);

  factory PlayRequest.catchup(ItemView ch, Programme p) =>
      PlayRequest._(PlayKind.catchup, ch, programme: p);

  factory PlayRequest.movie(ItemView m, {MovieDetail? detail, Duration start = Duration.zero}) =>
      PlayRequest._(PlayKind.movie, m, movie: detail, start: start);

  factory PlayRequest.episode(ItemView series, SeriesDetail detail, EpisodeInfo ep,
          {Duration start = Duration.zero}) =>
      PlayRequest._(PlayKind.episode, series, series: detail, episode: ep, start: start);

  final PlayKind kind;

  /// The channel, movie, or (for episodes) the series item.
  final ItemView item;
  final List<ItemView>? channels;
  final SeriesDetail? series;
  final EpisodeInfo? episode;
  final MovieDetail? movie;
  final Programme? programme;
  final Duration start;

  bool get isVod => kind == PlayKind.movie || kind == PlayKind.episode || kind == PlayKind.catchup;

  String get title => switch (kind) {
        PlayKind.episode => item.name,
        PlayKind.catchup => '${item.name} · ${programme!.title}',
        _ => item.name,
      };

  String? get subtitle => switch (kind) {
        PlayKind.episode =>
          'S${episode!.season} E${episode!.episode}${episode!.title.isEmpty ? '' : ' · ${episode!.title}'}',
        _ => null,
      };

  /// The episode after this one in season/episode order.
  EpisodeInfo? get nextEpisode {
    if (kind != PlayKind.episode) return null;
    final eps = [...series!.episodes]
      ..sort((a, b) => a.season != b.season ? a.season - b.season : a.episode - b.episode);
    final i = eps.indexWhere((e) => e.id == episode!.id);
    return i >= 0 && i + 1 < eps.length ? eps[i + 1] : null;
  }

  /// The episode before this one in season/episode order.
  EpisodeInfo? get previousEpisode {
    if (kind != PlayKind.episode) return null;
    final eps = [...series!.episodes]
      ..sort((a, b) => a.season != b.season ? a.season - b.season : a.episode - b.episode);
    final i = eps.indexWhere((e) => e.id == episode!.id);
    return i > 0 ? eps[i - 1] : null;
  }

  PlayRequest withChannel(ItemView ch, {List<ItemView>? channels}) =>
      PlayRequest._(PlayKind.live, ch, channels: channels ?? this.channels);

  PlayRequest withEpisode(EpisodeInfo ep) =>
      PlayRequest._(PlayKind.episode, item, series: series, episode: ep);
}
