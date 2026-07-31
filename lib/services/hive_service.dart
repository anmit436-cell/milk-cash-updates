import 'package:hive_flutter/hive_flutter.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';
import 'package:mishra_milk_cash/models/transaction_record.dart';

/// Manages all Hive database operations
class HiveService {
  static late Box _transactionsBox;
  static late Box _customersBox;
  static late Box _settingsBox;

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    _transactionsBox = await Hive.openBox(AppConstants.hiveTransactions);
    _customersBox = await Hive.openBox(AppConstants.hiveCustomers);
    _settingsBox = await Hive.openBox(AppConstants.hiveSettings);
  }

  // ── Transactions ──

  /// Save a transaction record
  static Future<void> saveTransaction(TransactionRecord record) async {
    await _transactionsBox.put(record.id, record.toMap());
  }

  /// Get all transactions sorted by date (newest first)
  static List<TransactionRecord> getAllTransactions() {
    final List<TransactionRecord> transactions = [];
    for (final key in _transactionsBox.keys) {
      final data = _transactionsBox.get(key);
      if (data != null) {
        try {
          transactions.add(
            TransactionRecord.fromMap(Map<String, dynamic>.from(data as Map)),
          );
        } catch (_) {
          // Skip corrupted entries
        }
      }
    }
    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return transactions;
  }

  /// Delete a transaction by ID
  static Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  /// Update a transaction record
  static Future<void> updateTransaction(TransactionRecord record) async {
    await _transactionsBox.put(record.id, record.toMap());
  }

  /// Delete all transactions
  static Future<void> clearAllTransactions() async {
    await _transactionsBox.clear();
  }

  /// Get transaction count
  static int get transactionCount => _transactionsBox.length;

  // ── Customers ──

  /// Save a customer name
  static Future<void> saveCustomer(String name) async {
    final customers = getCustomers();
    if (!customers.contains(name) && name.isNotEmpty) {
      customers.add(name);
      await _customersBox.put('list', customers);
    }
  }

  /// Get all customer names
  static List<String> getCustomers() {
    final data = _customersBox.get('list');
    if (data == null) return [];
    return List<String>.from(data as List);
  }

  // ── Settings ──

  /// Save a setting
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get a setting
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  /// Save bank QRs (list of base64 strings)
  static Future<void> saveBankQrs(List<String> qrs) async {
    await _settingsBox.put('bank_qrs', qrs);
  }

  /// Get bank QRs
  static List<String> getBankQrs() {
    final data = _settingsBox.get('bank_qrs');
    if (data == null) return [];
    return List<String>.from(data as List);
  }

  // ── Counter State Persistence ──

  /// Save the current counter state (denominations + customer name)
  static Future<void> saveCounterState({
    required String customerName,
    required List<Map<String, dynamic>> denominations,
  }) async {
    await _settingsBox.put('counter_customer', customerName);
    await _settingsBox.put('counter_denominations', denominations);
  }

  /// Get the saved counter state (returns null if none saved)
  static Map<String, dynamic>? getSavedCounterState() {
    final customer = _settingsBox.get('counter_customer');
    final denoms = _settingsBox.get('counter_denominations');
    if (customer == null && denoms == null) return null;
    return {
      'customerName': customer,
      'denominations': denoms,
    };
  }

  // ── Export/Import ──

  /// Export all data as JSON map
  static Map<String, dynamic> exportAll() {
    final transactions = <Map<String, dynamic>>[];
    for (final key in _transactionsBox.keys) {
      final data = _transactionsBox.get(key);
      if (data != null) {
        transactions.add(Map<String, dynamic>.from(data as Map));
      }
    }
    return {
      'transactions': transactions,
      'customers': getCustomers(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': AppConstants.appVersion,
    };
  }
}
