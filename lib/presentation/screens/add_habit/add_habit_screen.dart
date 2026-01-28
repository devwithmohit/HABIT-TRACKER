import 'package:flutter/material.dart';

/// Add/Edit Habit Screen
/// Note: Full implementation requires:
/// - Form validation
/// - Icon picker
/// - Color picker
/// - Active days selector
/// - Riverpod provider integration
class AddHabitScreen extends StatefulWidget {
  final String? habitId; // null for new habit, id for editing

  const AddHabitScreen({super.key, this.habitId});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedIcon = '🎯';
  String _selectedColor = '#6C63FF';
  List<int> _selectedDays = [1, 2, 3, 4, 5]; // Weekdays default

  bool get isEditing => widget.habitId != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'New Habit'),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Habit name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                hintText: 'e.g., Morning workout',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit name';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Icon selector (placeholder)
            Text(
              'Icon',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _selectedIcon,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Active days selector
            Text(
              'Active Days',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildDaySelector(),

            const SizedBox(height: 24),

            // Color selector (placeholder)
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Color picker will go here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final isSelected = _selectedDays.contains(dayNumber);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(dayNumber);
              } else {
                _selectedDays.add(dayNumber);
              }
            });
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day')),
        );
        return;
      }

      // TODO: Save using provider
      // final habitId = isEditing ? widget.habitId! : DateTime.now().millisecondsSinceEpoch.toString();
      // ref.read(habitsProvider.notifier).createHabit(...)

      Navigator.pop(context);
    }
  }
}
