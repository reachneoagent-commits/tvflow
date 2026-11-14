import '../../core/platform.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/database/schema.dart';
import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../navigation.dart';
import '../player/play_request.dart';
import '../widgets.dart';
import 'detail_common.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.item});
  final ItemView item;
  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  MovieDetail? detail;
  String? error;
  WatchRow? watch;
  late final AppState state = AppScope.read(context);

  @override
  void initState() {
    super.initState();
    state.revision.addListener(_loadWatch);
    _load();
  }

  @override
  void dispose() {
    state.revision.removeListener(_loadWatch);
    super.dispose();
  }

  Future<void> _load() async {
    _loadWatch();
    try {
      final src = await state.repo.source(widget.item.sourceId);
      if (src == null) return;
      final d = await state.catalog.movieDetail(src, widget.item);
      if (mounted) setState(() => detail = d);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  Future<void> _loadWatch() async {
    final w = await state.repo.watch(widget.item.sourceId, 'movie', widget.item.id);
    if (mounted) setState(() => watch = w);
  }

  @override
  Widget build(BuildContext context) {
    final d = detail;
    final w = watch;
    final hasResume = w != null && !w.finished && w.positionMs > 15000;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          BackBar(title: widget.item.name),
          Expanded(
            child: LiveItem(
              item: widget.item,
              builder: (context, it) => ListView(children: [
                DetailHeader(
                  item: it,
                  backdrop: d?.backdrop,
                  plot: d?.plot ?? it.plot,
                  rating: d?.rating ?? it.rating,
                  facts: [
                    if (d?.genre != null) ('Genre', d!.genre!),
                    if (d?.durationSecs != null && d!.durationSecs! > 0)
                      ('Duration', fmtDuration(Duration(seconds: d.durationSecs!))),
                    if (d?.releaseDate != null) ('Released', d!.releaseDate!),
                    if (d?.director != null) ('Director', d!.director!),
                    if (d?.cast != null) ('Cast', d!.cast!),
                  ],
                  actions: [
                    if (hasResume)
                      PrimaryButton(
                        autofocus: true,
                        label: 'Resume ${fmtDuration(Duration(milliseconds: w.positionMs))}',
                        icon: LucideIcons.play,
                        onPressed: () => openPlayer(context,
                            PlayRequest.movie(it, detail: d, start: Duration(milliseconds: w.positionMs))),
                      ),
                    if (hasResume)
                      GhostButton(
                        label: 'Start over',
                        icon: LucideIcons.rotateCcw,
                        onPressed: () => openPlayer(context, PlayRequest.movie(it, detail: d)),
                      )
                    else
                      PrimaryButton(
                        autofocus: true,
                        label: 'Play',
                        icon: LucideIcons.play,
                        onPressed: () => openPlayer(context, PlayRequest.movie(it, detail: d)),
                      ),
                  ],
                ),
                if (hasResume && w.durationMs > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.compact ? 16 : 36),
                    child: Row(children: [
                      SizedBox(width: context.compact ? 160 : 220, child: ThinBar(w.positionMs / w.durationMs, height: 4)),
                      const SizedBox(width: 12),
                      Text('${fmtDuration(Duration(milliseconds: w.durationMs - w.positionMs))} left',
                          style: const TextStyle(fontSize: 13)),
                    ]),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Details could not be loaded: $error'),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
