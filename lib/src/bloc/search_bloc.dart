import 'package:rtc_uoi/src/model/invicationMD.dart';
import 'package:rtc_uoi/src/service/search_friend_service.dart';
import 'package:rxdart/rxdart.dart';

class SearchhSendBloc {
  SearchfriendService _searchfriendService = SearchfriendService();
  final _datalist = PublishSubject<List<Empty>>();
  Stream<List<Empty>> get dataList => _datalist.stream;
  dispose() {
    _datalist.close();
  }

  invistSend(String token, String email) async {
    await _searchfriendService.inviteFriend(
        body: {
          'token': token,
          "email": email,
        },
        successBlock: (data) {
          _datalist.sink.add(data);
          return;
        },
        error: (error) {
          print(error);
          return;
        });
  }

  appectInvite(String token, String email, int id) async {
    await _searchfriendService.appectInvication(
        body: {"token": token, "emailFriend": email, "idFriend": id},
        successBlock: (data) {
          print(data);
          return;
        },
        error: (error) {
          print(error);
          return;
        });
  }

  refuseInvication(String token,  int id) async {
    await _searchfriendService.appectInvication(
        body: {"token": token, "idFriend": id},
        successBlock: (data) {
          print(data);
          return;
        },
        error: (error) {
          print(error);
          return;
        });
  }
}
