// @author Rayane Rousseau
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:docflow/config/api_config.dart';
import 'package:docflow/widgets/icon_action.dart';

class ToolbarActions extends StatelessWidget {
  const ToolbarActions({super.key});

  Future<void> _uploadDocument(BuildContext context) async {
    final typeGroup = XTypeGroup(
      label: 'Documents',
      extensions: ['pdf', 'png', 'jpg', 'jpeg', 'mp3'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Uploading…')));

    final request =
        http.MultipartRequest('POST', Uri.parse(kEndpointIngest));
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: p.basename(file.path),
    ));
    request.fields['uploader'] = 'Rayane';

    final response = await request.send().timeout(kApiTimeout);
    if (!context.mounted) return;

    String msg;
    if (response.statusCode == 200) {
      msg = 'Document ingested!';
    } else {
      final body = await response.stream.bytesToString();
      String? reason;
      try {
        reason = (jsonDecode(body) as Map<String, dynamic>)['error'] as String?;
      } catch (_) {
        reason = null;
      }
      msg = reason == null || reason.isEmpty
          ? 'Upload failed (${response.statusCode})'
          : 'Upload failed: $reason';
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconAction(
            icon: Icons.upload_file_rounded,
            label: 'Add Doc',
            onTap: () => _uploadDocument(context),
          ),
          IconAction(
            icon: Icons.bar_chart_rounded,
            label: 'Dashboard',
            onTap: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          IconAction(
            icon: Icons.folder_rounded,
            label: 'Vault',
            onTap: () => Navigator.pushNamed(context, '/vault'),
          ),
        ],
      ),
    );
  }
}
