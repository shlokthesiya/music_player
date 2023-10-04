import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  print("hello");
  runApp(MaterialApp(
    home: first(),
  ));

}

class first extends StatefulWidget {
  const first({Key? key}) : super(key: key);

  @override
  State<first> createState() => _firstState();
}

class _firstState extends State<first> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final player = AudioPlayer();

  @override
  void initState() {
    permission();
  }

  permission() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      print(sdkInt);

      if (sdkInt >= 30) {
        var status = await Permission.storage.status;
        var status1 = await Permission.audio.status;
        if (status.isDenied || status1.isDenied) {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.audio,
            Permission.storage,
          ].request();
        }
      } else {
        var status = await Permission.storage.status;
        if (status.isDenied) {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.storage,
          ].request();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _audioQuery.querySongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            List<SongModel> l = snapshot.data as List<SongModel>;
            print(l);
            return ListView.builder(
              itemCount: l.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      if(player.state==PlayerState.playing)
                        {
                           player.pause();
                        }
                      else
                        {
                            player.play(DeviceFileSource("${l[index].data}"));
                        }
                    },
                    title: Text("${l[index].displayName}"),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
