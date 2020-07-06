

import 'package:logindemo/src/model/friendMd.dart';
import 'package:logindemo/src/shared/base/base_service.dart';
import 'package:logindemo/src/shared/component/connfig.dart';

class FriendService {
  getAllUser(
      {Map<String, dynamic> body,
      Function successBlock(object),
      Function error(err)}) async {
    var url = Config.REACT_APP_API_URL + "/user/updateStatus";
    await BaseService().postRequest(
        contentUrl: url,
        body: body,
        successBlock: (object) {
          List<StatusElement> _friend = [];
          FriendMd friend = FriendMd.fromJson(object);
          for (StatusElement statusElement in friend.status) {
            var decode = Uri.decodeFull(statusElement.displayName);
            _friend.add(StatusElement(
              id: statusElement.id,
              firstName: statusElement.firstName,
              lastName: statusElement.lastName,
              displayName: decode,
              status: statusElement.status,
              avatars: statusElement.avatars,
              email: statusElement.email,
            ));
          }
          return successBlock(_friend);
        });
  }
}
