// lib/models/supplier.model.dart
class Supplier {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String photoUrl;

  Supplier({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.photoUrl = '',
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? photoUrl,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory Supplier.fromMap(Map<String, dynamic> m) {
    return Supplier(
      id: (m['id'] ?? '') as String,
      name: (m['name'] ?? '') as String,
      phone: (m['phone'] ?? '') as String,
      email: (m['email'] ?? '') as String,
      address: (m['address'] ?? '') as String,
      photoUrl: (m['photoUrl'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'photoUrl': photoUrl,
      };
}
