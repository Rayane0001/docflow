// @author Rayane Rousseau
import 'package:flutter/material.dart';
import 'package:docflow/config/app_theme.dart';
import 'package:docflow/utils/date_utils.dart';

class DocCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  final VoidCallback onTap;

  const DocCard({super.key, required this.doc, required this.onTap});

  IconData _iconForFilename(String filename) {
    final ext = filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    if (['png', 'jpg', 'jpeg'].contains(ext)) return Icons.image_rounded;
    if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
    if (ext == 'mp3') return Icons.audio_file_rounded;
    return Icons.insert_drive_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final filename = doc['filename'] as String? ?? '';
    final uploader = doc['uploader'] as String? ?? '';
    final uploadedAt = doc['uploaded_at'] as String?;
    final keywords = (doc['keywords'] as List<dynamic>?)?.cast<String>() ?? [];
    final tags = (doc['tags'] as List<dynamic>?)?.cast<String>() ?? [];
    final DateTime? dt = uploadedAt != null ? DateTime.tryParse(uploadedAt) : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: kPrimary.withOpacity(0.1),
          child: Icon(_iconForFilename(filename), color: kPrimary),
        ),
        title: Text(
          filename,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'by $uploader${dt != null ? ' · ${timeAgoLabel(dt)}' : ''}',
              style: const TextStyle(fontSize: 12),
            ),
            if (tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: tags
                    .map((t) => Chip(
                          label: Text(t, style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            if (keywords.isNotEmpty)
              Text(
                keywords.take(3).join(' · '),
                style: TextStyle(fontSize: 11, color: kAccent),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
