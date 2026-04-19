import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rewardpoints/app/bootstrap/app_router.dart';
import 'package:rewardpoints/app/di/service_locator.dart';
import 'package:rewardpoints/presentation/pages/export_import_page.dart';
import 'package:rewardpoints/presentation/pages/main_page.dart';
import 'package:rewardpoints/presentation/viewmodels/theme_viewmodel.dart';
import 'package:rewardpoints/shared/l10n/app_strings.dart';
import 'package:rewardpoints/shared/logging/app_logger.dart';
import 'package:rewardpoints/shared/theme/app_theme.dart';

/// Root widget. Listens to [ThemeViewModel] for live theme switching
/// and to the OS VIEW intent stream so opening a `.json` file from
/// another app pushes the Export/Import page with the payload.
class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> with WidgetsBindingObserver {
  late final AppLogger _logger;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<List<SharedMediaFile>>? _intentSub;

  @override
  void initState() {
    super.initState();
    _logger = sl<AppLogger>();
    WidgetsBinding.instance.addObserver(this);
    _logger.info('[App] AppWidget initialised');
    _wireIncomingJson();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.debug('[App] Lifecycle → ${state.name}');
  }

  void _wireIncomingJson() {
    // While the app is running, new VIEW intents arrive here.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      _handleIncoming,
      onError: (Object e) => _logger.warning('[App] Intent stream error: $e'),
    );
    // If the app was cold-started by a VIEW intent, process it once.
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      _handleIncoming(files);
      ReceiveSharingIntent.instance.reset();
    });
  }

  Future<void> _handleIncoming(List<SharedMediaFile> files) async {
    if (files.isEmpty) return;
    final first = files.first;
    try {
      final content = await File(first.path).readAsString();
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => ExportImportPage(initialImportJson: content),
        ),
      );
    } catch (e, st) {
      _logger.warning('[App] Failed to read shared JSON: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = sl<ThemeViewModel>();
    return ListenableBuilder(
      listenable: themeViewModel,
      builder: (context, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeViewModel.themeMode,
          navigatorKey: _navigatorKey,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const MainPage(),
        );
      },
    );
  }
}
