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
  static String cancelSchedule(String scheduleId) => '/api/schedule/schedule/$scheduleId/cancel';
  static String restoreSchedule(String scheduleId) => '/api/schedule/schedule/$scheduleId/restore';
  static const String addActivity = '/api/schedule/activity/add';
  static const String activities = '/api/schedule/activities';
  static const String joinSchedule = '/api/schedule/join';
  static String getScheduleParticipants(String scheduleId) => '/api/schedule/participants/$scheduleId';
  static String addParticipantByEmail(String scheduleId) => '/api/schedule/$scheduleId/add-participants-by-email';
  static String kickParticipant(String scheduleId, String participantId) => '/api/schedule/$scheduleId/kick/$participantId';
  static String leaveParticipant(String scheduleId, String userId) => '/api/schedule/$scheduleId/leave/$userId';
  static String changeParticipantRole(String scheduleId, String participantId) => '/api/schedule/$scheduleId/change-role/$participantId';
  static String reorderActivity(int newIndex, int activityId) => '/api/schedule/activities/$newIndex/$activityId';
  
  // Checked items endpoints
  static String getCheckedItems(String scheduleId) => '/api/schedule/checked-items/get-by-current?scheduleId=$scheduleId';
  static const String addCheckedItem = '/api/schedule/checked-items/add';
  static String toggleCheckedItem(int checkedItemId, bool isChecked) => '/api/schedule/checkitems/$checkedItemId/participants/toggle?isChecked=$isChecked';
  static const String deleteCheckedItemsBulk = '/api/schedule/checkitems/bulk';
  
  // Check-in/Check-out endpoints
  static const String checkIn = '/api/schedule/activities/check-in';
  static const String checkOut = '/api/schedule/activities/check-out';
  
  // Media endpoints
  static String getMediaByActivityId(int activityId) => '/api/schedule/media/get-by-activityId?activityId=$activityId';
  static const String uploadMedia = '/api/schedule/media/upload';
  
  // Advertisement endpoints
  static const String getAllPackages = '/api/advertisement/package/get-all';
  static const String getAllPosts = '/api/advertisement/post/all';
  static String getPurchasedPackagesByPartner(String partnerId) => '/api/advertisement/partner/purchase/get-by-partnerId/$partnerId';
  static String getPostById(String postId) => '/api/advertisement/partner/post/get-by-id/$postId';
  static const String createPost = '/api/advertisement/partner/post/create';
  static const String createPayment = '/api/payment/create';
  static const String getPaymentStatus = '/api/payment/transaction/status/by-id';
}
