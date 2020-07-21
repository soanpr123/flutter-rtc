import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:rtc_uoi/src/bloc/login_bloc.dart';
import 'package:rtc_uoi/src/model/loginMD.dart';
import 'package:rtc_uoi/src/shared/component/connfig.dart';
import 'package:rtc_uoi/src/shared/component/socket_client.dart';
import 'package:rtc_uoi/src/shared/component/toast.dart';
import 'package:rtc_uoi/src/shared/style/colors.dart';
import 'package:rtc_uoi/src/ui/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Palette.BACKGROUND),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Image(
                        width: 260,
                        image: AssetImage('assets/images/uoi_logo.png')),
                  ),
                  SizedBox(height: 20,),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  SimpleWebSocket _simpleWebSocket = SimpleWebSocket();
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final loginBloc = LoginBloc();
  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An Error Occurred'),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okey'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  void _submit()async {
    setState(() {
      _isLoading = true;
    });

    if (_authMode == AuthMode.Login) {
      loginBloc.Login(
          email: _emailController.text.trim(),
          Password: _passwordController.text.trim(),
          successBlock: (data) {
            print("data là  $data");
//            List<LoginMd> loginMd = data;
            List<int> key = utf8.encode(data['saltKey']);
            List<int> bytes = utf8.encode(_passwordController.text.trim());
            var hmacSha256 = new Hmac(sha512, key); // HMAC-SHA256
            var digest = hmacSha256.convert(bytes);
            print("pass so sánh $digest");
            print("pass  ${data['password']}");
            if (digest.toString() == data['password']) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext ctx) => HomeScreen(
                        token: data['webToken'],
                        idFome: data['id'],
                      )));
              _simpleWebSocket.connect(
                  Config.REACT_APP_URL_SOCKETIO, data['webToken']);


            } else {
              ToastShare().getToast("Password is error");
            }
            return;
          },
          error: (error) {
            print('error');
            return;
          });
    } else {
      ///Singupp
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _simpleWebSocket = SimpleWebSocket();
    _emailController.addListener(() {
      loginBloc.emailSink.add(_emailController.text);
    });
    _passwordController.addListener(() {
      loginBloc.passSink.add(_passwordController.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    loginBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 500 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder<String>(
                    stream: loginBloc.emailStream,
                    builder: (context, snapshot) {
                      return TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            icon: Icon(Icons.email),
                            hintText: "example@gmail.com",
                            labelText: "Email *",
                            errorText: snapshot.data),
                      );
                    }),
                StreamBuilder<String>(
                    stream: loginBloc.passStream,
                    builder: (context, snapshot) {
                      return TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            icon: Icon(Icons.lock),
                            hintText: "password",
                            labelText: "Passord *",
                            errorText: snapshot.data),
                      );
                    }),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                          }
                        : null,
                  ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                StreamBuilder<bool>(
                    stream: loginBloc.btnStream,
                    builder: (context, snapshot) {
                      return _isLoading
                          ? CircularProgressIndicator()
                          : RaisedButton(
                              child: Text(_authMode == AuthMode.Login
                                  ? 'LOGIN'
                                  : 'SIGN UP'),
                              onPressed: snapshot.data == true ? _submit : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 8.0),
                              color: Theme.of(context).primaryColor,
                              textColor: Theme.of(context)
                                  .primaryTextTheme
                                  .button
                                  .color,
                            );
                    }),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
