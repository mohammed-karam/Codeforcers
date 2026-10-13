import 'package:flutter/material.dart';

Widget buildInfoTile(IconData icon, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1B3B6F)),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: (title == 'Contribution') ? Colors.green : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
