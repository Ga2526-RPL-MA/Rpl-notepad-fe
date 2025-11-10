import 'package:rpl_notepad_fe/core/network/api_config.dart';

enum APIEndpoint {
  login,
  register,
  logout,
  getClasses,
  createClasses,
  getIssues,
  postIssues,
  postAnswer,
  postSubAnswer,
  getTask,
  createTask,
  updateTask,
  deleteTask,
}

extension APIEndpointExtension on APIEndpoint {
  String get path {
    switch (this) {
      case APIEndpoint.login:
        return "/login";
      case APIEndpoint.register:
        return "/register";
      case APIEndpoint.logout:
        return "/logout";
      case APIEndpoint.getClasses:
        return "/class";
      case APIEndpoint.createClasses:
        return "/class";
      case APIEndpoint.getIssues:
        return "/issues";
      case APIEndpoint.postIssues:
        return "/issues";
      case APIEndpoint.postAnswer:
        return "/answers";
      case APIEndpoint.postSubAnswer:
        return "/subAnswers";
      case APIEndpoint.getTask:
        return "/tasks";  
      case APIEndpoint.createTask:
        return "/tasks";
      case APIEndpoint.updateTask:
        return "/tasks";
      case APIEndpoint.deleteTask:
        return "/tasks";
    }
  }

  Uri get url => Uri.parse("${AppConfig.baseURL}$path");
}
