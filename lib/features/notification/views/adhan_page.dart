import 'package:flutter/material.dart';

class AdhanPage extends StatefulWidget {
  const AdhanPage({super.key, required this.prayerType});
  final String prayerType;

  @override
  State<AdhanPage> createState() => _AdhanPageState();
}

class _AdhanPageState extends State<AdhanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prayerType),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Text(
          'Prayer: ${widget.prayerType}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
