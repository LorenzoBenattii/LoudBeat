import 'package:flutter/material.dart';
import 'package:loud_beat/services/youtube.dart';
import 'dart:async';

class DownloadWidget extends StatefulWidget {
  
  
  @override
  State<DownloadWidget> createState() => _DownloadWidgetState();
} 


class _DownloadWidgetState extends State<DownloadWidget> {
  
  StreamSubscription? progressSubscription;

  @override
  void initState() {
    
    super.initState();
    
    yt.onDownloadsChanged = () {
      if (mounted) {
        setState(() {
          
        });
      }
    };  
  }

  @override
  void dispose() {
    progressSubscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
          const Text("Downloads:"),
          const SizedBox(height: 16,),

          Expanded(
            child: ListView.builder(
              itemCount: yt.activeDownloads.length,
              itemBuilder:(context, index) {
                final download = yt.activeDownloads.entries.elementAt(index);

                final id = download.key;
                final title = download.value;


                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.downloading),
                  ),
                  title: Text(title),
                  trailing: SizedBox(
                    width: 130,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Progress: ${yt.downloadProgress[id]?.toStringAsFixed(1) ?? "0.0"}%",
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          "Status: ${yt.downloadState[id] ?? "Unknown"}",
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (yt.downloadError[id] != null)
                          Text(
                            "Error: ${yt.downloadError[id]}",
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),


    );
  }
}



