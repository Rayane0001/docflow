// @author Rayane Rousseau
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:docflow/config/api_config.dart';
import 'package:docflow/config/app_theme.dart';
import 'package:docflow/widgets/app_header.dart';
import 'package:docflow/widgets/nav_bar.dart';
import 'package:docflow/widgets/stats_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http
          .get(Uri.parse(kEndpointStats))
          .timeout(kApiTimeout);
      if (!mounted) return;
      setState(() {
        _stats = jsonDecode(res.body) as Map<String, dynamic>;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Could not load stats. Is the server running?';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Dashboard'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off_rounded,
                          size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      StatsCard(
                        label: 'Total Documents',
                        value: '${_stats!['total_documents']}',
                        icon: Icons.folder_rounded,
                        color: kPrimary,
                      ),
                      const SizedBox(height: 10),
                      StatsCard(
                        label: 'Total Versions',
                        value: '${_stats!['total_versions']}',
                        icon: Icons.history_rounded,
                        color: kAccent,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Top Keywords',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Most frequent across all documents',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ..._buildKeywordBars(),
                    ],
                  ),
                ),
      bottomNavigationBar: const NavBar(currentIndex: 2),
    );
  }

  List<Widget> _buildKeywordBars() {
    final topKws =
        (_stats!['top_keywords'] as List<dynamic>?) ?? [];
    if (topKws.isEmpty) {
      return [
        const Text('No keywords yet — upload some documents!',
            style: TextStyle(color: Colors.grey))
      ];
    }
    final maxCount =
        (topKws.first as Map<String, dynamic>)['count'] as int;

    return topKws.map((entry) {
      final kw = (entry as Map<String, dynamic>)['keyword'] as String;
      final count = entry['count'] as int;
      final ratio = maxCount > 0 ? count / maxCount : 0.0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(kw,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '$count',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: kAccent.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(kAccent, kPrimary, 1 - ratio)!,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
