class ApiConstants {
  // Base URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
  
  // Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authVerifyPhone = '/auth/verify-phone';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  
  static const String incidents = '/incidents';
  static const String incidentHeatmap = '/incidents/heatmap';
  static const String incidentCorroborate = '/incidents'; // POST /incidents/:id/corroborate
  
  static const String circles = '/circles';
  static const String circleMembers = '/circles'; // GET /circles/:id/members
  
  static const String contacts = '/contacts';
  
  static const String routes = '/routes';
  
  static const String notifications = '/notifications';
  
  static const String users = '/users';
  static const String userTrustScore = '/users'; // GET /users/:id/trust
  
  // Admin
  static const String adminModerationQueue = '/admin/moderation/queue';
  static const String adminModerationApprove = '/admin/moderation/queue'; // PUT /admin/moderation/queue/:id/approve
  static const String adminModerationReject = '/admin/moderation/queue'; // PUT /admin/moderation/queue/:id/reject
  
  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer ';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Status Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int tooManyRequests = 429;
  static const int internalServerError = 500;
  static const int serviceUnavailable = 503;
}
