import 'package:flutter/material.dart';

class LSPIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function()? onTap;
  final EdgeInsetsGeometry padding;

  const LSPIconButton(
      {super.key,
      this.icon = Icons.abc,
      this.label = '',
      this.onTap,
      this.padding = const EdgeInsets.symmetric(vertical: 5)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(
            icon,
            size: 32,
          ),
          label: Text(
            label,
            style: const TextStyle(fontSize: 18),
          )),
    );
  }
}
