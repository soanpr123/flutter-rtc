import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rtc_uoi/src/model/loginMD.dart';
import 'package:rtc_uoi/src/service/login_service.dart';
import 'package:rtc_uoi/src/shared/base/base_service.dart';
import 'package:rtc_uoi/src/shared/component/connfig.dart';
import 'package:rtc_uoi/src/shared/component/socket_client.dart';
import 'package:rtc_uoi/src/shared/component/toast.dart';
import 'package:rtc_uoi/src/shared/component/validatetion.dart';
import 'package:rtc_uoi/src/ui/home_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginBloc {
  final _emailSubjectt = BehaviorSubject<String>();
  final _passSubject = BehaviorSubject<String>();
  final _btnSubject = BehaviorSubject<bool>();
  final _autoLogin = BehaviorSubject<bool>();
  final _datalogin = PublishSubject<List<LoginMd>>();



  AuthenSerice _authenSerice = AuthenSerice();
  SimpleWebSocket _simpleWebSocket = SimpleWebSocket();
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

  Stream<bool> get autoLoginStream => _autoLogin.stream;
  Sink<bool> get autoLoginSink => _autoLogin.sink;

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
      String Password,
      Function successBlock(object),
      Function error(err)}) async {
    var url = Config.REACT_APP_API_URL + "/login";
    final prefs = await SharedPreferences.getInstance();
    await BaseService().postRequest(
        contentUrl: url,
        body: {
          'email': email,
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
          final userData = jsonEncode({
            'id': object['id'],
            'webToken': object['webToken'],
            'password': object['password'],
            'pasinput': Password,
            'saltKey': object['saltKey']
          });
          prefs.setString('userData', userData);
          print("userData $userData");
          return successBlock(object);
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


