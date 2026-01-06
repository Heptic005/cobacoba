import 'dart:convert';
import 'package:dakara_weighbridge/Json/user_model.dart';
import 'package:dakara_weighbridge/SQLite/database_helper.dart';
import 'package:crypto/crypto.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  String? _currentShift;

  UserModel? get currentUser => _currentUser;
  String? get currentShift => _currentShift;

  /// Hashes a password using SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Attempts to login with username and password.
  /// Returns existing User model if successful, null otherwise.
  Future<UserModel?> login(
    String username,
    String password,
    String shift,
  ) async {
    final db = DatabaseHelper();
    // Use DatabaseHelper.authenticateUser which handles hashing and migration
    final row = await db.authenticateUser(username, password);
    if (row == null) return null;
    final user = UserModel.fromJson(row);
    _currentUser = user;
    _currentShift = shift;
    return user;
  }

  void logout() {
    _currentUser = null;
    _currentShift = null;
  }

  bool get isLoggedIn => _currentUser != null;

  // Role Checks based on Image/Flowchart
  bool get isManager =>
      _currentUser?.role == 'owner' ||
      _currentUser?.role == 'admin' ||
      _currentUser?.role == 'manager';

  bool get isSupervisor =>
      _currentUser?.role == 'supervisor' || _currentUser?.role == 'ktu';

  bool get isOperator => _currentUser?.role == 'operator';

  // Combinations
  bool get canManageUsers => isManager || isSupervisor;
  bool get canAccessSettings => isManager || isSupervisor;
}
