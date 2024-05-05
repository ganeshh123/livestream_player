import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:livestream_player/live_stream.dart';
import 'package:livestream_player/live_stream_storage.dart';
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<LiveStream> _streams = [];
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _loadStreams();
  }

  void _loadStreams() async {
    await LiveStreamStorage.init();
    var streams = await LiveStreamStorage.getLiveStreams();
    setState(() {
      _streams = streams;
    });
  }

  void _openStream(String url) async {
    setState(() {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    });
    await _controller!.initialize();

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _controller!,
        isLive: true,
        autoPlay: true,
        showOptions: false,
        allowPlaybackSpeedChanging: false,
      );
    });
  }

  void _addNewStream(String name, String url) async {
    final livestream = LiveStream(name: name, url: url);
    await LiveStreamStorage.addLiveStream(livestream);
    _loadStreams();
  }

  void _deleteStream(LiveStream stream) async {
    await LiveStreamStorage.deleteLivestream(stream);
    _loadStreams(); // Refresh the list after deleting
  }

  void _showAddStreamDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String url = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Livestream'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    name = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    url = value!;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  _addNewStream(name, url);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(LiveStream stream) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this livestream?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog without doing anything
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Proceed with deletion
                _deleteStream(stream);
                Navigator.of(context)
                    .pop(); // Dismiss the dialog after the action
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool videoReady = _controller != null && _chewieController != null;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text("Livestream Player",
              style: TextStyle(color: Colors.white)),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _streams
                        .map((stream) => InkWell(
                              onTap: () => _openStream(stream.url),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        stream.name,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () =>
                                            _showDeleteConfirmation(stream),
                                        icon: const Icon(Icons.clear_rounded))
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Material(
                        color: Colors.black,
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: videoReady
                              ? Chewie(
                                  controller: _chewieController!,
                                )
                              : Container(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (videoReady) ...[
                          // Stop Button
                          IconButton(
                            onPressed: () {},
                            iconSize: 48,
                            icon: const Icon(Icons.stop_rounded),
                          ),
                        ],
                        IconButton(
                          onPressed: _showAddStreamDialog,
                          iconSize: 48,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
