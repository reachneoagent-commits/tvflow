import '../../../core/platform.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/services/secrets.dart';
import '../../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../detail_common.dart';

/// Standalone page (from Home) wrapping [SyncSettingsPane].
class SyncSettingsPage extends StatelessWidget {
  const SyncSettingsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            const BackBar(title: 'Sync'),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720), child: const SyncSettingsPane()),
              ),
            ),
          ]),
        ),
      );
}

/// Folder-based sync between devices.
class SyncSettingsPane extends StatefulWidget {
  const SyncSettingsPane({super.key});
  @override
  State<SyncSettingsPane> createState() => _SyncSettingsPaneState();
}

class _SyncSettingsPaneState extends State<SyncSettingsPane> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = context.pal;
    final d = state.device;
    final hasPass = state.secrets.get(SecretsStore.syncPassphrase) != null;
    return ValueListenableBuilder(
      valueListenable: state.sync,
      builder: (context, s, _) {
        final last = d.lastSync == null ? null : DateTime.fromMillisecondsSinceEpoch(d.lastSync!);
        return ListView(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Each device writes its own snapshot into a folder you choose. Put that folder in '
              'Synology Drive, iCloud Drive, Dropbox or any shared/network folder and select the same '
              'folder on your other Macs. Changes made offline merge on the next sync; when the same '
              'thing was changed on two devices, the most recent change wins.',
              style: TextStyle(color: p.ink2, height: 1.45, fontSize: 13.5),
            ),
          ),
          PaneSection('Status', children: [
            SettingsRow(
              icon: s.error != null ? LucideIcons.circleAlert : LucideIcons.cloudCheck,
              title: s.running
                  ? 'Syncing…'
                  : !d.syncEnabled
                      ? 'Sync is off'
                      : last == null
                          ? 'Not synced yet'
                          : 'Last synced ${fmtDateTime(last)}',
              subtitle: s.error ??
                  (s.lastReport == null
                      ? null
                      : 'Received ${s.lastReport!.applied} change(s) · ${s.lastReport!.peers.length} other device(s)'),
              danger: s.error != null,
              trailing: GhostButton(
                label: 'Sync now',
                icon: LucideIcons.refreshCw,
                onPressed: s.running || d.syncFolder == null ? null : state.syncNow,
              ),
            ),
            if (s.lastReport != null)
              for (final peer in s.lastReport!.peers)
                SettingsRow(
                  icon: LucideIcons.laptop,
                  title: peer.deviceName,
                  subtitle: peer.error ??
                      (peer.written == null ? null : 'Last wrote ${fmtDateTime(peer.written!.toLocal())}'),
                  danger: peer.error != null,
                ),
          ]),
          PaneSection('Settings', children: [
            SettingsSwitch(
              icon: LucideIcons.refreshCw,
              title: 'Sync automatically',
              subtitle: d.syncFolder == null ? 'Choose a folder first' : 'Every ${d.syncIntervalMin} min and shortly after each change',
              value: d.syncEnabled,
              onChanged: (v) async {
                if (v && d.syncFolder == null) {
                  toast(context, 'Choose a sync folder first.', error: true);
                  return;
                }
                await state.configureSync(enabled: v);
                if (v) await state.syncNow();
              },
            ),
            SettingsRow(
              icon: LucideIcons.folder,
              title: 'Sync folder',
              subtitle: d.syncFolder ?? 'Not set',
              onTap: () async {
                final dir = await FilePicker.getDirectoryPath(dialogTitle: 'Choose the sync folder');
                if (dir == null) return;
                await state.configureSync(folder: dir);
                setState(() {});
                if (d.syncEnabled) await state.syncNow();
              },
            ),
            SettingsRow(
              icon: LucideIcons.timer,
              title: 'Sync interval',
              subtitle: '${d.syncIntervalMin} minutes',
              onTap: () async {
                final v = await pickOption<int>(context,
                    title: 'Sync interval',
                    current: d.syncIntervalMin,
                    options: [for (final m in [1, 5, 15, 30, 60]) (m, '$m minutes')]);
                if (v != null) await state.configureSync(intervalMin: v);
              },
            ),
            SettingsRow(
              icon: LucideIcons.badge,
              title: 'This device',
              subtitle: '${d.deviceName} · ${d.deviceId}',
              onTap: () async {
                final n = await promptText(context, title: 'Device name', initial: d.deviceName);
                if (n != null) await state.configureSync(deviceName: n);
              },
            ),
          ]),
          PaneSection('Encryption', children: [
            SettingsRow(
              icon: hasPass ? LucideIcons.lock : LucideIcons.lockOpen,
              title: hasPass ? 'Encrypted with a passphrase' : 'Not encrypted',
              subtitle: hasPass
                  ? 'AES-256-GCM. Use the same passphrase on every device.'
                  : 'Without a passphrase, usernames, passwords, MAC addresses and links that contain a login '
                      'stay on this ' + deviceName + '. Set the same passphrase on every device to sync them too.',
              onTap: () async {
                final v = await promptText(context,
                    title: hasPass ? 'Change passphrase' : 'Set passphrase', label: 'Passphrase', action: 'Save');
                if (v == null) return;
                await state.configureSync(passphrase: v);
                setState(() {});
                if (d.syncEnabled) await state.syncNow();
              },
            ),
            if (hasPass)
              SettingsRow(
                icon: LucideIcons.lockOpen,
                title: 'Remove passphrase',
                danger: true,
                onTap: () async {
                  if (!await confirm(context,
                      title: 'Remove passphrase?',
                      message: 'Snapshots will be written unencrypted and without passwords.',
                      action: 'Remove')) {
                    return;
                  }
                  await state.configureSync(clearPassphrase: true);
                  setState(() {});
                },
              ),
          ]),
          const SizedBox(height: 40),
        ]);
      },
    );
  }
}
