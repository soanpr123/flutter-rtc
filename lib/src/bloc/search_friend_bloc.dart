import 'package:rtc_uoi/src/model/searchfriendMD.dart';
import 'package:rtc_uoi/src/service/search_friend_service.dart';
import 'package:rxdart/rxdart.dart';

class SearchhFriendBloc {
  SearchfriendService _searchfriendService = SearchfriendService();
  final _datalist = PublishSubject<SearchFriendMd>();
  Stream<SearchFriendMd> get dataList => _datalist.stream;
  dispose() {
    _datalist.close();
  }

  getFriend(String token, int id) async {
    await _searchfriendService.getAllUser(
        body: {
          'token': token,
          "idFriend": id,
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
}
