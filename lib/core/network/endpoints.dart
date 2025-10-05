class Endpoints {
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String verifyRegisterOtp = '/api/auth/verify-register-otp';
  static const String resetPassword = '/api/auth/reset-password';
  static const String requestPasswordReset = '/api/auth/request-password-reset';
  static const String verifyResetPasswordOtp = '/api/auth/verify-reset-password-otp';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String resendRegisterOtp = '/api/auth/resend-register-otp';
  static const String me = '/api/auth/me';
  static const String changePassword = '/api/auth/change-password';
  static const String updateProfile = '/api/user/update';
  
  // Schedule endpoints
  static const String getSchedulesByParticipant = '/api/schedule/participant/schedules';
  static const String getActivitiesBySchedule = '/api/schedule/activities/getAll';
  static const String shareSchedule = '/api/schedule/share';
  static const String createSchedule = '/api/schedule/create';
  static const String updateSchedule = '/api/schedule/schedule';
  static const String addActivity = '/api/schedule/activity/add';
  static const String activities = '/api/schedule/schedule/activities';
}
