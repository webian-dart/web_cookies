import 'dart:io';

import '../cookie_jar.dart';

/// CookieJar is a cookie manager for http requests。
abstract class CookieJar {
  factory CookieJar({bool ignoreExpires = false}) {
    return DefaultCookieJar(ignoreExpires: ignoreExpires);
  }

  /// Save the cookies for specified uri.
  void saveFromResponse(Uri uri, List<Cookie> cookies);

  /// Load the cookies for specified uri.
  List<Cookie> loadForRequest(Uri uri);

  final bool ignoreExpires = false;
}
