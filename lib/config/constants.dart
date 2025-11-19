class AppConstants {
  // Prevenir instanciación
  AppConstants._();
  
  // ==================== API ====================
  static const String baseUrl = 'https://evalplus-api.emprenet.work/api';
  static const String authUrl = '$baseUrl/auth';
  static const String microsoftAuthUrl = '$authUrl/microsoft';
  static const String profileUrl = '$authUrl/profile';
  
  // ==================== STORAGE KEYS ====================
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isNewUserKey = 'is_new_user';
  static const String userProfileKey = 'user_profile';
  
  // ==================== TIMEOUTS ====================
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // ==================== DIMENSIONES ====================
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // ==================== APP INFO ====================
  static const String appName = 'Eval+';
  static const String appVersion = '1.0.0';
  
  // ==================== NAVEGACIÓN ====================
  static const List<String> navBarLabels = [
    'Carreras',
    'Evaluaciones',
    'Perfil',
  ];
}
