/*
 *  main.dart
 *
 *  Created by Ilya Chirkunov <xc@yar.net> on 14.11.2020.
 */

import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:single_radio/theme.dart';
import 'package:single_radio/config.dart';
import 'package:single_radio/services/admob_service.dart';
import 'package:single_radio/services/fcm_service.dart';
import 'package:single_radio/screens/player/player_view.dart';
import 'package:single_radio/screens/player/player_viewmodel.dart';
import 'package:single_radio/screens/timer/timer_view.dart';
import 'package:single_radio/screens/timer/timer_viewmodel.dart';
import 'package:single_radio/screens/about/about_view.dart';

//TODO: remove from global
late AudioHandler aHandler;
final StreamController<String> audioHandlerEventController = StreamController();
final StreamController<AudioPlayerEvent> audioEventController =
    StreamController();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  aHandler = await initAudioService();

  // Set device orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Init services.
  await AdmobService.init();
  await FcmService.init();

  // Init view models.
  late final playerViewModel = PlayerViewModel();
  late final timerViewModel = TimerViewModel(onTimer: playerViewModel.pause);

  // Init providers.
  final providers = [
    ChangeNotifierProvider<PlayerViewModel>.value(value: playerViewModel),
    ChangeNotifierProvider<TimerViewModel>.value(value: timerViewModel),
  ];

  // Init routes.
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PlayerView.routeName:
        return MaterialPageRoute(
          builder: (context) => const PlayerView(),
        );
      case AboutView.routeName:
        return MaterialPageRoute(
          builder: (context) => const AboutView(),
        );
      case TimerView.routeName:
        return MaterialPageRoute(
          builder: (context) => const TimerView(),
          allowSnapshotting: false,
        );
      default:
        return null;
    }
  }

  runApp(App(
    providers: providers,
    onGenerateRoute: onGenerateRoute,
  ));
}

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class AudioPlayerEvent {
  AudioPlayerEvent({
    required this.playerState,
    required this.title,
    required this.artist,
    required this.artUri,
  });

  final PlayerState playerState;
  final String title;
  final String artist;
  final String artUri;
}

class MyAudioHandler extends BaseAudioHandler {
  MyAudioHandler() {
    audioEventController.stream.listen(
      (event) {
        mediaItem.value = MediaItem(
          id: "",
          title: event.title,
          artist: event.artist,
          artUri: Uri.parse(event.artUri),
        );

        final playing = event.playerState == PlayerState.playing;
        playbackState.add(
          playbackState.value.copyWith(
            controls: [
              if (playing) MediaControl.pause else MediaControl.play,
              MediaControl.skipToNext,
            ],
            androidCompactActionIndices: const [0, 1],
            processingState: const {
                  PlayerState.paused: AudioProcessingState.ready,
                  PlayerState.completed: AudioProcessingState.completed,
                }[event.playerState] ??
                AudioProcessingState.ready,
            playing: playing,
          ),
        );
      },
    );
  }

  @override
  Future<void> play() {
    audioHandlerEventController.add("play");
    return super.play();
  }

  @override
  Future<void> pause() {
    audioHandlerEventController.add("pause");
    return super.pause();
  }

  @override
  Future<void> skipToNext() {
    audioHandlerEventController.add("skip");
    return super.skipToNext();
  }
}

class App extends StatelessWidget {
  const App({
    super.key,
    required this.providers,
    required this.onGenerateRoute,
  });

  final List<SingleChildStatelessWidget> providers;
  final Route<dynamic>? Function(RouteSettings) onGenerateRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: Config.title,
        theme: AppTheme.themeData,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
