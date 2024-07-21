
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';



class SoundPlayerWidget extends StatefulWidget {
  final Playlist playlist;

  const SoundPlayerWidget({required this.playlist, super.key});

  @override
  State<SoundPlayerWidget> createState() => _SoundPlayerWidgetState();
}

class _SoundPlayerWidgetState extends State<SoundPlayerWidget> {
  final assetsAudioPlayer = AssetsAudioPlayer();

  int valueEx = 0;
  double volumeEx = 1.0;
  double playSpeedEx = 1.0;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  Future<void> initPlayer() async {
    await assetsAudioPlayer.open(
      widget.playlist,
      autoStart: false,
      loopMode: LoopMode.playlist,
    );
    assetsAudioPlayer.playSpeed.listen((event) {});
    assetsAudioPlayer.volume.listen((event) {
      setState(() {
        volumeEx = event;
      });
    });
    assetsAudioPlayer.currentPosition.listen((event) {
      setState(() {
        valueEx = event.inSeconds;
      });
    });
  }

  @override
  void dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  void changedVolume(Set<double> values) {
    setState(() {
      volumeEx = values.first.toDouble();
      assetsAudioPlayer.setVolume(volumeEx);
    });
  }

  void playSpeed(Set<double> values) {
    setState(() {
      playSpeedEx = values.first.toDouble();
      assetsAudioPlayer.setPlaySpeed(playSpeedEx);
    });
  }

