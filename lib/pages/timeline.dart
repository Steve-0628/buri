import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:web_socket_channel/web_socket_channel.dart';


// class Timeline extends StatefulWidget {
//   const Timeline({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     return TimelineState();
//   }
// }

class Timeline extends StatelessWidget {
  final String host;
  final String apiKey;
  const Timeline({Key? key, required this.host, required this.apiKey}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, 
      child: Builder(builder: (BuildContext context) {
        int currnetTab = DefaultTabController.of(context)!.index;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
              children:const [
                TabBar(
                  tabs: [
                    Tab(
                      child: Text("Home")
                    ),
                    Tab(
                      child: Text("Local")
                    ),
                    Tab(
                      child: Text("Social")
                    ),
                    Tab(
                      child: Text("Global"),
                    )
                  ],
                ),
              ]
            )
          ),
          body: TabBarView(
            children: [
              Container(
                child: TimelineBuilder(apiKey: apiKey, host: host, apiUrl: "timeline",)
              ),
              Container(
                // child: TimelineBuilder(apiKey: apiKey, host: host, apiUrl: "local-timeline",)
                child: Text("Local timeline is not implemented. ")
              ),
              Container(
                child: TimelineBuilder(apiKey: apiKey, host: host, apiUrl: "hybrid-timeline",)
              ),
              Container(
                // child: TimelineBuilder(apiKey: apiKey, host: host, apiUrl: "global-timeline",)
                child: Text("Global is not implemented. ")
              ),
            ],
          )
        );
      },)
      
    );
  }
}


class TimelineBuilder extends StatefulWidget {
  final String host;
  final String apiKey;
  final String apiUrl;
  const TimelineBuilder({Key? key, required this.host, required this.apiKey, required this.apiUrl}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TimelineState();
  }
}


class TimelineState extends State<TimelineBuilder> with AutomaticKeepAliveClientMixin{
  List<Widget> timeline = [];
  dynamic InstanceInfo = {};
  int num = 0;
  late WebSocketChannel _stream;

  Future<http.Response> request(dynamic body) {
    body == null ? body = {"i": widget.apiKey} : body["i"] = widget.apiKey;
    return http.post(Uri(scheme: "https", host: widget.host, path: "/api/notes/${widget.apiUrl}"), headers: {"content-type": "application/json"}, body: json.encode(body) );
  }

  Widget createNote(note){
    dynamic main = note["renote"] ?? note;
    // print(note);
    Widget rnStatus = Row(
      children: [
        SizedBox(
          width: 32,
          height:32,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Image.network(note["user"]["avatarUrl"], fit: BoxFit.contain)
            ),
          ),
        ),
        Icon(Icons.repeat),
        Text("${note["user"]["name"] ?? note["user"]["username"]}がRenote")

      ]
    );
    return Column(
      children: [
        Row(), // リプ
        // Row(), // RN
        note["renote"] != null ? rnStatus : const SizedBox.shrink(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 64,
              height:64,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Image.network(main["user"]["avatarUrl"], fit: BoxFit.contain)
                ),
                
              ),
            ),
            Flexible(
              child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(main["user"]["name"] ?? main["user"]["username"], style: const TextStyle(fontWeight: FontWeight.bold),),
                        const SizedBox(width: 2),
                        Text("@" + main["user"]["username"]),
                        if(main["user"]["host"] != null) Text("@" + main["user"]["host"])
                      ],
                    ),  // TODO もうちょっといいかんじに
                    Container(
                      // color: Color(main["user"]["instance"] == null ?  int.parse(InstanceInfo["themeColor"].substring(1, 6), radix: 16) : int.parse(main["user"]["instance"]["themeColor"].substring(1, 6), radix: 16)),
                      //TODO: Decorationにする
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: Image.network(main["user"]["instance"] == null ? InstanceInfo["iconUrl"] : main["user"]["instance"]["iconUrl"], fit: BoxFit.contain)
                          ),
                          Text(main["user"]["instance"] == null ? InstanceInfo["name"] : main["user"]["instance"]["name"]),
                        ],
                      ),
                    ),
                    
                    Text(main["text"] ?? ""),
                  ],
                )
            )
          ],
        ), // main
      ],
    );
  }

  initTimeline() async {
    //TODO: federation/show-instanceにPOSTするとインスタンス情報が得られるのでそれをやる ←違う
    http.Response instanceInfo = await http.post(Uri(scheme: "https", host: widget.host, path: "/api/meta"), headers: {"content-type": "application/json"}, body: json.encode({}) );
    var temp = instanceInfo.body.toString();
    print(instanceInfo.statusCode);
    InstanceInfo = json.decode(instanceInfo.body.toString());
    http.Response resp = await request(null);
    List<dynamic> notes = json.decode(resp.body.toString());
    // List<Widget> notesTemp = [];
    for(var note in notes){

      setState(() {
        // timeline.add(createNote(note)); //TODO 壊れている
        timeline = [...timeline, createNote(note)];
        num+=1;
      });
      // notesTemp.
    }
  }

  @override
  initState() {
    super.initState();
    initTimeline();
    _stream = WebSocketChannel.connect(
      Uri(scheme: "wss", host: widget.host, path: "streaming", queryParameters: {"i": widget.apiKey})
    );
    String? channelName;
    if(widget.apiUrl == "timeline"){
      channelName = "homeTimeline";
    }
    else if(widget.apiUrl == "hybrid-timeline"){
      channelName = "hybridTimeline";
    }else if(widget.apiUrl == "global-timeline"){
      channelName = "globalTimeline";
    }else if(widget.apiUrl == "local-timeline"){
      channelName = "localTimeline";
    }
    if(channelName != null){
      _stream.sink.add(
        json.encode(
          {
            "type": 'connect',
            "body": {
              "channel": 'homeTimeline',
              "id": 'foobar',
            }
          }
        )
      );
      _stream.stream.listen((msg) {
        var jsmsg = json.decode(msg);
        print(jsmsg);
        var note = createNote(jsmsg["body"]["body"]);
        setState(() {
          // timeline.add(note);
          // timeline.insert(0, note); //TODO ここも壊れている
          // num+=1;
          timeline = [note, ...timeline];
          // timeline.insert(0, note);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      children: timeline,
    );
  }

  @override
  bool get wantKeepAlive => true;

}