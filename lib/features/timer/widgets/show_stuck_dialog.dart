
import 'package:flutter/material.dart';


void showStuckDialog(int minutes, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Are you stuck?'),
        content:  Text(
          'You have been solving this problem for $minutes minutes. '
          'Do you want to continue or view a hint?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showHint(context);
            },
            child: const Text('View Hint'),
          ),
        ],
      );
    },
  );
}

void showHint( BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const AlertDialog(
        title: Text('Hint'),
        content: Text(
          'Try thinking about the constraints first.',
        ),
      );
    },
  );
}