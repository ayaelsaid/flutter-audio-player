import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class SongWidget extends StatefulWidget {
  final Audio audio;
  const SongWidget({required this.audio, super.key});

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    assetsAudioPlayer.open(
      widget.audio,
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
    return ListTile(
      trailing: StreamBuilder<RealtimePlayingInfos>(
        stream: assetsAudioPlayer.realtimePlayingInfos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.data == null) {
            return const SizedBox.shrink();
          }
          return Text(convertSeconds(snapshot.data!.duration.inSeconds));
        },
      ),
      leading: CircleAvatar(
        child: Center(
          child: Text(
            '${widget.audio.metas.artist?.split(' ').first[0].toUpperCase() ?? ''}${widget.audio.metas.artist?.split(' ').last[0].toUpperCase() ?? ''}',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      title: Text(widget.audio.metas.title ?? 'No title'),
      subtitle: Text(widget.audio.metas.artist ?? 'No artist'),
      onTap: () async {
        if (!assetsAudioPlayer.isPlaying.value) {
          await assetsAudioPlayer.open(
            widget.audio,
            autoStart: true,
          );
        } else {
          await assetsAudioPlayer.stop();
          await assetsAudioPlayer.open(
            widget.audio,
            autoStart: true,
          );
        }
      },
    );
  }

  String convertSeconds(int seconds) {
    String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    String secondStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secondStr';
  }
}
