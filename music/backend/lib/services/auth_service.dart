import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../utils/jwt_utils.dart';
import '../utils/password_utils.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _userRepo = UserRepository();

  ({AuthResponse? response, String? error}) register({
    required String email,
    required String username,
    required String password,
  }) {
    // Validate input
    if (!PasswordUtils.isValidEmail(email)) {
      return (response: null, error: '邮箱格式不正确');
    }
    if (!PasswordUtils.isValidUsername(username)) {
      return (response: null, error: '用户名需要2-20个字符，只能包含字母、数字、下划线或中文');
    }
    if (!PasswordUtils.isValidPassword(password)) {
      return (response: null, error: '密码至少需要6个字符');
    }

    // Check if email exists
    if (_userRepo.emailExists(email)) {
      return (response: null, error: '该邮箱已被注册');
    }

    // Create user
    final passwordHash = PasswordUtils.hashPassword(password);
    final user = _userRepo.create(
      email: email,
      username: username,
      passwordHash: passwordHash,
    );

    // Generate tokens
    final accessToken = JwtUtils.generateAccessToken(user.id);
    final refreshToken = JwtUtils.generateRefreshToken(user.id);

    return (
      response: AuthResponse(
        user: user.toPublicJson(),
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: JwtUtils.accessTokenExpiresIn,
      ),
      error: null,
    );
  }

  ({AuthResponse? response, String? error}) login({
    required String email,
    required String password,
  }) {
    final user = _userRepo.findByEmail(email);
    if (user == null) {
      return (response: null, error: '邮箱或密码错误');
    }

    if (!PasswordUtils.verifyPassword(password, user.passwordHash)) {
      return (response: null, error: '邮箱或密码错误');
    }

    final accessToken = JwtUtils.generateAccessToken(user.id);
    final refreshToken = JwtUtils.generateRefreshToken(user.id);

    return (
      response: AuthResponse(
        user: user.toPublicJson(),
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: JwtUtils.accessTokenExpiresIn,
      ),
      error: null,
    );
  }

  ({AuthResponse? response, String? error}) refresh(String refreshToken) {
    final userId = JwtUtils.verifyRefreshToken(refreshToken);
    if (userId == null) {
      return (response: null, error: '无效的刷新令牌');
    }

    final user = _userRepo.findById(userId);
    if (user == null) {
      return (response: null, error: '用户不存在');
    }

    final newAccessToken = JwtUtils.generateAccessToken(user.id);
    final newRefreshToken = JwtUtils.generateRefreshToken(user.id);

    return (
      response: AuthResponse(
        user: user.toPublicJson(),
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        expiresIn: JwtUtils.accessTokenExpiresIn,
      ),
      error: null,
    );
  }

  User? getUserFromToken(String? authHeader) {
    final token = JwtUtils.extractTokenFromHeader(authHeader);
    if (token == null) return null;

    final userId = JwtUtils.verifyAccessToken(token);
    if (userId == null) return null;

    return _userRepo.findById(userId);
  }
}
