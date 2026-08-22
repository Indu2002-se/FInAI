class DetectionSettingsModel {
  final int id;
  final bool smsEnabled;
  final bool notificationEnabled;
  final bool confirmationRequired;
  final String? updatedAt;

  DetectionSettingsModel({
    required this.id,
    this.smsEnabled = false,
    this.notificationEnabled = false,
    this.confirmationRequired = true,
    this.updatedAt,
  });

  factory DetectionSettingsModel.fromJson(Map<String, dynamic> json) {
    return DetectionSettingsModel(
      id: json['id'] as int? ?? 0,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      notificationEnabled: json['notificationEnabled'] as bool? ?? false,
      confirmationRequired: json['confirmationRequired'] as bool? ?? true,
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'smsEnabled': smsEnabled,
      'notificationEnabled': notificationEnabled,
      'confirmationRequired': confirmationRequired,
    };
  }

  DetectionSettingsModel copyWith({
    int? id,
    bool? smsEnabled,
    bool? notificationEnabled,
    bool? confirmationRequired,
    String? updatedAt,
  }) {
    return DetectionSettingsModel(
      id: id ?? this.id,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      confirmationRequired: confirmationRequired ?? this.confirmationRequired,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
