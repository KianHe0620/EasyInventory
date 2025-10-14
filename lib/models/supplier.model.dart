class Supplier {
  final String id;
  String name;
  String phone;
  String email;
  String address;

  Supplier({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  Supplier copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}
