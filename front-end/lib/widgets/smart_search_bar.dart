// @author Rayane Rousseau
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:docflow/config/api_config.dart';
import 'package:docflow/config/app_theme.dart';
import 'package:docflow/widgets/tag_chip.dart';

enum _SearchMode { keywords, question }

class SmartSearchBar extends StatefulWidget {
  const SmartSearchBar({super.key});

  @override
  State<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends State<SmartSearchBar> {
  final _controller = TextEditingController();
  _SearchMode _mode = _SearchMode.keywords;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() => _loading = true);

    try {
      final List<dynamic> results;
      if (_mode == _SearchMode.keywords) {
        final res = await http.post(
          Uri.parse(kEndpointKeywords),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'keywords': query.split(' ')}),
        ).timeout(kApiTimeout);
        results = jsonDecode(res.body) as List;
      } else {
        final res = await http.post(
          Uri.parse(kEndpointQuery),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': query}),
        ).timeout(kApiTimeout);
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        results = data['results'] as List? ?? [];
      }

      if (!mounted) return;
      _showResults(results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showResults(List<dynamic> results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        builder: (_, scroll) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${results.length} result${results.length == 1 ? '' : 's'}',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No documents matched.'))
                  : ListView.builder(
                      controller: scroll,
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final d = results[i] as Map<String, dynamic>;
                        final kws = (d['keywords'] as List<dynamic>?)
                                ?.cast<String>() ??
                            [];
                        return ListTile(
                          leading: const Icon(Icons.insert_drive_file_rounded),
                          title: Text(d['filename'] ?? ''),
                          subtitle: Text(
                            _mode == _SearchMode.question && d['score'] != null
                                ? 'Flux score: ${d['score']}'
                                : kws.take(3).join(', '),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TagChip(
                label: 'Keywords',
                selected: _mode == _SearchMode.keywords,
                onTap: () => setState(() => _mode = _SearchMode.keywords),
              ),
              const SizedBox(width: 8),
              TagChip(
                label: 'Ask Flux',
                selected: _mode == _SearchMode.question,
                onTap: () => setState(() => _mode = _SearchMode.question),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: _mode == _SearchMode.keywords
                        ? 'Enter keywords…'
                        : 'Ask Flux a question…',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _loading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _search,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.search_rounded,
                          color: Colors.white),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
