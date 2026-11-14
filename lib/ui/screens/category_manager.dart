import '../../core/platform.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Reorder / hide categories and manage custom groups for one content type.
Future<void> showCategoryManager(BuildContext context, String sourceId, ContentType type) =>
    showDialog(context: context, builder: (_) => _CategoryManager(sourceId: sourceId, type: type));

class _CategoryManager extends StatefulWidget {
  const _CategoryManager({required this.sourceId, required this.type});
  final String sourceId;
  final ContentType type;
  @override
  State<_CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<_CategoryManager> {
  late final AppState state = AppScope.read(context);
  List<CategoryView> groups = [];
  List<CategoryView> cats = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await state.repo.categories(widget.sourceId, widget.type, includeHidden: true);
    if (!mounted) return;
    setState(() {
      groups = all.where((c) => c.isGroup).toList();
      cats = all.where((c) => !c.isGroup).toList();
      loading = false;
    });
  }

  Future<void> _reorderCats(int a, int b) async {
    setState(() => cats.insert(b, cats.removeAt(a)));
    await state.repo.setCategoryOrder(widget.sourceId, widget.type, [for (final c in cats) c.id]);
  }

  Future<void> _reorderGroups(int a, int b) async {
    setState(() => groups.insert(b, groups.removeAt(a)));
    await state.repo.reorderGroups([for (final g in groups) g.id.substring(6)]);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Dialog(
      child: SizedBox(
        width: context.dialogW(560),
        height: (MediaQuery.sizeOf(context).height - 80).clamp(0.0, 640.0),
        child: DefaultTabController(
          length: 2,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
              child: Row(children: [
                Expanded(
                  child: Text('${widget.type.label} categories',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ),
                IconBtn(LucideIcons.x, onTap: () => Navigator.pop(context)),
              ]),
            ),
            TabBar(
              labelColor: p.ink,
              indicatorColor: p.ink,
              tabs: const [Tab(text: 'Categories'), Tab(text: 'My groups')],
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(children: [_catsTab(p), _groupsTab(p)]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _catsTab(Palette p) {
    if (cats.isEmpty) {
      return const EmptyState(icon: LucideIcons.layoutGrid, title: 'No categories');
    }
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: Row(children: [
          Expanded(
            child: Text('Drag to reorder. Hidden categories disappear from the sidebar.',
                style: TextStyle(color: p.ink2, fontSize: 13)),
          ),
          TextButton(
            onPressed: () async {
              cats.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              setState(() {});
              await state.repo
                  .setCategoryOrder(widget.sourceId, widget.type, [for (final c in cats) c.id]);
            },
            child: const Text('Sort A-Z'),
          ),
        ]),
      ),
      Expanded(
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: cats.length,
          onReorderItem: _reorderCats,
          itemBuilder: (_, i) {
            final c = cats[i];
            return Container(
              key: ValueKey(c.id),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 50,
              child: Row(children: [
                ReorderableDragStartListener(
                  index: i,
                  child: const MouseRegion(
                      cursor: SystemMouseCursors.grab,
                      child: Padding(padding: EdgeInsets.all(8), child: Icon(LucideIcons.gripVertical, size: 20))),
                ),
                Expanded(
                  child: Text(c.name,
                      style: TextStyle(
                          fontFamily: Fonts.condensed,
                          fontSize: 15,
                          color: c.hidden ? p.ink3 : p.ink,
                          decoration: c.hidden ? TextDecoration.lineThrough : null)),
                ),
                IconBtn(c.hidden ? LucideIcons.eyeOff : LucideIcons.eye,
                    tooltip: c.hidden ? 'Show category' : 'Hide category', onTap: () async {
                  await state.repo.setHidden(widget.sourceId, widget.type, 'category', c.id, !c.hidden);
                  await _load();
                }),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  Widget _groupsTab(Palette p) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: Row(children: [
          Expanded(
            child: Text('Groups appear at the top of the sidebar. Add items from their ⋯ menu.',
                style: TextStyle(color: p.ink2, fontSize: 13)),
          ),
          GhostButton(
            label: 'New group',
            icon: LucideIcons.plus,
            onPressed: () async {
              final name = await promptText(context, title: 'New group', action: 'Create');
              if (name == null) return;
              await state.repo.createGroup(widget.sourceId, widget.type, name);
              await _load();
            },
          ),
        ]),
      ),
      Expanded(
        child: groups.isEmpty
            ? const EmptyState(icon: LucideIcons.folderHeart, title: 'No groups yet')
            : ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: groups.length,
                onReorderItem: _reorderGroups,
                itemBuilder: (_, i) {
                  final g = groups[i];
                  final gid = g.id.substring(6);
                  return Container(
                    key: ValueKey(g.id),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 50,
                    child: Row(children: [
                      ReorderableDragStartListener(
                        index: i,
                        child: const Padding(
                            padding: EdgeInsets.all(8), child: Icon(LucideIcons.gripVertical, size: 20)),
                      ),
                      Expanded(child: Text(g.name, style: const TextStyle(fontSize: 15))),
                      IconBtn(LucideIcons.pencil, tooltip: 'Rename', onTap: () async {
                        final n = await promptText(context, title: 'Rename group', initial: g.name);
                        if (n == null) return;
                        await state.repo.renameGroup(gid, n);
                        await _load();
                      }),
                      IconBtn(LucideIcons.trash2, tooltip: 'Delete', onTap: () async {
                        if (!await confirm(context,
                            title: 'Delete "${g.name}"?',
                            message: 'The items stay in your playlist; only the group is removed.')) {
                          return;
                        }
                        await state.repo.deleteGroup(gid);
                        await _load();
                      }),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }
}
