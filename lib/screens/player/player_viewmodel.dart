/*
 *  player_viewmodel.dart
 *
 *  Created by Ilya Chirkunov <xc@yar.net> on 14.11.2020.
 */

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:volume_regulator/volume_regulator.dart';
import 'package:single_radio/config.dart';
import 'package:single_radio/language.dart';
import 'package:single_radio/services/metadata_service.dart';

class PlayerViewModel with ChangeNotifier {
  final _audioPlayer = AudioPlayer();
  double volume = 0;
  TrackDetails? trackDetails;
  TrackDetails? nextTrackDetails;
  Uint8List? artwork;
  Uint8List? nextTrackArtwork;
  final MetadataService _metadataService = MetadataService();
  double progress = 0.0;

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  String get trackName => trackDetails != null && trackDetails!.name.isNotEmpty
      ? trackDetails!.name
      : _greeting;

  String get artist => trackDetails != null && trackDetails!.artist.isNotEmpty
      ? trackDetails!.artist
      : Config.title;

  Future<double?> getProgress() async {
    Duration? duration = await _audioPlayer.getDuration();
    if (duration != null) {
      Duration? position = await _audioPlayer.getCurrentPosition();
      if (position != null) {
        return position.inMicroseconds / duration.inMicroseconds;
      }
    }

    return null;
  }

  PlayerViewModel() {
    _metadataService.getTrack().then(
      (newTrack) {
        trackDetails = newTrack;
        get(Uri.parse(trackDetails!.artUrl)).then((response) {
          artwork = response.bodyBytes;
        });
        _audioPlayer.setSource(UrlSource(trackDetails!.url));
        getNextTrack();
      },
    );

    _audioPlayer.onPositionChanged.listen((_) async {
      progress = await getProgress() ?? 0.0;
      notifyListeners();
    });

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
        get(Uri.parse(nextTrackDetails!.artUrl)).then((response) {
          nextTrackArtwork = response.bodyBytes;
        });
      },
    );
  }

  bool isBlocked = false;

  void skipTrack() async {
    if (isBlocked) return;
    isBlocked = true;
    if (_audioPlayer.state == PlayerState.playing) await _audioPlayer.stop();
    progress = 0.0;
    trackDetails = nextTrackDetails;
    artwork = nextTrackArtwork;
    notifyListeners();
    _audioPlayer.setSource(UrlSource(trackDetails!.url)).then(
      (_) {
        play();
        getNextTrack();
        isBlocked = false;
      },
    );
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
