import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:atlasvault/models/user.dart';

class UserService {
  static const String _userKey = 'current_user';
  static const _uuid = Uuid();

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    
    // Create default user if none exists
    final defaultUser = User(
      id: _uuid.v4(),
      name: 'John Anderson',
      email: 'john.anderson@company.com',
      avatar: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _saveUser(defaultUser);
    return defaultUser;
  }

  Future<void> updateUser(User user) async {
    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    await _saveUser(updatedUser);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}