import 'package:get_it/get_it.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rpl_notepad_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:rpl_notepad_fe/features/auth/domain/usecases/login_usecase.dart';
import 'package:rpl_notepad_fe/features/auth/domain/usecases/register_usecase.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/register_view_model.dart';
import 'package:rpl_notepad_fe/features/discussion/data/repositories/class_repository_impl.dart';
import 'package:rpl_notepad_fe/features/discussion/data/repositories/issue_repository_impl.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/class_repository.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/issue_repository.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/add_answer_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/add_sub_answer_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/create_issue_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/get_answers_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/get_subanswers_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/get_class_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/get_issue_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/discussion_viewmodel.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/viewmodel/add_class_view_model.dart';
import 'package:rpl_notepad_fe/features/note/data/repositories/note_repository_impl.dart';
import 'package:rpl_notepad_fe/features/note/data/repositories/week_repository_impl.dart';
import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';
import 'package:rpl_notepad_fe/features/note/domain/repositories/week_repository.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/create_note_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/create_note_files_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/delete_note_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_note_by_id_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_notes_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/update_note_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/create_week_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/delete_week_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_week_by_id_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_weeks_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/update_week_usecase.dart';
import 'package:rpl_notepad_fe/features/note/presentation/viewmodel/note_viewmodel.dart';
import 'package:rpl_notepad_fe/features/note/presentation/viewmodel/week_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // API Service
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Auth Feature
  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(api: getIt<ApiService>()),
  );

  // Use Cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );

  // View Models
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(useCase: getIt<LoginUseCase>()),
  );
  getIt.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(useCase: getIt<RegisterUseCase>()),
  );

  // Register ApiService as a singleton
  if (!getIt.isRegistered<ApiService>()) {
    getIt.registerLazySingleton(() => ApiService());
  }

  // Register repositories
  getIt.registerLazySingleton<ClassRepository>(
    () => ClassRepositoryImpl(api: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<IssueRepository>(
    () => IssueRepositoryImpl(api: getIt<ApiService>()),
  );

  // Register use cases
  getIt.registerLazySingleton<GetAnswersUsecase>(
    () => GetAnswersUsecase(getIt<IssueRepository>()),
  );

  getIt.registerLazySingleton<AddAnswerUsecase>(
    () => AddAnswerUsecase(getIt<IssueRepository>()),
  );

  getIt.registerLazySingleton<AddSubAnswerUsecase>(
    () => AddSubAnswerUsecase(getIt<IssueRepository>()),
  );

  getIt.registerLazySingleton<CreateIssueUsecase>(
    () => CreateIssueUsecase(getIt<IssueRepository>()),
  );

  getIt.registerLazySingleton<GetSubAnswersUsecase>(
    () => GetSubAnswersUsecase(getIt<IssueRepository>()),
  );

  getIt.registerLazySingleton<GetclassUsecase>(
    () => GetclassUsecase(getIt<ClassRepository>()),
  );

  getIt.registerLazySingleton<GetIssueUsecase>(
    () => GetIssueUsecase(getIt<IssueRepository>()),
  );

  // Discussion Feature
  // View Model
  getIt.registerFactory<DiscussionViewModel>(
    () => DiscussionViewModel(usecase: getIt<GetclassUsecase>()),
  );

  // Admin Feature
  // View Model
  getIt.registerFactory<AddClassViewModel>(() => AddClassViewModel());

  // Note Feature
  // Repositories
  getIt.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(api: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<WeekRepository>(
    () => WeekRepositoryImpl(api: getIt<ApiService>()),
  );

  // Note Use Cases
  getIt.registerLazySingleton<GetNotesUsecase>(
    () => GetNotesUsecase(getIt<NoteRepository>()),
  );

  getIt.registerLazySingleton<GetNoteByIdUsecase>(
    () => GetNoteByIdUsecase(getIt<NoteRepository>()),
  );

  getIt.registerLazySingleton<CreateNoteUsecase>(
    () => CreateNoteUsecase(getIt<NoteRepository>()),
  );

  getIt.registerLazySingleton<CreateNoteFilesUsecase>(
    () => CreateNoteFilesUsecase(getIt<NoteRepository>()),
  );

  getIt.registerLazySingleton<UpdateNoteUsecase>(
    () => UpdateNoteUsecase(getIt<NoteRepository>()),
  );

  getIt.registerLazySingleton<DeleteNoteUsecase>(
    () => DeleteNoteUsecase(getIt<NoteRepository>()),
  );

  // Week Use Cases
  getIt.registerLazySingleton<GetWeeksUsecase>(
    () => GetWeeksUsecase(getIt<WeekRepository>()),
  );

  getIt.registerLazySingleton<GetWeekByIdUsecase>(
    () => GetWeekByIdUsecase(getIt<WeekRepository>()),
  );

  getIt.registerLazySingleton<CreateWeekUsecase>(
    () => CreateWeekUsecase(getIt<WeekRepository>()),
  );

  getIt.registerLazySingleton<UpdateWeekUsecase>(
    () => UpdateWeekUsecase(getIt<WeekRepository>()),
  );

  getIt.registerLazySingleton<DeleteWeekUsecase>(
    () => DeleteWeekUsecase(getIt<WeekRepository>()),
  );

  // View Models
  getIt.registerFactory<NoteViewModel>(
    () => NoteViewModel(
      getNotesUsecase: getIt<GetNotesUsecase>(),
      createNoteUsecase: getIt<CreateNoteUsecase>(),
      updateNoteUsecase: getIt<UpdateNoteUsecase>(),
      deleteNoteUsecase: getIt<DeleteNoteUsecase>(),
      createNoteFilesUsecase: getIt<CreateNoteFilesUsecase>(),
    ),
  );

  getIt.registerFactory<WeekViewModel>(
    () => WeekViewModel(
      getWeeksUsecase: getIt<GetWeeksUsecase>(),
      getWeekByIdUsecase: getIt<GetWeekByIdUsecase>(),
      createWeekUsecase: getIt<CreateWeekUsecase>(),
      updateWeekUsecase: getIt<UpdateWeekUsecase>(),
      deleteWeekUsecase: getIt<DeleteWeekUsecase>(),
    ),
  );
}
