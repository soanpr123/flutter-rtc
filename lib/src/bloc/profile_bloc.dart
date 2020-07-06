import 'package:logindemo/src/model/user_profile_MD.dart';
import 'package:logindemo/src/service/profile_service.dart';
import 'package:rxdart/rxdart.dart';

class ProfileBloc {
  UserProfileService _profileService = UserProfileService();
  final _datalist = PublishSubject<Proffile>();

  Stream<Proffile> get datalist => _datalist.stream;

  dispose() {
    _datalist.close();
  }

  getInfor(String token,Function getdata) async {
    await _profileService.getInforUser(
        body: {
          'token': token,
        },
        successBlock: (data) {
          _datalist.sink.add(data);
          getdata(data);
          return;
        },
        error: (error) {
          print(error);
          return;
        });
  }
}
