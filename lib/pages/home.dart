import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  Future<void> initPlayer() async {
    await assetsAudioPlayer.open(
      Playlist(
        audios: [
          Audio(
            'assets/first.mp3',
            metas: Metas(
              title: 'First Song',
            ),
          ),
          Audio(
            'assets/second.mp3',
            metas: Metas(
              title: 'Second Song',
            ),
          ),
          Audio(
            'assets/third.mp3',
            metas: Metas(
              title: 'third Song',
            ),
          ),
        ],
      ),
      autoStart: false,
    );
  }

  @override
  void dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Center(
        child: StreamBuilder<RealtimePlayingInfos>(
          stream: assetsAudioPlayer.realtimePlayingInfos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final String currentTitle =
                snapshot.data!.current?.audio.audio.metas.title ??
                    'Please play your song';

            return Container(
              color: Colors.lightBlue.shade100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 50),
                    child: Container(
                      height: 300,
                      width: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: snapshot.data?.current?.index == 0
                                      ? null
                                      : () {
                                          assetsAudioPlayer.previous();
                                        },
                                  icon: const Icon(Icons.skip_previous),
                                ),
                                getBtnWidget(),
                                IconButton(
                                  onPressed: snapshot.data?.current?.index ==
                                          (assetsAudioPlayer.playlist?.audios
                                                      .length ??
                                                  0) -
                                              1
                                      ? null
                                      : () {
                                          assetsAudioPlayer.next(
                                              keepLoopMode: false);
                                        },
                                  icon: const Icon(Icons.skip_next),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Slider(
                              value: snapshot.data?.currentPosition.inSeconds
                                      .toDouble() ??
                                  0.0,
                              min: 0,
                              max: snapshot.data?.duration.inSeconds
                                      .toDouble() ??
                                  0.0,
                              onChanged: (double value) async {
                                await assetsAudioPlayer
                                    .seekBy(const Duration(seconds: 2));
                              },
                            ),
                            const SizedBox(height: 25),
                            Text(
                              '${convertSeconds(snapshot.data!.currentPosition.inSeconds)} / ${convertSeconds(snapshot.data!.duration.inSeconds)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String convertSeconds(int seconds) {
    String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    String secondStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes : $secondStr';
  }

  Widget getBtnWidget() {
    return assetsAudioPlayer.builderIsPlaying(
      builder: (context, isPlaying) {
        return FloatingActionButton(
          onPressed: () {
            if (isPlaying) {
              assetsAudioPlayer.pause();
            } else {
              assetsAudioPlayer.play();
            }
          },
          shape: const CircleBorder(),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 50,
          ),
        );
      },
    );
  }
}
