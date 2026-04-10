class PartnerServiceItem {
  PartnerServiceItem({
    required this.id,
    required this.title,
    required this.partnerName,
    required this.description,
    this.validUntil,
  });

  final String id;
  final String title;
  final String partnerName;
  final String description;
  final DateTime? validUntil;

  factory PartnerServiceItem.fromJson(Map<String, dynamic> json) {
    return PartnerServiceItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      partnerName: json['partnerName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      validUntil: json['validUntil'] != null
          ? DateTime.tryParse(json['validUntil'].toString())
          : null,
    );
  }
}
