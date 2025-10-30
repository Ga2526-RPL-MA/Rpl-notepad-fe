import 'package:rpl_notepad_fe/core/network/api_config.dart';

enum APIEndpoint { login, register, logout }

extension APIEndpointExtension on APIEndpoint {
  String get path {
    switch (this) {
      case APIEndpoint.login:
        return "/login";

      case APIEndpoint.register:
        return "/register";

      case APIEndpoint.logout:
        return "/logout";
    }
  }

  Uri get url => Uri.parse("${AppConfig.baseURL}$path");
}
