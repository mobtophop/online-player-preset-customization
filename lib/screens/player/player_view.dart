/*
 *  player_view.dart
 *
 *  Created by Ilya Chirkunov <xc@yar.net> on 14.11.2020.
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:single_radio/widgets/round_button.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:single_radio/config.dart';
import 'package:single_radio/theme.dart';
import 'package:single_radio/widgets/screen.dart';
import 'package:single_radio/screens/player/player_viewmodel.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  static const routeName = '/';

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  late final viewModel = Provider.of<PlayerViewModel>(context, listen: true);

  double get padding => MediaQuery.of(context).size.width * 0.08;

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: Config.title,
      home: true,
      hideOverscrollIndicator: true,
      child: Column(
        children: [
          const SizedBox(height: 16.0),
          Expanded(
            flex: 5,
            child: FittedBox(
              fit: BoxFit.contain,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _Cover(
                  size: MediaQuery.of(context).size.width - padding * 2,
                  image: viewModel.artwork != null
                      ? Image.memory(viewModel.artwork!)
                      : Image.asset(
                          'assets/images/cover.jpg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          _Title(
            flex: 1,
            artist: viewModel.artist,
            track: viewModel.trackName,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RoundButton(
                    icon: Icons.now_widgets_outlined,
                    iconSize: 32,
                    size: const Size.square(60),
                    onTap: () {},
                  ),
                  _ControlButton(
                    isPlaying: viewModel.isPlaying,
                    play: viewModel.play,
                    pause: viewModel.pause,
                    progress: viewModel.progress,
                  ),
                  RoundButton(
                    icon: Icons.skip_next,
                    iconSize: 32,
                    size: const Size.square(60),
                    onTap: viewModel.skipTrack,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Slider(
              value: viewModel.volume,
              min: 0,
              max: 100,
              divisions: 100,
              label: viewModel.volume.round().toString(),
              onChanged: viewModel.setVolume,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.accentColor,
                ),
                clipBehavior: Clip.hardEdge,
                width: MediaQuery.of(context).size.width / 3,
                height: 32.0,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({
    required this.image,
    required this.size,
  });

  final Image image;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.artworkShadowColor,
              offset: AppTheme.artworkShadowOffset,
              blurRadius: AppTheme.artworkShadowRadius,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: image,
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.artist,
    required this.track,
    required this.flex,
  });

  final String artist;
  final String track;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextScroll(
              artist,
              numberOfReps: Config.textScrolling ? null : 0,
              intervalSpaces: 7,
              velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
              delayBefore: const Duration(seconds: 1),
              pauseBetween: const Duration(seconds: 2),
              style: TextStyle(
                fontSize: 24,
                color: AppTheme.artistFontColor,
                fontWeight: FontWeight.lerp(
                  FontWeight.w700,
                  FontWeight.w800,
                  AppTheme.fontWeight,
                ),
              ),
            ),
            TextScroll(
              track,
              numberOfReps: Config.textScrolling ? null : 0,
              intervalSpaces: 10,
              velocity: const Velocity(pixelsPerSecond: Offset(40, 0)),
              delayBefore: const Duration(seconds: 1),
              pauseBetween: const Duration(seconds: 2),
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.trackFontColor,
                fontWeight: FontWeight.lerp(
                  FontWeight.w700,
                  FontWeight.w800,
                  AppTheme.fontWeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.isPlaying,
    required this.play,
    required this.pause,
    required this.progress,
  });

  final bool isPlaying;
  final VoidCallback play;
  final VoidCallback pause;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: SweepGradient(
          colors: const [
            AppTheme.accentColor,
            AppTheme.headerColor,
          ],
          stops: [progress, progress],
          transform: const GradientRotation((-90) * pi / 180),
        ),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: RoundButton(
              icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              iconSize: 42,
              size: const Size.square(90),
              onTap: isPlaying ? pause : play,
            ),
          ),
        ),
      ),
    );
  }
}
