import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mishra_milk_cash/models/denomination.dart';
import 'package:mishra_milk_cash/models/transaction_record.dart';
import 'package:mishra_milk_cash/core/utils/number_to_words.dart';
import 'package:mishra_milk_cash/services/hive_service.dart';

/// State management for the Counter page
class CounterProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  // ── Customer ──
  String _customerName = '';
  String get customerName => _customerName;

  // ── Denominations ──
  List<Denomination> _denominations = Denomination.defaultList();
  List<Denomination> get denominations => _denominations;

  CounterProvider() {
    // Load saved state on creation
    _loadSavedState();
  }

  /// Load previously saved counter state from Hive
  void _loadSavedState() {
    final saved = HiveService.getSavedCounterState();
    if (saved != null) {
      _customerName = saved['customerName'] as String? ?? '';
      final denomData = saved['denominations'] as List<dynamic>?;
      if (denomData != null && denomData.isNotEmpty) {
        try {
          _denominations = denomData
              .map((d) => Denomination.fromMap(Map<String, dynamic>.from(d as Map)))
              .toList();
        } catch (_) {
          _denominations = Denomination.defaultList();
        }
      }
    }
  }

  /// Persist current counter state to Hive
  void _persistState() {
    HiveService.saveCounterState(
      customerName: _customerName,
      denominations: _denominations.map((d) => d.toMap()).toList(),
    );
  }

  // ── Tally Panel State ──
  bool _isTallyOpen = false;
  bool get isTallyOpen => _isTallyOpen;

  void toggleTallyPanel() {
    _isTallyOpen = !_isTallyOpen;
    notifyListeners();
  }

  void closeTallyPanel() {
    if (_isTallyOpen) {
      _isTallyOpen = false;
      notifyListeners();
    }
  }

  // ── Computed Totals ──

  /// Sum of all note denominations (₹500 through ₹10)
  int get notesTotal {
    int total = 0;
    for (final d in _denominations) {
      if (!d.isCoin && !d.isOnline && !d.isBaaki) {
        total += d.amount;
      }
    }
    return total;
  }

  /// Total count of all notes
  int get notesCount {
    int count = 0;
    for (final d in _denominations) {
      if (!d.isCoin && !d.isOnline && !d.isBaaki) {
        count += d.quantity;
      }
    }
    return count;
  }

  /// Total coins amount
  int get coinsTotal {
    for (final d in _denominations) {
      if (d.isCoin) return d.quantity;
    }
    return 0;
  }

  /// Total online payment amount
  int get onlineTotal {
    for (final d in _denominations) {
      if (d.isOnline) return d.quantity;
    }
    return 0;
  }

  /// Total baaki (due) amount
  int get baakiTotal {
    for (final d in _denominations) {
      if (d.isBaaki) return d.quantity;
    }
    return 0;
  }

  /// Grand total = Notes + Coins + Online + Baaki
  int get grandTotal => notesTotal + coinsTotal + onlineTotal + baakiTotal;

  /// Amount in words
  String get amountInWords {
    if (grandTotal == 0) return '';
    return NumberToWords.convert(grandTotal);
  }

  /// Payment type determination
  String get paymentType {
    final hasCash = notesTotal > 0 || coinsTotal > 0;
    final hasOnline = onlineTotal > 0;
    if (hasCash && hasOnline) return 'Mixed';
    if (hasOnline) return 'Online';
    return 'Cash';
  }

  // ── Actions ──

  /// Set customer name
  void setCustomerName(String name) {
    _customerName = name;
    _persistState();
    notifyListeners();
  }

  /// Update quantity for a specific denomination
  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _denominations.length) {
      _denominations[index].quantity = quantity < 0 ? 0 : quantity;
      _persistState();
      notifyListeners();
    }
  }

  /// Increment quantity
  void increment(int index) {
    if (index >= 0 && index < _denominations.length) {
      _denominations[index].quantity++;
      _persistState();
      notifyListeners();
    }
  }

  /// Decrement quantity (minimum 0)
  void decrement(int index) {
    if (index >= 0 && index < _denominations.length) {
      if (_denominations[index].quantity > 0) {
        _denominations[index].quantity--;
        _persistState();
        notifyListeners();
      }
    }
  }

  /// Reset all values
  void reset() {
    _customerName = '';
    _denominations = Denomination.defaultList();
    _persistState();
    notifyListeners();
  }

  /// Save current state as a transaction (does NOT reset entries)
  Future<TransactionRecord> save() async {
    final record = TransactionRecord(
      id: _uuid.v4(),
      customerName: _customerName.isEmpty ? 'Customer' : _customerName,
      dateTime: DateTime.now(),
      denominations: _denominations.map((d) => d.copyWith()).toList(),
      notesTotal: notesTotal,
      coinsTotal: coinsTotal,
      onlineTotal: onlineTotal,
      baakiTotal: baakiTotal,
      grandTotal: grandTotal,
      amountInWords: amountInWords,
      paymentType: paymentType,
    );

    await HiveService.saveTransaction(record);

    // Save customer name if provided
    if (_customerName.isNotEmpty) {
      await HiveService.saveCustomer(_customerName);
    }

    return record;
  }

  /// Load a transaction for editing
  void loadTransaction(TransactionRecord record) {
    _customerName = record.customerName;
    _denominations = record.denominations.map((d) => d.copyWith()).toList();
    _persistState();
    notifyListeners();
  }

  /// Generate WhatsApp share text matching the premium screenshot format
  String generateShareText({int? transactionNumber}) {
    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayNames[now.weekday - 1];
    final date = '${now.day}/${now.month}/${now.year}';
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $amPm';
    final idNum = transactionNumber ?? (HiveService.transactionCount + 1);
    final customerDisplay = _customerName.isEmpty ? 'Customer' : _customerName;

    final buffer = StringBuffer();
    buffer.writeln('*MISHRA CASH COUNTER*');
    buffer.writeln('*CASH MANAGEMENT*');
    buffer.writeln('');
    buffer.writeln('🧑 *Customer:* $customerDisplay');
    buffer.writeln('');
    buffer.writeln('🆔 *ID#$idNum*');
    buffer.writeln('');
    buffer.writeln('📅 *Day:* $dayName');
    buffer.writeln('');
    buffer.writeln('📅 *Date:* $date');
    buffer.writeln('');
    buffer.writeln('🕐 *Time:* $time');
    buffer.writeln('');

    // ── NOTE BREAKDOWN section ──
    buffer.writeln('💰 *NOTE BREAKDOWN:*');
    for (final d in _denominations) {
      if (d.quantity > 0 && !d.isCoin && !d.isOnline && !d.isBaaki) {
        buffer.writeln('₹${d.value} x ${d.quantity} = ₹${d.amount}');
      }
    }
    buffer.writeln('');

    // ── COINS section ──
    if (coinsTotal > 0) {
      buffer.writeln('🪙 *COINS:*');
      buffer.writeln('Coins = ₹$coinsTotal');
      buffer.writeln('');
    }

    // ── ONLINE PAYMENT section ──
    if (onlineTotal > 0) {
      buffer.writeln('💳 *ONLINE PAYMENT:*');
      buffer.writeln('Digital Payment = ₹$onlineTotal');
      buffer.writeln('');
    }

    // ── BAAKI (DUE) section ──
    if (baakiTotal > 0) {
      buffer.writeln('📋 *BAAKI (DUE):*');
      buffer.writeln('Due Amount = ₹$baakiTotal');
      buffer.writeln('');
    }

    buffer.writeln('💵 *Total Notes Count:* $notesCount Notes');
    buffer.writeln('');
    buffer.writeln('💰 *Grand Total:* ₹$grandTotal');
    if (amountInWords.isNotEmpty) {
      buffer.writeln('($amountInWords)');
    }
    buffer.writeln('');
    buffer.writeln('Thank you for your business! 🙏');

    return buffer.toString();
  }
}
