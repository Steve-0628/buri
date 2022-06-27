import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CreateNote extends StatefulWidget {
  const CreateNote({Key? key}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return CreateNoteState();
  }

}

class CreateNoteState extends State {
  String content = "";
  String host = "";
  String apiKey = "";
  String? errText;

  send () {
    Future<http.Response> resp = http.post(Uri(scheme: "https", host: host, path: "/api/notes/create"), body: json.encode({"i": apiKey, "text":content }));
    resp.then((value) => {
      if(value.statusCode == 200){
        Navigator.pop(context)
      }
      else {
        setState((){
          errText = "Error!!:${value.body}";
        })
      }
    })
    .catchError((err){
      setState(() {
        errText = "Error!!!!";
      });
    })
    ;
  }

  @override
  Widget build(BuildContext context) {
    Set arg = ModalRoute.of(context)!.settings.arguments as Set;
    setState((){
      host = arg.elementAt(0);
      apiKey = arg.elementAt(1);
    });


    return Scaffold(
      appBar: AppBar(
        title: const Text("New note")
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            minLines: null,
            maxLines: null,
            decoration: InputDecoration(
              errorText: errText,
              labelText: "What's happening?"
            ),
            onChanged: (val) => {
              setState((){
                content = val;
              })
            },
            // expands: true,
          ),
          const Expanded(child: SizedBox.shrink()),
          ElevatedButton(onPressed: (){send();}, child: const Text("Create"))
        ],
      )
    );
  }

}