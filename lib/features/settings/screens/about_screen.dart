import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      title: 'About Nox Keyboard',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          Center(
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(CupertinoIcons.keyboard, size: 42, color: Colors.black),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              AppConstants.appName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              AppConstants.packageName,
              style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 22),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Architecture & Highlights',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nox Keyboard is a modern Android Input Method Service with Bangla Avro Phonetic, animated RGB & dynamic glass keyboard themes, offline smart predictions, and zero-telemetry local privacy.',
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.65), height: 1.4),
                ),
                const SizedBox(height: 14),
                _detailRow('Package', AppConstants.packageName),
                _detailRow('Engine', 'Flutter + Android Kotlin IME'),
                _detailRow('Bangla Mode', 'Avro Phonetic + Probhat'),
                _detailRow('Privacy', '100% Offline & Local'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.5))),
          Text(v, style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
