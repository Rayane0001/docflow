// @author Rayane Rousseau
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:docflow/config/api_config.dart';
import 'package:docflow/config/app_theme.dart';
import 'package:docflow/main.dart';
import 'package:docflow/screens/doc_preview_screen.dart';
import 'package:docflow/widgets/app_header.dart';
import 'package:docflow/widgets/doc_card.dart';
import 'package:docflow/widgets/nav_bar.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> with RouteAware {
  List<Map<String, dynamic>> _docs = [];
  bool _loading = true;
  String _filter = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => _load();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await http
          .get(Uri.parse(kEndpointAll))
          .timeout(kApiTimeout);
      if (!mounted) return;
      setState(() {
        _docs = (jsonDecode(res.body) as List)
            .cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter.isEmpty) return _docs;
    final q = _filter.toLowerCase();
    return _docs.where((d) {
      final name = (d['filename'] as String? ?? '').toLowerCase();
      final kws = ((d['keywords'] as List?)?.cast<String>() ?? [])
          .join(' ')
          .toLowerCase();
      final tags = ((d['tags'] as List?)?.cast<String>() ?? [])
          .join(' ')
          .toLowerCase();
      return name.contains(q) || kws.contains(q) || tags.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Vault'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _filter = v),
              decoration: InputDecoration(
                hintText: 'Filter by name, keyword or tag…',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _filtered.isEmpty
                        ? const Center(child: Text('No documents found.'))
                        : ListView.builder(
                            itemCount: _filtered.length,
                            itemBuilder: (ctx, i) => DocCard(
                              doc: _filtered[i],
                              onTap: () => Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DocPreviewScreen(doc: _filtered[i]),
                                ),
                              ),
                            ),
                          ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 1),
    );
  }
}
