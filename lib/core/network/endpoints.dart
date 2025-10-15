class Endpoints {
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String verifyRegisterOtp = '/api/auth/verify-register-otp';
  static const String resetPassword = '/api/auth/reset-password';
  static const String requestPasswordReset = '/api/auth/request-password-reset';
  static const String verifyResetPasswordOtp =
      '/api/auth/verify-reset-password-otp';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String resendRegisterOtp = '/api/auth/resend-register-otp';
  static const String me = '/api/auth/me';
  static const String changePassword = '/api/auth/change-password';
  static const String updateProfile = '/api/user/update';

  // Schedule endpoints
  static const String getSchedulesByParticipant =
      '/api/schedule/participant/schedules';
  static String getScheduleById(String scheduleId) => '/api/schedule/$scheduleId';
  static String getActivitiesBySchedule(String scheduleId, String date) =>
      '/api/schedule/$scheduleId/activities/date(dd-MM-yyyy)/$date';
  static const String shareSchedule = '/api/schedule/share';
  static const String createSchedule = '/api/schedule/create';
  static const String updateSchedule = '/api/schedule/schedule';
  static const String addActivity = '/api/schedule/activity/add';
  static const String activities = '/api/schedule/activities';
  static const String joinSchedule = '/api/schedule/join';
  static String getScheduleParticipants(String scheduleId) => '/api/schedule/participants/$scheduleId';
  static String addParticipantByEmail(String scheduleId) => '/api/schedule/$scheduleId/add-participants-by-email';
  static String kickParticipant(String scheduleId, String participantId) => '/api/schedule/$scheduleId/kick/$participantId';
  static String changeParticipantRole(String scheduleId, String participantId) => '/api/schedule/$scheduleId/change-role/$participantId';
}
