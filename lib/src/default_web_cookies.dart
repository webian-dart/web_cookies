import 'dart:io';

import '../web_cookies.dart';

/// [DefaultWebCookies] is a default cookie manager which implements the standard
/// cookie policy declared in RFC. [DefaultWebCookies] saves the cookies in RAM, so if the application
/// exit, all cookies will be cleared.
class DefaultWebCookies implements WebCookies {
  /// [ignoreExpires]: save/load even cookies that have expired.
  DefaultWebCookies({this.ignoreExpires = false});

  /// A array to save cookies.
  ///
  /// [domains[0]] save the cookies with "domain" attribute.
  /// These cookie usually need to be shared among multiple domains.
  ///
  /// [domains[1]] save the cookies without "domain" attribute.
  /// These cookies are private for each host name.
  ///
  static final List<
          Map<
              String, //domain
              Map<
                  String, //path
                  Map<
                      String, //cookie name
                      SerializableCookie //cookie
                      >>>> _domains =
      <Map<String, Map<String, Map<String, SerializableCookie>>>>[
    <String, Map<String, Map<String, SerializableCookie>>>{},
    <String, Map<String, Map<String, SerializableCookie>>>{}
  ];

  List<Map<String, Map<String, Map<String, SerializableCookie>>>> get domains =>
      _domains;

  @override
  List<Cookie> loadForRequest(Uri uri) {
    final list = <Cookie>[];
    final urlPath = uri.path.isEmpty ? '/' : uri.path;
    // Load cookies without "domain" attribute, include port.
    final hostname = uri.host;
    for (final domain in domains[1].keys) {
      if (hostname == domain) {
        final cookies =
            domains[1][domain]!.cast<String, Map<String, dynamic>>();
        var keys = cookies.keys.toList()
          ..sort((a, b) => b.length.compareTo(a.length));
        for (final path in keys) {
          if (urlPath.toLowerCase().contains(path)) {
            final values = cookies[path]!;
            for (final key in values.keys) {
              final SerializableCookie cookie = values[key];
              if (_check(uri.scheme, cookie)) {
                if (list.indexWhere((e) => e.name == cookie.cookie.name) ==
                    -1) {
                  list.add(cookie.cookie);
                }
              }
            }
          }
        }
      }
    }
    // Load cookies with "domain" attribute, Ignore port.
    domains[0].forEach(
        (String domain, Map<String, Map<String, SerializableCookie>> cookies) {
      if (uri.host.contains(domain)) {
        cookies.forEach((String path, Map<String, SerializableCookie> values) {
          if (urlPath.toLowerCase().contains(path)) {
            values.forEach((String key, SerializableCookie v) {
              if (_check(uri.scheme, v)) {
                list.add(v.cookie);
              }
            });
          }
        });
      }
    });
    return list;
  }

  @override
  void saveFromResponse(Uri uri, List<Cookie> cookies) {
    for (final cookie in cookies) {
      var domain = cookie.domain;
      String path;
      var index = 0;
      // Save cookies with "domain" attribute
      if (domain != null) {
        if (domain.startsWith('.')) {
          domain = domain.substring(1);
        }
        path = cookie.path ?? '/';
      } else {
        index = 1;
        // Save cookies without "domain" attribute
        path = cookie.path ?? (uri.path.isEmpty ? '/' : uri.path);
        domain = uri.host;
      }
      var mapDomain =
          domains[index][domain] ?? <String, Map<String, dynamic>>{};
      mapDomain = mapDomain.cast<String, Map<String, dynamic>>();

      final map = mapDomain[path] ?? <String, dynamic>{};
      map[cookie.name] = SerializableCookie(cookie);
      if (_isExpired(map[cookie.name])) {
        map.remove(cookie.name);
      }
      mapDomain[path] = map.cast<String, SerializableCookie>();
      domains[index][domain] =
          mapDomain.cast<String, Map<String, SerializableCookie>>();
    }
  }

  /// Delete cookies for specified [uri].
  /// This API will delete all cookies for the `uri.host`, it will ignored the `uri.path`.
  ///
  /// [withDomainSharedCookie] `true` will delete the domain-shared cookies.
  void delete(Uri uri, [bool withDomainSharedCookie = false]) {
    final host = uri.host;
    domains[1].remove(host);
    if (withDomainSharedCookie) {
      domains[0].removeWhere(
          (String domain, Map<String, Map<String, SerializableCookie>> v) =>
              uri.host.contains(domain));
    }
  }

  /// Delete all cookies in RAM
  void deleteAll() {
    domains[0].clear();
    domains[1].clear();
  }

  bool _isExpired(SerializableCookie? cookie) {
    return ignoreExpires ? false : cookie!.isExpired();
  }

  bool _check(String scheme, SerializableCookie cookie) {
    return cookie.cookie.secure && scheme == 'https' || !_isExpired(cookie);
  }

  @override
  final bool ignoreExpires;
}
