import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:livestream_player/live_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveStreamStorage {
  static SharedPreferences? _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<List<LiveStream>> getLiveStreams() async {
    List<String> streamList = _prefs?.getStringList('livestreams') ?? [];
    return streamList.map((e) => LiveStream.fromJson(json.decode(e))).toList();
  }

  static Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  static Future<void> addLiveStream(LiveStream liveStream) async {
    final streams = await getLiveStreams();
    streams.add(liveStream);
    await _prefs?.setStringList(
        'livestreams', streams.map((e) => json.encode(e.toJson())).toList());
  }

  static Future<void> deleteLivestream(LiveStream livestream) async {
    final streams = await getLiveStreams();
    streams.removeWhere((element) =>
        element.url == livestream.url && element.name == livestream.name);
    await _prefs?.setStringList(
        'livestreams', streams.map((e) => json.encode(e.toJson())).toList());
  }

  static Future<String?> exportLivestreamsToFile() async {
    // Request storage permissions
    await requestStoragePermission();
    // Check if permission is granted
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      return null;
    }

    // Fetching the livestream data
    List<LiveStream> streams = await getLiveStreams();
    String jsonText =
        json.encode(streams.map((stream) => stream.toJson()).toList());

    // Let the user pick the save location through file picker
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      // User canceled the picker
      return null;
    }

    File file = File('$selectedDirectory/livestreams.json');
    await file.writeAsString(jsonText);
    return file.path;
  }

  static Future<String?> importLivestreams() async {
    // Request storage permissions
    await requestStoragePermission();
    // Check if permission is granted
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      return null;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null) {
      return null;
    }

    File file = File(result.files.single.path!);
    String jsonText = await file.readAsString();
    List<dynamic> jsonData = json.decode(jsonText);
    List<LiveStream> streams =
        jsonData.map((item) => LiveStream.fromJson(item)).toList();
    await _prefs?.setStringList('livestreams',
        streams.map((stream) => json.encode(stream.toJson())).toList());

    return file.path;
  }
}
