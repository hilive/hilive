import 'package:uuid/uuid.dart';
import '../models/user.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  final _uuid = const Uuid();
  final Map<String, User> _users = {};
  final Map<String, String> _emailIndex = {}; // email -> userId

  User? findById(String id) => _users[id];

  User? findByEmail(String email) {
    final userId = _emailIndex[email.toLowerCase()];
    if (userId == null) return null;
    return _users[userId];
  }

  bool emailExists(String email) => _emailIndex.containsKey(email.toLowerCase());

  User create({
    required String email,
    required String username,
    required String passwordHash,
  }) {
    final id = _uuid.v4();
    final now = DateTime.now();
    final user = User(
      id: id,
      email: email.toLowerCase(),
      username: username,
      passwordHash: passwordHash,
      createdAt: now,
    );
    _users[id] = user;
    _emailIndex[email.toLowerCase()] = id;
    return user;
  }

  User? update(String id, {String? username, String? avatarUrl}) {
    final user = _users[id];
    if (user == null) return null;

    final updatedUser = user.copyWith(
      username: username,
      avatarUrl: avatarUrl,
      updatedAt: DateTime.now(),
    );
    _users[id] = updatedUser;
    return updatedUser;
  }

  bool delete(String id) {
    final user = _users[id];
    if (user == null) return false;
    _emailIndex.remove(user.email);
    _users.remove(id);
    return true;
  }

  List<User> findAll() => _users.values.toList();
}
