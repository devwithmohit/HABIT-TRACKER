import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/di/injection.dart';
import '../../../core/constants/app_constants.dart';

/// Add/Edit Habit Screen
class AddHabitScreen extends ConsumerStatefulWidget {
  final String? habitId; // null for new habit, id for editing

  const AddHabitScreen({super.key, this.habitId});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedIcon = '🎯';
  String _selectedColor = '#6C63FF';
  List<int> _selectedDays = [1, 2, 3, 4, 5]; // Weekdays default

  bool get isEditing => widget.habitId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Load existing habit data for editing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingHabit();
      });
    }
  }

  void _loadExistingHabit() {
    final habitsState = ref.read(habitsProvider);
    final existingHabit = habitsState.habits
        .where((h) => h.habit.id == widget.habitId)
        .firstOrNull;

    if (existingHabit != null) {
      final habit = existingHabit.habit;
      setState(() {
        _nameController.text = habit.name;
        _selectedIcon = habit.icon;
        _selectedColor = habit.color;
        _selectedDays = List<int>.from(habit.activeDays);
      });
    }
  }

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
              maxLength: AppConstants.maxHabitNameLength,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                hintText: 'e.g., Morning workout',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit name';
                }
                if (value.trim().length > AppConstants.maxHabitNameLength) {
                  return 'Habit name must be ${AppConstants.maxHabitNameLength} characters or less';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Icon selector
            Text(
              'Icon',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showIconPicker,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    _selectedIcon,
                    style: const TextStyle(fontSize: 48),
                  ),
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

            // Color selector
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showColorPicker,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFF${_selectedColor.substring(1)}')),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.palette, color: Colors.white, size: 32),
                ),
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

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day')),
        );
        return;
      }

      // Generate unique ID for new habit
      final habitId = widget.habitId ?? const Uuid().v4();

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      bool success;
      if (isEditing) {
        // Update existing habit
        final habitsState = ref.read(habitsProvider);
        final existingHabit = habitsState.habits
            .where((h) => h.habit.id == widget.habitId)
            .firstOrNull;

        if (existingHabit != null) {
          final updatedHabit = existingHabit.habit.copyWith(
            name: _nameController.text.trim(),
            icon: _selectedIcon,
            color: _selectedColor,
            activeDays: _selectedDays,
          );
          success = await ref.read(habitsProvider.notifier).updateHabit(updatedHabit);
        } else {
          success = false;
        }
      } else {
        // Create new habit
        final settingsState = ref.read(settingsProvider);
        success = await ref.read(habitsProvider.notifier).createHabit(
          id: habitId,
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
          activeDays: _selectedDays,
          isPremium: settingsState.settings.isPremium,
        );
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEditing ? 'Habit updated successfully!' : 'Habit created successfully!')),
          );
          // Go back to home screen
          Navigator.pop(context);
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Failed to update habit. Please try again.' : 'Failed to create habit. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showIconPicker() {
    final icons = [
      '🎯', '💪', '📚', '🏃', '🧘', '💧', '🥗', '😴',
      '✍️', '🎨', '🎵', '🧹', '💼', '🌱', '📱', '⏰',
      '🎓', '🏋️', '🚴', '🏊', '🧠', '❤️', '☕', '🌟',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose an Icon'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIcon = icons[index];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedIcon == icons[index]
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      icons[index],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    final colors = [
      '#6C63FF', '#FF6B6B', '#4ECDC4', '#FFD93D', '#95E1D3',
      '#FF8B94', '#A8E6CF', '#FFD3B6', '#FFAAA5', '#C7CEEA',
      '#FF85A1', '#74B9FF', '#FD79A8', '#FDCB6E', '#6C5CE7',
      '#00B894', '#E17055', '#0984E3', '#A29BFE', '#55EFC4',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose a Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedColor = colors[index];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(int.parse('0xFF${colors[index].substring(1)}')),
                    borderRadius: BorderRadius.circular(8),
                    border: _selectedColor == colors[index]
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
