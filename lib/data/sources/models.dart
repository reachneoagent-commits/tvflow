/// Plain data passed from importers to the repository.
library;

enum ContentType {
  live('live', 'Live TV'),
  movie('movie', 'Movies'),
  series('series', 'Series');

  const ContentType(this.key, this.label);
  final String key;
  final String label;

  static ContentType of(String key) =>
      values.firstWhere((e) => e.key == key, orElse: () => live);
}

enum SourceKind {
  m3u('m3u', 'Playlist M3U/M3U8'),
  file('file', 'Local file'),
  xtream('xtream', 'Xtream Codes'),
  stalker('stalker', 'Stalker Portal');

  const SourceKind(this.key, this.label);
  final String key;
  final String label;

  static SourceKind of(String key) =>
      values.firstWhere((e) => e.key == key, orElse: () => m3u);
}

class ImportedCategory {
  ImportedCategory(this.id, this.name);
  final String id;
  final String name;
}

class ImportedItem {
  ImportedItem({
    required this.type,
    required this.id,
    required this.name,
    this.categoryId = '',
    this.icon,
    this.rating,
    this.added = 0,
    this.year,
    this.releaseDate,
    this.epgId,
    this.tmdbId,
    this.archiveDays = 0,
    this.ext,
    this.url,
    this.plot,
    this.extra,
  });

  final ContentType type;
  final String id;
  final String name;
  final String categoryId;
  final String? icon;
  final double? rating;
  final int added;
  final int? year;
  final String? releaseDate;
  final String? epgId;
  final int? tmdbId;
  final int archiveDays;
  final String? ext;
  final String? url;
  final String? plot;
  final Map<String, dynamic>? extra;
}

/// One content type's worth of imported data.
class ImportBatch {
  ImportBatch(this.type, this.categories, this.items);
  final ContentType type;
  final List<ImportedCategory> categories;
  final List<ImportedItem> items;
}

class EpisodeInfo {
  EpisodeInfo({
    required this.id,
    required this.season,
    required this.episode,
    required this.title,
    this.plot,
    this.image,
    this.durationSecs,
    this.ext,
    this.url,
    this.rating,
    this.airDate,
  });

  final String id;
  final int season;
  final int episode;
  final String title;
  final String? plot;
  final String? image;
  final int? durationSecs;
  final String? ext;
  final String? url;
  final double? rating;
  final String? airDate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'season': season,
        'episode': episode,
        'title': title,
        'plot': plot,
        'image': image,
        'duration': durationSecs,
        'ext': ext,
        'url': url,
        'rating': rating,
        'air': airDate,
      };

  factory EpisodeInfo.fromJson(Map<String, dynamic> j) => EpisodeInfo(
        id: j['id'].toString(),
        season: (j['season'] as num?)?.toInt() ?? 0,
        episode: (j['episode'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ?? '',
        plot: j['plot'] as String?,
        image: j['image'] as String?,
        durationSecs: (j['duration'] as num?)?.toInt(),
        ext: j['ext'] as String?,
        url: j['url'] as String?,
        rating: (j['rating'] as num?)?.toDouble(),
        airDate: j['air'] as String?,
      );
}

class SeriesDetail {
  SeriesDetail({
    required this.episodes,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.backdrop,
    this.tmdbId,
    this.rating,
    this.releaseDate,
    this.trailer,
  });

  final List<EpisodeInfo> episodes;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final String? backdrop;
  final int? tmdbId;
  final double? rating;
  final String? releaseDate;
  final String? trailer;

  List<int> get seasons =>
      (episodes.map((e) => e.season).toSet().toList()..sort());

  Map<String, dynamic> toJson() => {
        'episodes': [for (final e in episodes) e.toJson()],
        'plot': plot,
        'cast': cast,
        'director': director,
        'genre': genre,
        'backdrop': backdrop,
        'tmdb': tmdbId,
        'rating': rating,
        'release': releaseDate,
        'trailer': trailer,
      };

  factory SeriesDetail.fromJson(Map<String, dynamic> j) => SeriesDetail(
        episodes: [
          for (final e in (j['episodes'] as List? ?? const []))
            EpisodeInfo.fromJson((e as Map).cast<String, dynamic>())
        ],
        plot: j['plot'] as String?,
        cast: j['cast'] as String?,
        director: j['director'] as String?,
        genre: j['genre'] as String?,
        backdrop: j['backdrop'] as String?,
        tmdbId: (j['tmdb'] as num?)?.toInt(),
        rating: (j['rating'] as num?)?.toDouble(),
        releaseDate: j['release'] as String?,
        trailer: j['trailer'] as String?,
      );
}

class MovieDetail {
  MovieDetail({
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.durationSecs,
    this.backdrop,
    this.tmdbId,
    this.imdbId,
    this.rating,
    this.releaseDate,
    this.trailer,
  });

  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final int? durationSecs;
  final String? backdrop;
  final int? tmdbId;
  final String? imdbId;
  final double? rating;
  final String? releaseDate;
  final String? trailer;

  Map<String, dynamic> toJson() => {
        'plot': plot,
        'cast': cast,
        'director': director,
        'genre': genre,
        'duration': durationSecs,
        'backdrop': backdrop,
        'tmdb': tmdbId,
        'imdb': imdbId,
        'rating': rating,
        'release': releaseDate,
        'trailer': trailer,
      };

  factory MovieDetail.fromJson(Map<String, dynamic> j) => MovieDetail(
        plot: j['plot'] as String?,
        cast: j['cast'] as String?,
        director: j['director'] as String?,
        genre: j['genre'] as String?,
        durationSecs: (j['duration'] as num?)?.toInt(),
        backdrop: j['backdrop'] as String?,
        tmdbId: (j['tmdb'] as num?)?.toInt(),
        imdbId: j['imdb'] as String?,
        rating: (j['rating'] as num?)?.toDouble(),
        releaseDate: j['release'] as String?,
        trailer: j['trailer'] as String?,
      );
}

/// A programme in the guide.
class Programme {
  Programme({
    required this.start,
    required this.stop,
    required this.title,
    this.description,
  });
  final DateTime start;
  final DateTime stop;
  final String title;
  final String? description;

  bool isLiveAt(DateTime t) => !t.isBefore(start) && t.isBefore(stop);
  double progressAt(DateTime t) {
    final total = stop.difference(start).inSeconds;
    if (total <= 0) return 0;
    return (t.difference(start).inSeconds / total).clamp(0.0, 1.0);
  }
}
