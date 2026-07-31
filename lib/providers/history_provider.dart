import 'package:flutter/material.dart';
import 'package:mishra_milk_cash/models/transaction_record.dart';
import 'package:mishra_milk_cash/services/hive_service.dart';

/// State management for the History page
class HistoryProvider extends ChangeNotifier {
  List<TransactionRecord> _transactions = [];
  List<TransactionRecord> get transactions => _transactions;

  Set<String> _selectedIds = {};
  Set<String> get selectedIds => _selectedIds;
  bool get isSelectMode => _selectedIds.isNotEmpty;

  String _searchQuery = '';
  String _paymentFilter = 'All'; // All, Cash, Online, Mixed, Due
  String _dateFilter = 'All Time'; // All Time, Today, Yesterday, Last 7 Days, Last 30 Days, This Month, Last Month, Custom Date Range
  String _sortBy = 'Latest'; // Latest, Oldest, Highest Amount, Lowest Amount, Customer Name
  bool _showFilters = false;
  
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  String get paymentFilter => _paymentFilter;
  String get dateFilter => _dateFilter;
  String get sortBy => _sortBy;
  String get searchQuery => _searchQuery;
  bool get showFilters => _showFilters;

  /// Load all transactions from Hive
  void loadTransactions() {
    _transactions = HiveService.getAllTransactions();
    notifyListeners();
  }

