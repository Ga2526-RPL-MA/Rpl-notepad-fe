// This file helps with CORS issues during development
// It's only used in development mode

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final server = await HttpServer.bind('localhost', 8080);
  print('CORS Proxy server running on http://localhost:8080');
  print('Proxying requests to: https://rpl-notepad-be-production.up.railway.app');
  print('Press Ctrl+C to stop the server');

  await for (final request in server) {
    try {
      // Handle CORS preflight request
      if (request.method == 'OPTIONS') {
        _handleOptionsRequest(request);
        continue;
      }

      // Print request info for debugging
      print('${request.method} ${request.uri.path}');

      // Forward the request to the actual API
      final client = HttpClient();
      final uri = Uri.https(
        'rpl-notepad-be-production.up.railway.app',
        request.uri.path,
        request.uri.queryParameters,
      );

      final proxyRequest = await client.openUrl(request.method, uri);
      
      // Copy headers from original request
      request.headers.forEach((name, values) {
        if (!['host', 'origin', 'referer', 'content-length'].contains(name.toLowerCase())) {
          proxyRequest.headers.set(name, values);
        }
      });

      // Set content type if not set
      final contentType = proxyRequest.headers.value(HttpHeaders.contentTypeHeader);
      if (contentType == null || !contentType.contains('application/json')) {
        proxyRequest.headers.contentType = ContentType.json;
      }

      // Remove any CORS headers from the request before forwarding
      proxyRequest.headers.removeAll('access-control-allow-origin');
      proxyRequest.headers.removeAll('access-control-allow-methods');
      proxyRequest.headers.removeAll('access-control-allow-headers');

      // Forward the request body if present
      if (request.method == 'POST' || request.method == 'PUT') {
        final body = await request.cast<List<int>>().transform(utf8.decoder).join();
        if (body.isNotEmpty) {
          proxyRequest.write(body);
        }
      }

      // Get the response
      final response = await proxyRequest.close();
      
      // Set CORS headers on the response
      request.response.headers.set('Access-Control-Allow-Origin', 'http://localhost:3000');
      request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      request.response.headers.set('Access-Control-Allow-Headers', 'Origin, Content-Type, X-Auth-Token, Authorization, Accept');
      request.response.headers.set('Access-Control-Allow-Credentials', 'true');
      request.response.headers.contentType = ContentType.json;
      
      // Forward the status code
      request.response.statusCode = response.statusCode;
      
      // Forward the response body
      await response.pipe(request.response);
    } catch (e, stackTrace) {
      print('Proxy error: $e');
      print('Stack trace: $stackTrace');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'error': 'Proxy error',
        'message': e.toString(),
      }));
      await request.response.close();
    }
  }
}

void _handleOptionsRequest(HttpRequest request) {
  request.response.headers.set('Access-Control-Allow-Origin', 'http://localhost:3000');
  request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  request.response.headers.set('Access-Control-Allow-Headers', 'Origin, Content-Type, X-Auth-Token, Authorization, Accept');
  request.response.headers.set('Access-Control-Allow-Credentials', 'true');
  request.response.statusCode = HttpStatus.noContent;
  request.response.close();
}
