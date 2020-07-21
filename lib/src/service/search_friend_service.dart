import 'package:rtc_uoi/src/model/appect_invicationMD.dart';
import 'package:rtc_uoi/src/model/invicationMD.dart';
import 'package:rtc_uoi/src/model/searchfriendMD.dart';
import 'package:rtc_uoi/src/shared/base/base_service.dart';
import 'package:rtc_uoi/src/shared/component/connfig.dart';

class SearchfriendService {
  getAllUser(
      {Map<String, dynamic> body,
      Function successBlock(object),
      Function error(err)}) async {
    var url = Config.REACT_APP_API_URL + "/friends/searchFriend";
    await BaseService().postRequest(
        contentUrl: url,
        body: body,
        successBlock: (object) {
          List<Datum> _friend = [];
          SearchFriendMd friend = SearchFriendMd.fromJson(object);
          for (Datum item in friend.data) {
            _friend.add(Datum(
              firstName: item.firstName,
              lastName: item.lastName,
              displayName: item.displayName,
              email: item.email,
            ));
          }
          return successBlock(friend);
        });
  }

  inviteFriend(
      {Map<String, dynamic> body,
      Function successBlock(object),
      Function error(err)}) async {
    var url = Config.REACT_APP_API_URL + "/invitations/sendInvitations";
    await BaseService().postRequest(
        contentUrl: url,
        body: body,
        successBlock: (object) {
          List<Empty> _list = [];
          print(object);
          _list.add(Empty(
            message: object['message'],
            id: object['id'],
          ));
          return successBlock(_list);
        });
  }

  appectInvication(
      {Map<String, dynamic> body,
      Function successBlock(object),
      Function error(err)}) async {
    var url = Config.REACT_APP_API_URL + "/invitations/acceptInvitation";
    await BaseService().postRequest(
        contentUrl: url,
        body: body,
        successBlock: (object) {
          AppectInvication _appec = AppectInvication.fromJson(object);
          return successBlock(_appec);
        });
  }
  refuseInvication(
      {Map<String, dynamic> body,
        Function successBlock(object),
        Function error(err)}) async {
    var url = Config.REACT_APP_API_URL + "/invitations/refuseInvitation";
    await BaseService().postRequest(
        contentUrl: url,
        body: body,
        successBlock: (object) {
          return successBlock(object);
        });
  }
}
