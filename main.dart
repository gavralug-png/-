import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/name_screen.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final prefs = await SharedPreferences.getInstance();
  runApp(PravoslavnyPutApp(storage: StorageService(prefs)));
}

class PravoslavnyPutApp extends StatefulWidget {
  const PravoslavnyPutApp({super.key, required this.storage});

  final StorageService storage;

  @override
  State<PravoslavnyPutApp> createState() => _PravoslavnyPutAppState();
}

class _PravoslavnyPutAppState extends State<PravoslavnyPutApp>
    with WidgetsBindingObserver {
  late final AudioService _audio = AudioService();
  late final SettingsProvider _settings =
      SettingsProvider(widget.storage, _audio);
  late final GameProvider _game = GameProvider(widget.storage);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settings.initAudio();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settings.dispose();
    _game.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audio.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      _audio.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: _settings),
        ChangeNotifierProvider<GameProvider>.value(value: _game),
        Provider<AudioService>.value(value: _audio),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Православный путь',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.darkTheme ? ThemeMode.dark : ThemeMode.light,
          locale: const Locale('ru'),
          supportedLocales: const [Locale('ru')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Consumer<GameProvider>(
            builder: (context, game, _) =>
                game.hasName ? const HomeScreen() : const NameScreen(),
          ),
        ),
      ),
    );
  }
}
