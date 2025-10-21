import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/api_client.dart';
import 'core/network/dio_factory.dart';
import 'core/network/network_info.dart';
import 'core/utils/token_storage.dart';

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
import 'features/schedule/data/datasources/mapbox_geocoding_datasource.dart';
import 'features/schedule/data/repositories/schedule_repositories_impl.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'features/schedule/domain/usecases/get_schedules_by_participant_usecase.dart';
import 'features/schedule/domain/usecases/get_schedule_by_id_usecase.dart';
import 'features/schedule/domain/usecases/get_activities_by_schedule_usecase.dart';
import 'features/schedule/domain/usecases/share_schedule_usecase.dart';
import 'features/schedule/domain/usecases/create_schedule_usecase.dart';
import 'features/schedule/domain/usecases/update_schedule_usecase.dart';
import 'features/schedule/domain/usecases/create_activity_usecase.dart';
import 'features/schedule/domain/usecases/update_activity_usecase.dart';
import 'features/schedule/domain/usecases/delete_activity_usecase.dart';
import 'features/schedule/domain/usecases/join_schedule_usecase.dart';
import 'features/schedule/domain/usecases/get_schedule_participants_usecase.dart';
import 'features/schedule/domain/usecases/add_participant_by_email_usecase.dart';
import 'features/schedule/presentation/bloc/schedule_bloc.dart';
import 'features/schedule/domain/usecases/kick_participant_usecase.dart';
import 'features/schedule/domain/usecases/leave_schedule_usecase.dart';
import 'features/schedule/domain/usecases/change_participant_role_usecase.dart';
import 'features/schedule/domain/usecases/reorder_activity_usecase.dart';
import 'features/schedule/domain/usecases/get_checked_items_usecase.dart';
import 'features/schedule/domain/usecases/add_checked_item_usecase.dart';
import 'features/schedule/domain/usecases/toggle_checked_item_usecase.dart';
import 'features/schedule/domain/usecases/delete_checked_item_usecase.dart';
import 'features/schedule/domain/usecases/cancel_schedule_usecase.dart';
import 'features/schedule/domain/usecases/restore_schedule_usecase.dart';
import 'features/schedule/domain/usecases/checkin_activity_usecase.dart';
import 'features/schedule/domain/usecases/checkout_activity_usecase.dart';
import 'features/schedule/domain/usecases/get_media_by_activity_usecase.dart';
import 'features/schedule/domain/usecases/upload_media_usecase.dart';
import 'features/schedule/domain/usecases/search_address_usecase.dart';

// Advertisement feature
import 'features/advertisement/data/datasources/advertisement_remote_datasource.dart';
import 'features/advertisement/data/repositories/advertisement_repositories_impl.dart';
import 'features/advertisement/domain/repositories/advertisement_repositories.dart';
import 'features/advertisement/domain/usecases/get_all_packages.dart';
import 'features/advertisement/domain/usecases/get_all_posts.dart';
import 'features/advertisement/domain/usecases/get_post_by_id.dart';
import 'features/advertisement/domain/usecases/create_post.dart';
import 'features/advertisement/domain/usecases/create_payment.dart';
import 'features/advertisement/domain/usecases/get_payment_status.dart';
import 'features/advertisement/domain/usecases/cancel_payment.dart';
import 'features/advertisement/presentation/bloc/advertisement_bloc.dart';

// Notification feature
import 'features/notification/data/datasources/notification_remote_datasource.dart';
import 'features/notification/data/repositories/notification_repository_impl.dart';
import 'features/notification/domain/repositories/notification_repository.dart';
import 'features/notification/domain/usecases/get_notifications_usecase.dart';
import 'features/notification/domain/usecases/mark_notification_as_read_usecase.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  // Warm token caches before creating Dio
  await TokenStorage.init();
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

  // Features - Advertisement
  _initAdvertisement();

  // Features - Notification
  _initNotification();
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
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // Bloc
  sl.registerFactory(() => UserBloc(updateProfileUseCase: sl()));
}

