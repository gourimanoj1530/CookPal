import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui'; // For FontFeature in TimerCard

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  List<CookingTimer> _timers = [];
  int _nextTimerId = 1;

  @override
  void dispose() {
    // Cancel all timers
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _addTimer() {
    showDialog(
      context: context,
      builder: (context) => _AddTimerDialog(
        onAdd: (name, duration) {
          setState(() {
            _timers.add(
              CookingTimer(
                id: _nextTimerId++,
                name: name,
                duration: duration,
                onComplete: _onTimerComplete,
              ),
            );
          });
        },
      ),
    );
  }

  void _onTimerComplete(CookingTimer timer) {
    // Show notification dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.timer, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Timer Finished!'),
            ],
          ),
          content: Text('${timer.name} timer has completed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _removeTimer(timer.id);
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _restartTimer(timer);
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      );
    }
  }

  void _removeTimer(int id) {
    setState(() {
      _timers.removeWhere((timer) {
        if (timer.id == id) {
          timer.cancel();
          return true;
        }
        return false;
      });
    });
  }

  void _restartTimer(CookingTimer timer) {
    setState(() {
      timer.restart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Cooking Timers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addTimer,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _timers.isEmpty ? _buildEmptyState() : _buildTimerList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTimer,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Timers',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the + button to add a cooking timer',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _timers.length,
      itemBuilder: (context, index) {
        final timer = _timers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TimerCard(
            timer: timer,
            onRemove: () => _removeTimer(timer.id),
            onRestart: () => _restartTimer(timer),
          ),
        );
      },
    );
  }
}

class _AddTimerDialog extends StatefulWidget {
  final Function(String name, Duration duration) onAdd;

  const _AddTimerDialog({required this.onAdd});

  @override
  State<_AddTimerDialog> createState() => _AddTimerDialogState();
}

class _AddTimerDialogState extends State<_AddTimerDialog> {
  final _nameController = TextEditingController();
  int _hours = 0;
  int _minutes = 5;
  int _seconds = 0;

  final List<Map<String, dynamic>> _presets = [
    {'name': 'Boiling Eggs', 'duration': const Duration(minutes: 8)},
    {'name': 'Pasta', 'duration': const Duration(minutes: 12)},
    {'name': 'Steaming Rice', 'duration': const Duration(minutes: 18)},
    {'name': 'Roasting Chicken', 'duration': const Duration(hours: 1)},
    {'name': 'Baking Cookies', 'duration': const Duration(minutes: 15)},
    {'name': 'Pizza', 'duration': const Duration(minutes: 20)},
  ];

  void _usePreset(String name, Duration duration) {
    setState(() {
      _nameController.text = name;
      _hours = duration.inHours;
      _minutes = duration.inMinutes % 60;
      _seconds = duration.inSeconds % 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Timer'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Timer Name',
                hintText: 'e.g., Boiling Pasta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Duration:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeSelector('Hours', _hours, 23, (value) {
                  setState(() {
                    _hours = value;
                  });
                }),
                _buildTimeSelector('Minutes', _minutes, 59, (value) {
                  setState(() {
                    _minutes = value;
                  });
                }),
                _buildTimeSelector('Seconds', _seconds, 59, (value) {
                  setState(() {
                    _seconds = value;
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Quick Presets:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _presets.length,
                itemBuilder: (context, index) {
                  final preset = _presets[index];
                  return GestureDetector(
                    onTap: () => _usePreset(preset['name'], preset['duration']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Center(
                        child: Text(
                          preset['name'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a timer name')),
              );
              return;
            }

            final duration = Duration(
              hours: _hours,
              minutes: _minutes,
              seconds: _seconds,
            );

            if (duration.inSeconds <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please set a valid duration')),
              );
              return;
            }

            widget.onAdd(name, duration);
            Navigator.pop(context);
          },
          child: const Text('Add Timer'),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(String label, int value, int max, Function(int) onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        Container(
          width: 70,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (value < max) onChanged(value + 1);
                },
                child: const Icon(Icons.keyboard_arrow_up, size: 16),
              ),
              Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  if (value > 0) onChanged(value - 1);
                },
                child: const Icon(Icons.keyboard_arrow_down, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TimerCard extends StatefulWidget {
  final CookingTimer timer;
  final VoidCallback onRemove;
  final VoidCallback onRestart;

  const TimerCard({
    super.key,
    required this.timer,
    required this.onRemove,
    required this.onRestart,
  });

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: widget.timer.stream,
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Timer name and controls
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.timer.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'restart':
                          widget.onRestart();
                          break;
                        case 'remove':
                          widget.onRemove();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'restart',
                        child: Row(
                          children: [
                            Icon(Icons.restart_alt, size: 20),
                            SizedBox(width: 8),
                            Text('Restart'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20),
                            SizedBox(width: 8),
                            Text('Remove'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Timer display
              Text(
                widget.timer.formattedTime,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: widget.timer.isCompleted
                      ? Colors.red
                      : widget.timer.isRunning
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 20),
              // Progress bar
              LinearProgressIndicator(
                value: widget.timer.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.timer.isCompleted
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!widget.timer.isCompleted) ...[
                    ElevatedButton.icon(
                      onPressed: widget.timer.isRunning
                          ? widget.timer.pause
                          : widget.timer.start,
                      icon: Icon(
                        widget.timer.isRunning ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(widget.timer.isRunning ? 'Pause' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.timer.isRunning
                            ? Colors.orange
                            : Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: widget.timer.stop,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: widget.onRestart,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Restart'),
                    ),
                    OutlinedButton.icon(
                      onPressed: widget.onRemove,
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CookingTimer {
  final int id;
  final String name;
  final Duration duration;
  final Function(CookingTimer) onComplete;

  Duration _remainingTime;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;
  final StreamController<void> _controller = StreamController<void>.broadcast();

  CookingTimer({
    required this.id,
    required this.name,
    required this.duration,
    required this.onComplete,
  }) : _remainingTime = duration;

  bool get isRunning => _isRunning;
  bool get isCompleted => _isCompleted;
  Duration get remainingTime => _remainingTime;
  Stream<void> get stream => _controller.stream;

  String get formattedTime {
    int totalSeconds = _remainingTime.inSeconds;
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  double get progress {
    if (duration.inSeconds <= 0) return 1.0;
    return 1.0 - (_remainingTime.inSeconds / duration.inSeconds);
  }

  void start() {
    if (_isCompleted) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);

      if (_remainingTime.inSeconds <= 0) {
        _remainingTime = Duration.zero;
        _isCompleted = true;
        _isRunning = false;
        timer.cancel();
        onComplete(this);
      }

      _controller.add(null);
    });
    _controller.add(null);
  }

  void pause() {
    _isRunning = false;
    _timer?.cancel();
    _controller.add(null);
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _remainingTime = duration;
    _isCompleted = false;
    _controller.add(null);
  }

  void restart() {
    _timer?.cancel();
    _isRunning = false;
    _isCompleted = false;
    _remainingTime = duration;
    _controller.add(null);
  }

  void cancel() {
    _timer?.cancel();
    _controller.close();
  }
}