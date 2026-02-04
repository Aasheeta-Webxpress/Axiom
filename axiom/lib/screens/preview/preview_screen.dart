import 'package:flutter/material.dart';
import 'analytics_dashboard.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsDashboard(),
                ),
              );
            },
            icon: const Icon(Icons.analytics),
            tooltip: 'Analytics Dashboard',
          ),
        ],
      ),
      body: const Center(
        child: Text('Preview Screen'),
      ),
    );
  }
}
