enum AssetStatus { active, inactive, maintenance, disposed }

class Asset {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final double value;
  final String? serialNumber;
  final String? location;
  final AssetStatus status;
  final DateTime purchaseDate;
  final String? vendor;
  final String? image;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Asset({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.value,
    this.serialNumber,
    this.location,
    required this.status,
    required this.purchaseDate,
    this.vendor,
    this.image,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'categoryId': categoryId,
    'value': value,
    'serialNumber': serialNumber,
    'location': location,
    'status': status.name,
    'purchaseDate': purchaseDate.toIso8601String(),
    'vendor': vendor,
    'image': image,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    categoryId: json['categoryId'],
    value: json['value'].toDouble(),
    serialNumber: json['serialNumber'],
    location: json['location'],
    status: AssetStatus.values.firstWhere((e) => e.name == json['status']),
    purchaseDate: DateTime.parse(json['purchaseDate']),
    vendor: json['vendor'],
    image: json['image'],
    userId: json['userId'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Asset copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    double? value,
    String? serialNumber,
    String? location,
    AssetStatus? status,
    DateTime? purchaseDate,
    String? vendor,
    String? image,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Asset(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    categoryId: categoryId ?? this.categoryId,
    value: value ?? this.value,
    serialNumber: serialNumber ?? this.serialNumber,
    location: location ?? this.location,
    status: status ?? this.status,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    vendor: vendor ?? this.vendor,
    image: image ?? this.image,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String get statusDisplayName {
    switch (status) {
      case AssetStatus.active:
        return 'Active';
      case AssetStatus.inactive:
        return 'Inactive';
      case AssetStatus.maintenance:
        return 'Maintenance';
      case AssetStatus.disposed:
        return 'Disposed';
    }
  }
}