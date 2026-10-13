
import 'package:flutter/material.dart';

Widget buildDateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
      ],
    );
  }