  String convertSeconds(int seconds) {
    String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    String secondStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secondStr';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<RealtimePlayingInfos>(
          stream: assetsAudioPlayer.realtimePlayingInfos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final String currentTitle =
                snapshot.data?.current?.audio.audio.metas.title ??
                    'Please play your song';

            return Container(
              color: Colors.lightBlue.shade100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      height: 600,
                      width: 700,
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
                            Column(
                              children: [
                                const Text(
                                  'Volume',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SegmentedButton(
                                      onSelectionChanged: (values) {
                                        changedVolume(values);
                                      },
                                      segments: const [
                                        ButtonSegment(
                                          icon: Icon(Icons.volume_up),
                                          value: 1.0,
                                        ),
                                        ButtonSegment(
                                          icon: Icon(Icons.volume_down),
                                          value: 0.5,
                                        ),
                                        ButtonSegment(
                                          icon: Icon(Icons.volume_mute),
                                          value: 0.0,
                                        ),
                                      ],
                                      selected: {volumeEx},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                const Text(
                                  'Speed',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SegmentedButton(
                                      onSelectionChanged: (values) {
                                        playSpeed(values);
                                      },
                                      segments: const [
                                        ButtonSegment(
                                          icon: Text('1X'),
                                          value: 1.0,
                                        ),
                                        ButtonSegment(
                                          icon: Text('2X'),
                                          value: 2.0,
                                        ),
                                        ButtonSegment(
                                          icon: Text('3X'),
                                          value: 3.0,
                                        ),
                                        ButtonSegment(
                                          icon: Text('4X'),
                                          value: 4.0,
                                        ),
                                      ],
                                      selected: {playSpeedEx},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Slider(
                              value: valueEx.toDouble(),
                              min: 0,
                              max: snapshot.data?.duration.inSeconds
                                      .toDouble() ??
                                  0.0,
                              onChanged: (value) {
                                setState(() {
                                  valueEx = value.toInt();
                                  assetsAudioPlayer
                                      .seek(Duration(seconds: valueEx));
                                });
                              },
                            ),
                            const SizedBox(height: 25),
                            Text(
                              convertSeconds(valueEx),
                              style: const TextStyle(color: Colors.white),
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
}


// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter/material.dart';

// class SoundPlayerWidget extends StatefulWidget {
//   final Playlist playlist;

//   const SoundPlayerWidget({required this.playlist, super.key});

//   @override
//   State<SoundPlayerWidget> createState() => _SoundPlayerWidgetState();
// }

// class _SoundPlayerWidgetState extends State<SoundPlayerWidget> {
//   final assetsAudioPlayer = AssetsAudioPlayer();

//   int valueEx = 0;
//   double volumeEx = 1.0;
//   double playSpeedEx = 1.0;

//   @override
//   void initState() {
//     super.initState();
//     initPlayer();
//   }

//   Future<void> initPlayer() async {
//     await assetsAudioPlayer.open(
//       widget.playlist,
//       autoStart: false,
//       loopMode: LoopMode.playlist,
//     );
//     assetsAudioPlayer.playSpeed.listen((event) {});
//     assetsAudioPlayer.volume.listen((event) {
//       setState(() {
//         volumeEx = event;
//       });
//     });
//     assetsAudioPlayer.currentPosition.listen((event) {
//       setState(() {
//         valueEx = event.inSeconds;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     assetsAudioPlayer.dispose();
//     super.dispose();
//   }

//   void changedVolume(Set<double> values) {
//     setState(() {
//       volumeEx = values.first.toDouble();
//       assetsAudioPlayer.setVolume(volumeEx);
//     });
//   }

//   void playSpeed(Set<double> values) {
//     setState(() {
//       playSpeedEx = values.first.toDouble();
//       assetsAudioPlayer.setPlaySpeed(playSpeedEx);
//     });
//   }

//   String convertSeconds(int seconds) {
//     String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
//     String secondStr = (seconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$secondStr';
//   }

//   Widget getBtnWidget() {
//     return assetsAudioPlayer.builderIsPlaying(
//       builder: (context, isPlaying) {
//         return FloatingActionButton(
//           onPressed: () {
//             if (isPlaying) {
//               assetsAudioPlayer.pause();
//             } else {
//               assetsAudioPlayer.play();
//             }
//           },
//           shape: const CircleBorder(),
//           child: Icon(
//             isPlaying ? Icons.pause : Icons.play_arrow,
//             color: Colors.white,
//             size: 50,
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: StreamBuilder<RealtimePlayingInfos>(
//           stream: assetsAudioPlayer.realtimePlayingInfos,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             }

//             final String currentTitle =
//                 snapshot.data?.current?.audio.audio.metas.title ??
//                     'Please play your song';

//             return Container(
//               color: Colors.lightBlue.shade100,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: Container(
//                       height: 600,
//                       width: 700,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: Colors.blue,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               currentTitle,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 25),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 IconButton(
//                                   onPressed: snapshot.data?.current?.index == 0
//                                       ? null
//                                       : () {
//                                           assetsAudioPlayer.previous();
//                                         },
//                                   icon: const Icon(Icons.skip_previous),
//                                 ),
//                                 getBtnWidget(),
//                                 IconButton(
//                                   onPressed: snapshot.data?.current?.index ==
//                                           (assetsAudioPlayer.playlist?.audios
//                                                       .length ??
//                                                   0) -
//                                               1
//                                       ? null
//                                       : () {
//                                           assetsAudioPlayer.next(
//                                               keepLoopMode: false);
//                                         },
//                                   icon: const Icon(Icons.skip_next),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 25),
//                             Column(
//                               children: [
//                                 const Text(
//                                   'Volume',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     SegmentedButton<double>(
//                                       onSelectionChanged: changedVolume,
//                                       segments: const [
//                                         ButtonSegment(
//                                           icon: Icon(Icons.volume_up),
//                                           value: 1.0,
//                                         ),
//                                         ButtonSegment(
//                                           icon: Icon(Icons.volume_down),
//                                           value: 0.5,
//                                         ),
//                                         ButtonSegment(
//                                           icon: Icon(Icons.volume_mute),
//                                           value: 0.0,
//                                         ),
//                                       ],
//                                       selected: {volumeEx},
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 25),
//                                 const Text(
//                                   'Speed',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     SegmentedButton<double>(
//                                       onSelectionChanged: playSpeed,
//                                       segments: const [
//                                         ButtonSegment(
//                                           icon: Text('1X'),
//                                           value: 1.0,
//                                         ),
//                                         ButtonSegment(
//                                           icon: Text('2X'),
//                                           value: 2.0,
//                                         ),
//                                         ButtonSegment(
//                                           icon: Text('3X'),
//                                           value: 3.0,
//                                         ),
//                                         ButtonSegment(
//                                           icon: Text('4X'),
//                                           value: 4.0,
//                                         ),
//                                       ],
//                                       selected: {playSpeedEx},
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 25),
//                             Slider(
//                               value: valueEx.toDouble(),
//                               min: 0,
//                               max: snapshot.data?.duration.inSeconds
//                                       .toDouble() ??
//                                   0.0,
//                               onChanged: (value) {
//                                 setState(() {
//                                   valueEx = value.toInt();
//                                   assetsAudioPlayer
//                                       .seek(Duration(seconds: valueEx));
//                                 });
//                               },
//                             ),
//                             const SizedBox(height: 25),
//                             Text(
//                               convertSeconds(valueEx),
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

