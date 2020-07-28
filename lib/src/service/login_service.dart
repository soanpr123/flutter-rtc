import 'package:rtc_uoi/src/model/loginMD.dart';
import 'package:rtc_uoi/src/shared/base/base_service.dart';
import 'package:rtc_uoi/src/shared/component/connfig.dart';

class AuthenSerice {
  Login(
      {Map<String, dynamic> body,
      Function successBlock(object),
      Function error(err)}) async {
    var url = Config.REACT_APP_API_URL + "/login";
    await BaseService().postRequest(
        contentUrl: url,
        body: body,
        successBlock: (object) {
          List<LoginMd> item = [];
          item.add(LoginMd(
            password: object['password'],
            saltKey: object['saltKey'],
            message: object['message'],
            id: object['id'],
            nbConnect: object['nbConnect'],
            webToken: object['webToken'],
          ));
          print('data : $object');
          print('pass là : ${object['password']}');
          print('data là: ${item.length}');
          return successBlock(item);
        },
        error: (error) {
          print(error);
          return;
        });
  }

  signUp(
      {Map<String, dynamic> body,
      Function successBlock(object),
      Function error(err)}) async {
    var url = Config.REACT_APP_API_URL + "/signup";
    await BaseService().postRequest(
        contentUrl: url,
        body: body,
        successBlock: (object) {

          return successBlock(object);
        },
        error: (error) {
          return;
        });
    print('sign up success');
  }
}
