import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/play_list.dart';
import 'package:flutter_application_1/widget/sound.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final playlistEx = Playlist(
    audios: [
      Audio(
        'assets/first.mp3',
        metas: Metas(
          title: 'First Song',
          artist: 'artist 1',
        ),
      ),
      Audio(
        'assets/second.mp3',
        metas: Metas(
          title: 'Second Song',
          artist: 'artist 2',
        ),
      ),
      Audio(
        'assets/third.mp3',
        metas: Metas(
          title: 'Third Song',
          artist: 'artist 3',
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Center(
          child: Text(
            'Music Player',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistPage(
                    playlist: playlistEx,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.playlist_add_check_circle_sharp),
          ),
        ],
      ),
      body: SoundPlayerWidget(
        playlist: playlistEx,
      ),
    );
  }
}