void _initSchedule() {
  // Data sources
  sl.registerLazySingleton<MapboxGeocodingDataSource>(
    () => MapboxGeocodingDataSourceImpl(dio: sl()),
  );
  
  sl.registerLazySingleton<ScheduleRemoteDataSource>(
    () => ScheduleRemoteDataSourceImpl(
      apiClient: sl(),
      mapboxDataSource: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSchedulesByParticipant(sl()));
  sl.registerLazySingleton(() => GetScheduleById(sl()));
  sl.registerLazySingleton(() => GetActivitiesBySchedule(sl()));
  sl.registerLazySingleton(() => ShareSchedule(sl()));
  sl.registerLazySingleton(() => CreateSchedule(sl()));
  sl.registerLazySingleton(() => UpdateSchedule(sl()));
  sl.registerLazySingleton(() => CreateActivity(sl()));
  sl.registerLazySingleton(() => UpdateActivity(sl()));
  sl.registerLazySingleton(() => DeleteActivity(sl()));
  sl.registerLazySingleton(() => JoinSchedule(sl()));
  sl.registerLazySingleton(() => GetScheduleParticipants(sl()));
  sl.registerLazySingleton(() => AddParticipantByEmail(sl()));
  sl.registerLazySingleton(() => KickParticipant(sl()));
  sl.registerLazySingleton(() => LeaveSchedule(sl()));
  sl.registerLazySingleton(() => ChangeParticipantRole(sl()));
  sl.registerLazySingleton(() => ReorderActivity(sl()));
  sl.registerLazySingleton(() => GetCheckedItemsUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddCheckedItemUseCase(repository: sl()));
  sl.registerLazySingleton(() => ToggleCheckedItemUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteCheckedItemsBulkUseCase(repository: sl()));
  sl.registerLazySingleton(() => CancelScheduleUseCase(repository: sl()));
  sl.registerLazySingleton(() => RestoreScheduleUseCase(repository: sl()));
  sl.registerLazySingleton(() => CheckInActivityUseCase(repository: sl()));
  sl.registerLazySingleton(() => CheckOutActivityUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetMediaByActivityUseCase(repository: sl()));
  sl.registerLazySingleton(() => UploadMediaUseCase(repository: sl()));
  sl.registerLazySingleton(() => SearchAddressUseCase(sl()));
  sl.registerLazySingleton(() => SearchAddressStructuredUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ScheduleBloc(
      getSchedulesByParticipant: sl(),
      getScheduleById: sl(),
      getActivitiesBySchedule: sl(),
      shareSchedule: sl(),
      createSchedule: sl(),
      updateSchedule: sl(),
      createActivity: sl(),
      updateActivity: sl(),
      deleteActivity: sl(),
      joinSchedule: sl(),
      getScheduleParticipants: sl(),
      addParticipantByEmail: sl(),
      kickParticipant: sl(),
      leaveSchedule: sl(),
      changeParticipantRole: sl(),
      reorderActivity: sl(),
      getCheckedItems: sl(),
      addCheckedItem: sl(),
      toggleCheckedItem: sl(),
      deleteCheckedItemsBulk: sl(),
      cancelSchedule: sl(),
      restoreSchedule: sl(),
      checkInActivity: sl(),
      checkOutActivity: sl(),
      getMediaByActivity: sl(),
      uploadMedia: sl(),
      searchAddress: sl(),
      searchAddressStructured: sl(),
    ),
  );
}

void _initAdvertisement() {
  // Data sources
  sl.registerLazySingleton<AdvertisementRemoteDataSource>(
    () => AdvertisementRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AdvertisementRepository>(
    () => AdvertisementRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllPackages(sl()));
  sl.registerLazySingleton(() => GetPurchasedPackagesByPartner(sl()));
  sl.registerLazySingleton(() => GetAllPosts(sl()));
  sl.registerLazySingleton(() => GetPostById(sl()));
  sl.registerLazySingleton(() => CreatePost(sl()));
  sl.registerLazySingleton(() => CreatePayment(sl()));
  sl.registerLazySingleton(() => GetPaymentStatus(sl()));
  sl.registerLazySingleton(() => CancelPayment(sl()));

  // Bloc
  sl.registerLazySingleton(
    () => AdvertisementBloc(
      getAllPackages: sl(),
      getAllPosts: sl(),
      getPostById: sl(),
      createPost: sl(),
      createPayment: sl(),
      getPaymentStatus: sl(),
      cancelPayment: sl(),
      getPurchasedPackagesByPartner: sl(),
    ),
  );
}

void _initNotification() {
  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(repository: sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(repository: sl()));

  // Bloc
  sl.registerFactory(
    () => NotificationBloc(
      getNotificationsUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
    ),
  );
}
