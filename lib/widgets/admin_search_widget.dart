import 'package:flutter/material.dart';

class AdminSearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final String hinText;
  const AdminSearchWidget({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
    required this.hinText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25.0),

        ),
        child: Padding(
          padding: const EdgeInsets.only(left:10.0),
          child: TextField(
            controller: searchController,
            decoration:  InputDecoration(
              hintText: '$hinText',
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 20.0),
                border: InputBorder.none,
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: onSearchChanged,
          ),
        ),
      ),
    );
  }
}
