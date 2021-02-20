# WebCookies

[![build statud](https://img.shields.io/travis/tautalos/web_cookies/master.svg?style=flat-square)](https://travis-ci.org/tautalos/web_cookies)
[![Pub](https://img.shields.io/pub/v/web_cookies.svg?style=flat-square)](https://pub.dartlang.org/packages/web_cookies)
[![support](https://img.shields.io/badge/platform-flutter%7Cdart%20vm-ff69b4.svg?style=flat-square)](https://github.com/tautalos/web_cookies)

A cookie manager for http requests in Dart, by which you can deal with the complex cookie policy and persist cookies easily.

### Add dependency

```yaml
dependencies:
  web_cookies: ^1.0.0
```

## Usage

A simple usage example:

```dart
import 'package:web_cookies/web_cookies.dart';
void main() async {
  List<Cookie> cookies = [new Cookie("name", "wendux"),new Cookie("location", "china")];
  var cj = new WebCookies();
  //Save cookies   
  cj.saveFromResponse(Uri.parse("https://www.google.com/"), cookies);
  //Get cookies  
  List<Cookie> results = cj.loadForRequest(Uri.parse("https://www.google.com/xx"));
  print(results);  
}    
       
```

## Classes

### `SerializableCookie`

This class is a wrapper for `Cookie` class. Because the `Cookie` class doesn't  support Json serialization, for the sake of persistence, we use this class instead of it.

### `WebCookies`

`WebCookies` is a default cookie manager which implements the standard cookie policy declared in RFC. WebCookies saves the cookies in **RAM**, so if the application exit, all cookies will be cleared. A example as follow:

```dart
var cj= new WebCookies();
```

### `PersistWebCookies`

`PersistWebCookies` is a cookie manager which implements the standard cookie policy declared in RFC. `PersistWebCookies`  persists the cookies in files, so if the application exit, the cookies always exist unless call `delete` explicitly. A example as follows:

```dart
// Cookie files will be saved in "./cookies"
var cj=new PersistWebCookies(
    dir:"./cookies",
    ignoreExpires:true, //save/load even cookies that have expired.
);
```

> **Note**: In Flutter, File system is different from PC,  you can use [path_provider](https://pub.dartlang.org/packages/path_provider) package to get the path :
>
> ```dart
> // API `getTemporaryDirectory` is from "path_provider" package.
> Directory tempDir = await getTemporaryDirectory();
> String tempPath = tempDir.path;
> WebCookies cj=new PersistWebCookies(dir:tempPath);
> ```



## APIs

**void saveFromResponse(Uri uri, List<Cookie> cookies);**

Save the cookies for specified uri.

**List<Cookie> loadForRequest(Uri uri);**

Load the cookies for specified uri.

**delete(Uri uri,[bool withDomainSharedCookie = false] )**

Delete cookies for specified `uri`. This API will delete all cookies for the `uri.host`, it will ignored the `uri.path`.

If `withDomainSharedCookie` is `true `  ,  will delete the domain-shared cookies.

*Note: This API is only available in `PersistWebCookies` class.*

## Working with `HttpClient`

Using  `WebCookies` or `PersistWebCookies` manages  `HttpClient ` 's  request/response cookies is very easy:

```dart
var cj=new WebCookies();
...
request= await httpClient.openUrl(options.method, uri);
request.cookies.addAll(cj.loadForRequest(uri));
response= await request.close();
cj.saveFromResponse(uri, response.cookies);
```

## Working with web

[web](https://github.com/tautalos/web) is a powerful Http client for Dart, which supports Interceptors, Global configuration, FormData, File downloading, Timeout etc.  And [web](https://github.com/tautalos/web) supports to manage cookies with web_cookies, the simple example is:

```dart
import 'package:web/web.dart';
import 'package:web_cookie_manager/web_cookie_manager.dart';
import 'package:web_cookies/web_cookies.dart';

main() async {
  var web =  Web();
  var webCookies=WebCookies();
  web.interceptors.add(CookieManager(webCookies));
  await web.get("https://google.com/");
  // Print cookies
  print(webCookies.loadForRequest(Uri.parse("https://google.com/")));
  // second request with the cookie
  await web.get("https://google.com/");
}
```

More details about [web](https://github.com/tautalos/web)  see : https://github.com/tautalos/web .

## Copyright & License

This open source project authorized by https://tautalos.club , and the license is MIT.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/tautalos/web_cookies

