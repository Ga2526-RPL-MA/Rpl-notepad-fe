import 'package:rpl_notepad_fe/core/network/api_config.dart';

enum APIEndpoint {
  login
}

extension APIEndpointExtension on APIEndpoint {
  String get path {
    switch (this) {
      case APIEndpoint.login:
        return "/login";

    }
  }

  Uri get url => Uri.parse("${AppConfig.baseURL}$path");
}