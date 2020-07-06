

import 'package:logindemo/src/model/user_profile_MD.dart';
import 'package:logindemo/src/shared/base/base_service.dart';
import 'package:logindemo/src/shared/component/connfig.dart';

class UserProfileService {
  getInforUser(
      {Map<String, dynamic> body,
      Function successBlock(object),
      Function error(err)}) async {
    var url = Config.REACT_APP_API_URL + "/user/profile";
    await BaseService().postRequest(
        contentUrl: url,
        body: body,
        successBlock: (object) {
          List<InfoUser> item = [];
          Proffile proffile = Proffile.fromJson(object);
          item.add(InfoUser(
            id: proffile.infoUser.id,
            firstName: proffile.infoUser.firstName,
            lastName: proffile.infoUser.lastName,
            email: proffile.infoUser.email,
            phone: proffile.infoUser.phone,
            company: proffile.infoUser.company,
            displayName: proffile.infoUser.displayName,
            bio: proffile.infoUser.bio,
            status: proffile.infoUser.status,
            friendsList: proffile.infoUser.friendsList,
            invitations: proffile.infoUser.invitations,
            avatars: proffile.infoUser.avatars,
          ));
          return successBlock(proffile);
        });
  }
}
