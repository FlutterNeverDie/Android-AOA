import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/theme.dart';
import 'screens/s_mode_selection.dart';

void main() {
  runApp(const ProviderScope(child: AoaApp()));
}

class AoaApp extends StatelessWidget {
  const AoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AOA 티타임',
      theme: AppTheme.lightTheme,
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
