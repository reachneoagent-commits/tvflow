import '../core/platform.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/repository.dart';
import '../data/sources/models.dart';
import '../state/app_state.dart';
import 'theme.dart';
import 'widgets.dart';

String typeNoun(ContentType t) => switch (t) {
      ContentType.live => 'channel',
      ContentType.movie => 'movie',
      ContentType.series => 'series',
    };

/// Context menu for a channel / movie / series.
Future<void> showItemMenu(
  BuildContext context,
  ItemView item,
  Offset pos, {
  VoidCallback? onOpen,
  String openLabel = 'Play',
  VoidCallback? onGuide,
  VoidCallback? onRemoveRecent,
}) async {
  final state = AppScope.read(context);
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final noun = typeNoun(item.type);
  final choice = await showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(pos & const Size(1, 1), Offset.zero & overlay.size),
    items: [
      if (onOpen != null) _mi('open', LucideIcons.play, openLabel),
      _mi('fav', LucideIcons.heart, item.isFavorite ? 'Remove from favourites' : 'Add to favourites',
          filledHeart: item.isFavorite),
      _mi('group', LucideIcons.listPlus, 'Add to group…'),
      if (onGuide != null) _mi('guide', LucideIcons.listVideo, 'TV guide'),
      _mi('hide', LucideIcons.eyeOff, 'Hide $noun'),
      if (onRemoveRecent != null) _mi('recent', LucideIcons.history, 'Remove from recently watched'),
    ],
  );
  if (!context.mounted || choice == null) return;
  switch (choice) {
    case 'open':
      onOpen?.call();
    case 'fav':
      await state.repo.toggleFavorite(item.sourceId, item.type, item.id);
    case 'group':
      await showGroupPicker(context, item);
    case 'guide':
      onGuide?.call();
    case 'hide':
      await state.repo.setHidden(item.sourceId, item.type, 'item', item.id, true);
      if (context.mounted) {
        toast(context, '"${item.name}" hidden. Restore it in Settings → Content → Hidden ${noun == 'series' ? 'series' : '${noun}s'}.');
      }
    case 'recent':
      onRemoveRecent?.call();
  }
}

PopupMenuItem<String> _mi(String v, IconData icon, String label, {bool filledHeart = false}) => PopupMenuItem(
      value: v,
      height: 40,
      child: Row(children: [
        filledHeart ? const FilledHeart(size: 19) : Icon(icon, size: 19),
        const SizedBox(width: 12),
        Text(label)
      ]),
    );

/// Checkbox list of custom groups for the item's type, plus "New group".
Future<void> showGroupPicker(BuildContext context, ItemView item) async {
  final state = AppScope.read(context);
  await showDialog(
    context: context,
    builder: (c) => _GroupPicker(state: state, item: item),
  );
}

class _GroupPicker extends StatefulWidget {
  const _GroupPicker({required this.state, required this.item});
  final AppState state;
  final ItemView item;
  @override
  State<_GroupPicker> createState() => _GroupPickerState();
}

class _GroupPickerState extends State<_GroupPicker> {
  List<(String, String)> groups = [];
  Set<String> member = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final g = await widget.state.repo.userGroups(widget.item.sourceId, widget.item.type);
    final m = await widget.state.repo.groupsContaining(widget.item.id);
    if (mounted) {
      setState(() {
        groups = [for (final x in g) (x.id, x.name)];
        member = m;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AlertDialog(
      title: const Text('Add to group'),
      content: SizedBox(
        width: context.dialogW(380),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.item.name, style: TextStyle(color: p.ink2)),
          const SizedBox(height: 12),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No groups yet. Create one to organise your ${typeNoun(widget.item.type)}s.',
                  style: TextStyle(color: p.ink2)),
            ),
          for (final (id, name) in groups)
            CheckboxListTile(
              value: member.contains(id),
              title: Text(name),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) async {
                await widget.state.repo.setInGroup(id, widget.item.id, v ?? false);
                await _load();
              },
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: GhostButton(
              label: 'New group',
              icon: LucideIcons.plus,
              onPressed: () async {
                final name = await promptText(context, title: 'New group', action: 'Create');
                if (name == null) return;
                final g = await widget.state.repo
                    .createGroup(widget.item.sourceId, widget.item.type, name);
                await widget.state.repo.setInGroup(g.id, widget.item.id, true);
                await _load();
              },
            ),
          ),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
    );
  }
}
