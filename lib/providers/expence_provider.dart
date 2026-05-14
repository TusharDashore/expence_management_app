import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:test_two/model/expence.dart';

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, List<ExpenseModel>>((ref) {
      return ExpenseNotifier();
    });

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredExpenseProvider = Provider<List<ExpenseModel>>((ref) {
  final expenses = ref.watch(expenseProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == 'All') {
    return expenses;
  }

  return expenses
      .where((expense) => expense.category == selectedCategory)
      .toList();
});

final totalExpenseProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseProvider);

  return expenses.fold(0, (sum, expense) => sum + expense.amount);
});

final categoryTotalProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expenseProvider);
  final Map<String, double> data = {};

  for (var expense in expenses) {
    data[expense.category] = (data[expense.category] ?? 0) + expense.amount;
  }

  return data;
});

class ExpenseNotifier extends StateNotifier<List<ExpenseModel>> {
  ExpenseNotifier() : super([]) {
    loadExpenses();
  }

  final Box<ExpenseModel> expenseBox = Hive.box<ExpenseModel>('expenses');

  void loadExpenses() {
    state = expenseBox.values.toList();
  }

  void addExpense(ExpenseModel expense) {
    expenseBox.add(expense);
    loadExpenses();
  }

  void updateExpense(int index, ExpenseModel expense) {
    expenseBox.putAt(index, expense);
    loadExpenses();
  }

  void deleteExpense(int index) {
    expenseBox.deleteAt(index);
    loadExpenses();
  }
}
