import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/theme_mode.dart';
import '../../domain/models/export_document.dart';
import 'settings_cubit.dart';
import 'settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: Semantics(
          label: 'Back',
          button: true,
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.phase == SettingsLoadPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final committed = state.committedMode;
          if (committed == null) {
            return _SettingsFailure(
              message: state.failureMessage ?? 'Unable to load settings.',
              onRetry: context.read<SettingsCubit>().retry,
            );
          }
          final saving = state.isSaving;
          final exportButtonKey = GlobalKey();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: [
              Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Choose how Vulcan Fitness looks on this device.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Semantics(
                container: true,
                label: 'Appearance',
                child: Card(
                  child: Column(
                    children: [
                      RadioGroup<VulcanThemeMode>(
                        groupValue: committed,
                        onChanged: (mode) {
                          if (!saving && mode != null) {
                            context.read<SettingsCubit>().selectTheme(mode);
                          }
                        },
                        child: Column(
                          children: [
                            for (final mode in VulcanThemeMode.values)
                              _ThemeModeTile(
                                mode: mode,
                                selected: committed == mode,
                                enabled: !saving,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.phase == SettingsLoadPhase.failure) ...[
                const SizedBox(height: 16),
                Text(
                  state.failureMessage ?? 'Unable to save appearance.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: context.read<SettingsCubit>().retry,
                    child: const Text('Retry'),
                  ),
                ),
              ],
              if (saving) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(
                  semanticsLabel: 'Saving appearance',
                ),
              ],
              const SizedBox(height: 28),
              Text('Data', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Your data lives on this device only.'),
              const SizedBox(height: 8),
              const Text(
                'Exported JSON is plaintext training data shared by the app you choose.',
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  key: exportButtonKey,
                  onPressed:
                      state.isExporting ||
                          context.read<SettingsCubit>().exportData == null
                      ? null
                      : () => context.read<SettingsCubit>().export(
                          _shareOrigin(exportButtonKey.currentContext!),
                        ),
                  icon: state.isExporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share),
                  label: Text(
                    state.isExporting ? 'Exporting data' : 'Export data',
                  ),
                ),
              ),
              if (state.exportFailureMessage case final message?) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                TextButton(
                  onPressed: () => context.read<SettingsCubit>().retryExport(
                    _shareOrigin(exportButtonKey.currentContext!),
                  ),
                  child: const Text('Retry export'),
                ),
              ],
              if (state.exportOutcome case final outcome?) ...[
                const SizedBox(height: 8),
                Text(switch (outcome) {
                  ExportShareOutcome.shared => 'Share sheet opened. The receiving app determines whether it keeps the file.',
                  ExportShareOutcome.dismissed => 'Sharing cancelled.',
                  ExportShareOutcome.unavailable =>
                    'Sharing is unavailable on this device.',
                }),
              ],
            ],
          );
        },
      ),
    );
  }
}

ExportShareOrigin _shareOrigin(BuildContext context) {
  final render = context.findRenderObject();
  if (render is RenderBox && render.hasSize) {
    final topLeft = render.localToGlobal(Offset.zero);
    return ExportShareOrigin(
      x: topLeft.dx,
      y: topLeft.dy,
      width: render.size.width,
      height: render.size.height,
    );
  }
  return const ExportShareOrigin(x: 0, y: 0, width: 1, height: 1);
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.mode,
    required this.selected,
    required this.enabled,
  });

  final VulcanThemeMode mode;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final label = switch (mode) {
      VulcanThemeMode.dark => 'Dark',
      VulcanThemeMode.light => 'Light',
      VulcanThemeMode.system => 'System',
    };
    return ListTile(
      onTap: enabled
          ? () => RadioGroup.maybeOf<VulcanThemeMode>(context)?.onChanged(mode)
          : null,
      minTileHeight: 48,
      leading: Radio<VulcanThemeMode>(value: mode),
      title: Text(label),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      selected: selected,
      trailing: selected ? const Icon(Icons.check) : null,
    );
  }
}

class _SettingsFailure extends StatelessWidget {
  const _SettingsFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
