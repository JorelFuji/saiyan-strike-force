import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan/features/settings/cubit/settings_cubit.dart';
import 'package:vulcan/features/settings/cubit/settings_state.dart';
import 'package:vulcan/features/settings/view/settings_page.dart';
import 'package:vulcan/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>()..load(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final isDarkMode = switch (state) {
            SettingsLoaded(:final isDarkMode) => isDarkMode,
            _ => false,
          };

          return MaterialApp(
            title: 'Vulcan',
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepOrange,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: const SettingsPage(),
          );
        },
      ),
    );
  }
}
