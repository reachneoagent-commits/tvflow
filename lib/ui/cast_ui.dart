import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../cast/cast_backends.dart';
import '../cast/cast_service.dart';
import '../core/platform.dart';
import 'theme.dart';
import 'widgets.dart';

/// Header / player button: opens the device list. Lit up while casting.
class CastButton extends StatelessWidget {
  const CastButton({super.key, this.color, this.size = 20});
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cast = CastService.instance;
    return ListenableBuilder(
      listenable: cast,
      builder: (context, _) => IconBtn(
        LucideIcons.cast,
        size: size,
        color: cast.casting ? context.pal.accent : (color ?? context.pal.ink2),
        tooltip: cast.casting ? 'Casting to ${cast.target?.name ?? 'TV'}' : 'Cast to a TV',
        onTap: () => showCastPicker(context),
      ),
    );
  }
}

Future<void> showCastPicker(BuildContext context) {
  final cast = CastService.instance;
  if (!cast.scanning && !cast.casting) cast.scan();
  return showDialog<void>(context: context, builder: (_) => const _CastDialog());
}

class _CastDialog extends StatelessWidget {
  const _CastDialog();

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final cast = CastService.instance;
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.dialogW(460), maxHeight: 560),
        child: ListenableBuilder(
          listenable: cast,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(LucideIcons.cast, color: p.accent, size: 22),
                const SizedBox(width: 10),
                const Expanded(child: Text('Cast to a TV', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
                if (!cast.scanning && !cast.casting)
                  IconBtn(LucideIcons.refreshCw, size: 18, tooltip: 'Search again', onTap: cast.scan),
              ]),
              const SizedBox(height: 12),
              if (cast.casting) _Active(cast: cast) else ..._list(context, cast, p),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  List<Widget> _list(BuildContext context, CastService cast, Palette p) {
    final noSource = cast.source == null;
    return [
      if (cast.scanning) ...[
        ClipRRect(borderRadius: BorderRadius.circular(3), child: const LinearProgressIndicator(minHeight: 4)),
        const SizedBox(height: 10),
      ],
      if (noSource)
        Text('Start playing a channel, movie or episode first. Then press the cast button to send it to a TV.',
            style: TextStyle(color: p.ink2, fontSize: 13.5, height: 1.4))
      else
        Text('Make sure this device is on the same Wi-Fi as your TV.', style: TextStyle(color: p.ink2, fontSize: 13.5)),
      if (cast.error != null) ...[
        const SizedBox(height: 10),
        Text(cast.error!, style: TextStyle(color: p.danger, fontSize: 13.5, height: 1.4)),
      ],
      const SizedBox(height: 10),
      Flexible(
        child: cast.devices.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(cast.scanning ? 'Searching for devices…' : 'No devices found.',
                    style: TextStyle(color: p.ink3)),
              )
            : ListView(shrinkWrap: true, children: [
                for (final d in cast.devices)
                  Pressable(
                    onTap: noSource ? null : () => cast.start(d),
                    radius: 12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Row(children: [
                        Icon(_icon(d.kind), size: 22, color: noSource ? p.ink3 : p.ink),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            Text(d.kind.label, style: TextStyle(color: p.ink2, fontSize: 12.5)),
                          ]),
                        ),
                      ]),
                    ),
                  ),
              ]),
      ),
    ];
  }

  IconData _icon(CastKind k) => switch (k) {
        CastKind.chromecast => LucideIcons.cast,
        CastKind.airplay => LucideIcons.airplay,
        CastKind.roku => LucideIcons.tv,
        CastKind.dlna => LucideIcons.monitorPlay,
      };
}

class _Active extends StatelessWidget {
  const _Active({required this.cast});
  final CastService cast;

  String _fmt(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
    final mm = m.toString().padLeft(2, '0'), ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final live = cast.source?.isLive ?? false;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(cast.status == CastStatus.connecting ? 'Connecting to ${cast.target?.name}…' : 'Casting to ${cast.target?.name}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(cast.source?.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.ink2, fontSize: 13.5)),
      if (cast.error != null) ...[
        const SizedBox(height: 8),
        Text(cast.error!, style: TextStyle(color: p.danger, fontSize: 13)),
      ],
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (!live) IconBtn(LucideIcons.rotateCcw, size: 24, tooltip: 'Back 10 s', onTap: () => cast.seekBy(const Duration(seconds: -10))),
        IconBtn(cast.paused ? LucideIcons.play : LucideIcons.pause, size: 30, tooltip: cast.paused ? 'Play' : 'Pause', onTap: cast.togglePause),
        if (!live) IconBtn(LucideIcons.rotateCw, size: 24, tooltip: 'Forward 10 s', onTap: () => cast.seekBy(const Duration(seconds: 10))),
      ]),
      if (!live) Center(child: Text(_fmt(cast.position), style: TextStyle(color: p.ink2, fontSize: 13))),
      const SizedBox(height: 14),
      PrimaryButton(label: 'Stop casting', icon: LucideIcons.x, onPressed: cast.stop),
    ]);
  }
}
