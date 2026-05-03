class Company {
  final int id;
  final int fkIdUser;
  final String name;
  final String ruc;
  final String phone;
  final String email;
  final String address;
  final String description;
  final String? logoUrl;

  const Company({
    required this.id,
    this.fkIdUser = 0,
    required this.name,
    this.ruc = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.description = '',
    this.logoUrl,
  });
}
