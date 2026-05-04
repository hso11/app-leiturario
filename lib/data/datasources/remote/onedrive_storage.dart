import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../auth/microsoft_auth_service.dart';
import 'storage_service.dart';

@lazySingleton
class OneDriveStorage implements StorageService {
  final MicrosoftAuthService _authService;
  OneDriveStorage(this._authService);

  static const _graphBase = 'https://graph.microsoft.com/v1.0';
  static const _filePath = 'me/drive/special/approot:/booktracker_db.json';

  @override
  String get providerId => 'onedrive';

  @override
  Future<bool> isAuthenticated() => _authService.isSignedIn();

  Future<String?> _getAccessToken() => _authService.getAccessToken();

  @override
  Future<void> upload(Map<String, dynamic> payload) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    await http.put(
      Uri.parse('$_graphBase/$_filePath:/content'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );
  }

  @override
  Future<Map<String, dynamic>?> download() async {
    final token = await _getAccessToken();
    if (token == null) return null;

    // Get download URL from metadata
    final metaResponse = await http.get(
      Uri.parse('$_graphBase/$_filePath'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (metaResponse.statusCode != 200) return null;

    final meta = json.decode(metaResponse.body) as Map<String, dynamic>;
    final downloadUrl = meta['@microsoft.graph.downloadUrl'] as String?;
    if (downloadUrl == null) return null;

    final response = await http.get(Uri.parse(downloadUrl));
    if (response.statusCode != 200) return null;
    return json.decode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<void> deleteRemote() async {
    final token = await _getAccessToken();
    if (token == null) return;
    await http.delete(
      Uri.parse('$_graphBase/$_filePath'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
