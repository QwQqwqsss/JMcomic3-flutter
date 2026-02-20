import 'dart:async';
import 'dart:convert';
import 'dart:io';

class AppHttpClient {
  static final HttpClient _client = HttpClient()
    ..autoUncompress = true
    ..connectionTimeout = const Duration(seconds: 10)
    ..idleTimeout = const Duration(seconds: 20)
    ..maxConnectionsPerHost = 6
    ..userAgent = "Jasmine/Flutter";

  static Future<String> getText(
    String url, {
    Map<String, String>? headers,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration requestTimeout = const Duration(seconds: 15),
    int retries = 1,
    bool allowMalformedUtf8 = true,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        final request = await _client.getUrl(Uri.parse(url)).timeout(
              connectTimeout,
            );
        request.followRedirects = true;
        request.maxRedirects = 5;
        headers?.forEach((key, value) {
          request.headers.set(key, value);
        });

        final response = await request.close().timeout(requestTimeout);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException(
            "HTTP ${response.statusCode}",
            uri: Uri.parse(url),
          );
        }

        final bytes = await response.fold<List<int>>(
          <int>[],
          (previous, element) => previous..addAll(element),
        );
        return utf8.decode(bytes, allowMalformed: allowMalformedUtf8);
      } on TimeoutException catch (e) {
        lastError = e;
      } on SocketException catch (e) {
        lastError = e;
      } on HandshakeException catch (e) {
        lastError = e;
      } on HttpException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = e;
      }

      if (attempt < retries) {
        await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
      }
    }

    throw lastError ?? StateError("http get failed: $url");
  }

  static Future<String?> getTextOrNull(
    String url, {
    Map<String, String>? headers,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration requestTimeout = const Duration(seconds: 15),
    int retries = 1,
    bool allowMalformedUtf8 = true,
  }) async {
    try {
      return await getText(
        url,
        headers: headers,
        connectTimeout: connectTimeout,
        requestTimeout: requestTimeout,
        retries: retries,
        allowMalformedUtf8: allowMalformedUtf8,
      );
    } catch (_) {
      return null;
    }
  }
}
