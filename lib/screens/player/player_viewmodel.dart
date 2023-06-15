/*
 *  player_viewmodel.dart
 *
 *  Created by Ilya Chirkunov <xc@yar.net> on 14.11.2020.
 */

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:volume_regulator/volume_regulator.dart';
import 'package:single_radio/config.dart';
import 'package:single_radio/language.dart';
import 'package:single_radio/services/metadata_service.dart';
//import 'package:single_radio/services/smartstop_service.dart';

class PlayerViewModel with ChangeNotifier {
  final _audioPlayer = AudioPlayer();
  double volume = 0;
  TrackDetails? trackDetails;
  TrackDetails? nextTrackDetails;
  final MetadataService _metadataService = MetadataService();
  Image? artwork;

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  String get trackName => trackDetails != null && trackDetails!.name.isNotEmpty
      ? trackDetails!.name
      : _greeting;

  String get artist => trackDetails != null && trackDetails!.artist.isNotEmpty
      ? trackDetails!.artist
      : Config.title;

  PlayerViewModel() {
    _metadataService.getTrack().then(
      (newTrack) {
        trackDetails = newTrack;
        _audioPlayer.setSource(UrlSource(trackDetails!.url));
        getNextTrack();
      },
    );

    VolumeRegulator.getVolume().then((value) {
      volume = value.toDouble();
      notifyListeners();
    });

    VolumeRegulator.volumeStream.listen((value) {
      volume = value.toDouble();
      notifyListeners();
    });
  }

  void play() async {
    if (trackDetails != null) await _audioPlayer.resume();
    notifyListeners();
  }

  void pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  void getNextTrack() {
    _metadataService.getTrack().then(
      (newTrack) {
        nextTrackDetails = newTrack;
      },
    );
  }

  void skipTrack() async {
    trackDetails = nextTrackDetails;
    await _audioPlayer.setSource(UrlSource(trackDetails!.url));
    play();
    getNextTrack();
  }

  void setVolume(double value) {
    VolumeRegulator.setVolume(value.toInt());
    notifyListeners();
  }

  String get _greeting {
    int hour = DateTime.now().hour;

    if (hour < 12) {
      return Language.goodMorning;
    } else if (hour < 17) {
      return Language.goodAfternoon;
    } else {
      return Language.goodEvening;
    }
  }
}
