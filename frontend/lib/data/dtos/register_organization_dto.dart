class RegisterOrganizationDto {
  final String organizationName;
  final String? organizationAddress;
  final String adminFirstName;
  final String adminLastName;
  final String adminEmail;
  final String adminPassword;

  RegisterOrganizationDto({
    required this.organizationName,
    this.organizationAddress,
    required this.adminFirstName,
    required this.adminLastName,
    required this.adminEmail,
    required this.adminPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'organizationName': organizationName,
      'organizationAddress': organizationAddress,
      'adminFirstName': adminFirstName,
      'adminLastName': adminLastName,
      'adminEmail': adminEmail,
      'adminPassword': adminPassword,
    };
  }
}