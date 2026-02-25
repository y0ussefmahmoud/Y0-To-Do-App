import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';

class ProviderScopeOverrides extends ConsumerWidget {
  final Widget child;

  const ProviderScopeOverrides({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        settingsBoxProvider.overrideWithValue(
          Hive.box<AppSettings>('settingsBox'),
        ),
      ],
      child: child,
    );
  }
}
