import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_two/edit_screen.dart';
import 'package:test_two/model/expence.dart';
import 'package:test_two/providers/expence_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  final List<String> categories = const [
    'All',
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Other',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredExpenses = ref.watch(filteredExpenseProvider);
    final allExpenses = ref.watch(expenseProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final categoryTotals = ref.watch(categoryTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Manager'), centerTitle: true),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Spending: RS. ${totalExpense.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  if (categoryTotals.isEmpty)
                    const Text('No data available')
                  else
                    Column(
                      children: categoryTotals.entries.map((mapentry) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(mapentry.key),
                            Text('RS. ${mapentry.value.toStringAsFixed(2)}'),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                ref.read(selectedCategoryProvider.notifier).state = value!;
              },
            ),
          ),

          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(child: Text('No expenses found'))
                : ListView.builder(
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final ExpenseModel expense = filteredExpenses[index];
                      final originalIndex = allExpenses.indexOf(expense);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            expense.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'RS. ${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddEditExpenseScreen(
                                        expense: expense,
                                        index: originalIndex,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  ref
                                      .read(expenseProvider.notifier)
                                      .deleteExpense(originalIndex);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
