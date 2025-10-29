import 'package:get_it/get_it.dart';
import 'package:rpl_notepad_fe/core/network/api_sevice.dart';
import 'package:rpl_notepad_fe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rpl_notepad_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:rpl_notepad_fe/features/auth/domain/usecases/login_usecase.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';

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

  // View Models 
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(useCase: getIt<LoginUseCase>()),
  );
}
