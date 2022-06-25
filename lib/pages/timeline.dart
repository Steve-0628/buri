import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


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
                child: Text("local")
              ),
              Container(
                child: Text("social")
              ),
              Container(
                child: Text("global")
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
  dynamic InstanceInfo = {}; //TODO ローカルのノートはInstance情報が返ってこないのでどこかで初期化する

  Future<http.Response> request(dynamic body) {
    body == null ? body = {"i": widget.apiKey} : body["i"] = widget.apiKey;
    return http.post(Uri(scheme: "https", host: widget.host, path: "/api/notes/${widget.apiUrl}"), headers: {"content-type": "application/json"}, body: json.encode(body) );
  }

  Widget createNote(note){
    dynamic main = note["renote"] ?? note;
    print(note);
    return Column(
      children: [
        Row(), // リプ
        Row(), // RN
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
                        Text(main["user"]["name"] ?? main["user"]["username"]),
                        const SizedBox(width: 2),
                        Text("@" + main["user"]["username"]),
                        if(main["user"]["host"] != null) Text("@" + main["user"]["host"])
                      ],
                    ),  // TODO もうちょっといいかんじに
                    Container(
                      color: Color(main["user"]["instance"] == null ?  int.parse(InstanceInfo["themeColor"].substring(1, 6), radix: 16) : int.parse(main["user"]["instance"]["themeColor"].substring(1, 6), radix: 16)),
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
    List<Widget> notesTemp = [];
    for(var note in notes){
      notesTemp.add(createNote(note));
    }
    setState(() {
      timeline = notesTemp;
    });
  }

  @override
  initState() {
    super.initState();
    initTimeline();

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