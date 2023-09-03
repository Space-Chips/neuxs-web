import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;

  // ignore: use_key_in_widget_constructors
  const MyTextBox({
    Key? key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: 20,
      ),
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // section name
              Text(sectionName, style: TextStyle(color: Colors.grey[500])),

              // edit button centered using a Stack
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  IconButton(
                    onPressed: onPressed,
                    icon: Icon(
                      Icons.settings,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // text
          Text(text),
        ],
      ),
    );
  }
}
