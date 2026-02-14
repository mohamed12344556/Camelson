import 'package:flutter/material.dart';

import '../core.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required TextEditingController searchController,
    this.onChanged,
    this.onClearPressed,
    this.hintText,
    this.isPaddingZero = false,
  }) : _searchController = searchController;

  final TextEditingController _searchController;
  final void Function(String)? onChanged;
  final void Function()? onClearPressed;
  final String? hintText;
  final bool isPaddingZero;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isPaddingZero ? EdgeInsets.zero : const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search subjects',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed:
                        onClearPressed ??
                        () {
                          _searchController.clear();
                        },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          fillColor: Colors.grey.shade50,
          filled: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
