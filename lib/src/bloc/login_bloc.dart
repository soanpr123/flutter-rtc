import 'dart:async';

import 'package:logindemo/src/model/loginMD.dart';
import 'package:logindemo/src/service/login_service.dart';
import 'package:logindemo/src/shared/base/base_service.dart';
import 'package:logindemo/src/shared/component/connfig.dart';
import 'package:logindemo/src/shared/component/validatetion.dart';
import 'package:rxdart/rxdart.dart';



class LoginBloc {
  final _emailSubjectt = BehaviorSubject<String>();
  final _passSubject = BehaviorSubject<String>();
  final _btnSubject = BehaviorSubject<bool>();

  final _datalogin = PublishSubject<List<LoginMd>>();

  AuthenSerice _authenSerice = AuthenSerice();

  var emailValidation =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    sink.add(Validation.validationEmail(email));
  });

  var passValidation =
      StreamTransformer<String, String>.fromHandlers(handleData: (pass, sink) {
    sink.add(Validation.validationPass(pass));
  });

  Stream<String> get emailStream =>
      _emailSubjectt.stream.transform(emailValidation);
  Sink<String> get emailSink => _emailSubjectt.sink;

  Stream<String> get passStream =>
      _passSubject.stream.transform(passValidation);
  Sink<String> get passSink => _passSubject.sink;

  Stream<bool> get btnStream => _btnSubject.stream;
  Sink<bool> get btnSink => _btnSubject.sink;

  Stream<List<LoginMd>> get datalistStream => _datalogin.stream;
  Sink<List<LoginMd>> get datalistSink => _datalogin.sink;

  dispose() {
    _emailSubjectt.close();
    _passSubject.close();
    _btnSubject.close();
    _datalogin.close();
  }

  void Login(
      {String email,
  String password,
      Function successBlock(object),

      Function error(err)}) async {

    var url = Config.REACT_APP_API_URL + "/login";
    await BaseService().postRequest(
        contentUrl: url,
        body: {
          'email':email,
        },
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

         return  successBlock(object);
        },
        error: (error) {
          print(" error là : $error");
          return;
        });
  }
  LoginBloc() {
    Rx.combineLatest2(_emailSubjectt, _passSubject, (email, pass) {
      return Validation.validationEmail(email) == null &&
          Validation.validationPass(pass) == null;
    }).listen((enable) {
      btnSink.add(enable);
    });
  }
}
