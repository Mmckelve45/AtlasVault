import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:atlasvault/models/asset.dart';
import 'package:atlasvault/models/category.dart';
import 'package:atlasvault/services/asset_service.dart';
import 'package:atlasvault/services/category_service.dart';
import 'package:atlasvault/widgets/asset_card.dart';
import 'package:atlasvault/widgets/custom_button.dart';
import 'package:atlasvault/screens/asset_details_page.dart';
import 'package:atlasvault/screens/add_edit_asset_page.dart';

class AssetsListPage extends StatefulWidget {
  const AssetsListPage({super.key});

  @override
  State<AssetsListPage> createState() => _AssetsListPageState();
}

class _AssetsListPageState extends State<AssetsListPage> {
  final AssetService _assetService = AssetService();
  final CategoryService _categoryService = CategoryService();
  
  List<Asset> _assets = [];
  List<Asset> _filteredAssets = [];
  List<Category> _categories = [];
  String _searchQuery = '';
  String? _selectedCategoryId;
  AssetStatus? _selectedStatus;
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final assets = await _assetService.getAllAssets();
      final categories = await _categoryService.getAllCategories();
      
      setState(() {
        _assets = assets;
        _categories = categories;
        _isLoading = false;
      });
      
      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Asset> filtered = _assets;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((asset) =>
        asset.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        asset.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply category filter
    if (_selectedCategoryId != null) {
      filtered = filtered.where((asset) => asset.categoryId == _selectedCategoryId).toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered.where((asset) => asset.status == _selectedStatus).toList();
    }

    setState(() {
      _filteredAssets = filtered;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        categories: _categories,
        selectedCategoryId: _selectedCategoryId,
        selectedStatus: _selectedStatus,
        onCategoryChanged: (categoryId) {
          setState(() {
            _selectedCategoryId = categoryId;
          });
          _applyFilters();
        },
        onStatusChanged: (status) {
          setState(() {
            _selectedStatus = status;
          });
          _applyFilters();
        },
        onClearFilters: () {
          setState(() {
            _selectedCategoryId = null;
            _selectedStatus = null;
          });
          _applyFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Assets',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_selectedCategoryId != null || _selectedStatus != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF374151)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Search assets...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _applyFilters();
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          // Assets Grid
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _filteredAssets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty || _selectedCategoryId != null || _selectedStatus != null
                                  ? Icons.search_off
                                  : Icons.inventory_2_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _selectedCategoryId != null || _selectedStatus != null
                                  ? 'No assets match your filters'
                                  : 'No assets found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'Add Asset',
                              icon: Icons.add,
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddEditAssetPage(),
                                  ),
                                );
                                _loadData();
                              },
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          itemCount: _filteredAssets.length,
                          itemBuilder: (context, index) {
                            final asset = _filteredAssets[index];
                            return AssetCard(
                              asset: asset,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AssetDetailsPage(assetId: asset.id),
                                  ),
                                );
                                _loadData();
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditAssetPage(),
            ),
          );
          _loadData();
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final AssetStatus? selectedStatus;
  final Function(String?) onCategoryChanged;
  final Function(AssetStatus?) onStatusChanged;
  final VoidCallback onClearFilters;

  const _FilterBottomSheet({
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedStatus,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  onClearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category Filter
          Text(
            'Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedCategoryId == null,
                onSelected: (selected) {
                  onCategoryChanged(null);
                },
              ),
              ...categories.map((category) => FilterChip(
                label: Text(category.name),
                selected: selectedCategoryId == category.id,
                onSelected: (selected) {
                  onCategoryChanged(selected ? category.id : null);
                },
              )),
            ],
          ),
          const SizedBox(height: 24),

          // Status Filter
          Text(
            'Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedStatus == null,
                onSelected: (selected) {
                  onStatusChanged(null);
                },
              ),
              ...AssetStatus.values.map((status) => FilterChip(
                label: Text(status.name.replaceFirst(status.name[0], status.name[0].toUpperCase())),
                selected: selectedStatus == status,
                onSelected: (selected) {
                  onStatusChanged(selected ? status : null);
                },
              )),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}