import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:atlasvault/models/asset.dart';
import 'package:atlasvault/services/category_service.dart';
import 'package:atlasvault/services/user_service.dart';

class AssetService {
  static const String _assetsKey = 'assets';
  static const _uuid = Uuid();
  final CategoryService _categoryService = CategoryService();
  final UserService _userService = UserService();

  Future<List<Asset>> getAllAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final assetsJson = prefs.getStringList(_assetsKey);
    
    if (assetsJson != null && assetsJson.isNotEmpty) {
      return assetsJson
          .map((json) => Asset.fromJson(jsonDecode(json)))
          .toList();
    }
    
    // Initialize with sample assets
    final sampleAssets = await _getSampleAssets();
    await _saveAssets(sampleAssets);
    return sampleAssets;
  }

  Future<Asset?> getAssetById(String id) async {
    final assets = await getAllAssets();
    try {
      return assets.firstWhere((asset) => asset.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Asset>> getAssetsByCategory(String categoryId) async {
    final assets = await getAllAssets();
    return assets.where((asset) => asset.categoryId == categoryId).toList();
  }

  Future<List<Asset>> searchAssets(String query) async {
    final assets = await getAllAssets();
    final lowercaseQuery = query.toLowerCase();
    return assets.where((asset) =>
      asset.name.toLowerCase().contains(lowercaseQuery) ||
      asset.description.toLowerCase().contains(lowercaseQuery) ||
      (asset.serialNumber?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      (asset.location?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  Future<void> addAsset(Asset asset) async {
    final assets = await getAllAssets();
    assets.add(asset);
    await _saveAssets(assets);
  }

  Future<void> updateAsset(Asset asset) async {
    final assets = await getAllAssets();
    final index = assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      assets[index] = asset.copyWith(updatedAt: DateTime.now());
      await _saveAssets(assets);
    }
  }

  Future<void> deleteAsset(String id) async {
    final assets = await getAllAssets();
    assets.removeWhere((asset) => asset.id == id);
    await _saveAssets(assets);
  }

  Future<double> getTotalAssetValue() async {
    final assets = await getAllAssets();
    return assets.fold<double>(0.0, (sum, asset) => sum + asset.value);
  }

  Future<Map<AssetStatus, int>> getAssetStatusCounts() async {
    final assets = await getAllAssets();
    final statusCounts = <AssetStatus, int>{};
    
    for (final status in AssetStatus.values) {
      statusCounts[status] = assets.where((asset) => asset.status == status).length;
    }
    
    return statusCounts;
  }

  Future<void> _saveAssets(List<Asset> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final assetsJson = assets
        .map((asset) => jsonEncode(asset.toJson()))
        .toList();
    await prefs.setStringList(_assetsKey, assetsJson);
  }

  Future<List<Asset>> _getSampleAssets() async {
    final categories = await _categoryService.getAllCategories();
    final user = await _userService.getCurrentUser();
    final now = DateTime.now();
    
    if (categories.isEmpty || user == null) return [];

    return [
      Asset(
        id: _uuid.v4(),
        name: 'MacBook Pro 16"',
        description: 'High-performance laptop for development work',
        categoryId: categories[0].id, // Electronics
        value: 2499.99,
        serialNumber: 'MBP2023001',
        location: 'Office - Developer Desk',
        status: AssetStatus.active,
        purchaseDate: DateTime(2023, 6, 15),
        vendor: 'Apple Inc.',
        image: null,
        userId: user.id,
        createdAt: now,
        updatedAt: now,
      ),
      Asset(
        id: _uuid.v4(),
        name: 'Ergonomic Office Chair',
        description: 'Herman Miller Aeron chair with lumbar support',
        categoryId: categories[1].id, // Furniture
        value: 1395.00,
        serialNumber: 'HM-AERON-001',
        location: 'Office - Workstation 1',
        status: AssetStatus.active,
        purchaseDate: DateTime(2023, 3, 10),
        vendor: 'Herman Miller',
        image: null,
        userId: user.id,
        createdAt: now,
        updatedAt: now,
      ),
      Asset(
        id: _uuid.v4(),
        name: 'Company Vehicle - Tesla Model Y',
        description: 'Electric vehicle for business travel',
        categoryId: categories[2].id, // Vehicles
        value: 52990.00,
        serialNumber: 'TESLA-MY-2023',
        location: 'Parking Garage - Level 2',
        status: AssetStatus.active,
        purchaseDate: DateTime(2023, 8, 22),
        vendor: 'Tesla Motors',
        image: null,
        userId: user.id,
        createdAt: now,
        updatedAt: now,
      ),
      Asset(
        id: _uuid.v4(),
        name: '3D Printer - Ultimaker S5',
        description: 'Professional 3D printer for prototyping',
        categoryId: categories[3].id, // Equipment
        value: 6495.00,
        serialNumber: 'UM-S5-2023-001',
        location: 'Lab - Prototyping Room',
        status: AssetStatus.maintenance,
        purchaseDate: DateTime(2023, 4, 5),
        vendor: 'Ultimaker',
        image: null,
        userId: user.id,
        createdAt: now,
        updatedAt: now,
      ),
      Asset(
        id: _uuid.v4(),
        name: 'Adobe Creative Suite License',
        description: 'Annual license for design and creative work',
        categoryId: categories[4].id, // Software
        value: 599.88,
        serialNumber: 'ADOBE-CC-2023',
        location: 'Digital License',
        status: AssetStatus.active,
        purchaseDate: DateTime(2023, 1, 1),
        vendor: 'Adobe Systems',
        image: null,
        userId: user.id,
        createdAt: now,
        updatedAt: now,
      ),
      Asset(
        id: _uuid.v4(),
        name: 'Dell UltraSharp 32" Monitor',
        description: '4K monitor for enhanced productivity',
        categoryId: categories[0].id, // Electronics
        value: 799.99,
        serialNumber: 'DELL-U3223QE-001',
        location: 'Office - Developer Desk',
        status: AssetStatus.active,
        purchaseDate: DateTime(2023, 7, 12),
        vendor: 'Dell Technologies',
        image: null,
        userId: user.id,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}