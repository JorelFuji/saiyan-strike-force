import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan/features/settings/cubit/settings_cubit.dart';
import 'package:vulcan/features/settings/cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return switch (state) {
            SettingsInitial() || SettingsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            SettingsLoaded(:final isDarkMode) => ListView(
                children: [
                  SwitchListTile(
                    title: const Text('Dark mode'),
                    subtitle: const Text('Persist theme preference locally'),
                    value: isDarkMode,
                    onChanged: (value) =>
                        context.read<SettingsCubit>().setDarkMode(value),
                  ),
                ],
              ),
            SettingsError(:final failure) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        failure.message ?? 'Something went wrong',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.read<SettingsCubit>().load(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
          };
        },
      ),
    );
  }
}
