import 'package:get_it/get_it.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rpl_notepad_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:rpl_notepad_fe/features/auth/domain/usecases/login_usecase.dart';
import 'package:rpl_notepad_fe/features/auth/domain/usecases/register_usecase.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/register_view_model.dart';
import 'package:rpl_notepad_fe/features/discussion/data/repositories/class_repository_impl.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/class_repository.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/getclass_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/discussion_view_model.dart';

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

  // Register use cases
  getIt.registerLazySingleton<GetclassUsecase>(
    () => GetclassUsecase(getIt<ClassRepository>()),
  );

  // Discussion Feature
  // View Model
  getIt.registerFactory<DiscussionViewModel>(
    () => DiscussionViewModel(usecase: getIt<GetclassUsecase>()),
  );
}
