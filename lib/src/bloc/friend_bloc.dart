import 'package:rtc_uoi/src/model/friendMd.dart';
import 'package:rtc_uoi/src/service/friend_service.dart';
import 'package:rxdart/rxdart.dart';

class FriendBloc {
  FriendService _friendService = FriendService();
  final _dataList = PublishSubject<List<StatusElement>>();

  Stream<List<StatusElement>> get dataList => _dataList.stream;

  dispose() {
    _dataList.close();
  }

  getUser(String token) async {
    await _friendService.getAllUser(
        body: {
          'token': token,
        },
        successBlock: (data) {
          _dataList.sink.add(data);

          return;
        },
        error: (err) {
          print(err);
          return;
        });
  }
}