  /// Get filtered transactions (excluding deleted ones unless specifically requested)
  List<TransactionRecord> get filteredTransactions {
    var list = _transactions.where((t) => !t.isDeleted).toList();

    // 1. Apply Date Filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (_dateFilter) {
      case 'Today':
        list = list.where((t) {
          final tDate = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
          return tDate.isAtSameMomentAs(today);
        }).toList();
        break;
      case 'Yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        list = list.where((t) {
          final tDate = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
          return tDate.isAtSameMomentAs(yesterday);
        }).toList();
        break;
      case 'Last 7 Days':
        final last7 = today.subtract(const Duration(days: 7));
        list = list.where((t) => t.dateTime.isAfter(last7)).toList();
        break;
      case 'Last 30 Days':
        final last30 = today.subtract(const Duration(days: 30));
        list = list.where((t) => t.dateTime.isAfter(last30)).toList();
        break;
      case 'This Month':
        list = list.where((t) => t.dateTime.year == now.year && t.dateTime.month == now.month).toList();
        break;
      case 'Last Month':
        final lastMonth = now.month == 1 ? 12 : now.month - 1;
        final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
        list = list.where((t) => t.dateTime.year == lastMonthYear && t.dateTime.month == lastMonth).toList();
        break;
      case 'Custom Date Range':
        if (_customStartDate != null && _customEndDate != null) {
          final endDay = _customEndDate!.add(const Duration(days: 1)); // Include the end day fully
          list = list.where((t) => t.dateTime.isAfter(_customStartDate!) && t.dateTime.isBefore(endDay)).toList();
        }
        break;
    }

    // 2. Apply Payment Filter
    if (_paymentFilter != 'All') {
      if (_paymentFilter == 'Due') {
        list = list.where((t) => t.baakiTotal > 0).toList();
      } else {
        list = list.where((t) => t.paymentType == _paymentFilter).toList();
      }
    }

    // 3. Apply Search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((t) {
        return t.customerName.toLowerCase().contains(query) ||
            t.grandTotal.toString().contains(query) ||
            t.baakiTotal.toString().contains(query) ||
            t.paymentType.toLowerCase().contains(query);
      }).toList();
    }

    // 4. Apply Sort
    switch (_sortBy) {
      case 'Latest':
        list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case 'Oldest':
        list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case 'Highest Amount':
        list.sort((a, b) => b.grandTotal.compareTo(a.grandTotal));
        break;
      case 'Lowest Amount':
        list.sort((a, b) => a.grandTotal.compareTo(b.grandTotal));
        break;
      case 'Customer Name':
        list.sort((a, b) => a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase()));
        break;
    }

    return list;
  }

  /// Total of all sales (excluding deleted)
  int get totalSales {
    int total = 0;
    for (final t in _transactions.where((t) => !t.isDeleted)) {
      total += t.grandTotal;
    }
    return total;
  }

  /// Today's sales total (excluding deleted)
  int get todaysSales {
    final today = DateTime.now();
    int total = 0;
    for (final t in _transactions.where((t) => !t.isDeleted)) {
      if (t.dateTime.year == today.year &&
          t.dateTime.month == today.month &&
          t.dateTime.day == today.day) {
        total += t.grandTotal;
      }
    }
    return total;
  }

  /// Today's transaction count
  int get todaysTransactionCount {
    final today = DateTime.now();
    int count = 0;
    for (final t in _transactions.where((t) => !t.isDeleted)) {
      if (t.dateTime.year == today.year &&
          t.dateTime.month == today.month &&
          t.dateTime.day == today.day) {
        count++;
      }
    }
    return count;
  }

  /// Set Search Query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Toggle filters visibility
  void toggleShowFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  /// Filter by payment type
  void setPaymentFilter(String filter) {
    _paymentFilter = filter;
    notifyListeners();
  }

  /// Filter by date
  void setDateFilter(String filter, {DateTime? startDate, DateTime? endDate}) {
    _dateFilter = filter;
    if (filter == 'Custom Date Range') {
      _customStartDate = startDate;
      _customEndDate = endDate;
    }
    notifyListeners();
  }
  
  /// Sort by
  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  /// Toggle select mode for a transaction
  void toggleSelect(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  /// Select all filtered transactions
  void selectAll() {
    _selectedIds = filteredTransactions.map((t) => t.id).toSet();
    notifyListeners();
  }

  /// Hard delete a transaction
  Future<void> deleteTransaction(String id) async {
    await HiveService.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    _selectedIds.remove(id);
    notifyListeners();
  }

  /// Soft delete a transaction (move to trash essentially)
  Future<void> softDeleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final updated = _transactions[index].copyWith(isDeleted: true);
      await HiveService.updateTransaction(updated);
      _transactions[index] = updated;
      _selectedIds.remove(id);
      notifyListeners();
    }
  }

  /// Restore soft deleted transaction
  Future<void> restoreTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final updated = _transactions[index].copyWith(isDeleted: false);
      await HiveService.updateTransaction(updated);
      _transactions[index] = updated;
      notifyListeners();
    }
  }

  /// Toggle Favorite
  Future<void> toggleFavorite(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final updated = _transactions[index].copyWith(isFavorite: !_transactions[index].isFavorite);
      await HiveService.updateTransaction(updated);
      _transactions[index] = updated;
      notifyListeners();
    }
  }

  /// Soft delete selected transactions
  Future<void> deleteSelected() async {
    for (final id in _selectedIds) {
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index >= 0) {
        final updated = _transactions[index].copyWith(isDeleted: true);
        await HiveService.updateTransaction(updated);
        _transactions[index] = updated;
      }
    }
    _selectedIds.clear();
    notifyListeners();
  }

  /// Clear all history (hard delete all)
  Future<void> clearAll() async {
    await HiveService.clearAllTransactions();
    _transactions.clear();
    _selectedIds.clear();
    notifyListeners();
  }

  /// Add a duplicate transaction
  Future<void> duplicateTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final original = _transactions[index];
      final newRecord = original.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // New ID
        dateTime: DateTime.now(), // New DateTime
        isDeleted: false,
        isFavorite: false,
      );
      await HiveService.saveTransaction(newRecord);
      _transactions.add(newRecord);
      notifyListeners();
    }
  }

  /// Update a transaction
  Future<void> updateTransaction(TransactionRecord record) async {
    await HiveService.updateTransaction(record);
    final index = _transactions.indexWhere((t) => t.id == record.id);
    if (index >= 0) {
      _transactions[index] = record;
    } else {
      _transactions.add(record);
    }
    notifyListeners();
  }

  /// Get next transaction number
  int get nextTransactionNumber => _transactions.length + 1;

  /// Get transaction number by ID
  int getTransactionNumber(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index >= 0) {
      return _transactions.length - index;
    }
    return 0;
  }
}
