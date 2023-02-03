import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Variable{
  static int index = 2;
  static String search = '';
  static late InAppWebViewController inAppWebViewController;
  static late PullToRefreshController pullToRefreshController;
  static TextEditingController textEditingController = TextEditingController();
  static List history=[];
  static List bookmark=[];
}