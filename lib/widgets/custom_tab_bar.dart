import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          int index = entry.key;
          String tab = entry.value;
          bool isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black87 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}