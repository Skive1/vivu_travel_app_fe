import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/api_client.dart';
import 'core/network/dio_factory.dart';
import 'core/network/network_info.dart';

// Authentication
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/data/repositories/auth_repositories_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/domain/usecases/login_usecase.dart';
import 'features/authentication/domain/usecases/logout_usecase.dart';
import 'features/authentication/domain/usecases/check_auth_status_usecase.dart';
import 'features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'features/authentication/domain/usecases/get_user_profile_usecase.dart';
// User feature
import 'features/user/data/datasources/user_remote_datasource.dart';
import 'features/user/data/repositories/user_repository_impl.dart';
import 'features/user/domain/repositories/user_repository.dart';
import 'features/user/domain/usecases/update_profile_usecase.dart';
import 'features/user/presentation/bloc/user_bloc.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/domain/usecases/register_usecase.dart';
import 'features/authentication/domain/usecases/verify_register_otp_usecase.dart';
import 'features/authentication/domain/usecases/request_password_reset_usecase.dart';
import 'features/authentication/domain/usecases/verify_reset_password_otp_usecase.dart';
import 'features/authentication/domain/usecases/reset_password_usecase.dart';
import 'features/authentication/domain/usecases/resend_register_otp_usecase.dart';
import 'features/authentication/domain/usecases/change_password_usecase.dart';

// Schedule feature
import 'features/schedule/data/datasources/schedule_remote_datasource.dart';
import 'features/schedule/data/repositories/schedule_repositories_impl.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'features/schedule/domain/usecases/get_schedules_by_participant_usecase.dart';
import 'features/schedule/domain/usecases/get_activities_by_schedule_usecase.dart';
import 'features/schedule/domain/usecases/share_schedule_usecase.dart';
import 'features/schedule/domain/usecases/create_schedule_usecase.dart';
import 'features/schedule/domain/usecases/update_schedule_usecase.dart';
import 'features/schedule/domain/usecases/create_activity_usecase.dart';
import 'features/schedule/domain/usecases/update_activity_usecase.dart';
import 'features/schedule/domain/usecases/delete_activity_usecase.dart';
import 'features/schedule/presentation/bloc/schedule_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<Dio>(() => DioFactory.create());
  sl.registerLazySingleton<ApiClient>(() => ApiClientImpl(sl()));
 
  // Features - Authentication
  _initAuth();

  // Features - Home  
  _initHome();

  // Features - User
  _initUser();

  // Features - Schedule
  _initSchedule();
}

void _initAuth() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => VerifyRegisterOtpUseCase(sl()));
  sl.registerLazySingleton(() => ResendRegisterOtpUseCase(sl()));
  sl.registerLazySingleton(() => RequestPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => VerifyResetPasswordOtpUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      refreshTokenUseCase: sl(),
      registerUseCase: sl(),
      verifyRegisterOtpUseCase: sl(),
      resendRegisterOtpUseCase: sl(),
      requestPasswordResetUseCase: sl(),
      verifyResetPasswordOtpUseCase: sl(),
      resetPasswordUseCase: sl(),
      getUserProfileUseCase: sl(),
      changePasswordUseCase: sl(),
      authRepository: sl(),
    ),
  );
}

void _initHome() {
}

void _initUser() {
  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // Bloc
  sl.registerFactory(() => UserBloc(updateProfileUseCase: sl()));
}

void _initSchedule() {
  // Data sources
  sl.registerLazySingleton<ScheduleRemoteDataSource>(
    () => ScheduleRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSchedulesByParticipant(sl()));
  sl.registerLazySingleton(() => GetActivitiesBySchedule(sl()));
  sl.registerLazySingleton(() => ShareSchedule(sl()));
  sl.registerLazySingleton(() => CreateSchedule(sl()));
  sl.registerLazySingleton(() => UpdateSchedule(sl()));
  sl.registerLazySingleton(() => CreateActivity(sl()));
  sl.registerLazySingleton(() => UpdateActivity(sl()));
  sl.registerLazySingleton(() => DeleteActivity(sl()));

  // Bloc
  sl.registerFactory(
    () => ScheduleBloc(
      getSchedulesByParticipant: sl(),
      getActivitiesBySchedule: sl(),
      shareSchedule: sl(),
      createSchedule: sl(),
      updateSchedule: sl(),
      createActivity: sl(),
      updateActivity: sl(),
      deleteActivity: sl(),
    ),
  );
}
