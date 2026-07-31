import 'package:mishra_milk_cash/models/denomination.dart';

/// Represents a saved transaction record
class TransactionRecord {
  final String id;
  final String customerName;
  final DateTime dateTime;
  final List<Denomination> denominations;
  final int notesTotal;
  final int coinsTotal;
  final int onlineTotal;
  final int baakiTotal;
  final int grandTotal;
  final String amountInWords;
  final String paymentType; // Cash, Online, Mixed
  final String notes;
  final bool isFavorite;
  final bool isDeleted;

  TransactionRecord({
    required this.id,
    required this.customerName,
    required this.dateTime,
    required this.denominations,
    required this.notesTotal,
    required this.coinsTotal,
    required this.onlineTotal,
    required this.baakiTotal,
    required this.grandTotal,
    required this.amountInWords,
    required this.paymentType,
    this.notes = '',
    this.isFavorite = false,
    this.isDeleted = false,
  });

  /// Serialize to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'dateTime': dateTime.toIso8601String(),
      'denominations': denominations.map((d) => d.toMap()).toList(),
      'notesTotal': notesTotal,
      'coinsTotal': coinsTotal,
      'onlineTotal': onlineTotal,
      'baakiTotal': baakiTotal,
      'grandTotal': grandTotal,
      'amountInWords': amountInWords,
      'paymentType': paymentType,
      'notes': notes,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
    };
  }

  /// Deserialize from Map
  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      id: map['id'] as String,
      customerName: map['customerName'] as String? ?? '',
      dateTime: DateTime.parse(map['dateTime'] as String),
      denominations: (map['denominations'] as List)
          .map((d) => Denomination.fromMap(Map<String, dynamic>.from(d as Map)))
          .toList(),
      notesTotal: map['notesTotal'] as int? ?? 0,
      coinsTotal: map['coinsTotal'] as int? ?? 0,
      onlineTotal: map['onlineTotal'] as int? ?? 0,
      baakiTotal: map['baakiTotal'] as int? ?? 0,
      grandTotal: map['grandTotal'] as int? ?? 0,
      amountInWords: map['amountInWords'] as String? ?? '',
      paymentType: map['paymentType'] as String? ?? 'Cash',
      notes: map['notes'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  /// Create a copy with modifications
  TransactionRecord copyWith({
    String? id,
    String? customerName,
    DateTime? dateTime,
    List<Denomination>? denominations,
    int? notesTotal,
    int? coinsTotal,
    int? onlineTotal,
    int? baakiTotal,
    int? grandTotal,
    String? amountInWords,
    String? paymentType,
    String? notes,
    bool? isFavorite,
    bool? isDeleted,
  }) {
    return TransactionRecord(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      dateTime: dateTime ?? this.dateTime,
      denominations: denominations ?? this.denominations,
      notesTotal: notesTotal ?? this.notesTotal,
      coinsTotal: coinsTotal ?? this.coinsTotal,
      onlineTotal: onlineTotal ?? this.onlineTotal,
      baakiTotal: baakiTotal ?? this.baakiTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      amountInWords: amountInWords ?? this.amountInWords,
      paymentType: paymentType ?? this.paymentType,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
