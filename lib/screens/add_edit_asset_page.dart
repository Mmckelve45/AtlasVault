import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:atlasvault/models/asset.dart';
import 'package:atlasvault/models/category.dart';
import 'package:atlasvault/services/asset_service.dart';
import 'package:atlasvault/services/category_service.dart';
import 'package:atlasvault/services/user_service.dart';
import 'package:atlasvault/widgets/custom_button.dart';

class AddEditAssetPage extends StatefulWidget {
  final Asset? asset;

  const AddEditAssetPage({
    super.key,
    this.asset,
  });

  @override
  State<AddEditAssetPage> createState() => _AddEditAssetPageState();
}

class _AddEditAssetPageState extends State<AddEditAssetPage> {
  final _formKey = GlobalKey<FormState>();
  final AssetService _assetService = AssetService();
  final CategoryService _categoryService = CategoryService();
  final UserService _userService = UserService();
  
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _valueController;
  late final TextEditingController _serialNumberController;
  late final TextEditingController _locationController;
  late final TextEditingController _vendorController;
  
  List<Category> _categories = [];
  String? _selectedCategoryId;
  AssetStatus _selectedStatus = AssetStatus.active;
  DateTime _selectedPurchaseDate = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingData = true;

  bool get _isEditing => widget.asset != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    final asset = widget.asset;
    
    _nameController = TextEditingController(text: asset?.name ?? '');
    _descriptionController = TextEditingController(text: asset?.description ?? '');
    _valueController = TextEditingController(text: asset?.value.toString() ?? '');
    _serialNumberController = TextEditingController(text: asset?.serialNumber ?? '');
    _locationController = TextEditingController(text: asset?.location ?? '');
    _vendorController = TextEditingController(text: asset?.vendor ?? '');
    
    if (asset != null) {
      _selectedCategoryId = asset.categoryId;
      _selectedStatus = asset.status;
      _selectedPurchaseDate = asset.purchaseDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _serialNumberController.dispose();
    _locationController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _categories = categories;
        if (_selectedCategoryId == null && categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _selectPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedPurchaseDate = picked;
      });
    }
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _userService.getCurrentUser();
      if (user == null) throw Exception('User not found');

      final now = DateTime.now();
      final asset = Asset(
        id: widget.asset?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        value: double.parse(_valueController.text),
        serialNumber: _serialNumberController.text.trim().isEmpty 
            ? null 
            : _serialNumberController.text.trim(),
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        status: _selectedStatus,
        purchaseDate: _selectedPurchaseDate,
        vendor: _vendorController.text.trim().isEmpty 
            ? null 
            : _vendorController.text.trim(),
        image: widget.asset?.image,
        userId: user.id,
        createdAt: widget.asset?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await _assetService.updateAsset(asset);
      } else {
        await _assetService.addAsset(asset);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving asset: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Asset' : 'Add Asset',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Text(
                'Basic Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _CustomTextField(
                controller: _nameController,
                label: 'Asset Name',
                hint: 'Enter asset name',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter an asset name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter asset description',
                maxLines: 3,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Financial Information
              Text(
                'Financial Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _CustomTextField(
                controller: _valueController,
                label: 'Value (\$)',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter a value';
                  }
                  final parsed = double.tryParse(value!);
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _selectPurchaseDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Purchase Date',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_selectedPurchaseDate.day}/${_selectedPurchaseDate.month}/${_selectedPurchaseDate.year}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Classification
              Text(
                'Classification',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    hint: const Text('Select category'),
                    isExpanded: true,
                    items: _categories.map((category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AssetStatus>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: AssetStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name.replaceFirst(
                        status.name[0], 
                        status.name[0].toUpperCase(),
                      )),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Additional Details
              Text(
                'Additional Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _CustomTextField(
                controller: _serialNumberController,
                label: 'Serial Number',
                hint: 'Enter serial number (optional)',
              ),
              const SizedBox(height: 16),

              _CustomTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Enter location (optional)',
              ),
              const SizedBox(height: 16),

              _CustomTextField(
                controller: _vendorController,
                label: 'Vendor',
                hint: 'Enter vendor name (optional)',
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      style: CustomButtonStyle.outline,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: _isEditing ? 'Update Asset' : 'Create Asset',
                      isLoading: _isLoading,
                      onPressed: _saveAsset,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}