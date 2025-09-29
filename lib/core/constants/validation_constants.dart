
class ValidationConstants {
  // Email validation
  static const String emailPattern = 
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  
  // Phone number validation (Vietnamese format)
  static const String phonePattern = 
      r'^(\+84|84|0)[1-9][0-9]{8,9}$';
  
  // Password validation
  static const String passwordPattern = 
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]';
  
  // Name validation (letters, spaces, and common characters)
  static const String namePattern = 
      r'^[a-zA-Z\s\-]+$';
  
  // Address validation (letters, numbers, spaces, and common punctuation)
  static const String addressPattern = 
      r'^[a-zA-Z0-9\s\.,\-\/]+$';
  
  // OTP validation (6 digits)
  static const String otpPattern = r'^\d{6}$';
  
  // Date format patterns
  static const String datePattern = r'^\d{2}/\d{2}/\d{4}$';
  static const String isoDatePattern = r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}';
  
  // URL validation
  static const String urlPattern = 
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  
  // File extension patterns
  static const String imageExtensionPattern = r'\.(jpg|jpeg|png|gif|webp)$';
  static const String documentExtensionPattern = r'\.(pdf|doc|docx|txt)$';
  
  // Vietnamese text patterns
  static const String vietnameseTextPattern = 
      r'^[a-zA-Z\s\.,\-\/]+$';
  
  // Length constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int otpLength = 6;
  static const int maxAddressLength = 200;
}

/// Validation error messages
class ValidationMessages {
  // Email validation messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String emailTooLong = 'Email is too long';
  
  // Password validation messages
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordTooLong = 'Password is too long';
  static const String passwordWeak = 'Password must contain uppercase, lowercase, number and special character';
  static const String passwordMismatch = 'Passwords do not match';
  
  // Name validation messages
  static const String nameRequired = 'Name is required';
  static const String nameTooShort = 'Name must be at least 2 characters';
  static const String nameTooLong = 'Name is too long';
  static const String nameInvalid = 'Name contains invalid characters';
  
  // Phone validation messages
  static const String phoneRequired = 'Phone number is required';
  static const String phoneInvalid = 'Please enter a valid phone number';
  static const String phoneTooShort = 'Phone number is too short';
  static const String phoneTooLong = 'Phone number is too long';
  
  // Address validation messages
  static const String addressRequired = 'Address is required';
  static const String addressTooLong = 'Address is too long';
  static const String addressInvalid = 'Address contains invalid characters';
  
  // OTP validation messages
  static const String otpRequired = 'OTP code is required';
  static const String otpInvalid = 'Please enter a valid 6-digit OTP code';
  static const String otpIncomplete = 'Please enter complete OTP code';
  static const String otpExpired = 'OTP code has expired';
  
  // Date validation messages
  static const String dateRequired = 'Date is required';
  static const String dateInvalid = 'Please enter a valid date';
  static const String dateFuture = 'Date cannot be in the future';
  static const String dateTooOld = 'Date is too old';
  
  // General validation messages
  static const String fieldRequired = 'This field is required';
  static const String fieldTooLong = 'This field is too long';
  static const String fieldTooShort = 'This field is too short';
  static const String fieldInvalid = 'This field contains invalid characters';
  static const String networkError = 'Please check your internet connection';
  static const String serverError = 'Server error. Please try again later';
  static const String unknownError = 'An unexpected error occurred';
}

/// Input field constraints
class InputConstraints {
  // Text field constraints
  static const int maxEmailLength = 254;
  static const int maxNameLength = 50;
  static const int maxPasswordLength = 128;
  static const int maxPhoneLength = 15;
  static const int maxAddressLength = 200;
  static const int maxDescriptionLength = 1000;
  static const int maxCommentLength = 500;
  
  // Numeric field constraints
  static const double minAge = 13;
  static const double maxAge = 120;
  static const double minPrice = 0;
  static const double maxPrice = 999999999;
  
  // File constraints
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB
  
  // Array constraints
  static const int maxTagsCount = 10;
  static const int maxImagesCount = 10;
  static const int maxDocumentsCount = 5;
}