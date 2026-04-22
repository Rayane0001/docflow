// @author Rayane Rousseau
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:docflow/config/api_config.dart';
import 'package:docflow/screens/doc_preview_screen.dart';
import 'package:docflow/widgets/doc_card.dart';

class RecentDocsPanel extends StatefulWidget {
  const RecentDocsPanel({super.key});

  @override
  State<RecentDocsPanel> createState() => _RecentDocsPanelState();
}

class _RecentDocsPanelState extends State<RecentDocsPanel> {
  late final StreamController<List<dynamic>> _controller;
  late final Stream<List<dynamic>> _stream;

  @override
  void initState() {
    super.initState();
    _controller = StreamController<List<dynamic>>();
    _stream = _controller.stream;
    _load();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await http
          .get(Uri.parse(kEndpointAll))
          .timeout(kApiTimeout);
      final all = jsonDecode(res.body) as List;
      _controller.add(all.take(5).toList());
    } catch (e) {
      _controller.addError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: _stream,
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Could not load documents.'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final docs = snapshot.data!;
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No documents yet. Upload one!'),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (ctx, i) => DocCard(
            doc: docs[i] as Map<String, dynamic>,
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) =>
                    DocPreviewScreen(doc: docs[i] as Map<String, dynamic>),
              ),
            ),
          ),
        );
      },
    );
  }
}
