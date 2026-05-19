import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff151513),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)) ,
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.controller, required this.label, this.obscureText = false, this.keyboardType});

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class StatData {
  const StatData(this.label, this.value, this.detail);

  final String label;
  final String value;
  final String detail;
}

class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.stats});

  final List<StatData> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stats
          .map(
            (stat) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stat.label, style: const TextStyle(color: Color(0xffaaa59a))),
                          const SizedBox(height: 6),
                          Text(stat.value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                          Text(stat.detail, style: const TextStyle(color: Color(0xffaaa59a))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class DataRowTile extends StatelessWidget {
  const DataRowTile({super.key, required this.title, required this.subtitle, required this.trailing});

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(trailing, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class EmptyMessage extends StatelessWidget {
  const EmptyMessage(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Center(child: Text(message, style: const TextStyle(color: Color(0xffaaa59a)))),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x22ff6b57),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x44ff6b57)),
      ),
      child: Text(message),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
