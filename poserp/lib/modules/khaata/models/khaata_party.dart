class KhaataParty {
  final String id;
  final String name;
  final String phone;
  final String partyType; // 'customer' | 'supplier'
  final double currentBalance;
  final int creditDays;
  final bool isAutoReminderEnabled;
  final String? lastReminderSentAt;

  KhaataParty({
    required this.id,
    required this.name,
    required this.phone,
    required this.partyType,
    this.currentBalance = 0.0,
    this.creditDays = 0,
    this.isAutoReminderEnabled = false,
    this.lastReminderSentAt,
  });

  factory KhaataParty.fromJson(Map<String, dynamic> json) {
    return KhaataParty(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      partyType: json['partyType']?.toString() ?? 'customer',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      creditDays: (json['creditDays'] as num?)?.toInt() ?? 0,
      isAutoReminderEnabled: json['isAutoReminderEnabled'] as bool? ?? false,
      lastReminderSentAt: json['lastReminderSentAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'partyType': partyType,
      'currentBalance': currentBalance,
      'creditDays': creditDays,
      'isAutoReminderEnabled': isAutoReminderEnabled,
      'lastReminderSentAt': lastReminderSentAt,
    };
  }
}
