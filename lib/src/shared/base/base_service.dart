import 'dart:convert';

import 'package:http/http.dart' as http;


class BaseService {

  Map<String, String> requestHeaders = {
    'Accept': 'application/json',
    'Content-type': 'application/json'
  };

  postRequest({String contentUrl, Map<String, dynamic> body, Function successBlock(object), Function error(err)}) async {
    var response = await http.post(contentUrl,
        headers:requestHeaders,
        body: jsonEncode(body));
      var dataJson = json.decode(utf8.decode(response.bodyBytes));
      print(dataJson);
      return successBlock(dataJson);
  }

  getRequest({String contentUrl, Function successBlock(object), Function error(err)}) async {
    print(contentUrl);

    var response = await http.get(contentUrl);

    if (response.statusCode == 200) {
      //kết nối thành công
      var dataJson = json.decode(utf8.decode(response.bodyBytes));
      print(dataJson);
      return successBlock(dataJson);
    } else {
      return error(response.body);
    }
  }
}
