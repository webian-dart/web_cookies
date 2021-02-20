import 'dart:io';

import '../web_cookies.dart';

/// WebCookies is a cookie manager for http requests。
abstract class WebCookies {
  factory WebCookies({bool ignoreExpires = false}) {
    return DefaultWebCookies(ignoreExpires: ignoreExpires);
  }

  /// Save the cookies for specified uri.
  void saveFromResponse(Uri uri, List<Cookie> cookies);

  /// Load the cookies for specified uri.
  List<Cookie> loadForRequest(Uri uri);

  final bool ignoreExpires = false;
}
