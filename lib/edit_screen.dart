import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_two/model/expence.dart';
import 'package:test_two/providers/expence_provider.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel? expense;
  final int? index;

  const AddEditExpenseScreen({super.key, this.expense, this.index});

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      titleController.text = widget.expense!.title;
      amountController.text = widget.expense!.amount.toString();
      selectedCategory = widget.expense!.category;
      selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void saveExpense() {
    if (formKey.currentState!.validate()) {
      final expense = ExpenseModel(
        title: titleController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        category: selectedCategory,
        date: selectedDate,
      );

      final notifier = ref.read(expenseProvider.notifier);

      if (widget.expense == null) {
        notifier.addExpense(expense);
      } else {
        notifier.updateExpense(widget.index!, expense);
      }

      Navigator.pop(context);
    }
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.expense != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Expense' : 'Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }

                  final amount = double.tryParse(value);

                  if (amount == null) {
                    return 'Enter valid amount';
                  }

                  if (amount <= 0) {
                    return 'Amount should be greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: pickDate,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: saveExpense,
                  child: Text(isEdit ? 'Update Expense' : 'Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
