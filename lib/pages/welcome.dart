import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WelcomeState();
  }
}

class WelcomeState extends State {
  String _host = "submarin.online";
  String? _hostError = null;
  String _apiKey = "";
  String? _apiKeyError = null;
  String _authErrText = "";
  bool _isAuthenticating = false;
  doSubmit() {
    bool canContinue = true;
    if(_host == ""){
      setState(() {
        _hostError = "Host is none";
      });
      canContinue = false;
    } 
    else if (_host.startsWith("https://") || _host.startsWith("http://")){
      setState(() {
        _hostError = "You don't need https or http";
      });
      canContinue = false;
    }
    else if(_host.endsWith("/")){
      setState(() {
        _hostError = "You don't need trailing slash";
      });
      canContinue = false;
    }
    else {
      _hostError = null;
    }

    if(_apiKey == ""){
      setState(() {
        _apiKeyError = "API Key cannot be none";
      });
      canContinue = false;
    }else {
      _apiKeyError = null;
    }
    if(!canContinue) {
      return false;
    }
    try{
      _isAuthenticating = true;
      setState((){
        _authErrText = "";
      });
      Future<http.Response> resp = http.post(Uri(scheme: "https", host: _host, path: "/api/i"), body: json.encode({"i": _apiKey}), headers: {"content-type": "applicaiton/json"});
      resp.then((resp){
        if(resp.statusCode != 200){
          throw "Unauthorized";
        }
        Navigator.pushNamed(context, "/main", arguments: {_host, _apiKey});
      })
      .catchError((err){
      setState((){
        _authErrText = "Failed to authenticate. Double check your host and key. ";
      });
      });
    }
    catch (e){
      setState((){
        _authErrText = "Failed to authenticate. ";
      });
    }
    finally {
      _isAuthenticating = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            children: [
              const Text("Welcome to Buri.", textScaleFactor: 1.5,),
              TextField(
                decoration: InputDecoration(
                  labelText: "Host",
                  errorText: _hostError
                ),
                onChanged: (value) => {
                  setState(() {
                    _host = value;
                  })
                },
                onSubmitted: (val) => {
                  doSubmit()
                },
              ),
              
              TextField(
                decoration: InputDecoration(
                  labelText: "API Key",
                  errorText: _apiKeyError,
                ),
                onChanged: (value) => {
                  setState(() {
                    _apiKey = value;
                  })
                },
                onSubmitted: (val) => {
                  doSubmit()
                },
              ),

              ElevatedButton(onPressed: (){doSubmit();}, child: const Text("Submit")),
              _isAuthenticating ? const CircularProgressIndicator() : Text(_authErrText),
            ],
          )
        )
      );
  }
}
