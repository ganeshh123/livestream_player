import 'dart:convert';
import 'package:livestream_player/live_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveStreamStorage {
  static SharedPreferences? _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<List<LiveStream>> getLiveStreams() async {
    List<String> streamList = _prefs?.getStringList('liveStreams') ?? [];
    return streamList.map((e) => LiveStream.fromJson(json.decode(e))).toList();
  }

  static Future<void> addLiveStream(LiveStream liveStream) async {
    final streams = await getLiveStreams();
    streams.add(liveStream);
    await _prefs?.setStringList(
        'liveStreams', streams.map((e) => json.encode(e.toJson())).toList());
  }

  static Future<void> deleteLivestream(LiveStream livestream) async {
    final streams = await getLiveStreams();
    streams.removeWhere((element) =>
        element.url == livestream.url && element.name == livestream.name);
    await _prefs?.setStringList(
        'liveStreams', streams.map((e) => json.encode(e.toJson())).toList());
  }
}
