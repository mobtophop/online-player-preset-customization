/*
 *  metadata_service.dart
 *
 *  Created by Ilya Chirkunov <xc@yar.net> on 03.02.2022.
 */

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:single_radio/config.dart';

class TrackDetails {
  TrackDetails({
    this.name = "",
    this.artist = "",
    this.url = "",
    this.artUrl = "",
  });

  String name;
  String artist;
  String url;
  String artUrl;
}

class MetadataService {
  MetadataService();

  TrackDetails? _previousMetadata;

  TrackDetails? get previousMetadata => _previousMetadata != null
      ? TrackDetails(
          name: _previousMetadata!.name,
          artist: _previousMetadata!.artist,
          url: _previousMetadata!.url,
          artUrl: _previousMetadata!.artUrl,
        )
      : null;

  Future<TrackDetails?> getTrack() async {
    final response = await get(Uri.parse(Config.metadataUrl));
    final content = utf8.decode(response.bodyBytes);

    // Parse Json.
    try {
      TrackDetails details = TrackDetails();

      var map = json.decode(content) as Map<String, dynamic>;

      List<String> name = (map[Config.nameTag] ?? Config.titleSeparator)
          .split(Config.titleSeparator);
      details.artist = name[0];
      details.name = name[1];
      details.url = map[Config.urlTag] ?? "";
      details.artUrl = map[Config.coverTag] ?? "";

      details.artUrl = details.artUrl
          .replaceAll("//", "/")
          .replaceFirst("/", "//")
          .replaceFirst("/FFF/", "/FFF.png/");

      return details;
    } catch (_) {
      return null;
    }
  }
}
