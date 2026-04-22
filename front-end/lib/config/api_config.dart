// @author Rayane Rousseau
import 'package:flutter/foundation.dart';

String get kBaseUrl {
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  if (apiBaseUrl.isNotEmpty) return apiBaseUrl;
  if (kIsWeb) return 'http://127.0.0.1:5000';

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'http://10.0.2.2:5000',
    _ => 'http://127.0.0.1:5000',
  };
}

const Duration kApiTimeout = Duration(seconds: 12);

String get kEndpointIngest => '$kBaseUrl/api/docs/ingest';
String get kEndpointAll => '$kBaseUrl/api/docs/all';
String get kEndpointQuery => '$kBaseUrl/api/search/query';
String get kEndpointKeywords => '$kBaseUrl/api/search/keywords';
String get kEndpointHistory => '$kBaseUrl/api/docs/history';
String get kEndpointVersions => '$kBaseUrl/api/docs/versions';
String get kEndpointStats => '$kBaseUrl/api/stats';
String get kEndpointTags => '$kBaseUrl/api/docs/tags';
String get kEndpointAssistant => '$kBaseUrl/api/assistant/compare';
