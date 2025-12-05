import 'package:rpl_notepad_fe/core/network/api_config.dart';

enum APIEndpoint {
  login,
  register,
  logout,
  getClasses,
  createClasses,
  updateClasses,
  deleteClasses,
  getIssues,
  postIssues,
  postAnswer,
  postSubAnswer,
  getTask,
  createTask,
  updateTask,
  deleteTask,
  getNotes,
  createNote,
  updateNote,
  deleteNote,
  getNoteFiles,
  createNoteFile,
  updateNoteFile,
  deleteNoteFile,
  getWeeks,
  getWeekById,
  createWeek,
  updateWeek,
  deleteWeek,
  searchTask,
  searchClass,
  searchIssue,
  searchAnswers,
  searchSubAnswers,
  searchNotes,
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
      case APIEndpoint.updateClasses:
        return "/class";
      case APIEndpoint.deleteClasses:
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
      case APIEndpoint.getNotes:
        return "/notes";
      case APIEndpoint.createNote:
        return "/notes";
      case APIEndpoint.updateNote:
        return "/notes";
      case APIEndpoint.deleteNote:
        return "/notes";
      case APIEndpoint.getNoteFiles:
        return "/noteFiles";
      case APIEndpoint.createNoteFile:
        return "/noteFiles";
      case APIEndpoint.updateNoteFile:
        return "/noteFiles";
      case APIEndpoint.deleteNoteFile:
        return "/noteFiles";
      case APIEndpoint.getWeeks:
        return "/weeks";
      case APIEndpoint.getWeekById:
        return "/weeks";
      case APIEndpoint.createWeek:
        return "/week";
      case APIEndpoint.updateWeek:
        return "/week";
      case APIEndpoint.deleteWeek:
        return "/week";
      case APIEndpoint.searchTask:
        return "/tasks/search";
      case APIEndpoint.searchClass:
        return "/class/search";
      case APIEndpoint.searchIssue:
        return "/issues/search";
      case APIEndpoint.searchAnswers:
        return "/answers/search";
      case APIEndpoint.searchSubAnswers:
        return "/sub-answers/search";
      case APIEndpoint.searchNotes:
        return "/notes/search";
    }
  }

  Uri get url => Uri.parse("${AppConfig.baseURL}$path");
}
