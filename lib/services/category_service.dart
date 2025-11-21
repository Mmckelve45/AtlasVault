import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:atlasvault/models/category.dart';

class CategoryService {
  static const String _categoriesKey = 'categories';
  static const _uuid = Uuid();

  Future<List<Category>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getStringList(_categoriesKey);
    
    if (categoriesJson != null && categoriesJson.isNotEmpty) {
      return categoriesJson
          .map((json) => Category.fromJson(jsonDecode(json)))
          .toList();
    }
    
    // Initialize with sample categories
    final sampleCategories = _getSampleCategories();
    await _saveCategories(sampleCategories);
    return sampleCategories;
  }

  Future<Category?> getCategoryById(String id) async {
    final categories = await getAllCategories();
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCategory(Category category) async {
    final categories = await getAllCategories();
    categories.add(category);
    await _saveCategories(categories);
  }

  Future<void> updateCategory(Category category) async {
    final categories = await getAllCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category.copyWith(updatedAt: DateTime.now());
      await _saveCategories(categories);
    }
  }

  Future<void> deleteCategory(String id) async {
    final categories = await getAllCategories();
    categories.removeWhere((category) => category.id == id);
    await _saveCategories(categories);
  }

  Future<void> _saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = categories
        .map((category) => jsonEncode(category.toJson()))
        .toList();
    await prefs.setStringList(_categoriesKey, categoriesJson);
  }

  List<Category> _getSampleCategories() {
    final now = DateTime.now();
    return [
      Category(
        id: _uuid.v4(),
        name: 'Electronics',
        description: 'Computer equipment, devices, and electronic assets',
        icon: 'laptop',
        color: '3B82F6',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Furniture',
        description: 'Office furniture and workspace equipment',
        icon: 'chair',
        color: '059669',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Vehicles',
        description: 'Company vehicles and transportation assets',
        icon: 'car',
        color: 'DC2626',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Equipment',
        description: 'Machinery and specialized equipment',
        icon: 'tools',
        color: 'F59E0B',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Software',
        description: 'Software licenses and digital assets',
        icon: 'code',
        color: '8B5CF6',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}