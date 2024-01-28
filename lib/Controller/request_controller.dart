import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestController {
  String path;
  String server;
  http.Response? _res;
  final Map<dynamic, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;

  RequestController({required this.path, this.server = "http://172.20.10.13"});

  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-type"] = "application/json; charset=UTF-8";
  }

  Future<void> post() async {
    _res = await http.post(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  Future<void> get() async {
    _res = await http.get(
      Uri.parse(server + path),
      headers: _headers,
    );
    _parseResult();
  }

  void _parseResult() {
    //parse result into json structure if possible
    try {
      print("raw response:${_res?.body}");
      _resultData = jsonDecode(_res?.body ?? "");
    } catch (ex) {
      _resultData = _res?.body;
      print("exception in http result parsing ${ex}");
    }
  }
  dynamic result() {
    return _resultData;
  }
  int status() {
    return _res?.statusCode??0;
    }
}