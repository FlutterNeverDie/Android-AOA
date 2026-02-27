import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'share/theme/theme.dart';
import 'features/aoa/screen/s_mode_selection.dart';

import 'share/provider/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: AoaApp()));
}

class AoaApp extends ConsumerWidget {
  const AoaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AOA 티타임',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: ModeSelectionScreen.routeName,
      onGenerateRoute: (settings) {
        if (settings.name == ModeSelectionScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const ModeSelectionScreen(),
            settings: const RouteSettings(name: ModeSelectionScreen.routeName),
          );
        }
        return null;
      },
      home: const ModeSelectionScreen(),
    );
  }
}
