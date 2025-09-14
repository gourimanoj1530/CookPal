import 'package:flutter/material.dart';
import 'dart:async';
import '../models/cooking_timer.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final List<CookingTimer> _timers = [];

  void _addTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddTimerDialog(
        onAdd: (name, duration) {
          setState(() {
            _timers.add(
              CookingTimer(
                id: DateTime.now().millisecondsSinceEpoch,
                name: name,
                durationInSeconds: duration.inSeconds,
                startTime: DateTime.now(),
                isRunning: true,
              ),
            );
          });
        },
      ),
    );
  }

  void _removeTimer(CookingTimer timer) {
    setState(() {
      _timers.remove(timer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Timers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTimerDialog,
          ),
        ],
      ),
      body: _timers.isEmpty
          ? const Center(child: Text('No active timers'))
          : ListView.builder(
        itemCount: _timers.length,
        itemBuilder: (context, index) {
          final timer = _timers[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(timer.name),
              subtitle: Text(timer.formattedTime),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeTimer(timer),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTimerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddTimerDialog extends StatefulWidget {
  final Function(String, Duration) onAdd;
  const _AddTimerDialog({required this.onAdd});

  @override
  State<_AddTimerDialog> createState() => _AddTimerDialogState();
}

class _AddTimerDialogState extends State<_AddTimerDialog> {
  final TextEditingController _nameController = TextEditingController();
  int _minutes = 1;
  int _seconds = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<int>(
                value: _minutes,
                items: List.generate(60, (i) => i)
                    .map((v) => DropdownMenuItem(value: v, child: Text("$v min")))
                    .toList(),
                onChanged: (v) => setState(() => _minutes = v!),
              ),
              DropdownButton<int>(
                value: _seconds,
                items: List.generate(60, (i) => i)
                    .map((v) => DropdownMenuItem(value: v, child: Text("$v sec")))
                    .toList(),
                onChanged: (v) => setState(() => _seconds = v!),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            widget.onAdd(
              _nameController.text.trim(),
              Duration(minutes: _minutes, seconds: _seconds),
            );
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}