// @author Rayane Rousseau
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:docflow/config/api_config.dart';
import 'package:docflow/config/app_theme.dart';
import 'package:docflow/widgets/tag_chip.dart';

class DocPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> doc;

  const DocPreviewScreen({super.key, required this.doc});

  @override
  State<DocPreviewScreen> createState() => _DocPreviewScreenState();
}

class _DocPreviewScreenState extends State<DocPreviewScreen> {
  final _tagController = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List<String>.from(
        (widget.doc['tags'] as List<dynamic>? ?? []).cast<String>());
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _persistTags(List<String> updated) async {
    await http.post(
      Uri.parse(kEndpointTags),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'doc_id': widget.doc['id'], 'tags': updated}),
    ).timeout(kApiTimeout);
  }

  Future<void> _addTag(String tag) async {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || _tags.contains(trimmed)) return;
    final updated = [..._tags, trimmed];
    await _persistTags(updated);
    if (!mounted) return;
    setState(() => _tags = updated);
    _tagController.clear();
  }

  Future<void> _removeTag(String tag) async {
    final updated = _tags.where((t) => t != tag).toList();
    await _persistTags(updated);
    if (!mounted) return;
    setState(() => _tags = updated);
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final keywords =
        (doc['keywords'] as List<dynamic>?)?.cast<String>() ?? [];
    final versions = (doc['versions'] as List<dynamic>?) ?? [];
    final content = doc['extracted_text'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          doc['filename'] ?? '',
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Uploader', doc['uploader'] ?? ''),
                    _infoRow('Uploaded', doc['uploaded_at'] ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle('Auto Keywords'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: keywords.map((k) => TagChip(label: k)).toList(),
            ),
            const SizedBox(height: 16),
            _sectionTitle('Manual Tags'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags
                  .map((t) => TagChip(
                        label: '× $t',
                        selected: true,
                        onTap: () => _removeTag(t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    onSubmitted: _addTag,
                    decoration: InputDecoration(
                      hintText: 'Add a tag…',
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addTag(_tagController.text),
                  child: const Text('Add'),
                ),
              ],
            ),
            if (content.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Extracted Content'),
              Text(content, style: const TextStyle(fontSize: 13)),
            ],
            const SizedBox(height: 16),
            _sectionTitle('Version History'),
            versions.isEmpty
                ? const Text('No previous versions.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: versions.length,
                    itemBuilder: (_, i) {
                      final v = versions[i] as Map<String, dynamic>;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: kAccent.withOpacity(0.15),
                          child: Text(
                            'v${v['version_number']}',
                            style: TextStyle(
                                color: kAccent, fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(v['filename'] ?? ''),
                        subtitle: Text(v['uploaded_at'] ?? ''),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
