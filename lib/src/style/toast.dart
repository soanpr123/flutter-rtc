import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastShare {
  getToast(String content) {
    return Fluttertoast.showToast(
        msg: content,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
