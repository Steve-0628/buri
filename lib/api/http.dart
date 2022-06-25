import 'package:http/http.dart' as http;

class HTTP {
  post(String url, dynamic body){
    return http.post(Uri.parse(url), body: body);
  }
}